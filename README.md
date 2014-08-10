S-Expression Logic
==================

This is a node library to evaluate data objects using an s-expression based logic reresented in YAML (JSON). When there is a stream of data objects to evaluate against one logic, you can use `compile(condition)` function to generate `test(obj)` providing an efficient way of evaluation.

#API

`test(condition, obj)`

 - returns `true` or `false` based on whether `obj` satisfies the logic in `condition`

`compile(condition)`

 - returns a dynamically generated function `test(obj)` to evalute any `obj` with the logic in `condition`

#How to use

####Here is an s-expression logic example in YAML

```yaml
condition:
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
    val: '[Cc]ollege'
  -
   school: Devi Balika
 -
  meta.dataset: employee
```

#### Evaluating objects against above logic

If we have following records to be evaluated against above logic:

```yaml
records:
 -
  name: chethiya
  age: 27
  address: 23A, Ella way, Kurunegala
  school: Maliyadeva College
  meta:
   dataset: 'employee'
 -
  name: gangani
  age: 26
  address: homagama
  school: Devi Balika
 -
  name: tharaka
  age: 33
  address:  02342, Oman
  school: Maliyadeva College
```

We can test records using the logic as follows:


```coffeescript
SExprsLogic = require 'sexprs_logic'
for r, i in records
 console.log "Record #{i}: #{SExprsLogic.test condition, r}"
```

Furthermore if there is a long list of objects to be evaluated with same logic there is an efficient way of testing :

```coffeescript
test = SExprsLogic.compile condition
for r, i in records
 console.log "Record #{i} using compiled : #{test r}"
```
