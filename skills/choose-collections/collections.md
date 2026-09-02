# Collections

Contiguous vs keyed. One-line actions. Language names differ; the
access does not. Pin order: SKILL.md.

| Access | Use | Not |
| --- | --- | --- |
| Scan in order, append, index by position | array / slice / list | map as a list |
| Lookup by id / key | map / dict / `Map` | scan a slice each time at size |
| Unique membership | set / `map[T]struct{}` / `Set` | nested equality loops |
| Record (known fields) | object / struct | `Map` or `{}` of user keys |
| Ordered keys + lookup | pin: JS `Map` / Python dict insert; Go map + slice of keys | range a Go `map`; sort the map each read |
| Front/back queue | deque / ring if stdlib has it | `shift` / `pop(0)` / `s[1:]` in a hot path |
| Stack | append / pop at the end | delete-from-front |
| Priority / top-K | heap if the pin has one | full sort when you need K repeatedly |
| Nested by parent | map of slices, or a table (`data-modeling`) | a graph library |
| Tree of UI / DOM | the platform tree | a hand-rolled tree |
| Graph (real edges) | adjacency map / edge list | matrix fashion on a sparse list |
| Linked list | **no** unless measured | `container/list` as the sequence |
| Query the database owns | **index** / `WHERE` / `ORDER BY` | load all rows into a slice |

Tiny n (a handful): a slice scan is clearer than a map. Do not
micro-optimize a four-element list.

Grow: start with a slice. Change to a map when you look up. Change
to a set when you ask "have I seen this". Change to a heap when you
need top-K repeatedly. Do not start with a graph.

The database is the structure when the data lives there. An
in-memory map of every row is a cache — `source-of-truth` must
allow it.
