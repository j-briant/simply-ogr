#!/usr/bin/bash

# TRANSFERT DATA 

usage="$(basename "$0") [-h] [-c CONF]
Move data around in different formats (OGR compatible), using a configuration file to allow multiple instances:
        -h show this help text
        -c configuration file path"

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
# If the sql value is empty make the sql option null
if [ ! $(jq -r '.sql' <<< "$i") ]; then
	sql_option=
else
	sql_option="-sql @$(jq -r '.sql' <<< "$i")"
fi

# Check if LAYER CREATION OPTIONS (lco) are present
if [ ! "$(jq 'select(.lco != null).lco' <<< "$i")" ]; then
	lco_option=
else
	for o in $(jq -r 'select(.lco != null).lco|.[]' <<< "$i"); do
		lco_option=$lco_option" -lco $o"
	done
fi

echo $lco_option

echo Transfering $(jq -r '.sql' <<< "$i")...
su - postgres -c "ogr2ogr -overwrite -preserve_fid -a_srs EPSG:2056 \
			'$(jq -r '.destination_connexion' <<< "$i")' '$(jq -r '.source_connexion' <<< "$i")' \
			$sql_option \
			-nln '$(jq -r '.destination_table' <<< "$i")' \
			-nlt '$(jq -r '.geometry_type' <<< "$i")' $lco_option"
done
