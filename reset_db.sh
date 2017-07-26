#!/bin/bash
pushd .
cd ./sql/
./_purge_rivus.sh && ./create_from_staruml.sh
popd