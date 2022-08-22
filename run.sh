#!/usr/bin/env bash

DB_NAME="data/ledger.db"
STAT_XLSX="data/stat.xlsx"
STAT_SQL="data/stat.sql"

get_credo_token() {
  local op_id=$(curl -sk 'https://mycredo.ge:8443/api/Auth/Initiate' \
    -H 'content-type: application/json' \
    --data-raw $"{\"username\":\"$CREDO_LOGIN\",\"password\":\"$CREDO_PWD\",\"channel\":508,\"loggedInWith\":\"4\",\"WebDevicePublicId\":\"ffc8fce4-5cbc-4a3a-b814-a8c33b16c85b\",\"deviceName\":\"Chrome\"}" |
    jq -r .data.operationId)

  curl -sk 'https://mycredo.ge:8443/api/Auth/confirm' \
    -H 'content-type: application/json' \
    --data-raw "{\"OperationId\":\"$op_id\",\"TraceId\":\"VM8B4VMA0Z/UVWt236QFj2bjLgUZYN9nNXRmprBG4pU=\"}" |
    jq -r .data.operationData.token
}

if [[ "$@" == *"backup"* ]] || [[ "$@" == "" ]]; then
  mv "${DB_NAME}.bkp" "${DB_NAME}.bkp.old"
  cp "$DB_NAME" "${DB_NAME}.bkp"
  echo Backup created
fi

if [[ "$@" == *"download"* ]] || [[ "$@" == "" ]]; then
  curl -sk 'https://mycredo.ge:8443/graphql' \
    -H "authorization: Bearer $(get_credo_token)" \
    -H 'content-type: application/json' \
    --data-raw "{\"variables\":{\"exportToExcel\":{\"accountNumber\":\"$CREDO_ACC\",\"startDate\":\"20100101\",\"endDate\":\"20500101\",\"currency\":\"GEL\"}},\"query\":\"mutation(\$exportToExcel:ExportToExcelInputGType!){exportToExcel(exportToExcel:\$exportToExcel)}\"}" |
    jq -r .data.exportToExcel | base64 -d > "$STAT_XLSX"

  if [[ -f "$STAT_XLSX" ]] && (( $(stat -c "%s" "$STAT_XLSX") > 64 )); then
    echo Statement downloaded
  else
    echo Error while downloading statement
    exit 1
  fi
fi

if [[ "$@" == *"dump"* ]] || [[ "$@" == "" ]]; then
  ./import.py "$STAT_XLSX" > "$STAT_SQL"
  echo "$STAT_SQL" created
fi

if [[ "$@" == *"import"* ]] || [[ "$@" == "" ]]; then
  sqlite3 "$DB_NAME" < "$STAT_SQL"
  echo "$STAT_SQL" imported
fi
