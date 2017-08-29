select V.run_id, V.vertex_num, C.commodity, max(S.capacity)
from "source" as S
join vertex as V on V.vertex_id=S.vertex_id
join commodity as C on C.commodity_id=S.commodity_id
-- for view, remove where V.run_id in (4825, 4833)
where V.run_id in (4825, 4833) and S.capacity > 0
group by V.run_id, V.vertex_num, C.commodity
order by V.run_id, V.vertex_num;