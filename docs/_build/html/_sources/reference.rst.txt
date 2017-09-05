###########
Reference
###########
*****************
Entity Relations
*****************

The structure was created so that it is as flexible as possible regarding dimension changes.
E.g. The number of commodities, demand types etc. are normalized in 3NF.
As such it is no problem (read, you do not need to restructure the database), if at one time there is not 2 but 3 commodity types that are included in the demand per edge DataFrame.
Database structural changes are no friend of ours...

Change in the program part:

+------+----------+------+------+
| Edge | geometry | Heat | Elec |
+======+==========+======+======+
| 0    | LINE     | 150  | 200  |
+------+----------+------+------+

to

+------+----------+------+------+------+
| Edge | geometry | Heat | Elec | Cold |
+======+==========+======+======+======+
| 0    | LINE     | 150  | 200  | 50   |
+------+----------+------+------+------+

Is no problem, as in the DB the edge table is separated from the demand table.
The relation is represented by a table which connects an edge with a commodity.

+---------+-------+----------+
| edge_id | edge  | geometry |
+=========+=======+==========+
| 12345   | 0     | LINE     |
+---------+-------+----------+

is connected to 

+--------------+-----------+
| commodity_id | commodity |
+==============+===========+
| 345          | Heat      |
+--------------+-----------+

through

+----------+--------------+--------+
| edge_id  | commodity_id | demand |
+==========+==============+========+
| 12345    | 345          | 50     |
+----------+--------------+--------+

More on normalization and normal forms `here (simple) <http://www.studytonight.com/dbms/database-normalization.php>`_ 
and `here (detailed) <https://www.sqa.org.uk/e-learning/SoftDevRDS02CD/page_11.htm>`_

The above example shows that storing the DataFrames of the rivus model is often
not a proper solution.

In the following diagram you can see how the data is organised inside the database.
Besides the names, you can retrieve the respective data types too.

    Note: Some type notation follow the syntax of the `PSQL plug-in`_

.. _PSQL plug-in: https://github.com/adrianandrei-ca/staruml-postgresql

+---------------+-----------------------------------------+
| Special       | Explanation                             |
+===============+=========================================+
| INTEGER(-1)   | for Postgres data type SERIAL           |
+---------------+-----------------------------------------+
| BIGINT(-1)    | for Postgres data type BIGSERIAL        |
+---------------+-----------------------------------------+
| enum tags     | see description in Postgres Extension   |
+---------------+-----------------------------------------+

.. image:: img/RivusDB.png

Blue:
    Optimization results
Gray:
    Input (spatial and non-spatial)
White:
    Global and extensions.

******************
Enumerated values
******************

The following columns accept only the listed values (Case Sensitive.)
Notation: ``table.columns``

``run.status``:
    + prepared
    + run
    + error
``run.outcome``:
    + optimum,
    + optimum_not_found
    + error
    + not_run
``process_commodity.direction``:
    + in
    + out

*********************************
Scripts - Make Your Life Easier
*********************************

.. _scripts-anchor:

Short summary of the used scripts. These scripts are shot and rich with in-line
documentation. So for detail open them up with a text editor.

Database Create/Drop
=====================

:file:`rivus_db/sql/create_from_staruml.sh`:
    1. copies the raw scripts from :file:`rivus_db/sql/staruml_expor/` into :file:`rivus_db/sql/` and modifies them slightly

        + add extension handling
        + drop some generated defaults (encoding)
        + your future feature?

    2. executes the modified `create_*.sql` scripts.
    3. if executed with ``extend`` argument: ``create_from_staruml.sh extend`` the 2. step is omitted. (The scripts get modified, but not executed.)

:file:`rivus_db/sql/_purge_rivus.sh`:
    - Executes the ``drop_*.sql`` scripts in :file:`rivus_db/sql/`

:file:`rivus_db/reset_db.sh`:
    - Executes the above two scripts after each other. This results in a clean new database.

.. _a_queries:

Report/Analysis
=================

I have a work-flow, where I narrow down the large data set with some SQL queries on the database 
client (DBeaver, plsq...). Typically, from those results I can pick 1-5 runs which are really interesting.
I can investigate them further with ``rivus`` functions.

Some of the scripts are enlightened here for inspiration:

List used hub processes
------------------------

Entry level query, join the relevant tables, filter data. Get the used processes.

.. literalinclude:: ../sql/extra_snippets/list_built_process.sql
    :linenos:
    :caption: Built processes (no hubs) and their capacity.

Example results:

