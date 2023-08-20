#!/usr/bin/env python

import datetime
import json
import locale
import subprocess
import codecs
from html import escape
import itertools

months = ['Jan', 'Feb', 'Apr', 'Mar', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
max_len = 68
cal_sep_len = 2
cal_indent_line = 24
time_len = 12
schedule_max_len = max_len - cal_indent_line
cal_indent_line += cal_sep_len

data = {}

today = datetime.date.today().strftime("%Y-%m-%d")

cal_output = subprocess.check_output("khal calendar now week", shell=True)
cal_output = cal_output.decode("utf-8")
output = subprocess.check_output("khal list now week", shell=True)
output = output.decode("utf-8")

cal_lines = []
lines = cal_output.split("\n")
month_counter = 0
for line in lines:
    clean_line = escape(line).split("     ")[0]
    if len(clean_line) == 0:
        continue
    if 'Mo Tu We' in clean_line:
        clean_line = "\n<b>"+clean_line+"</b>"
    if clean_line[:3] in months:
        month_counter += 1
    if month_counter >= 4:
        continue
    cal_lines.append(clean_line)

new_lines = []
lines = output.split("\n")
for line in lines:
    clean_line = escape(line).split(" ::")[0]
    if len(clean_line) and not clean_line[0] in ['0', '1', '2']:
        clean_line = "<b>"+clean_line+"</b>"
    if len(clean_line) > schedule_max_len:
        new_lines.append(clean_line[:schedule_max_len])
        rest = clean_line[schedule_max_len:]
        chunks = [rest[i:i+schedule_max_len-time_len] for i in range(0, len(rest), schedule_max_len-time_len)]
        chunks = [" "*time_len + chunk.strip() for chunk in chunks]
        new_lines.extend(chunks)
    else:
        new_lines.append(clean_line)

out_lines = []
cal_sep = " " * cal_sep_len
cal_indent = " " * cal_indent_line

for cal_line, new_line in itertools.zip_longest(cal_lines, new_lines):
    if cal_line:
        out_line = f'{cal_line}{cal_sep}{new_line or ""}'
    else:
        out_line = f'{cal_indent}{new_line or ""}'
    out_lines.append(out_line)
output = "\n".join(out_lines).strip()

locale.setlocale(locale.LC_TIME, "en_GB.utf8")
mytime = datetime.datetime.now().strftime("%H:%M")
mydate = datetime.datetime.now().strftime("%d/%m/%Y %a")
if today in output:
    data['text'] = f"{mydate}  {mytime}"
else:
    data['text'] = f"{mydate}  {mytime}"

data['tooltip'] = output

print(json.dumps(data), flush=True)
