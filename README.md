# ogr-transfer

Utility script for transfering table data from and to ogr formats.

## Configuration

The script is a unique shell file calling a formatted `ogr2ogr` command. For now it's thought to be working with PostgreSQL sources and destinations, further reflexions might come in the future. There is no destination database because for now all data is moved to a known database, might change in the future.

A single configuration JSON file contains the necessary parameters for indicating sources and destinations. The format is as follow:

```json
[{
        "source_connexion": "PG:service=my_service",
        "sql": "my_request.sql",
        "source_schema": "my_src_schema",
        "destination_schema": "my_dst_schema",
        "destination_table": "my_dst_table"
}]
```

The above configuration replicate data from the databse reached by connecting using the service `my_service`, formatted according to the sql request in the file `my_sql.sql`. The parameter `source_schema` is present in case there are duplicated table names in the source databse. Data will be moved to the existing schema `my_dst_schema`, in a table (existing or not) `my_dst_table`. 

A other table transfer can be added by adding an object to the list following the same rules.

**Move the config file `conf.json` under `/etc/ogr_transfer/conf.json` because it's hardcoded for now.**

## Running

Once the `conf.json` is at the correct place, you can run the script with 

```shell
$ ogr_transfer.sh
```