+-----------+---------------+--------------------------+------------+
| run\_id   | vertex\_num   | process                  | capacity   |
+===========+===============+==========================+============+
| 3599      | 0             | Gas power plant          | 2462       |
+-----------+---------------+--------------------------+------------+
| 3600      | 0             | Gas power plant          | 6154       |
+-----------+---------------+--------------------------+------------+
| 3601      | 0             | Gas power plant          | 6154       |
+-----------+---------------+--------------------------+------------+
| 3602      | 0             | Gas power plant          | 6154       |
+-----------+---------------+--------------------------+------------+
| 3603      | 0             | Gas power plant          | 6154       |
+-----------+---------------+--------------------------+------------+
| 3604      | 0             | Gas power plant          | 6154       |
+-----------+---------------+--------------------------+------------+
| 3605      | 0             | Gas power plant          | 6154       |
+-----------+---------------+--------------------------+------------+
| 3607      | 0             | Gas power plant          | 6154       |
+-----------+---------------+--------------------------+------------+
| 3608      | 0             | Gas power plant          | 6154       |
+-----------+---------------+--------------------------+------------+
| 3609      | 0             | Gas power plant          | 6154       |
+-----------+---------------+--------------------------+------------+
| 3610      | 0             | District heating plant   | 10001      |
+-----------+---------------+--------------------------+------------+
| 3611      | 0             | District heating plant   | 10000      |
+-----------+---------------+--------------------------+------------+

List source vertices and their capacity
----------------------------------------

Entry level query, join the relevant tables, filter data. Get the source vertices.

.. literalinclude:: ../sql/extra_snippets/sources.sql
    :linenos:
    :caption: Used source vertices.

Example results:

+-----------+---------------+-------------+--------+
| run\_id   | vertex\_num   | commodity   | max    |
+===========+===============+=============+========+
| 4825      | 0             | Elec        | 1748   |
+-----------+---------------+-------------+--------+
| 4825      | 5             | Gas         | 6229   |
+-----------+---------------+-------------+--------+
| 4833      | 0             | Elec        | 1796   |
+-----------+---------------+-------------+--------+
| 4833      | 30            | Gas         | 6090   |
+-----------+---------------+-------------+--------+

List count and max-capacity of built commodities
----------------------------------------------------

Or what have found a way into pmax (should be built) as a column. Plus show the maximum capacity per.

Show built commodities in a nice, tight manner. Here you can filter the results
with the addition of a `where` clause.

Note ``jsonb_agg`` and ``jsonb_object_agg`` these are over the boundaries of MySQL or such,
but look how convenient they are! (Hooray, PostgreSQL_!)

.. literalinclude:: ../sql/extra_snippets/built_comms2.sql
    :linenos:
    :emphasize-lines: 4,12
    :caption: Number of built commodity grids and their maximum capacity.

Example results:

+-----------+-----------------------+----------------+----------------------------------------+
| run\_id   | start\_ts             | built\_comms   | comm\_cap\_max                         |
+===========+=======================+================+========================================+
| 5637      | 2017-09-02 10:47:30   | 1              | {“Gas”: 0, “Elec”: 1646, “Heat”: 0}    |
+-----------+-----------------------+----------------+----------------------------------------+
| 5636      | 2017-09-02 10:46:31   | 1              | {“Gas”: 0, “Elec”: 1537, “Heat”: 0}    |
+-----------+-----------------------+----------------+----------------------------------------+
| 5635      | 2017-09-02 10:45:30   | 2              | {“Elec”: 1317, “Heat”: 46}             |
+-----------+-----------------------+----------------+----------------------------------------+
| 5634      | 2017-09-02 10:43:44   | 1              | {“Elec”: 1263, “Heat”: 0}              |
+-----------+-----------------------+----------------+----------------------------------------+
| 5633      | 2017-09-02 10:42:50   | 1              | {“Gas”: 0, “Elec”: 1731}               |
+-----------+-----------------------+----------------+----------------------------------------+
| 5632      | 2017-09-02 10:41:54   | 2              | {“Elec”: 1787, “Heat”: 46}             |
+-----------+-----------------------+----------------+----------------------------------------+
| 5631      | 2017-09-02 10:39:56   | 1              | {“Elec”: 1029}                         |
+-----------+-----------------------+----------------+----------------------------------------+
| 5630      | 2017-09-02 10:38:43   | 1              | {“Elec”: 1114}                         |
+-----------+-----------------------+----------------+----------------------------------------+
| 5629      | 2017-09-02 10:29:53   | 2              | {“Gas”: 0, “Elec”: 1342, “Heat”: 93}   |
+-----------+-----------------------+----------------+----------------------------------------+


