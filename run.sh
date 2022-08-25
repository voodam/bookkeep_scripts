#!/usr/bin/env bash

. credo.sh

CUR="${CUR:-GEL}"

DB_NAME="data/ledger.db"
STAT_XLSX="data/stat.xlsx"
STAT_SQL="data/stat.sql"

if [[ "$@" == *"backup"* ]] || [[ "$@" == "" ]]; then
  mv "${DB_NAME}.bkp" "${DB_NAME}.bkp.old"
  cp "$DB_NAME" "${DB_NAME}.bkp"
  echo Backup created
fi

if [[ "$@" == *"download"* ]] || [[ "$@" == "" ]]; then
  download_credo_xlsx "$CUR" > "$STAT_XLSX"
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
