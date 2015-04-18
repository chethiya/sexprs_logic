#compile cond s-expression to a test function
compile = (cond) ->
 st = ''
 gc = 0
 dfs = (l, cond, tab) ->
  oper = undefined
  isMap = off
  if (typeof cond is 'object') and (cond instanceof Array)
   oper = cond[0].trim().toLowerCase()
  else if typeof cond is 'object'
   oper = 'and'
   isMap = on
  else
   throw new Error "invalid condition"

  if oper isnt 'and' and oper isnt 'or' and oper isnt 'not'
   throw new Error "Invalid binary operation: #{cond[0]}"
  res = off
  if oper is 'and'
   res = on
  else
   res = off
  st += "#{tab}l#{l} = #{res};\n"
  if isMap is off
   for i in [1...cond.length]
    st += "#{tab}if (l#{l} == #{res}) {\n"
    dfs l+1, cond[i], tab + ' '
    st += "#{tab} l#{l} = l#{l+1};\n"
    st += "#{tab}}\n"
  else
   for k, v of cond
    st += "#{tab}if (l#{l} == #{res}) {\n"
    # leaf step
    TABL = tab + ' '
    keys = k.split '.'
    st += "#{TABL}val = void 0;\n"
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
    if (typeof v is 'string') or (typeof v is 'number')
     comp = 'is'
     val = v
    else if (typeof v is 'object') and (v instanceof RegExp)
     comp = 'regex'
     val = v
    else if (typeof v is 'object') and (v instanceof Date)
     comp = 'is'
     val = v
    else if (typeof v is 'object') and not (v instanceof Array)
     comp = v.comp?.trim().toLowerCase()
     val = v.val

    vst = ''
    if typeof val is 'string'
     val = (val.replace /\\/g, '\\\\').replace /"/g, "\\\""
     vst = "var temp = \"#{val}\";\n"
    else if typeof val is 'number'
     vst = "var temp = #{val};\n"
    else if (typeof val is 'object') and (val instanceof Date)
     vst = "var temp = new Date(#{val.getTime()});\n"
    else
     vst = "var temp = #{val};\n"

    #lit cast
    if v.type?
     if v.type is 'date'
      st += "#{TABL}if (lit !== null){ \n"
      st += "#{TABL} lit = new Date(lit);\n"
      st += "#{TABL}}\n"
     else if v.type is 'int'
      st += "#{TABL}if (lit !== null){ \n"
      st += "#{TABL} lit = parseInt(lit);\n"
      st += "#{TABL}}\n"
     else
      throw new Error "Unknown type #{v.type}"

    #global cast
    if comp is 'regex'
     vst += "var global#{gc} = new RegExp(temp);\n"
    else
     if v.type?
      if v.type is 'date'
       vst += "var global#{gc} = new Date(temp);\n"
      else if v.type is 'int'
       vst += "var global#{gc} = parseInt(temp);\n"
     else
      vst += "var global#{gc} = temp;\n"
    st = vst + st

    if comp is 'is'
     if v.type is 'date' or val instanceof Date
      st += "#{TABL}l#{l+1} = (lit instanceof Date && global#{gc} instanceof Date) ? lit.getTime() == global#{gc}.getTime() : false;\n"
     else
      st += "#{TABL}l#{l+1} = lit == global#{gc};\n"
    else if comp is 'gte'
     st += "#{TABL}l#{l+1} = lit >= global#{gc};\n"
    else if comp is 'gt'
     st += "#{TABL}l#{l+1} = lit > global#{gc};\n"
    else if comp is 'lte'
     st += "#{TABL}l#{l+1} = lit <= global#{gc};\n"
    else if comp is'lt'
     st += "#{TABL}l#{l+1} = lit < global#{gc};\n"
    else if comp is 'regex'
     st += "#{TABL}l#{l+1} = global#{gc}.test(lit);\n"
    else
     throw new Error "Invalid comparator: #{comp}"


    st += "#{TABL}l#{l} = l#{l+1};\n"
    gc++
    # leaf step
    st += "#{tab}}\n"
  if l is 0
   st += "#{tab}return l0;\n"
 st += "return function(obj) {\n"
 dfs 0, cond, ' '
 st += "}\n"
 return (new Function '', st)()

