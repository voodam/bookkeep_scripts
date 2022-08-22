#!/usr/bin/env python3

import sys
import re
from datetime import datetime
from decimal import Decimal
from openpyxl import load_workbook
import json
from jsoncomment import JsonComment
json_comment = JsonComment(json)

_, xslx = sys.argv
expences_sheet = load_workbook(filename = xslx).worksheets[1]
with open("categories.json") as f:
  default_categories = json_comment.load(f)

def get_target(row):
  target = row[5].value
  target = re.sub("^გადახდა - ", "", target) # "Payment - "
  target = re.sub(" \d+\.\d{2} GEL \d{2}.\d{2}.\d{4}$", "", target)
  if target == "Personal Transfer.":
    beneficiary_name = row[6].value
    beneficiary_acc_num = row[7].value
    target = f"Personal transfer to {beneficiary_name} [{beneficiary_acc_num}]"
  return target

def get_defaults(target):
  account = "u"
  if target in default_categories:
    category = default_categories[target]
    if isinstance(category, list):
      category, account = category
  else:
    category = "unknown"
  return category, account

data = []
iter = expences_sheet.iter_rows()
next(iter) # skip title
for row in iter:
  if not row[2].value:
    continue # skip incomes
  target = get_target(row)
  date = row[0].value
  amount = row[2].value
  category, account = get_defaults(target)
  data.append({"target": target, "date": date, "amount": amount, "category": category, "account": account})

if data:
  strings = map(lambda d: f"""('{d["target"]}', '{d["date"]}', {d['amount']}, '{d["category"]}', '{d["account"]}')""", data)
  values = ",\n".join(strings)
  print(f"INSERT OR IGNORE INTO ledger(target, date, amount, category, account) VALUES\n{values};")
