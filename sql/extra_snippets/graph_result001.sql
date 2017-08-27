select RUN.run_id, start_ts, "comment", RUN.profiler->>'solve' as solve_time, commodity, is_connected, connected_components, side_dim.dimension, edge_len.edge_max, edge_len.edge_min
from commodity as COM
JOIN run as RUN ON COM.run_id = RUN.run_id
JOIN graph_analysis as GRA ON GRA.commodity_id = COM.commodity_id
JOIN (
	select r.run_id, round(max(ST_Length(geometry))) AS edge_max, round(min(ST_Length(geometry))) AS edge_min
	from edge as e 
	join run as r on r.run_id=e.run_id
	where r.start_ts > timestamp '2017-08-06 19:00:00'
	group by r.run_id
	order by edge_max, edge_min, r.run_id
) as edge_len on edge_len.run_id = RUN.run_id
JOIN (
	select R.run_id, sqrt(count(vertex_num)) AS dimension
	from vertex as V join run as R on R.run_id=V.run_id
	where r.start_ts > timestamp '2017-08-06 19:00:00'
	GROUP BY R.run_id
) as side_dim on side_dim.run_id = RUN.run_id
order by start_ts DESC, commodity limit 300;