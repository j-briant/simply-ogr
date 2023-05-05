# ogr-transfer

Utility script for transfering table data from and to ogr formats, and to keep processes in place organised and understandable.

## Configuration

The script is a unique shell file calling a formatted `ogr2ogr` command. The command is piloted by configuration files that indicate the data source, destination, the sql request to be applied, the name of the destination layer and the geometry type. Each configuration file will have information for a list of tables to be transfered, sources and destinations can be the same but that's a rule of thumb.

The format is as follow:

```json
[{
        "source_connexion": "PG:service=myservice",
        "destination_connexion": "PG:dbname=database1",
        "sql": "/path/to/sqlfile.sql",
        "destination_table": "pgschema.pgtable",
        "geometry_type": "LINESTRING"
},
{
        "source_connexion": "/path/to/myshapefile.shp",
        "destination_connexion": "PG:dbname=database2",
        "sql": "mysqlfile.sql",
        "destination_table": "anotherschema.anothertable",
        "geometry_type": "POINTZ"
}]
```

The tool is thought to be a way of managing multiple data transfers, without intoducing any new logic or complication. In a context where different needs and processes need to cohabitate, it helps to keep a certain order and granularity with the "process-specific" configuration. Capabilities are potentially the same as _ogr_. Basic knowledge of _ogr2ogr_ are necessary to create correctly the configuration files. 

## Organisation

Keeping things simple and kind of tidy is a big part of the motivation for this. Most data transfers require rather simple "transformations", making `sql` usually sufficient. Combining data from different sources being out of the scope here. Also, this allows to keep the transfer logic and configuration out of databases (e.g. views), so nothing could by lost by changes on databases that you don't manage (in unstable environments). The recommanded way of organising is to have a configuration file by "process" but the granularity is let to the user to decide. Directories can be as it pleases, as long as paths are correctly 

## Running

Once our configuration file is ready, let's call it `myconf.json`, the transfers can be started with

```shell
./ogr_transfer.sh -c myconf.json
```

Where `-c` is the only parameter (with the help `-h`) requiring the path to the desired configuration file.

If multiple processes require to transfer data, you can multiply the calls with a different configuration file each time.
