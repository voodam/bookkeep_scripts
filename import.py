#!/usr/bin/env python3

import sys
import os
import re
import json
from jsoncomment import JsonComment
json_comment = JsonComment(json)
from source import *

with open("categories.json") as f:
  default_categories = json_comment.load(f)

def get_defaults(target):
  account = "u"
  for regexp in default_categories.keys():
    if re.search(regexp, target, re.IGNORECASE):
      category = default_categories[regexp]
      if isinstance(category, list):
        category, account = category
      break
  else:
    category = "unknown"
  return category, account

_, bankname, filename = sys.argv
ignored_ibans = os.environ.get("IGNORE_IBANS")
ignored_ibans = ignored_ibans.split(",") if ignored_ibans else []

source = DataSource.create(bankname, filename, ignored_ibans)
iban = source.get_iban()
currency = source.get_currency()
rows = source.get_rows()
aug_rows = map(lambda r: AugmentedRow(r.target, r.date, r.amount, *get_defaults(r.target)), rows)

if aug_rows:
  strings = map(lambda r: f"""('{r.target}', '{r.date}', {r.amount}, '{r.category}', '{r.account}', '{iban}', '{currency}')""", aug_rows)
  values = ",\n".join(strings)
  print(f"INSERT OR IGNORE INTO ledger(target, date, amount, category, account, iban, currency) VALUES\n{values};")
