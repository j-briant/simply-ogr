#!/usr/bin/bash

# TRANSFERT DATA 

usage="$(basename "$0") [-h] [-c CONF] [-w WHERE]
Move data around in different formats (OGR compatible), using a configuration file to allow multiple instances:
        -h show this help text
        -c configuration file path
	-w condition to be passed to filter data"

die() {
  printf '%s\n' "$1" >&2
  exit 1
}

# Get parameters
while :; do
        case $1 in
                -h|-\?|--help) 
                        echo "$usage" 
                        exit;;
                -c|--configuration) 
                        if [ "$2" ]; then 
                                configuration=$2 
                                shift 
                        else 
                                die 'ERROR: "--configuration" requires a non-empty option argument.'
                        fi;;
                --)
                        shift
                        break
                        ;;
                -?*)
                        printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
                        ;;
                *)
                        break
        esac
        shift
done

# Make parameter mandatory
if [ ! ${configuration} ]; then
  echo "argument -c must be provided"
  echo "$usage" >&2; exit 1
fi

# Make the transfer
jq -c '.[]' $configuration | while read i; do
echo Transfering $(jq -r '.sql' <<< "$i")...
su - postgres -c "ogr2ogr -overwrite -preserve_fid -a_srs EPSG:2056 \
			$(jq -r '.destination_connexion' <<< "$i") $(jq -r '.source_connexion' <<< "$i") \
			-sql @$(jq -r '.sql' <<< "$i") \
			-nln $(jq -r '.destination_table' <<< "$i") \
			-nlt $(jq -r '.geometry_type' <<< "$i")"
done
