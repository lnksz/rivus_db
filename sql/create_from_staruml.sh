#!/bin/bash

# Execute in rivus_db/sql/
# Extends the raw exported DDL scripts.
# Results in ribus_db/sql/
# 	- data_model_table_create.sql
# 	- data_model_table_drop.sql
# 	- db_create.sql
# 	- db_drop.sql
echo "$1"
if [ $# -eq 1 ] && [ $1 = "extend" ] ; then
	EXTEND=true
	CREATE=false
else
	EXTEND=true
	CREATE=true
fi

if [ "$EXTEND" = true ] ; then
	echo "Extending raw staruml sql scripts from ./staruml_export to . "
	# Add extension to create method
	echo -e "CREATE EXTENSION IF NOT EXISTS postgis;\n" > data_model_table_create.sql
	# echo -e "CREATE EXTENSION IF NOT EXISTS tablefunc;\n" >> data_model_table_create.sql
	cat ./staruml_export/data_model_table_create.sql >> data_model_table_create.sql

	# Add extension to drop method
	echo -e "DROP EXTENSION IF EXISTS postgis CASCADE;\n" > data_model_table_drop.sql
	# echo -e "DROP EXTENSION IF EXISTS tablefunc CASCADE;\n" >> data_model_table_drop.sql
	cat ./staruml_export/data_model_table_drop.sql >> data_model_table_drop.sql

	# Drop encoding specification if present
	cat ./staruml_export/db_create.sql > db_create.sql
	sed -i "/ENCODING = 'UTF8'/d" ./db_create.sql

	# Mirror files which do not need extension
	cat ./staruml_export/db_drop.sql > db_drop.sql
fi

if [ "$CREATE" = true ] ; then
	# Create rivus database and its contents locally.
	# This supposes that there is not rivus db in postgres
	echo "Executing sql scripts in . "
	psql -h localhost -U postgres -f ./db_create.sql
	psql -h localhost -U postgres -f ./data_model_table_create.sql rivus
fi

read -p "Process finished, press [return] to confirm."