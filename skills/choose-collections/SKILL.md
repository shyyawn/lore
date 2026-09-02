---
name: choose-collections
description: >-
  Chooses in-memory collections and stdlib algorithms: slice vs map vs
  set vs heap, contiguous vs keyed, SQL/index as the structure, invent
  default no. Use when generating, editing, or reviewing slice vs map,
  heap, deque, graph, Object vs Map, O(n²) loops, a hand-rolled sort,
  ORDER BY, or when the user asks which data structure or algorithm to
  use.
---

# Choose collections

In-memory **chooser**. Not a textbook. Do not invent a sort the
stdlib or the database already has.

Sources: language stdlib — Go spec `For_range` (map order not
specified), `slices`, `container/heap`; MDN `Map` / `Set` / `Array`;
Python `tutorial/datastructures`, `collections.deque`, `heapq`.
Postgres `queries-order`. MySQL 8.4 `order-by-optimization` only for
`GROUP BY` no longer sorting. Not CLRS. Not GoF Strategy for a filter.

Catalogs: [collections.md](collections.md), [algorithms.md](algorithms.md).
Schema / indexes as persistence: `data-modeling`. Writer:
`source-of-truth`. Language spelling: `go-idioms` /
`typescript-idioms`.

## First step

1. Inventory what is already there. Honor it.

   The collection already in the function. Stdlib sort/search. A DB
   index or `ORDER BY` that already answers this.
2. Read the **pin**. Do not bump it.

   Language (Go / TypeScript / Python), the database if the rows
   live there.
3. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | Table / JSONB / child rows | `data-modeling` |
   | Second store, cache as truth | `source-of-truth` |
   | Go `slices` / `maps` spelling, `slices.Sort` | `go-idioms` — this skill still owns slice vs map |
   | TS `Object.groupBy` / `Set` methods / `Map.getOrInsert` | `typescript-idioms` — this skill still owns the choice |
4. Contiguous vs keyed ([collections.md](collections.md)). If the
   database can answer it, do not load the table to sort in process.
5. Earn a custom algorithm ([algorithms.md](algorithms.md)). Tick yes
   on at least two, or stay on stdlib / SQL.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Sequence | array / slice / list | existing other collection works |
| Lookup by key | map / dict / `Map` | n is tiny and a scan is clearer |
| Unique membership | set / `map[T]struct{}` / `Set` | — |
| Record (known fields) | object / struct | keys are dynamic or user-provided → `Map` |
| Ordered + keyed | JS `Map` / Python dict insert; Go map + slice of keys | existing order already works |
| Front/back queue | stdlib deque if the pin has it | `shift` / `pop(0)` / `s[1:]` already fine at tiny n |
| Stack | append / pop at the **end** | — |
| Top-K / priority | heap if the pin has one; else sort-once or `ORDER BY … LIMIT` | existing heap already there |
| Graph | **no** (list or map of edges) | you have real edges and a named traversal |
| Linked list | **no** | stdlib list and you measured |
| Sort / search | stdlib, or `ORDER BY` / index | Earn custom (below) |
| Filter | a loop or `slices.DeleteFunc` / `filter` | GoF Strategy as fashion |
| Structure for a query | DB index / `WHERE` | in-memory copy of the table |

## Pin strings

Inventory the language. Do not copy JS `Map` insertion order onto a
Go `map`.

| Pin | Keyed lookup | Order / queue |
| --- | --- | --- |
| Go `map` | keyed | **not** ordered (`For_range`). Stable → map + slice of keys |
| Go sequence | slice | `container/list` is not the default. `container/heap` is a min-heap |
| JS / TS | `Map` for a dynamic collection; object for a record | `Map` / `Set` insert order (MDN). `shift` is O(n). No stdlib heap |
| Python 3.7+ `dict` | keyed | insertion order. `list.pop(0)` is O(n); `collections.deque` |
| Python `heapq` | min-heap; `heap[0]` is smallest | do not bump for `heapify_max` (3.14) |
| sqlc / SQL | `WHERE` / `UNIQUE` | `ORDER BY` / `LIMIT`. Scan order is not a sort |

## Division of labor

| Artifact | Owner |
| --- | --- |
| In-memory collection and algorithm choice | this skill |
| SQL types, indexes as schema | `data-modeling` |
| Which store is truth | `source-of-truth` |
| Language catalog (`slices.Sort`, `Object.groupBy`) | `go-idioms` / `typescript-idioms` |

