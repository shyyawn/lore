# Infrastructure primitives

All resources are package-level vars. Encore statically analyses them and
provisions matching infra. Config fields that Encore must see (names, migration
paths, delivery guarantees) are **compile-time constants**, not runtime values.

## SQL databases

```go
var db = sqldb.NewDatabase("user", sqldb.DatabaseConfig{
	Migrations: "./migrations",
})
```

Migrations live in the service: `migrations/1_create_users.up.sql`, then
`2_add_index.up.sql`. Sequential integers, `.up.sql` suffix. Applied on start.

```go
err := db.QueryRow(ctx, `
	SELECT id, email, name FROM users WHERE id = $1
`, id).Scan(&u.ID, &u.Email, &u.Name)
if errors.Is(err, sqldb.ErrNoRows) {
	return nil, &errs.Error{Code: errs.NotFound, Message: "user not found"}
}

rows, err := db.Query(ctx, `SELECT id, email, name FROM users WHERE active`)
if err != nil {
	return nil, err
}
defer rows.Close()
for rows.Next() { /* Scan */ }
return users, rows.Err()

_, err = db.Exec(ctx, `INSERT INTO users (id, email) VALUES ($1, $2)`, id, email)
```

Always `$n` placeholders. Scan by **column position**. Never `interface{}`
destinations. `defer rows.Close()`. Transactions:

```go
tx, err := db.Begin(ctx)
if err != nil {
	return err
}
defer tx.Rollback()
// tx.Exec / Query ...
return tx.Commit()
```

Share another service's DB only with `var other = sqldb.Named("todo")`. Prefer
an API. `db.Stdlib()` (`*sql.DB`) when sqlc/gorm is already in the repo — do
not add an ORM to a new service that only needs a handful of queries.

External (non-Encore) Postgres: dedicated package, `pgxpool`, password in
`secrets`. Not `sqldb.NewDatabase`.

Local Postgres is **18** as of Encore v1.57. pgvector is an extension, not a
separate primitive:

```sql
-- migrations/2_pgvector.up.sql
CREATE EXTENSION IF NOT EXISTS vector;
CREATE TABLE docs (
    id UUID PRIMARY KEY,
    embedding vector(1536) NOT NULL
);
CREATE INDEX docs_embedding_hnsw ON docs USING hnsw (embedding vector_cosine_ops);
```

Query with `embedding <=> $1::vector`. Keep embeddings in the same database as
the rows they describe. Do not add a dedicated vector DB for typical scale.

CLI: `encore db shell <name>`, `encore db conn-uri <name>`, `encore db reset`.

## Pub/Sub

```go
type OrderCreated struct {
	OrderID string `json:"order_id"`
	UserID  string `json:"user_id"`
}

var OrderCreatedTopic = pubsub.NewTopic[*OrderCreated]("order-created", pubsub.TopicConfig{
	DeliveryGuarantee: pubsub.AtLeastOnce,
})

_, err := OrderCreatedTopic.Publish(ctx, &OrderCreated{OrderID: id})

var _ = pubsub.NewSubscription(OrderCreatedTopic, "email-receipt",
	pubsub.SubscriptionConfig[*OrderCreated]{
		Handler: sendReceipt, // or pubsub.MethodHandler((*Service).SendReceipt)
	},
)
```

- `AtLeastOnce` (default): handlers **must be idempotent** (check a unique
  event id / row status before charging, emailing, etc.).
- `ExactlyOnce`: stronger, lower throughput (AWS ~300 msg/s, GCP ~3000+).
- Ordering: `OrderingAttribute` + `pubsub-attr` tag on the field.
- `Publish` returns when queued, not when consumed.
- Inject with `pubsub.TopicRef[pubsub.Publisher[T]](Topic)`.
- Tests: `et.Topic(Topic).PublishedMessages()`.
- Delivery is not order-preserving across the topic. Do not sort "latest" by
  subscriber insert time; sort by a monotonic id from the payload.

Transactional outbox (DB + publish atomically): `outbox.Bind` + `outbox.NewRelay`
with the documented `outbox` table. Use when a commit and a publish must not
diverge.

## Cron

```go
var _ = cron.NewJob("cleanup-sessions", cron.JobConfig{
	Title:    "Clean up expired sessions",
	Schedule: "0 2 * * *", // 02:00 UTC
	Endpoint: CleanupExpiredSessions,
})

//encore:api private
func CleanupExpiredSessions(ctx context.Context) error { return nil }
```

`Every: 2 * cron.Hour` (must divide 24h) or `Schedule` (5-field cron, UTC).
Endpoint: no request params; `func(ctx) error` or `func(ctx) (*T, error)`;
**private**; idempotent. Cron does **not** fire in `encore run` or preview
envs — test by calling the function.

## Secrets

```go
var secrets struct {
	StripeKey string
	JWTSecret string
}
```

Field names are app-global. Set with `encore secret set --type production|development|preview|local Name`.
Local file `.secrets.local.cue` (gitignore): `StripeKey: "sk_test_..."`.
Never commit values. Never `os.Getenv` for the same key.

