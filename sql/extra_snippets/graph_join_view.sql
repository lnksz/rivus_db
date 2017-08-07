create view graph_joined as (
SELECT C.run_id, C.commodity, G.is_connected, G.connected_components
FROM graph_analysis as G join commodity as C on C.commodity_id = G.commodity_id);