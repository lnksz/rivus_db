CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE public.time (
    time_id serial NOT NULL,
    run_id serial NOT NULL,
    time_step varchar(40) NOT NULL,
    weight real NOT NULL,
    PRIMARY KEY (time_id)
);

CREATE INDEX ON public.time
    (run_id);


CREATE TABLE public.area (
    area_id serial NOT NULL,
    run_id serial NOT NULL,
    building_type varchar(20) NOT NULL,
    PRIMARY KEY (area_id)
);

CREATE INDEX ON public.area
    (run_id);


CREATE TYPE public.run_status AS ENUM('error', 'prepared', 'run');

CREATE CAST (CHARACTER VARYING AS public.run_status) WITH INOUT AS IMPLICIT;

CREATE TYPE public.run_outcome AS ENUM('optima', 'no_optima', 'error');

CREATE CAST (CHARACTER VARYING AS public.run_outcome) WITH INOUT AS IMPLICIT;

CREATE TABLE public.run (
    run_id serial NOT NULL,
    start_ts timestamp without time zone NOT NULL,
    runner varchar(30) NOT NULL,
    status public.run_status NOT NULL,
    outcome public.run_outcome NOT NULL,
    pre_duration real,
    solve_duration real,
    post_duration real,
    PRIMARY KEY (run_id)
);


COMMENT ON COLUMN public.run.status
    IS '+  error
+ prepared
+ run';
COMMENT ON COLUMN public.run.outcome
    IS '+ optima
+ runtime_error
+ no-optima';

CREATE TABLE public.edge (
    edge_id bigserial NOT NULL,
    run_id serial NOT NULL,
    edge_num integer NOT NULL,
    vertex1 integer NOT NULL,
    vertex2 integer NOT NULL,
    geometry GEOGRAPHY NOT NULL,
    PRIMARY KEY (edge_id)
);

CREATE INDEX ON public.edge
    (run_id);


COMMENT ON COLUMN public.edge.geometry
    IS '```
CREATE TABLE global_points ( 
    id SERIAL PRIMARY KEY,
    name VARCHAR(64),
    location GEOGRAPHY(POINT,4326)
  );
