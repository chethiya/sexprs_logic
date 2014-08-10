YAML = require 'yamljs'

#compile cond s-expression to a test function
compile = (cond) -> -> false

#test obj against cond s-expression
test = (cond, obj) ->
 #console.log 'TEST'
 #console.log cond, obj
 if (typeof cond is 'object') and (cond instanceof Array)
  oper = cond[0].trim().toLowerCase()
  if oper isnt 'and' and oper isnt 'or' and oper isnt 'not'
   throw "Invalid binary operation: #{cond[0]}"
  res = off
  if oper is 'and'
   res = on
  else
   res = off
  for i in [1...cond.length]
   if oper is 'and'
    res = res and test cond[i], obj
    break if res is off
   else if oper is 'or'
    res = res or test cond[i], obj
    break if oper is on
   else if oper is 'not'
    res = not test cond[i], obj
    break
  #console.log "RETURN: #{res}"
  return res
 else if typeof cond is 'object'
  res = on
  for k, v of cond
   keys = k.split '.'
   comp = lit = val = undefined
   lit = obj
   lit = lit?[key] for key in keys
   if typeof v is 'string'
    comp = 'is'
    val = v
   else if (typeof v is 'object') and not (v instanceof Array)
    comp = v.comp?.trim().toLowerCase()
    val = v.val
    if v.type? and lit? and val?
     if v.type is 'date'
      lit = new Date lit
      val = new Date val
     else if v.type is 'int'
      lit = parseInt lit
      val = parseInt val
   else
    throw "Invalid comparison object"

   #console.log "comp: #{comp}, Key literal: #{lit}, val: #{val}"

   if comp is 'is'
    res = false if lit isnt val
   else if comp is 'gte'
    res = false if lit < val
   else if comp is 'gt'
    res = false if lit <= val
   else if comp is 'lte'
    res = false if lit > val
   else if comp is'lt'
    res = false if lit >= val
   else if comp is 'regex'
    r = new RegExp val
    res = false if not r.test lit
   break if res is off
  #console.log "RETURN: #{res}"
  return res
 else
  throw "Invalid data"

exports.compile = compile
exports.test = test
