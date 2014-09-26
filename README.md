# CouchDB Extra Scripts

Some experiments on CouchDB improvment scripts.

- Metadata relevant code
- Sync CouchDB to ElasticSearch
- Dedicate a history db to each db to keep all revision
- Master-master replication setup
- Define the "cluster" databases via arguments or from etcd

I should elaborate more...

## Usage

### Install

    # apt-get install ruby
    # gem install couchdb-extras

### CouchDB to ElasticSearch

This will keep sending creations, updates and deletes of all databases to elasticsearch, using the database name as index name and metadata.type as index type.

    $ couchdb2elasticsearch http://localhost:5984 http://localhost:9200

### CouchDB to history

Will save each revision of a document in a database as a separate document in another database with same name but suffixed with "\_history":

    $ couchdb2history http://localhost:5984

This can also run on multiple servers:

    $ couchdb2history http://localhost:5984 http://localhost:5985 http://localhost:5986

### CouchDB to CouchDB

Setup master-master replication on for each database for each server:

    $ couchdb2couchdb http://localhost:5984 http://localhost:5985 http://localhost:5986

### Infinite run

Workaround some problems I have runing ruby scripts for too long, will spawn, kill and loop:

    $ infinite-run your command here with arguments
    $ TIME_SPAN=3600 infinite-run your command here with arguments # let run of an hour, default value

## License

MIT