#compile the condition by binding condition functions
compileByBind = (cond) ->
 cast = (type, val) ->
  return val unless type?
  if type is 'date'
   return new Date val
  else if type is 'int'
   return parseInt val
  else
   return val
 keyVal = (obj, keys) ->
  kval = obj
  kval = kval?[k] for k in keys
  return kval

 #Operations def
 oper_is = (obj) ->
  kval = cast @type, keyVal obj, @keys
  if @val instanceof Date and kval instanceof Date
   return @val.getTime() is kval.getTime()
  return kval is @val

 oper_gte = (obj) ->
  kval = cast @type, keyVal obj, @keys
  return kval >= @val


 oper_gt = (obj) ->
  kval = cast @type, keyVal obj, @keys
  return kval > @val


 oper_lte = (obj) ->
  kval = cast @type, keyVal obj, @keys
  return kval <= @val

 oper_lt = (obj) ->
  kval = cast @type, keyVal obj, @keys
  return kval < @val


 oper_regex = (obj) ->
  kval = cast @type, keyVal obj, @keys
  return @val.test kval
 #Operations def

 oper_andornot = (obj) ->
  res = off
  res = on if @oper is 'and'
  if @oper is 'not'
   res = not @funcs[0] obj if @funcs.length > 0
  else
   for f, i in @funcs
    res = f obj
    break if (@oper is 'and' and res is off) or (@oper is 'or' and res is on)
  return res

 createFunc = (cond) ->
  if (typeof cond is 'object') and (cond instanceof Array)
   oper = cond[0]?.trim().toLowerCase()
   if oper isnt 'and' and oper isnt 'or' and oper isnt 'not'
    throw new Error "Invalid binary operation: #{cond[0]}"
   context =
    oper: oper
    funcs: []
   context.funcs.push createFunc cond[i] for i in [1...cond.length]
   return oper_andornot.bind context
  else if typeof cond is 'object'
   context =
    oper: 'and'
    funcs: []
   for k, v of cond
    c =
     keys: []
     val: undefined
     type: undefined
    c.keys = k.split '.' if typeof k is 'string' and k.length > 0

    comp = undefined
    if typeof v is 'string' or typeof v is 'number' or typeof v is 'boolean'
     comp = 'is'
     c.val = v
    else if (typeof v is 'object') and (v instanceof RegExp)
     comp = 'regex'
     c.val = v
    else if (typeof v is 'object') and not (v instanceof Array)
     comp = v.comp?.trim().toLowerCase()
     c.val = v.val
     c.type = v.type if v.type?
    else
     throw new Error "Invalid comparison object"

    if comp is 'regex'
     c.val = new RegExp c.val
    else if c.type?
     if c.type is 'date'
      c.val = new Date c.val
     else if c.type is 'int'
      c.val = parseInt c.val

    if comp is 'is'
     context.funcs.push oper_is.bind c
    else if comp is 'gte'
     context.funcs.push oper_gte.bind c
    else if comp is 'gt'
     context.funcs.push oper_gt.bind c
    else if comp is 'lte'
     context.funcs.push oper_lte.bind c
    else if comp is 'lt'
     context.funcs.push oper_lt.bind c
    else if comp is 'regex'
     context.funcs.push oper_regex.bind c
    else
     throw new Error "Invalid operator: #{comp}"

   return oper_andornot.bind context
 return createFunc cond

#test obj against cond s-expression
test = (cond, obj) ->
 #console.log 'TEST'
 #console.log cond, obj
 if (typeof cond is 'object') and (cond instanceof Array)
  oper = cond[0].trim().toLowerCase()
  if oper isnt 'and' and oper isnt 'or' and oper isnt 'not'
   throw new Error "Invalid binary operation: #{cond[0]}"
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
   if typeof v is 'string' or typeof v is 'number' or typeof v is 'boolean'
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
    throw new Error "Invalid comparison object"

   #console.log "comp: #{comp}, Key literal: #{lit}, val: #{val}"

   if comp is 'is'
    if val instanceof Date and lit instanceof Date
     res = false if val.getTime() isnt lit.getTime()
    else
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
  throw new Error "Invalid condition"

exports?.compile = compile
exports?.compileByBind = compileByBind
exports?.test = test
window?.SExprsLogic =
 compile: compile
 compileByBind: compileByBind
 test: test
