# DDD Lite

Canonical shapes. Gate on the earn checklist in [SKILL.md](SKILL.md).
Persistence wiring: `go-backend` `internals.md`. Encore API boundary:
`encore-go`.

## Aggregate

Methods are the API. Invalid combinations cannot be constructed.

```go
type Training struct {
	id       TrainingID
	userID   UserID
	when     time.Time
	canceled bool
	events   []Event
}

func NewTraining(id TrainingID, userID UserID, when time.Time) (Training, error) {
	if when.Before(time.Now()) { // or a passed clock in tests
		return Training{}, ErrNotInFuture
	}
	t := Training{id: id, userID: userID, when: when}
	t.record(TrainingScheduled{ID: id, UserID: userID, When: when})
	return t, nil
}

func (t *Training) Cancel(reason string) error {
	if t.canceled {
		return ErrAlreadyCanceled
	}
	t.canceled = true
	t.record(TrainingCanceled{ID: t.id, Reason: reason})
	return nil
}

func (t Training) Events() []Event { return slices.Clone(t.events) }
```

- Unexport fields that have rules. Export on a DTO at the API boundary if
  the wire type is a different shape.
- `NewX` / methods return sentinels (`ErrAlreadyCanceled`). Handlers map
  them (`go-backend`).
- Table-test the methods (`go-unit-tests`). Do not test SQL in the same
  test as "cannot cancel twice".
- Pass a clock (`func() time.Time` or `synctest`) instead of sprinkling
  `time.Now` if "future" is a rule you assert.

No aggregate: a row you only Get/Save with no method that can fail.

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
#18). IDs: a named type (`type TrainingID string`), not a raw `string`
through every signature once two ID kinds exist.

## Repository

Collection of aggregates. Same consumer-side rule as `go-backend`:

```go
type TrainingStore interface {
	Get(ctx context.Context, id TrainingID) (Training, error)
	Save(ctx context.Context, t Training) error
}
```

- `Save` persists the aggregate **and** (in the same transaction when you
  have one) the outbox rows for `t.Events()`. Then clear or do not reload
  events as if they were uncommitted.
- Optimistic concurrency: a version column, `ErrConflict` on stale write.
  Add it when two writers exist, not on day one.
- No `List` on this interface unless a command needs it. Queries that are
  screens of data are a different function (and, later, a different model).

## Domain events

Values. The aggregate appends them. The application layer publishes
**after** a successful save.

```go
type Event interface{ event() }

type TrainingCanceled struct {
	ID     TrainingID
	Reason string
}

func (TrainingCanceled) event() {}
```

Encore: publish on the service's `*pubsub.Topic` in the API function after
`Save`. Temporal: the workflow is the long-running reaction — do not
invent a second process manager. Same-process listener: a function call,
not a broker.

Do not import the subscriber's package from the aggregate.

## Application (command)

The only extra layer. It is the Encore API or the `go-backend` handler.

```go
func (s *Service) CancelTraining(ctx context.Context, p *CancelParams) error {
	t, err := s.trainings.Get(ctx, TrainingID(p.ID))
	if err != nil {
		return err
	}
	if err := t.Cancel(p.Reason); err != nil {
		return err
	}
	if err := s.trainings.Save(ctx, t); err != nil {
		return err
	}
	for _, e := range t.Events() {
		if err := s.publish(ctx, e); err != nil {
			return err
		}
	}
	return nil
}
```

No "can this user cancel" rules duplicated here if `Cancel` already
enforces them. Authz that is not a domain rule stays at the API
(`encore-go` auth).

## CQRS (later)

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
