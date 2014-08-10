fs = require 'fs'
YAML = require 'yamljs'
sexprs = require './sexprs_logic'

s = fs.readFileSync 'sample.yaml', 'utf8'
o = YAML.parse s
console.log 'Yaml file has been parsed with no errors'
cond = o.condition
records = o.records
for r, i in records
 console.log "Record #{i}: #{sexprs.test cond, r}"

###
test = sexprs.compile cond
for r in records
 console.log r, test r
###
