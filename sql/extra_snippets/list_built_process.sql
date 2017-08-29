select V.run_id, V.vertex_num, P.process, KP.capacity
from kappa_process as KP
join vertex as V on V.vertex_id=KP.vertex_id
join process as P on P.process_id=KP.process_id
where V.run_id in (4825, 4833) and KP.capacity > 0
	-- for filtering most of the hubs (here not concerned with the number of inputs)
	and P.cost_inv_fix <> 0 and P.cap_min <> 0;