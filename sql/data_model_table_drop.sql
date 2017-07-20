DROP EXTENSION IF EXISTS postgis CASCADE;

DROP EXTENSION IF EXISTS tablefunc CASCADE;

DROP TABLE public.time CASCADE;
DROP TABLE public.area CASCADE;
DROP TABLE public.run CASCADE;
DROP TYPE public.run_status CASCADE;
DROP TYPE public.run_outcome CASCADE;
DROP TABLE public.edge CASCADE;
DROP TABLE public.edge_demand CASCADE;
DROP TABLE public.vertex CASCADE;
DROP TABLE public.vertex_source CASCADE;
DROP TABLE public.commodity CASCADE;
DROP TABLE public.process CASCADE;
DROP TABLE public.process_commodity CASCADE;
DROP TYPE public.process_commodity_direction CASCADE;
DROP TABLE public.direction CASCADE;
DROP TABLE public.time_demand CASCADE;
DROP TABLE public.area_demand CASCADE;
DROP TABLE public.pmax CASCADE;
DROP TABLE public.kappa_hub CASCADE;
DROP TABLE public.kappa_process CASCADE;
DROP TABLE public.source CASCADE;
DROP TABLE public.flow CASCADE;
DROP TABLE public.time_hub CASCADE;
DROP TABLE public.cost CASCADE;
DROP TABLE public.graph_analysis CASCADE;