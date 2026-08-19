# Internals

Canonical shapes. Gate on `go.mod` and [SKILL.md](SKILL.md). Language:
`go-idioms`. Encore APIs/errors: `encore-go`. Aggregates: `go-ddd`.

## Handler (non-Encore)

```go
func (s *Server) handleGetItem(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	item, err := s.items.Get(r.Context(), id)
	if err != nil {
		writeErr(w, err)
		return
	}
	writeJSON(w, http.StatusOK, item)
}
```

- `Server` holds deps (`*slog.Logger`, store, clock). Constructed in `main`.
- `writeErr` maps `ErrNotFound` → 404, `ErrConflict` → 409, else 500 and
  log the 500. Do not stringify `err` into the client body for internals.
- Decode with a size-limited `json.Decoder`. Do not `json.Unmarshal` a
  unbounded `io.ReadAll`.
- Authn identity is an argument or a small type, not a magic `context`
  value the domain has to fish out.

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

SQL type is concrete:

```go
type ItemSQL struct {
	db *sql.DB
}

func (s ItemSQL) Get(ctx context.Context, id string) (Item, error) {
	var it Item
	err := s.db.QueryRowContext(ctx, `SELECT id, name FROM items WHERE id = $1`, id).
		Scan(&it.ID, &it.Name)
	if errors.Is(err, sql.ErrNoRows) {
		return Item{}, ErrNotFound
	}
	if err != nil {
		return Item{}, fmt.Errorf("get item %s: %w", id, err)
	}
	return it, nil
}
```

- Two or three methods. Add a method when a caller needs it, not "for the
  whole database".
- Fake: an in-memory map in `item_test.go`. Same interface.
- Transactions: a method that takes `func(tx ItemStore) error`, or a
  `Begin`/`Commit` on a small unit-of-work type. Do not pass `*sql.Tx`
  into domain functions.
- pgx: `pgx.ErrNoRows` maps the same way. Encore: `sqldb.ErrNoRows`.

## Config and wiring (non-Encore)

```go
// cmd/itemd/main.go
func main() {
	cfg := configFromFlags()
	log := slog.New(slog.NewJSONHandler(os.Stderr, nil))
	slog.SetDefault(log)

	db, err := sql.Open("pgx", cfg.DSN)
	if err != nil {
		log.Error("open db", "err", err)
		os.Exit(1)
	}
	defer db.Close()

	srv := &Server{
		items: ItemSQL{db: db},
		log:   log,
	}
	if err := srv.run(context.Background(), cfg.Addr); err != nil {
		log.Error("run", "err", err)
		os.Exit(1)
	}
}
```

`configFromFlags` fills a typed struct (`Addr`, `DSN`, timeouts). No
global `Cfg`. Encore: `encore.dev/config` and `initService` instead of
this `main`.

## Shutdown (non-Encore)

```go
func (s *Server) run(ctx context.Context, addr string) error {
	ctx, stop := signal.NotifyContext(ctx, os.Interrupt)
	defer stop()

	httpSrv := &http.Server{
		Addr:              addr,
		Handler:           s.routes(),
		ReadHeaderTimeout: 5 * time.Second,
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
```

Honor `ctx` in store methods (`QueryRowContext`). Drain in-flight work in
`Shutdown`; do not `os.Exit` from a handler.

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
