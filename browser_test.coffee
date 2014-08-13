window.test = ->
 N = 1000000
 cond = o.condition
 records = o.records
 test = SExprsLogic.compile cond
 test2 = SExprsLogic.compileByBind cond
#console.log test.toString()
#console.log cond[3][2] #college regex
#console.log records[2] #college record

 console.log "Testing compile"
 d = new Date()
 res = ''
 for i in [0...N]
  res = '' + test records[i%records.length]
 console.log "Test ans: #{res}, time: #{(new Date() - d) / 1000}sec"

 console.log "Testing compile by bind"
 d = new Date()
 res = ''
 for i in [0...N]
  res = '' + test2 records[i%records.length]
 console.log "Test ans: #{res}, time: #{(new Date() - d) / 1000}sec"

 console.log "Testing test"
 d = new Date()
 res = ''
 for i in [0...N]
  res = '' + SExprsLogic.test cond, records[i%records.length]
 console.log "Test ans: #{res}, time: #{(new Date() - d) / 1000}sec"

 return

yaml = """
 condition:
  - OR
  -
   meta.dataset: employee
  -
   one.two.three.four.five: 5
  -
   date:
    comp: is
    val: 2014-08-12
  -
   - AND
   -
    - OR
    -
     name: chethiya
     age:
      comp: gte
      val: 27
    -
     name:
      comp: is
      val: gangani
    -
     address:
      comp: regex
      val: '^[0-9]+'
    -
     age:
      comp: lt
      val: 27
   -
    - OR
    -
     school:
      comp: regex
      val: '^".*[Cc]ollege"$'
    -
     school: Devi Balika

 records:
  -
   name: chethiya
   age: 27
   address: 23A, Ella way, Kurunegala
   school: Maliyadeva College
  -
   name: gangani
   age: 26
   address: homagama
   school: Devi Balika
  -
   name: tharaka
   age: 33
   address:  02342, Oman
   school: '"Maliyadeva College"'
  - {}
  -
   meta:
    dataset: 'employee'
  -
   one: 1
   two: 1
  -
   one:
    two:
     three:
      four:
       five: 5
  -
   date: 2014-08-12
  -
   date: 2014-08-13
"""

o = YAML.parse yaml
