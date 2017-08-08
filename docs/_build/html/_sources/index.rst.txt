.. _contents:


rivus_db documentation
======================

`rivus_db`_ is a database helper extension for the `rivus`_ project.
It helps you set up and manage a PostgreSQL_ database for the project, with some
specific configuration. (Specific for my current work with rivus.)

However, the core functions are general enough to serve as a good starting point
for any related projects. Feel free to fork the repository and adjust it to your needs.

In :doc:`overview`, you can get a broad impression, what the goal(s) of this package is (are),
and what you can and cannot do with these tools.

In :doc:`introduction`, I gathered some information about the Postgresql database itself,
and how I suggest to install it (multi-platform, without admin/root privileges).
Afterwards, I show you the suggested work-flow with ``rivus_db``

Under :doc:`reference`, you can find the detailed entity diagram and description of the scripts.

.. _rivus_db: https://github.com/lnksz/rivus_db
.. _rivus: https://github.com/tum-ens/rivus
.. _PostgreSQL: https://www.postgresql.org/

.. toctree::
   :maxdepth: 2

   overview
   introduction
   reference


