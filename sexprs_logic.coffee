#compile cond s-expression to a test function
compile = (cond) ->
 st = ''
 dfs = (l, cond) ->
  tab = ''
  tab += ' ' for i in [0...l]
  oper = undefined
  isMap = off
  if (typeof cond is 'object') and (cond instanceof Array)
   oper = cond[0].trim().toLowerCase()
  else if typeof cond is 'object'
   oper = 'and'
   isMap = on
  else
   throw "invalid condition"

  if oper isnt 'and' and oper isnt 'or' and oper isnt 'not'
   throw "Invalid binary operation: #{cond[0]}"
  res = off
  if oper is 'and'
   res = on
  else
   res = off
  st += "#{tab}l#{l} = #{res};\n"
  if isMap is off
   for i in [1...cond.length]
    st += "#{tab}if (l#{l} == #{res}) {\n"
    dfs l+1, cond[i]
    st += "#{tab}l#{l} = l#{l+1};\n"
    st += "#{tab}}\n"
  else
   for k, v of cond
    st += "#{tab}if (l#{l} == #{res}) {\n"
    #TODO leaf step
    TABL = tab + ' '
    keys = k.split '.'
    st += "#{TABL}lit = typeof obj !== \"undefined\" && obj !== null"
    key = ''
    for i in [0...keys.length-1]
     key += "." if key.length > 0
     key += keys[i]
     st += " ? obj.#{key} != null"
    if key.length is 0
     key = keys[0]
    else
     key += ".#{keys[keys.length-1]}"
    st += " ? obj.#{key} : void 0"
    st += " : void 0" for i in [0...keys.length-1]
    st += ";\n"

    comp = val = undefined
    if typeof v is 'string'
     comp = 'is'
     val = v
    else if (typeof v is 'object') and not (v instanceof Array)
     comp = v.comp?.trim().toLowerCase()
     val = v.val

    if typeof val is 'string'
     val = (val.replace /\\/g, '\\\\').replace /"/g, "\\\""
     st += "#{TABL}val = \"#{val}\";\n"
    else if typeof val is 'number'
     st += "#{TABL}val = #{val};\n"

    if v.type?
     if v.type is 'date'
      st += "#{TABL}if (lit !== null && val !== null){ \n"
      st += "#{TABL} lit = new Date(lit);\n"
      st += "#{TABL} val = new Date(val);\n"
      st += "#{TABL}}\n"
     else if v.type is 'int'
      st += "#{TABL}if (lit !== null && val !== null){ \n"
      st += "#{TABL} lit = parseInt(lit);\n"
      st += "#{TABL} val = parseInt(val);\n"
      st += "#{TABL}}\n"

    if comp is 'is'
     st += "#{TABL}l#{l+1} = lit == val;\n"
    else if comp is 'gte'
     st += "#{TABL}l#{l+1} = lit >= val;\n"
    else if comp is 'gt'
     st += "#{TABL}l#{l+1} = lit > val;\n"
    else if comp is 'lte'
     st += "#{TABL}l#{l+1} = lit <= val;\n"
    else if comp is'lt'
     st += "#{TABL}l#{l+1} = lit < val;\n"
    else if comp is 'regex'
     st += "#{TABL}val = new RegExp(val);\n"
     st += "#{TABL}l#{l+1} = val.test(lit);\n"

    # leaf step
    st += "#{tab}l#{l} = l#{l+1};\n"
    st += "#{tab}}\n"
  if l is 0
   st += "#{tab}return l0;"
 dfs 0, cond
 return new Function 'obj', st


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
   if typeof v is 'string' or typeof v is 'number'
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
  throw "Invalid condition"

exports?.compile = compile
exports?.test = test
window?.compile = compile
window?.test = test
