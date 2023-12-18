# simply-ogr

Utility script for transfering table data from and to ogr formats, and to keep processes in place organised and understandable.

## Prerequisites

You'll need a Linux command line with ogr2ogr and jq installed.

```shell
apt install gdal-bin jq
```

Check versions:

```shell 
ogr2ogr --version
GDAL 3.4.1, released 2021/12/27
```

```shell 
jq --version
jq-1.6
```
## Configuration

The script is a unique shell file calling a formatted `ogr2ogr` command. The command is piloted by configuration files in json list format that indicate the data source, destination, the sql request to be applied, the name of the destination layer, the layer creation options (-lco) and the geometry type. Each configuration file will have information for a list of tables to be transfered.

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
},
{
        "source_connexion": "PG:service=myservice",
        "destination_connexion": "/path/to/mycsvfile.csv",
        "sql": "myothersqlfile.sql",
        "destination_table": "mycsvfile",
        "lco": ["SEPARATOR=SPACE", "STRING_QUOTING=IF_NEEDED"],
        "geometry_type": "POINTZ"
}]
```

The tool is thought to be a way of managing multiple data transfers, without intoducing any new logic or complication. In a context where different needs and processes need to cohabitate, it helps to keep a certain order and granularity with the "process-specific" configuration. Capabilities are potentially the same as _ogr_. Basic knowledge of _ogr2ogr_ are necessary to create correctly the configuration files. 

It's important to note that **the order in which each block is written is important**. The configuration is read from top to bottom, so the first transfer happens before the second etc. A chained data update would need to be written in its 'update order' (first transfer before the second etc.).

## Organisation

Keeping things simple and kind of tidy is a big part of the motivation for this. Most data transfers require rather simple "transformations", making `sql` usually sufficient. Combining data from different sources being out of the scope here. Also, this allows to keep the transfer logic and configuration out of databases (e.g. views), so nothing could be lost by changes on databases that you don't manage. The recommanded way of organising is to have a configuration file by "process" but the granularity is let to the user to decide. Directories can be as it pleases, as long as paths are correctly defined, written and permissions given. Example given below:

        ├── process1  
        │   ├── myconfiguration1.json  
        │   └── mysql.sql  
        ├── process2  
        │   ├── mymorecomplexconfiguration.json  
        │   ├── request1.sql  
        │   ├── request2.sql  
        │   ├── request3.sql 
        │   ├── request4.sql  
        │   ├── request5.sql  
        │   ├── request6.sql  
        │   └── request7.sql 
        ├── process3  
        │   ├── subdirectory
        │   |    └── withdirectories.json
        │   └── requests
        │        ├── nestedrequest1.json
        │        ├── nestedrequest2.json
        │        └── nestedrequest3.json
        ├── you_get_the_gist

This is purely a matter of choice, as long as you're happy with it and communicate/document.

## Running

Once our configuration file is ready, let's call it `myconf.json`, the transfers can be started with

```shell
./simply-ogr.sh -c myconf.json
```

Where `-c` is the only parameter (with the help `-h`) requiring the path to the desired configuration file.

You can `cron` you different processes like any other, and log wherever and however you want.

## Thoughts

This is absolutely not an attempt at rewriting an ETL. The aim is to do simple things with simple tools, without introducing blackboxes or convoluted softwares. Self documentation is also part of the reasonning; listing the configuration files gives the list of processes, and any transfer is documented by its sql request. Things become more complex when a large number of similar transfers need to be configured (e.g. the same request but with varying filter) and configuration files can't realistically be created by hand. Template tools like [jinja](https://jinja.palletsprojects.com/en/3.1.x/) might come handy in this case.


