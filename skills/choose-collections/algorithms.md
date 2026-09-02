# Algorithms

Stdlib and SQL first. Invent default is **no**. Earn in SKILL.md.

| Need | Use | Do not |
| --- | --- | --- |
| Sort | stdlib (`slices.Sort`, `Array.sort`, `sorted`) or `ORDER BY` | a custom comparison sort |
| Binary search on a sorted slice | stdlib (`sort.Search`, `bisect`) | a hand-rolled mid |
| Unique | set, or `SELECT DISTINCT` / `UNIQUE` | O(n²) equality |
| Filter / map / reject | a loop or stdlib helper | Strategy / Visitor |
| Group by key | pin `Object.groupBy` / `Map.groupBy` / a map of slices | lodash `groupBy` |
| Top-K | heap, `heapq.nsmallest` / `nlargest`, or `ORDER BY … LIMIT` | sort the whole table; a JS Heap class |
| Min / max | stdlib, or `MIN()` / `MAX()` | sort to take `[0]` |
| Membership | set / map, or a DB unique | linear scan at size |
| Graph walk | BFS/DFS you can state, when you have edges | a library on a list |
| Shortest path | stdlib or a named lib **after** Earn | Dijkstra on day one |
| Shuffle | stdlib | a custom swap loop |
| Row order | `ORDER BY` (Postgres `queries-order`) | scan order; MySQL 8.4+ `GROUP BY` is not a sort |

Complexity is a **reason to pick**, not a reason to invent. O(n²) on
a hot path → map, set, index, or stdlib. Then measure.

SQL / index is often the algorithm:

- Order → `ORDER BY`
- Unique → `UNIQUE` / `DISTINCT`
- Range → index + `WHERE`
- Top-K → `ORDER BY … LIMIT`
- Exists → `EXISTS` / `UNIQUE`, not load-and-scan

Do not dump EXPLAIN, filesort, or an index cookbook
(`data-modeling`).

Correctness you can state: one sentence plus a table test. If you
cannot state it, you have not earned the custom code.

Do not dump CLRS. Do not teach Master Theorem. Do not add an
`algorithms/` package as fashion.