```';

CREATE TABLE public.edge_demand (
    edge_id bigserial NOT NULL,
    commodity_id serial NOT NULL,
    value real NOT NULL
);

CREATE INDEX ON public.edge_demand
    (edge_id);
CREATE INDEX ON public.edge_demand
    (commodity_id);


CREATE TABLE public.vertex (
    vertex_id bigserial NOT NULL,
    run_id serial NOT NULL,
    vertex_num integer NOT NULL,
    geometry GEOGRAPHY NOT NULL,
    PRIMARY KEY (vertex_id)
);

CREATE INDEX ON public.vertex
    (run_id);


CREATE TABLE public.vertex_source (
    vertex_id bigserial NOT NULL,
    commodity_id serial NOT NULL,
    value real NOT NULL
);

CREATE INDEX ON public.vertex_source
    (vertex_id);
CREATE INDEX ON public.vertex_source
    (commodity_id);


CREATE TABLE public.commodity (
    commodity_id serial NOT NULL,
    run_id serial NOT NULL,
    commodity varchar(10) NOT NULL,
    unit varchar(10) NOT NULL,
    cost_inv_fix real NOT NULL,
    cost_inv_var real NOT NULL,
    cost_fix real NOT NULL,
    cost_var real NOT NULL,
    loss_fix real NOT NULL,
    loss_var real NOT NULL,
    allowed_max real NOT NULL,
    PRIMARY KEY (commodity_id)
);

CREATE INDEX ON public.commodity
    (run_id);


COMMENT ON COLUMN public.commodity.cost_inv_fix
    IS '# Specific investment costs (€/kW)

Size-dependent part for building a plant.';
COMMENT ON COLUMN public.commodity.cost_inv_var
    IS '# Specific investmeant costs (€/kW)

Size-dependent part for building a plant.';

CREATE TABLE public.process (
    process_id serial NOT NULL,
    run_id serial NOT NULL,
    process varchar(40) NOT NULL,
    cost_inv_fix real NOT NULL,
    cost_inv_var real NOT NULL,
    cost_fix real NOT NULL,
    cost_var real NOT NULL,
    cost_min real NOT NULL,
    cost_max real NOT NULL,
    PRIMARY KEY (process_id)
);

CREATE INDEX ON public.process
    (run_id);


CREATE TYPE public.process_commodity_direction AS ENUM('in', 'out');

CREATE CAST (CHARACTER VARYING AS public.process_commodity_direction) WITH INOUT AS IMPLICIT;

CREATE TABLE public.process_commodity (
    process_id serial NOT NULL,
    commodity_id serial NOT NULL,
    direction public.process_commodity_direction NOT NULL,
    ratio real NOT NULL
);

CREATE INDEX ON public.process_commodity
    (process_id);
CREATE INDEX ON public.process_commodity
    (commodity_id);


COMMENT ON COLUMN public.process_commodity.direction
    IS 'CREATE TYPE direction AS ENUM (''in'', ''out'');
CREATE TABLE person (
    name text,
    current_dir direction
);
INSERT INTO person VALUES (''Moe'', ''out'');';

CREATE TABLE public.direction (
    dir_bool boolean NOT NULL,
    dir_string varchar(3) NOT NULL,
    PRIMARY KEY (dir_bool)
);


CREATE TABLE public.time_demand (
    time_id serial NOT NULL,
    commodity_id serial NOT NULL,
    scale real NOT NULL
);

CREATE INDEX ON public.time_demand
    (time_id);
CREATE INDEX ON public.time_demand
    (commodity_id);


CREATE TABLE public.area_demand (
    area_id serial NOT NULL,
    commodity_id serial NOT NULL,
    peak real NOT NULL
);

CREATE INDEX ON public.area_demand
    (area_id);
CREATE INDEX ON public.area_demand
    (commodity_id);


COMMENT ON COLUMN public.area_demand.peak
    IS '# Building peak demand (kW/m2)
Peak demand of building type (must be present in building_shapefile) normalised to building area. Annual demand is encoded in timestep weights in table `time`';

CREATE TABLE public.pmax (
    pmax_id serial NOT NULL,
    edge_id bigserial NOT NULL,
    commodity_id serial NOT NULL,
    capacity integer NOT NULL,
    PRIMARY KEY (pmax_id)
);

CREATE INDEX ON public.pmax
    (edge_id);
CREATE INDEX ON public.pmax
    (commodity_id);


CREATE TABLE public.kappa_hub (
    edge_id bigserial NOT NULL,
    process_id serial NOT NULL,
    capacity integer NOT NULL
);

CREATE INDEX ON public.kappa_hub
    (edge_id);
CREATE INDEX ON public.kappa_hub
    (process_id);


CREATE TABLE public.kappa_process (
    vertex_id bigserial NOT NULL,
    process_id serial NOT NULL,
    capacity integer NOT NULL
);

CREATE INDEX ON public.kappa_process
    (vertex_id);
CREATE INDEX ON public.kappa_process
    (process_id);


CREATE TABLE public.source (
    vertex_id serial NOT NULL,
    commodity_id serial NOT NULL,
    time_id serial NOT NULL,
    capacity integer NOT NULL
);

CREATE INDEX ON public.source
    (vertex_id);
CREATE INDEX ON public.source
    (commodity_id);
CREATE INDEX ON public.source
    (time_id);


CREATE TABLE public.flow (
    edge_id bigserial NOT NULL,
    commodity_id serial NOT NULL,
    time_id serial NOT NULL,
    p_in integer NOT NULL,
    p_out integer NOT NULL,
    p_si integer NOT NULL,
    sigma integer NOT NULL
);

CREATE INDEX ON public.flow
    (edge_id);
CREATE INDEX ON public.flow
    (commodity_id);
CREATE INDEX ON public.flow
    (time_id);


CREATE TABLE public.time_hub (
    edge_id bigserial NOT NULL,
    process_id serial NOT NULL,
    time_id serial NOT NULL,
    capacity integer NOT NULL
);

CREATE INDEX ON public.time_hub
    (edge_id);
CREATE INDEX ON public.time_hub
    (process_id);
CREATE INDEX ON public.time_hub
    (time_id);


CREATE TABLE public.cost (
    cost_id serial NOT NULL,
    run_id serial NOT NULL,
    variable integer NOT NULL,
    investment integer NOT NULL,
    fix integer NOT NULL,
    PRIMARY KEY (cost_id)
);

CREATE INDEX ON public.cost
    (run_id);


ALTER TABLE public.time ADD CONSTRAINT FK_time__run_id FOREIGN KEY (run_id) REFERENCES public.run(run_id);
ALTER TABLE public.area ADD CONSTRAINT FK_area__run_id FOREIGN KEY (run_id) REFERENCES public.run(run_id);
ALTER TABLE public.edge ADD CONSTRAINT FK_edge__run_id FOREIGN KEY (run_id) REFERENCES public.run(run_id);
ALTER TABLE public.edge_demand ADD CONSTRAINT FK_edge_demand__edge_id FOREIGN KEY (edge_id) REFERENCES public.edge(edge_id);
ALTER TABLE public.edge_demand ADD CONSTRAINT FK_edge_demand__commodity_id FOREIGN KEY (commodity_id) REFERENCES public.commodity(commodity_id);
ALTER TABLE public.vertex ADD CONSTRAINT FK_vertex__run_id FOREIGN KEY (run_id) REFERENCES public.run(run_id);
ALTER TABLE public.vertex_source ADD CONSTRAINT FK_vertex_source__vertex_id FOREIGN KEY (vertex_id) REFERENCES public.vertex(vertex_id);
ALTER TABLE public.vertex_source ADD CONSTRAINT FK_vertex_source__commodity_id FOREIGN KEY (commodity_id) REFERENCES public.commodity(commodity_id);
ALTER TABLE public.commodity ADD CONSTRAINT FK_commodity__run_id FOREIGN KEY (run_id) REFERENCES public.run(run_id);
ALTER TABLE public.process ADD CONSTRAINT FK_process__run_id FOREIGN KEY (run_id) REFERENCES public.run(run_id);
ALTER TABLE public.process_commodity ADD CONSTRAINT FK_process_commodity__process_id FOREIGN KEY (process_id) REFERENCES public.process(process_id);
ALTER TABLE public.process_commodity ADD CONSTRAINT FK_process_commodity__commodity_id FOREIGN KEY (commodity_id) REFERENCES public.commodity(commodity_id);
ALTER TABLE public.time_demand ADD CONSTRAINT FK_time_demand__time_id FOREIGN KEY (time_id) REFERENCES public.time(time_id);
ALTER TABLE public.time_demand ADD CONSTRAINT FK_time_demand__commodity_id FOREIGN KEY (commodity_id) REFERENCES public.commodity(commodity_id);
ALTER TABLE public.area_demand ADD CONSTRAINT FK_area_demand__area_id FOREIGN KEY (area_id) REFERENCES public.area(area_id);
ALTER TABLE public.area_demand ADD CONSTRAINT FK_area_demand__commodity_id FOREIGN KEY (commodity_id) REFERENCES public.commodity(commodity_id);
ALTER TABLE public.pmax ADD CONSTRAINT FK_pmax__edge_id FOREIGN KEY (edge_id) REFERENCES public.edge(edge_id);
ALTER TABLE public.pmax ADD CONSTRAINT FK_pmax__commodity_id FOREIGN KEY (commodity_id) REFERENCES public.commodity(commodity_id);
ALTER TABLE public.kappa_hub ADD CONSTRAINT FK_kappa_hub__edge_id FOREIGN KEY (edge_id) REFERENCES public.edge(edge_id);
ALTER TABLE public.kappa_hub ADD CONSTRAINT FK_kappa_hub__process_id FOREIGN KEY (process_id) REFERENCES public.process(process_id);
ALTER TABLE public.kappa_process ADD CONSTRAINT FK_kappa_process__vertex_id FOREIGN KEY (vertex_id) REFERENCES public.vertex(vertex_id);
ALTER TABLE public.kappa_process ADD CONSTRAINT FK_kappa_process__process_id FOREIGN KEY (process_id) REFERENCES public.process(process_id);
ALTER TABLE public.source ADD CONSTRAINT FK_source__vertex_id FOREIGN KEY (vertex_id) REFERENCES public.vertex(vertex_id);
ALTER TABLE public.source ADD CONSTRAINT FK_source__commodity_id FOREIGN KEY (commodity_id) REFERENCES public.commodity(commodity_id);
ALTER TABLE public.source ADD CONSTRAINT FK_source__time_id FOREIGN KEY (time_id) REFERENCES public.time(time_id);
ALTER TABLE public.flow ADD CONSTRAINT FK_flow__commodity_id FOREIGN KEY (commodity_id) REFERENCES public.commodity(commodity_id);
ALTER TABLE public.flow ADD CONSTRAINT FK_flow__time_id FOREIGN KEY (time_id) REFERENCES public.time(time_id);
ALTER TABLE public.time_hub ADD CONSTRAINT FK_time_hub__edge_id FOREIGN KEY (edge_id) REFERENCES public.edge(edge_id);
ALTER TABLE public.time_hub ADD CONSTRAINT FK_time_hub__process_id FOREIGN KEY (process_id) REFERENCES public.process(process_id);
ALTER TABLE public.time_hub ADD CONSTRAINT FK_time_hub__time_id FOREIGN KEY (time_id) REFERENCES public.time(time_id);
ALTER TABLE public.cost ADD CONSTRAINT FK_cost__run_id FOREIGN KEY (run_id) REFERENCES public.run(run_id);