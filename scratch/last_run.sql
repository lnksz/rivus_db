SELECT (select max(run_id) from run) as RUNS, 
(select max(run_id) from commodity) as COMS,
(select max(run_id) from process) as proc,
(select max(run_id) from vertex) as vert,
(select max(run_id) from edge) as proc,
(select max(run_id) from area) as vert,
(select max(run_id) from time) as time;