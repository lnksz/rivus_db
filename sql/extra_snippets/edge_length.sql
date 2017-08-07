select r.run_id, round(max(ST_Length(geometry))) AS edge_max, round(min(ST_Length(geometry))) AS edge_min
from edge as e 
join run as r on r.run_id=e.run_id
where r.start_ts > timestamp '2017-08-06 19:00:00'
group by r.run_id
order by edge_max, edge_min, r.run_id;