#!/bin/bash
psql -h localhost -U postgres -f ./data_model_table_drop.sql rivus
psql -h localhost -U postgres -f ./db_drop.sql
read -p "Process finished, press [return] to confirm."