Encore Cloud can bind an **external vault** (v1.57.9) as the secret backend.
Application code still reads `secrets.StripeKey`. Do not add HashiCorp Vault /
SSM / Secret Manager SDKs for secrets Encore already injects.

## Cache (Redis)

```go
var cluster = cache.NewCluster("app", cache.ClusterConfig{EvictionPolicy: cache.AllKeysLRU})

var Hits = cache.NewIntKeyspace[auth.UID](cluster, cache.KeyspaceConfig{
	KeyPattern:     "hits/:key",
	DefaultExpiry:  cache.ExpireIn(10 * time.Second),
})
```

Typed keyspaces (int, string, float, struct, set, list). Structured keys match
`KeyPattern` fields. Use for hot reads and rate limits, not as a source of
truth. Batch reads (v1.52): `Hits.MultiGet(ctx, uid1, uid2)` — per-key `Err`
is `cache.Miss` when absent, not a fatal error.

## Object storage

```go
var Avatars = objects.NewBucket("avatars", objects.BucketConfig{Versioned: false})
var Public = objects.NewBucket("cdn", objects.BucketConfig{Public: true})

ref := objects.BucketRef[interface {
	objects.Downloader
	objects.Uploader
}](Avatars)
```

Upload / Download / List / Remove / Attrs / Exists. Narrow refs for library
code (`Downloader`, `Uploader`, `Lister`, `Remover`, `Attrser`,
`SignedDownloader`, `SignedUploader`). Public buckets get a CDN in cloud;
prefer `PublicURL()` over signed URLs when the object is public.

Signed URLs (v1.46) let clients upload/download **directly** so large payloads
skip the API. Default TTL 1h, max 7 days. Anyone with the URL can use that
object name — treat them as capabilities.

```go
up, err := Avatars.SignedUploadURL(ctx, "u/"+id+".jpg", objects.WithTTL(2*time.Hour))
down, err := Avatars.SignedDownloadURL(ctx, "u/"+id+".jpg", objects.WithTTL(time.Hour))
// return up.URL / down.URL to the client
```

Local/cloud Object Explorer (v1.58, dashboard + MCP `get_objects`) is for
humans/agents browsing buckets — not a substitute for these APIs.

## Config (CUE)

```go
type Cfg struct {
	ReadOnly config.Bool
	Name     config.String
}

var cfg = config.Load[*Cfg]()
```

CUE files next to the package. Types: `config.String`, `Bool`, `Int`,
`Float64`, `Time`, `UUID`, `Value[T]`, `Values[T]`. Constraints via
`` `cue:">100"` ``. Tests: `et.SetCfg(cfg.ReadOnly, true)`. Meta:
`Environment.Type` (`production` / `development` / `ephemeral` / `test`),
`Environment.Cloud`.

Config is for non-secret, env-varying knobs. Secrets stay in `secrets`.

## Metrics

```go
var Processed = metrics.NewCounter[uint64]("orders_processed", metrics.CounterConfig{})
Processed.Add(1)

type Labels struct{ Region string }
var Latency = metrics.NewGaugeGroup[Labels, float64]("queue_lag", metrics.GaugeConfig{})
Latency.With(Labels{Region: "us"}).Set(1.2)
```

Label fields: `string`, `int`, or `bool` only. Avoid high-cardinality labels
(user ids).

## Testing infrastructure

```bash
encore test ./...
encore test -v ./user/...
```

Call APIs as functions. Infra is real (isolated DBs, topics).

```go
et.MockEndpoint(products.GetPrice, func(ctx context.Context, p *products.PriceParams) (*products.PriceResponse, error) {
	return &products.PriceResponse{Price: 100}, nil
})
et.MockService("products", &fakeProducts{})
testDB := et.NewTestDatabase(t, db)
et.EnableServiceInstanceIsolation() // when tests mutate service struct state
```

Use `t.Context()` (Go 1.24+) when the module allows it. Do not `time.Sleep` for
Pub/Sub; assert `et.Topic(T).PublishedMessages()` or use the local MCP
`wait_for_subscription_message` when it is wired.

## CLI (reach for these)

| Task | Command |
| --- | --- |
| Run locally | `encore run` (dashboard `:9400`, API `:4000`) |
| Compile + boot | `encore check` |
| Tests | `encore test ./...` (traces at `:9400`) |
| Client SDK | `encore gen client --lang=go\|typescript\|openapi` |
| Self-host image | `encore build docker IMAGE:TAG` (`--services`, `--config`) |
| Secrets | `encore secret set --type local Name` |
| DB | `encore db shell <name>` |
| Reset DBs | `encore db reset --all` |
| LLM rules in-repo | `encore llm-rules init` |

If `.mcp.json` registers `encore-local`, use it for **runtime** (call endpoint,
query DB, traces). For static structure (services, schemas, topics), read the
source — faster and accurate.
