# dbtop — Manual

Detailed usage of dbtop. For installation and an overview see
[README.md](README.md).

## 1. Starting & connecting

```bash
dbtop                              # ~/.my.cnf, localhost
dbtop -h <host> -u <user> -p       # prompts for the password
dbtop -h <host> -u <user> -p --interval 2
```

Recommended: create a `~/.my.cnf` with a **read-only monitor user**, then plain
`dbtop` is enough:
```ini
[client]
user=monitor
password=SECRET
host=127.0.0.1
```
Creating the monitor user (example):
```sql
CREATE USER 'monitor'@'localhost' IDENTIFIED BY 'SECRET';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'monitor'@'localhost';
-- optional, for kill / create index:
-- GRANT CONNECTION_ADMIN ON *.* TO 'monitor'@'localhost';
```

## 2. The header (KPI dashboard)

Five groups, updated live, fixed columns (no jitter):
- **Verbind.** (connections) – open/running connections, thread cache, max, aborted, created, open files
- **Durchsatz** (throughput) – QPS, sel/ins/upd/del per second, slow rate, full joins, full scans
- **InnoDB** – buffer hit, rows read/written, history list, temp tables (RAM/disk), log waits
- **Netz** (network) – in/out, open tables, sort rate, lock waits
- **System** – load, CPU %, RAM, disk (of the host dbtop runs on)
- **Load** – a full-width, 3-row load-average graph (24 levels): one bar per
  refresh, newest on the right, normalized to the host's core count (full
  height = run queue equals cores; bar height is square-root scaled so low
  load stays visible on many-core machines). Colours: green (<0.7 per core),
  amber (<1.0), red (≥1.0). Load is plotted instead of CPU %, because a server
  drowning in lock/disk waits shows low CPU but exploding load. The label
  column shows the current load1 and the average over the visible window.
  It keeps updating even while the DB is unreachable.

Health-relevant values are **coloured** (green good, amber warning, red bad).
If the server stops answering under load, the header keeps the last good values
and shows `● stale` plus the error instead of freezing or zeroing out.

## 3. Views

| Key | View | Content |
|---|---|---|
| `1` | Threads | Process list; columns Id/User/Host/DB/Cmd/Time/State/Query. Long runtimes amber (≥5 s) / red (≥30 s). |
| `2` | InnoDB | Engine status: history list length, active transactions, buffer pool, pending I/O |
| `3` | Replication | IO/SQL running?, seconds behind, last error (MySQL `REPLICA` & MariaDB `SLAVE`) |
| `4` | Top | largest tables by size |
| `5` | Health | health checks with traffic light + recommendation, below that the explained raw metrics list |

Switch with `1`–`5` or the **arrow keys `←/→`**. Inside the list select a row
with `↑/↓`.

## 4. Working with a query (Threads view)

Highlight a row with `↑/↓`, then:
- **`f`** – full query in a scrollable window.
- **`c`** – copy the query: tries the local clipboard via **OSC 52**; it is also
  always saved to **`/tmp/dbtop-clip.sql`** (path is shown). Tip: in the terminal
  you can also simply select the query with the mouse.
- **`x`** – **analyze**: runs `EXPLAIN` and evaluates the plan heuristically
  (full table scan, missing/unused indexes, filesort/temporary). Where possible
  a concrete **`CREATE INDEX …`** is suggested.
- **`e`** – **EXPLAIN** as an aligned table **incl. verdict** below; if all is
  fine it says the plan looks good.
- **`g`** – in the analysis window: **create** the suggested index. The exact
  statement is shown with a **red confirmation prompt**; on confirmation it runs
  **online** (`ALGORITHM=INPLACE, LOCK=NONE`) and the result is reported.
- **`k`** – **kill** the query (confirmed).

## 5. Sorting / filtering / display

- **`s`** – cycle the sort column (Time/Id/User/DB), **`r`** – reverse direction.
- **`/`** – enter a filter (user/host/DB/command/text); Enter applies, Esc cancels.
- **`a`** – toggle between *active only* and *all* threads (incl. `Sleep`). The
  tab line shows the shown/total counts and the current filter.

## 6. Display & control

- **`t`** – toggle **light/dark** theme.
- **`p`** – pause/resume (stops refreshing).
- **`+` / `-`** – refresh interval (0.5 / 1 / 2 / 5 s).
- **`Ctrl+L`** – force a full redraw (repairs a garbled screen).
- **`?`** – help, **`q`** – quit.

## 7. Notes

- **Stability:** every query runs with a deadline, so a stuck server can never
  wedge the monitor. dbtop reconnects automatically when the connection drops
  and shows `● stale` instead of freezing. The expensive top-tables query runs
  at most every 30 s.
- **System metrics** (load/CPU/RAM/disk) come from the machine dbtop **runs on** —
  most meaningful when you start dbtop directly on the DB server.
- **Safety:** apart from kill and create index (both confirmed) dbtop changes nothing.
- **Clipboard over SSH:** only works with an OSC 52 capable terminal; otherwise
  use the file fallback `/tmp/dbtop-clip.sql` or select with the mouse.
- **UI language:** the interface is currently in German.
