# Framework routing

Route universal checks to the repository's actual stack. Do not teach one
framework through another framework's APIs.
Sources: current official docs named below. The project pin wins.

## First step

1. Read manifests and imports. Record exact framework and persistence pins.
2. Identify who owns validation, transactions, persistence, jobs, cache, and
   cancellation. One product may use six libraries.
3. Load the matching language, platform, and domain skills.
4. Read official pin-matched docs for every load-bearing seam left unowned.

## Route

| Detect | Follow |
| --- | --- |
| Django | `python-idioms`; Django forms, model instances, QuerySet, transactions, migrations |
| FastAPI / Starlette | `python-idioms` + `api-contracts`; FastAPI boundary, selected ORM / driver and job system |
| Laravel | PHP pin; Laravel validation, Eloquent, transactions, queries, queues |
| Rails | Ruby pin; Active Record validations, callbacks, locking, adapter |
| Spring / JPA | Java pin; Spring transaction / validation setup, Spring Data, provider, database |
| Next.js | `typescript-idioms`; project `AGENTS.md`, bundled Next docs, selected database and deployment runtime |
| NestJS | `typescript-idioms` + `api-contracts`; Nest pin, selected ORM / driver, validator, queue |
| Expo / React Native | `expo-overview` first; local store, remote API, sync ownership, OS task lifecycle |
| Go HTTP / Gin / Chi / Echo / Fiber | `go-idioms` + `go-backend`; router pin, driver / ORM, worker |
| Other | language skill + official framework and persistence docs; fill the gate below |

## Seam reminders

| Stack | Check before claiming the path complete |
| --- | --- |
| Django | `save()` does not imply full validation; bulk writes bypass model save; lock behavior differs by backend |
| FastAPI | dependency lifetime is not transaction proof; `BackgroundTasks` is not a durable queue |
| Laravel | mass writes bypass model events; after-commit timing is not delivery durability |
| Rails | direct bulk methods bypass callbacks; `lock_version` and row locks solve different anomalies |
| Spring / JPA | proxy self-invocation can bypass `@Transactional`; bulk DML bypasses `@Version` and managed state |
| Next.js | Server Actions are authenticated mutation boundaries; the selected data layer owns atomicity |
| NestJS | providers own wiring, not database atomicity; persisted queues may redeliver |
| Expo | OS work is deferrable; local, remote, UI, and sync state need explicit ownership |
| Go routers | request context is canceled; copying router context is not durable execution |

For an unlisted framework, do not borrow the nearest row. Inspect its public
lifecycle and fill the same gate.

## Framework gate

```text
Framework translation:
- project framework and exact pin:
- persistence library and provider:
- production database(s):
- public validation boundary:
- transaction boundary:
- single-record lifecycle:
- bulk / direct mutation bypasses:
- relationship / cascade stage:
- optimistic and pessimistic mechanisms:
- post-commit effect mechanism:
- request and job cancellation owners:
- real-store test gate:
```

If a load-bearing entry is unknown, **stop**. Research the pin before coding.

## Official sources

| Stack | Source |
| --- | --- |
| Django | [documentation](https://docs.djangoproject.com/en/stable/) |
| FastAPI | [dependencies](https://fastapi.tiangolo.com/tutorial/dependencies/), [background tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/) |
| Laravel | [Eloquent](https://laravel.com/docs/eloquent), [database](https://laravel.com/docs/database), [queues](https://laravel.com/docs/queues) |
| Rails | [validations](https://guides.rubyonrails.org/active_record_validations.html), [callbacks](https://guides.rubyonrails.org/active_record_callbacks.html), [locking](https://api.rubyonrails.org/classes/ActiveRecord/Locking/Optimistic.html) |
| Spring / JPA | [transactions](https://docs.spring.io/spring-framework/reference/data-access/transaction.html), [Spring Data JPA](https://docs.spring.io/spring-data/jpa/reference/), [Jakarta Persistence](https://jakarta.ee/specifications/persistence/) |
| Next.js | [App Router](https://nextjs.org/docs/app) |
| NestJS | [documentation](https://docs.nestjs.com/) |
| Expo | [documentation](https://docs.expo.dev/) |
| Go / Gin | [`net/http`](https://pkg.go.dev/net/http), [Gin documentation](https://gin-gonic.com/en/docs/) |

## Do not

- Treat this file as a vendor API reference.
- Assign ORM semantics to a router or web framework.
- Assign queue durability to an in-process background helper.
- Use living documentation without checking the repository pin.
