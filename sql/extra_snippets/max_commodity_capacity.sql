select run_id, jsonb_object_agg(commodity, cap_max) as comm_cap_max
from
(select C.run_id, C.commodity, max(P.capacity) as cap_max
	from pmax as P
	join commodity as C on P.commodity_id=C.commodity_id
	join edge as E on E.edge_id = P.edge_id
	group by C.run_id, C.commodity
	order by C.run_id, C.commodity)
	as cap_maxs
group by run_id
;
	
