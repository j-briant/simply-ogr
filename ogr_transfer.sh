#!/usr/bin/bash

# TRANSFERT DATA 

jq -c '.[]' /etc/ogr_transfer/conf.json | while read i; do
	ogr2ogr PG:dbname=gc_transfert $(jq -r '.source_connexion' <<< "$i") \
		-sql @/etc/ogr_transfer/$(jq -r '.sql' <<< "$i") \
		-oo LIST_ALL_TABLES=YES -oo SCHEMAS=$(jq -r '.source_schema' <<< "$i") \
		-lco SCHEMA=$(jq -r '.destination_schema' <<< "$i") -lco OVERWRITE=YES \
		--config PG_USE_COPY YES --config OGR_TRUNCATE YES \
		-nln $(jq -r '.destination_table' <<< "$i")
done