select R.run_id, start_ts, built_comms, comm_cap_max
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
order by start_ts DESC
;