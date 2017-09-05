select E.run_id, E.edge_num, P.process, KH.capacity
from kappa_hub as KH
join edge as E on E.edge_id=KH.edge_id
join process as P on P.process_id=KH.process_id
where 
	E.run_id > 1250 --E.run_id in (4825, 4833)
	and KH.capacity > 0
order by E.run_id, E.edge_num;