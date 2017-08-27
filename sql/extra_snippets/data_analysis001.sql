select R.run_id, start_ts, built_comms, comm_cap_max, vertex_dim
from run as R
join (
	select C.run_id, count(distinct C.commodity) as built_comms, jsonb_agg(distinct C.commodity) as built_names
	from pmax as P
	join commodity as C on P.commodity_id=C.commodity_id
	join edge as E on E.edge_id = P.edge_id
	where P.capacity <> 0
	group by C.run_id
) as builts on builts.run_id = R.run_id
join (
	select run_id, jsonb_object_agg(commodity, cap_max) as comm_cap_max
	from (
		select C.run_id, C.commodity, max(P.capacity) as cap_max
		from pmax as P
		join commodity as C on P.commodity_id=C.commodity_id
		join edge as E on E.edge_id = P.edge_id
		group by C.run_id, C.commodity
		order by C.run_id, C.commodity
		) as cap_maxs
	group by run_id
) as json_built on json_built.run_id = R.run_id
JOIN (
	select R.run_id, sqrt(count(vertex_num)) AS vertex_dim
	from vertex as V
	join run as R on R.run_id=V.run_id
	where R.start_ts BETWEEN '2017-08-26 10:00:00'::timestamp AND '2017-08-26 22:00:00'::timestamp
	GROUP BY R.run_id
) as side_dim on side_dim.run_id = R.run_id
order by start_ts DESC
;