## What this skill owns

| Own | Leave |
| --- | --- |
| Slice vs map vs set vs heap vs queue; contiguous vs keyed | CLRS proofs; GoF catalogs |
| Stdlib sort/search; SQL as the algorithm; earn invent | Column types (`data-modeling`) |
| DB index as the structure when the data lives there | Cache as a second writer (`source-of-truth`) |
| Record vs `Map`; map iteration order is pin-gated | `slices` / `Set` method spelling |

## Earn a custom algorithm

Copy this checklist. Tick **yes** on at least two, or stay on stdlib
or SQL.

```
Earn a custom algorithm:
- [ ] Measured hot path (not a guess, not O(n²) folklore)
- [ ] Stdlib (and the DB) missing this
- [ ] Correctness you can state — and a test that states it
```

If every line is **no**, do not write a sort, a graph library, a
Heap class, or a hand-rolled b-tree. A SQL `ORDER BY` / index is
often the algorithm.

## Hard rules

- Pick a collection for the **access**: scan → contiguous; lookup →
  keyed; unique → set; top-K → heap (or sort-once / `LIMIT` if the
  pin has no heap). Do not pick for fashion.
- If the rows live in a database, an **index** is the structure. Do
  not load the table to sort or unique in process as the default.
- Sort, search, heap, and shuffle come from the **stdlib**. Invent
  default is **no**.
- Complexity is a reason to pick (n² in a hot loop). It is not a
  reason to invent. Measure, then earn.
- A filter is a function. Do not teach Strategy / Visitor for it.
- Map iteration **order** is pin-gated. Go `map` is not ordered. Do
  not copy JS `Map` / Python `dict` order onto it.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Sort | stdlib / `ORDER BY` | a custom sort |
| Unique | set / `UNIQUE` | nested loops |
| Lookup | map, or a DB index | scan a slice each time at size |
| Queue | deque if the pin has it | linked list; `pop(0)` / `shift` as a hot default |
| Graph | edge list / map when you have edges | a graph library on a list |
| Filter | a function | GoF Strategy |
| Faster query | index (`data-modeling`) | in-memory copy of the table |
| Group | pin `Object.groupBy` / a map of slices | lodash `groupBy` |

## After every edit

Name the collection and why (contiguous vs keyed). A custom sort or
graph that did not tick Earn is deleted. An in-memory table copy
becomes a query.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Nested loop on a growing list | want a map, a set, or a DB unique |
| Loaded 100k rows to sort | `ORDER BY` / index |
| Heap for a one-shot sort | stdlib sort |
| Graph library on a parent FK | that is a table (`data-modeling`) |
| Strategy class around a filter | a function |
| "O(n²) so I wrote a sort" | did not earn; stdlib / SQL first |
| Go `range` of a map is a stable list | map is not ordered. Key slice |
| `Array.shift` / `list.pop(0)` in a hot loop | want a deque, or a head index |
| User keys on `{}` collide / pollute | that is a `Map` (MDN), not a record |
| MySQL 8.4 `GROUP BY` order changed | `GROUP BY` is not `ORDER BY` |

## LLM traps — never generate these

- A custom sort / b-tree / graph library / JS Heap class on the first use
- `[]User` scanned by id in a hot loop (want `map[ID]User`)
- Loading the table to unique in process
- GoF Strategy / Visitor / Decorator for a filter
- CLRS dump, Big-O theater without a measured path
- Redis as an in-memory map that is secretly a second writer
- `sort.Slice` of a SQL result that `ORDER BY` already owns
- Ranging a Go `map` and treating the order as stable
- `{}` with user-provided keys as a dictionary (prototype / injection)
- `container/list` as the default Go sequence
- Python `OrderedDict` as a drive-by on 3.7+ `dict`
- lodash `groupBy` / `uniq` next to `Object.groupBy` / `Set`
- Bumping Python for `heapify_max`

## Do not

- Restyle a working array into a graph as a drive-by.
- Skip Earn because the user said "this should be O(n)".
- Recopy `go-idioms` slice catalogs or `data-modeling` types here.
- Teach CLRS, GoF, or an EXPLAIN / filesort cookbook.
- Restyle JSON records into `Map` as a drive-by.
