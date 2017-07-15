#!/bin/bash

# Execute in rivus_db/sql/
# Extends the raw exported DDL scripts.
# Results in ribus_db/sql/
# 	- data_model_table_create.sql
# 	- data_model_table_drop.sql
# 	- db_create.sql
# 	- db_drop.sql

# Add extension to create method
echo -e "CREATE EXTENSION IF NOT EXISTS postgis;\n" > data_model_table_create.sql
cat ./staruml_export/data_model_table_create.sql >> data_model_table_create.sql

# Add extension to drop method
echo -e "DROP EXTENSION IF EXISTS postgis CASCADE;\n" > data_model_table_drop.sql
cat ./staruml_export/data_model_table_drop.sql >> data_model_table_drop.sql

# Mirror files which do not need extension
cat ./staruml_export/db_drop.sql > db_drop.sql
cat ./staruml_export/db_create.sql > db_create.sql

# Create rivus database and its contents locally.
# This supposes that there is not rivus db in postgres
psql -h localhost -U postgres -f ./db_create.sql
psql -h localhost -U postgres -f ./data_model_table_create.sql rivus