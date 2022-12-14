#!/usr/bin/env bash

. credo.sh

CUR="${CUR:-GEL}"
BANK="${BANK:-Credo}"
STAT_SRC_FILE="${STAT_SRC_FILE:-data/stat.xlsx}"

DB_NAME="data/ledger.db"
STAT_SQL="data/stat.sql"

if [[ "$@" == *"backup"* ]] || [[ "$@" == "" ]]; then
  mv "${DB_NAME}.bkp" "${DB_NAME}.bkp.old"
  cp "$DB_NAME" "${DB_NAME}.bkp"
  echo Backup created
fi

if [[ "$@" == *"download"* ]] || [[ "$@" == "" ]]; then
  download_credo_SRC_FILE "$CUR" > "$STAT_SRC_FILE"
  if [[ -f "$STAT_SRC_FILE" ]] && (( $(stat -c "%s" "$STAT_SRC_FILE") > 64 )); then
    echo Statement downloaded
  else
    echo Error while downloading statement
    exit 1
  fi
fi

if [[ "$@" == *"dump"* ]] || [[ "$@" == "" ]]; then
  ./import.py "$BANK" "$STAT_SRC_FILE" > "$STAT_SQL"
  echo "$STAT_SQL" created
fi

if [[ "$@" == *"import"* ]] || [[ "$@" == "" ]]; then
  sqlite3 "$DB_NAME" < "$STAT_SQL"
  echo "$STAT_SQL" imported
fi
