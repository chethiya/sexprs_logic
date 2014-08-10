fs = require 'fs'
YAML = require 'yamljs'
sexprs = require './sexprs_logic'

s = fs.readFileSync 'sample.yaml', 'utf8'
o = YAML.parse s
#console.log JSON.stringify o
console.log 'Yaml file has been parsed with no errors'
cond = o.condition
records = o.records
test = sexprs.compile cond
#console.log test.toString()
for r, i in records
 console.log "Record #{i} - test: #{sexprs.test cond, r}, compile -  #{test r}"
