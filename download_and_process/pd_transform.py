#this script transforms JSON object downloaded from primedice.com to csv
#based on http://stackoverflow.com/questions/1871524/convert-from-json-to-csv-using-python
import csv, json, sys

input = sys.stdin
data = json.load(input)
input.close()

if data:

	output = csv.writer(sys.stdout)

	#output.writerow(data[0].keys())  # header row

	for row in data:
		output.writerow(row.values())
