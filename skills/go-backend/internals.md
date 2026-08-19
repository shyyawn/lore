# Internals

Canonical shapes. Gate on `go.mod` and [SKILL.md](SKILL.md). Language:
`go-idioms`. Encore APIs/errors: `encore-go`. Aggregates: `go-ddd`.

## Handler (non-Encore)

```go
func (s *Server) handleGetItem(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	item, err := s.items.Get(r.Context(), id)
	if err != nil {
		s.writeErr(r.Context(), w, err)
		return
	}
	writeJSON(w, http.StatusOK, item)
}
```

- `Server` holds deps (`*slog.Logger`, store). Constructed in `main`.
- `writeErr` maps `ErrNotFound` → 404, `ErrConflict` → 409, else 500 and
  `slog.ErrorContext` the 500. Do not stringify `err` into the client body.
- Decode with a size-limited `json.Decoder`. Do not `json.Unmarshal` an
  unbounded `io.ReadAll`. JSON tags: `omitzero` on `time.Time` (1.24+).
- Authn identity is an argument or a small type, not a magic `context`
  value the domain has to fish out.
- Request logs: `slog.InfoContext(r.Context(), ...)`. Plain `Info` drops
  trace IDs once `otelhttp` is in the stack.

## API (Encore)

```go
//encore:api method=GET path=/items/:id
func (s *Service) GetItem(ctx context.Context, p *GetItemParams) (*Item, error) {
	return s.items.Get(ctx, p.ID)
}
```

Map domain sentinels to `encore.dev/beta/errs` **at this boundary**. Do
not import Encore errors from a persistence file. Tiny no-dep services
stay as package-level API funcs (`encore-go-app-structure`).

## Persistence

Declared where it is **used**:

```go
type ItemStore interface {
	Get(ctx context.Context, id string) (Item, error)
	Save(ctx context.Context, item Item) error
}

type Item struct {
	ID   string
	Name string
}

var ErrNotFound = errors.New("item not found")
```

SQL type is concrete. Prefer `pgxpool` for Postgres; `database/sql` is
fine when the module already uses it. `lib/pq` is maintenance-mode — do
not add it.

```go
type ItemSQL struct {
	db *pgxpool.Pool
}

func (s ItemSQL) Get(ctx context.Context, id string) (Item, error) {
	var it Item
	err := s.db.QueryRow(ctx, `SELECT id, name FROM items WHERE id = $1`, id).
		Scan(&it.ID, &it.Name)
	if errors.Is(err, pgx.ErrNoRows) {
		return Item{}, ErrNotFound
	}
	if err != nil {
		return Item{}, fmt.Errorf("get item %s: %w", id, err)
	}
	return it, nil
}
```

- Two or three methods. Add a method when a caller needs it.
- Fake: an in-memory map in `item_test.go`. Same interface.
- Transactions: a method that takes `func(tx ItemStore) error`, or
  `Begin`/`Commit` on a small unit-of-work type. Do not pass `pgx.Tx`
  into domain functions.
- sqlc: `ItemSQL` holds `*db.Queries` (and a pool for tx). Map
  `db.GetItemRow` → `Item` here. `sql.ErrNoRows` / `pgx.ErrNoRows`
  become `ErrNotFound` before they leave the store. Encore: `sqldb.ErrNoRows`.
- CRUD with no rules: the API may call sqlc directly. Introduce
  `ItemStore` when a test or a rule needs it — not a folder named
  `repository`.

## Config and wiring (non-Encore)

```go
func main() {
	ctx := context.Background()
	cfg := configFromFlags()
	log := slog.New(slog.NewJSONHandler(os.Stderr, nil))
	slog.SetDefault(log)

	pool, err := pgxpool.New(ctx, cfg.DSN)
	if err != nil {
		log.Error("open db", "err", err)
		os.Exit(1)
	}
	defer pool.Close()
	if err := pool.Ping(ctx); err != nil {
		log.Error("ping db", "err", err)
		os.Exit(1)
	}

	srv := &Server{items: ItemSQL{db: pool}, pool: pool, log: log}
	if err := srv.run(ctx, cfg); err != nil {
		log.Error("run", "err", err)
		os.Exit(1)
	}
}
```

`configFromFlags` fills a typed struct (`Addr`, `DSN`, timeouts). No
global `Cfg`. Encore: `encore.dev/config` and `initService` instead of
this `main`. `*sql.DB`: `PingContext`, then `SetMaxOpenConns` /
`SetMaxIdleConns` / `SetConnMaxLifetime`. `pgxpool` takes `MaxConns` in
the parse config.

## HTTP server and shutdown (non-Encore)

```go
func (s *Server) run(ctx context.Context, cfg Config) error {
	ctx, stop := signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM)
	defer stop()

	mux := http.NewServeMux()
	mux.HandleFunc("GET /livez", s.handleLive)
	mux.HandleFunc("GET /readyz", s.handleReady)
	s.routes(mux)

	httpSrv := &http.Server{
		Addr:              cfg.Addr,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	g, ctx := errgroup.WithContext(ctx)
	g.Go(func() error {
		if err := httpSrv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			return err
		}
		return nil
	})
	g.Go(func() error {
		<-ctx.Done()
		shutCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		return httpSrv.Shutdown(shutCtx)
	})
	return g.Wait()
}

func (s *Server) handleLive(w http.ResponseWriter, _ *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func (s *Server) handleReady(w http.ResponseWriter, r *http.Request) {
	if err := s.pool.Ping(r.Context()); err != nil {
		http.Error(w, "not ready", http.StatusServiceUnavailable)
		return
	}
	w.WriteHeader(http.StatusOK)
}
```

- `SIGINT` (local) and `SIGTERM` (Kubernetes). Do not derive `Shutdown`'s
  timeout from the cancelled signal ctx.
- `WriteTimeout` includes handler time. Streaming / SSE: raise it or use
  `http.NewResponseController`.
- If the module already imports `otelhttp`, wrap `mux` and filter probes
  out of spans. Do not add OTel otherwise. Encore: skip this whole file.

## Error mapping

| Domain | HTTP | Encore |
| --- | --- | --- |
| `ErrNotFound` | 404 | `errs.NotFound` |
| `ErrConflict` / duplicate | 409 | `errs.AlreadyExists` |
| validation | 400 | `errs.InvalidArgument` |
| authz deny | 403 | `errs.PermissionDenied` |
| anything else | 500, log it | `errs.Internal` (wrap, do not leak) |

Wrap once at the boundary that knows the name: `fmt.Errorf("get item %s: %w", id, err)`.
Handlers map with `errors.Is` / `AsType`, never `err.Error()`.
