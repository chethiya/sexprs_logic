console.log 'Running compiled test'
fs = require 'fs'
YAML = require 'yamljs'
sexprs = require './sexprs_logic'

s = fs.readFileSync 'sample.yaml', 'utf8'
o = YAML.parse s
#console.log JSON.stringify o
console.log 'Yaml file has been parsed with no errors'
cond = o.condition
records = o.records
res = ''
test = sexprs.compile cond
for i in [0...1000000]
 res = test records[i%records.length]
console.log res
