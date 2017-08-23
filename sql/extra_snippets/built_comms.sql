select R.run_id, start_ts, built_comms, built_names
from run as R
join
	(select C.run_id, count(distinct C.commodity) as built_comms, jsonb_agg(distinct C.commodity) as built_names
	from pmax as P
	join commodity as C on P.commodity_id=C.commodity_id
	join edge as E on E.edge_id = P.edge_id
	group by C.run_id) as builts on builts.run_id = R.run_id
--where built_comms <> 2
order by start_ts DESC
;