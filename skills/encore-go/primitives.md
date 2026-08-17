# APIs, auth, errors, middleware

## API signatures

Always: `ctx context.Context` first, `error` last.

```go
func Foo(ctx context.Context, p *Params) (*Response, error) // full
func Foo(ctx context.Context) (*Response, error)            // response only
func Foo(ctx context.Context, p *Params) error              // request only
func Foo(ctx context.Context) error                         // minimal
```

Response types are pointers. Path params map to struct fields by name
(`path=/users/:id` → `Params.ID`). Single path params may be a function
argument; prefer a params struct once there is more than one input.

### Annotation options

```
//encore:api public method=GET path=/users/:id
//encore:api private method=POST path=/internal/process
//encore:api auth method=GET path=/profile
//encore:api public sensitive method=POST path=/auth/login
//encore:api public method=GET path=/users/:id tag:cache
```

`method` defaults exist but **always set method + path** on new endpoints.
`sensitive` redacts the whole payload in traces. Field-level:
`` Password string `json:"password" encore:"sensitive"` ``.

Custom HTTP status: `` Status int `encore:"httpstatus"` `` on the response
(e.g. `201`). Prefer this over raw endpoints.

### Where data comes from

| Location | Tag | Types |
| --- | --- | --- |
| path | field name matches `:param` | bool, numeric, string, time.Time, UUID, json.RawMessage |
| query | `query:"limit"` (default for GET/HEAD/DELETE) | path types + slices |
| header | `header:"X-Request-Id"` | path types |
| cookie | `cookie:"session"` (`*http.Cookie`) | cookies |
| body | `json:"email"` (default for other methods) | any JSON-able type |

Query names are snake_case unless tagged. Wildcards: `*name` at end of path.
Fallback route: `path=/!fallback` (raw, last-resort).

Optional fields: prefer `option.Option[T]` (`encore.dev/types/option`) over a
pointer when absence vs zero-value matters (v1.52). Allowed in header, query,
and body — **not** path.

```go
import "encore.dev/types/option"

type PatchUserParams struct {
	ID    string                  // path
	Name  option.Option[string]   `json:"name"`
	Email option.Option[string]   `json:"email"`
}

name, ok := p.Name.Get()
if ok { /* was sent */ }
```

`option.Some(v)`, `option.None[T]()`, `GetOrElse`, `IsZero` (works with
`omitzero`). Pointers remain valid; do not mix both styles on one field.

Go has no enums. String `const` values plus `Validate()` — not iota in JSON
APIs. JSON `null` is a missing pointer / `None`, not a sentinel string.

## Validation

After decode, before the handler, Encore calls `Validate() error` on the
params struct if present.

```go
func (p *CreateParams) Validate() error {
	if p.Email == "" {
		return &errs.Error{Code: errs.InvalidArgument, Message: "email required"}
	}
	return nil
}
```

Non-`*errs.Error` values become `InvalidArgument` (HTTP 400).

## Errors

Package: `encore.dev/beta/errs`.

```go
return nil, &errs.Error{Code: errs.NotFound, Message: "user not found"}

eb := errs.B().Meta("user_id", id)
return nil, eb.Code(errs.NotFound).Msg("user not found").Err()

return nil, errs.WrapCode(err, errs.Unavailable, "billing down")
```

| Code | HTTP |
| --- | --- |
| `InvalidArgument` / `FailedPrecondition` / `OutOfRange` | 400 |
| `Unauthenticated` | 401 |
| `PermissionDenied` | 403 |
| `NotFound` | 404 |
| `AlreadyExists` / `Aborted` | 409 |
| `ResourceExhausted` | 429 |
| `Canceled` | 499 |
| `Internal` / `Unknown` / `DataLoss` | 500 |
| `Unimplemented` | 501 |
| `Unavailable` | 503 |
| `DeadlineExceeded` | 504 |

`Message` and `Details` go to clients. `Meta` is internal-only (traces). Map
`sqldb.ErrNoRows` → `errs.NotFound`. Auth failures → `errs.Unauthenticated`,
never `PermissionDenied` (that is "known user, not allowed").

Inspect with `errs.Code(err)`, `errors.As` to `*errs.Error`.

## Auth

One `//encore:authhandler` per app.

```go
type AuthParams struct {
	Authorization string       `header:"Authorization"`
	Session       *http.Cookie `cookie:"session"`
}

type AuthData struct {
	Email string
	Role  string
}

//encore:authhandler
func Authenticate(ctx context.Context, p *AuthParams) (auth.UID, *AuthData, error) {
	token := strings.TrimPrefix(p.Authorization, "Bearer ")
	claims, err := verify(token)
	if err != nil {
		return "", nil, &errs.Error{Code: errs.Unauthenticated, Message: "invalid token"}
	}
	return auth.UID(claims.Sub), &AuthData{Email: claims.Email, Role: claims.Role}, nil
}
```

Minimal form: `(auth.UID, error)` with a `token string` argument. Structured
params are preferred when cookies/query are involved. Auth handler inputs are
always treated as sensitive.

In handlers:

```go
uid, ok := auth.UserID()
data := auth.Data().(*authpkg.AuthData)
```

Tests: `auth.WithContext(ctx, auth.UID("u1"), &AuthData{...})`. Keep the
handler fast — it runs on every `auth` request.

## Middleware

```go
//encore:middleware global target=all
func Validate(req middleware.Request, next middleware.Next) middleware.Response {
	if v, ok := req.Data().Payload.(interface{ Validate() error }); ok {
		if err := v.Validate(); err != nil {
			return middleware.Response{Err: errs.WrapCode(err, errs.InvalidArgument, "validation failed")}
		}
	}
	return next(req)
}

//encore:middleware target=tag:cache
func (s *Service) Cache(req middleware.Request, next middleware.Next) middleware.Response { /* ... */ }
```

Global runs before service-specific. Order is lexicographic by filename. Prefer
`Validate()` on params over a global validation middleware unless many types
share one interface. Do not import gin/echo middleware.

## Raw endpoints (webhooks / WebSockets)

```go
//encore:api public raw method=POST path=/webhooks/stripe
func StripeWebhook(w http.ResponseWriter, req *http.Request) {
	body, err := io.ReadAll(req.Body)
	if err != nil {
		http.Error(w, "read body", http.StatusBadRequest)
		return
	}
	sig := req.Header.Get("Stripe-Signature")
	event, err := webhook.ConstructEvent(body, sig, secrets.StripeWebhookSecret)
	if err != nil {
		http.Error(w, "bad signature", http.StatusBadRequest)
		return
	}
	_, _ = StripeEvents.Publish(req.Context(), toEvent(event))
	w.WriteHeader(http.StatusOK)
}
```

Path params on raw endpoints: `encore.CurrentRequest().PathParams.Get("id")`.
Verify signatures against the **raw** body. Respond 2xx quickly; do work on
Pub/Sub.

## Metadata

```go
meta := encore.Meta()          // AppID, APIBaseURL, Environment, Build, Deploy
req := encore.CurrentRequest() // Service, Endpoint, Path, StartTime
```

Branch on `meta.Environment.Cloud` (`encore.CloudAWS`, `CloudGCP`, `CloudLocal`)
only when the sink is cloud-specific (Redshift vs BigQuery). Prefer Encore
primitives so the same code runs everywhere.
