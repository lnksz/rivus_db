select avg(solve) as average
from (select r.run_id, vertex_dim, (r.profiler->>'solve')::float as solve, round(max(ST_Length(geometry))) AS edge_max, round(min(ST_Length(geometry))) AS edge_min
	from edge as e 
	join run as r on r.run_id=e.run_id
	JOIN (
	    select R.run_id, sqrt(count(vertex_num)) AS vertex_dim
	    from vertex as V
	    join run as R on R.run_id=V.run_id
	    --where R.start_ts between '2017-08-26 10:00' and '2017-08-26 22:00'
	    GROUP BY R.run_id
	) as side_dim on side_dim.run_id = R.run_id
	--where r.start_ts between '2017-08-26 10:00' and '2017-08-26 22:00'
	where vertex_dim = 10
	group by r.run_id, vertex_dim
	order by edge_max, edge_min, r.run_id) as x;