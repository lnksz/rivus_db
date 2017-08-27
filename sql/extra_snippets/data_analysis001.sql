select R.run_id, start_ts, comm_cap_max, vertex_dim, edge_max, edge_min, cost_fix, cost_inv_fix
from run as R
--join (
--	select C.run_id, count(distinct C.commodity) as built_comms, jsonb_agg(distinct C.commodity) as built_names
--	from pmax as P
--	join commodity as C on P.commodity_id=C.commodity_id
--	join edge as E on E.edge_id = P.edge_id
--	where P.capacity <> 0
--	group by C.run_id
--) as builts on builts.run_id = R.run_id
join (
	select run_id, jsonb_object_agg(commodity, cap_max) as comm_cap_max
	from (
		select C.run_id, C.commodity, max(P.capacity) as cap_max
		from pmax as P
		join commodity as C on P.commodity_id=C.commodity_id
		join edge as E on E.edge_id = P.edge_id
		where p.capacity > 0 -- if this is disabled comm_cap_max will also include Commodities with 0 max Like Gas:0
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
JOIN (
	select r.run_id, round(max(ST_Length(geometry))) AS edge_max, round(min(ST_Length(geometry))) AS edge_min
	from edge as e 
	join run as r on r.run_id=e.run_id
	where r.start_ts  BETWEEN '2017-08-26 10:00:00'::timestamp AND '2017-08-26 22:00:00'::timestamp
	group by r.run_id
	order by edge_max, edge_min, r.run_id
) as edge_len on edge_len.run_id = R.run_id
join (
	select run.run_id, cost_fix, cost_inv_fix
	from run
	join commodity AS C on C.run_id = run.run_id
	where run.start_ts  BETWEEN '2017-08-26 10:00:00'::timestamp AND '2017-08-26 22:00:00'::timestamp
		and C.commodity = 'Heat'
) as parameters on parameters.run_id = R.run_id
where comm_cap_max->>'Heat' is not null and comm_cap_max->>'Heat' <> '0'
order by start_ts DESC
;