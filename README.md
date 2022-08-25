### Description
Quick-and-dirty script for collecting personal expenses statistics from Georgian banks.

### Requirements
* python3
* sqlite3
* Optionally: handy DB client (dbeaver, for example)

### Usage
#### First usage
* ```sqlite3 data/ledger.db < table.sql```
* Rename `categories.json.example` to `categories.json` and edit

#### Exporting Credo Bank statement
* Run script:
```
export CREDO_LOGIN=XXX
export CREDO_PWD=YYY
export CREDO_ACC=GE...
./run.sh
```
* Run DB client and edit rows `WHERE category = 'unknown' OR account = 'u'`

If you change something from primary key (target, date or amount), entry will be duplicated.
