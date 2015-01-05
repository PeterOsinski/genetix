
Engine = require './genetix'

t = new Engine 20, 5, 100, 0.2, 0.8
t.setRandomSolution((cb) ->
  rand = (min, max) ->
    Math.random() * (max - min) + min;

  cb({ a: rand(0.8, 1), b: rand(0.8, 1) })
)
t.setFitness((solution, cb) -> cb(1/(solution.a + solution.b)))
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

t.setMutator((solution) ->

  solution.a = 0.05 * Math.random()
  solution.b = 0.05 * Math.random()

  solution
)

t.start()