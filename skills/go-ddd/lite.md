# DDD Lite

Canonical shapes. Gate on the earn checklist in [SKILL.md](SKILL.md).
Persistence wiring: `go-backend` `internals.md`. Encore API boundary:
`encore-go`.

## Aggregate

Methods are the API. Invalid combinations cannot be constructed. Name
methods in the ubiquitous language (`Cancel`, `Confirm`), not CRUD
(`SetStatus`). Errors name the rule (`ErrAlreadyCanceled`).

```go
type Training struct {
	id       TrainingID
	userID   UserID
	when     time.Time
	canceled bool
}

func NewTraining(id TrainingID, userID UserID, when time.Time) (Training, error) {
	if !when.After(time.Now()) {
		return Training{}, ErrNotInFuture
	}
	return Training{id: id, userID: userID, when: when}, nil
}

func (t *Training) Cancel(reason string) (Event, error) {
	if t.canceled {
		return nil, ErrAlreadyCanceled
	}
	t.canceled = true
	return TrainingCanceled{ID: t.id, Reason: reason}, nil
}
```

- Unexport fields that have rules. Map to a DTO at the API / sqlc boundary.
- `NewX` / methods return sentinels. Handlers map them (`go-backend`).
- Table-test the methods (`go-unit-tests`). Do not test SQL in the same
  test as "cannot cancel twice".
- Time: `testing/synctest` (1.25+) in tests. Do not add a clock interface
  only to freeze `time.Now`.

No aggregate: a row you only Get/Save with no method that can fail. That
corner stays `go-backend` even if this package has an aggregate next to it.

## Value object

```go
type Money struct {
	cents    int64
	currency string
}

func NewMoney(cents int64, currency string) (Money, error) {
	if cents < 0 || currency == "" {
		return Money{}, ErrInvalidMoney
	}
	return Money{cents: cents, currency: currency}, nil
}

func (m Money) Add(o Money) (Money, error) {
	if m.currency != o.currency {
		return Money{}, ErrCurrencyMismatch
	}
	return Money{cents: m.cents + o.cents, currency: m.currency}, nil
}
```

Equal by value. No `ID`. Never `float64` for money (`go-100-mistakes-avoid`
#18). IDs: a named type (`type TrainingID string`) once two ID kinds exist.

## Repository

Collection of aggregates. Same consumer-side rule as `go-backend`:

```go
type TrainingStore interface {
	Get(ctx context.Context, id TrainingID) (Training, error)
	Save(ctx context.Context, t Training, events ...Event) error
}
```

- `Save` persists the aggregate **and** outbox rows for `events` in **one
  transaction**. Then a relay publishes. That is the reliability default
  (no dual-write).
- sqlc: `Save` maps `Training` → generated params, `Get` maps the row →
  `Training` (unexported fields via a constructor in this package). Do
  not return `db.Training` as the aggregate.
- Optimistic concurrency: a version column, `ErrConflict` on stale write.
  Add it when two writers exist, not on day one.
- No `List` on this interface unless a command needs it. Screens of data
  are a different function (and, later, a different model).

## Domain events

Values **returned** from the method that caused them. `nil` means nothing
emitted. The aggregate does not import a bus.

```go
type Event interface{ event() }

type TrainingCanceled struct {
	ID     TrainingID
	Reason string
}

func (TrainingCanceled) event() {}
```

Do not plug a publisher into `NewTraining`. Tests should not need a fake
broker to cancel a training.

Consumers are **idempotent**. Outbox delivery is at-least-once. Dedup on
event ID or make the apply an upsert.

Encore: if loss of a publish is unacceptable, write the outbox row in the
same `sqldb` transaction as the aggregate, then publish from a worker.
`topic.Publish` *after* `Save` is dual-write — fine for logs, not for
another service that must not miss the event. Temporal: the workflow is
the long-running reaction. Same-process listener: a function call.

Do not import the subscriber's package from the aggregate.

## Application (command)

The only extra layer. It is the Encore API or the `go-backend` handler.

```go
func (s *Service) CancelTraining(ctx context.Context, p *CancelParams) error {
	t, err := s.trainings.Get(ctx, TrainingID(p.ID))
	if err != nil {
		return err
	}
	ev, err := t.Cancel(p.Reason)
	if err != nil {
		return err
	}
	return s.trainings.Save(ctx, t, ev)
}
```

No "can this user cancel" rules duplicated here if `Cancel` already
enforces them. Authz that is not a domain rule stays at the API
(`encore-go` auth).

## CQRS (later)

See `source-of-truth`.

Split when a read cannot use the write aggregate without loading it for
display, reporting, or a screen that needs a join the aggregate forbids.

Until then: a `List(ctx, filter) ([]TrainingView, error)` next to the
store is fine. That is a query function, not a second bounded context.

When you do split: the write side stays the aggregate; the read side is a
projection updated from events (Wild Workouts v2.5 order). Do not start
with two databases.

## Bounded context map

| Already in this repo | Context boundary |
| --- | --- |
| Encore app | Service package. New context = new service with its own tables |
| Temporal OMS | Subsystem package (`temporal-go-app-structure`) |
| Plain module | `internal/<noun>` with one-way imports (`go-idioms`) |

Do not share the aggregate's tables across services. Duplicate a small VO
before creating `internal/common`.
