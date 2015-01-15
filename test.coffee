
Engine = require './genetix'

t = new Engine 100, 10, 15000, 0.15, 0.8
t.setRandomSolution((cb) ->
  rand = (min, max) ->
    Math.random() * (max - min) + min;

  cb({ a: rand(0.8, 1), b: rand(0.8, 1) })
)
t.setFitness (solution, cb) -> 
  setTimeout () ->
    cb(1/(solution.a + solution.b))
  , 10

t.setCrossover((s1, s2) ->
  child = {}

  if Math.random() > 0.5
    child.a = s1.a
    child.b = s2.b
  else
    child.a = s1.b
    child.b = s2.a

  child
)

t.setStop (solution) ->
  console.log solution
  if solution.solution > 6000
    return true

  return false

t.setMutator((solution) ->

  if Math.random() < 0.25
    solution.a *= 1.005
    solution.b *= 0.995
  else if Math.random() < 0.5
    solution.a *= 0.995
    solution.b *= 1.005
  else if Math.random() < 0.75
    solution.a *= 0.995
    solution.b *= 0.995
  else
    solution.a *= 1.005
    solution.b *= 1.005


  solution
)

t.start((result) ->
  console.log result
)