Advanced Report
------------------

A more in depth analysis (report) with built capacities with their maximum value, square grid side dimension and edge length plus some parameters which were changed throughout a long run.

1. Here you can even experience the PostGIS extension in action with length calculation.
2. Some time filtering
3. Filtering with the JSONb column. (Very intuitive.)

.. literalinclude:: ../sql/extra_snippets/data_analysis002.sql
    :linenos:
    :emphasize-lines: 20,24,27,35,38
    :caption: Extensive report.

.. note::

    ``sqrt(count(vertex_num))`` works here as the stored grids where symmetrical. (6x6, 5x5 etc...)

Example results:

+-----------+-----------------------+------------------------------+---------------+-------------+-------------+-------------+------------------+
| run\_id   | start\_ts             | comm\_cap\_max               | vertex\_dim   | edge\_max   | edge\_min   | cost\_fix   | cost\_inv\_fix   |
+===========+=======================+==============================+===============+=============+=============+=============+==================+
| 5635      | 2017-09-02 10:45:30   | {“Elec”: 1317, “Heat”: 46}   | 6             | 50          | 50          | 4           | 350              |
+-----------+-----------------------+------------------------------+---------------+-------------+-------------+-------------+------------------+
| 5632      | 2017-09-02 10:41:54   | {“Elec”: 1787, “Heat”: 46}   | 6             | 50          | 50          | 4           | 350              |
+-----------+-----------------------+------------------------------+---------------+-------------+-------------+-------------+------------------+
| 5629      | 2017-09-02 10:29:53   | {“Elec”: 1342, “Heat”: 93}   | 6             | 50          | 50          | 4           | 350              |
+-----------+-----------------------+------------------------------+---------------+-------------+-------------+-------------+------------------+

After these results, I could say, ok, run ``5635`` looks interesting, I want to re-run it, maybe change some parameter or re-plot or plot it with matplotlib or or or...

I could do something like this:

.. code-block:: python

    from rivus.io import db as rdb
    engine_string = 'postgresql://postgresql:postgresql@localhost/rivus'
    engine = create_engine(engine_string)

    data_dfs = ['process', 'commodity', 'process_commodity', 'time', 'area_demand']
    data = {df_name: rdb.df_from_table(engine, df_name, run_id)
            for df_name in data_dfs}
    vertex = rdb.df_from_table(engine, 'vertex', run_id)
    edge = rdb.df_from_table(engine, 'edge', run_id)

    #... Change whatever parameter I would like ...

    import pyomo.environ  # although is not used directly, is needed by pyomo
    from pyomo.opt.base import SolverFactory
    from rivus.utils.prerun import setup_solver
    from rivus.main.rivus import create_model
    # Solve again!
    prob = create_model(data, vertex, edge, hub_only_in_edge=False)
    solver = SolverFactory(config['solver'])
    solver = setup_solver(solver, log_to_console=True)
    solver.solve(prob, tee=True)

    # 3D Re-plot
    from rivus.io.plot import fig3d
    from plotly.offline import plot as plot3d
    plotcomms = ['Gas', 'Heat', 'Elec']
    fig = fig3d(prob, linescale=8, comms=plotcomms, use_hubs=True,
                dz=(0.25 * 100))
    plot3d(fig, filename='bunch-{}.html'.format(4242))

    # Whatever you would like.




************************
Archive (Dump - Import)
************************

One can have various reasons to archive a database. For our project a short excerpt of
the detailed official-tutorial_ is given here.

The bundled tools shipping with PostgreSQL_ are pretty amazing.
In the previous :ref:`section <scripts-anchor>` or during :ref:`psql database connection <db-connect>`
you already used one of them. (``psql``)
Now we will get to know ``pg_dump`` and ``createdb``.

To dump all the contents of a database:

1. Make sure the database server is running.
2. Dump the contents into a SQL file.

    + -U database-user
    + -f file name to dump to
    + last parameter without flag is the target database.

3. [Optional] Transport the created file to the site, where it should be restored.
4. Create a database where the restoration should take place.
5. Restore from file with ``psql``

.. code-block:: psql

    pg_ctl status
    pg_dump -U postgres -f rivus_dump.sql rivus
    createdb -h localhost -U postgres rivus_import
    psql -U postgres rivus_import < rivus_dump.sql


Voilà, you have there you have two local databases, on which you can run super fast queries.

.. _official-tutorial: https://www.postgresql.org/docs/current/static/backup.html
.. _PostgreSQL: https://www.postgresql.org/



