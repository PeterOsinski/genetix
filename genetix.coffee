async = require 'async'
debug = (require 'debug')('ga')
_ = require 'lodash'

class Engine
  constructor: (
    @populationSize,
    @surviveGeneration
    @generations,
    @mutatePropability = 0.2,
    @crossoverPropability = 0.8) ->

    @populationPoll = []
    @generationResult = []
    @generationParents = []
    @generation = 0

  _initPopulation = (self, callback) ->
    debug 'Initializing population'

    async.until(
      () -> self.populationPoll.length == self.populationSize
      (cb) -> self.random_solution_fn((solution)  ->
        self.populationPoll.push solution
        cb())
      (err) ->
        debug(err) if err
        debug 'Population initialized'
        callback()
    )

  _evolve = (self, callback) ->
    debug 'Evoluting population'

    async.times(
      self.generations
      (n, cb) -> _startGeneration(self, cb)
      (err) ->
        debug(err) if err
        debug 'Population evolved'
        callback()
    )

  _startGeneration = (self, callback) ->

    self.generation++
    self.generationResult = []
    self.generationParents = []
    children = []

    async.eachLimit(self.populationPoll, 1,
      (item, cb) ->
        self.fitness_fn(item, (solution) ->
          self.generationResult.push {
            item: item
            solution: solution
          }
          cb()
      )
      (err) ->
        firstMax = 0
        secondMax = 0
        newPopulation = []

        self.generationParents = _.sortBy self.generationResult, 'solution'
          .reverse()
          .slice 0, self.surviveGeneration

        for i in [1..self.populationSize]

          p1 = _arrRand(self.generationParents).item
          p2 = _arrRand(self.generationParents).item

          if Math.random() <= self.crossoverPropability
            child = self.crossover_fn p1, p2
          else
            child = p1

          if Math.random() <= self.mutatePropability
            child = self.mutator_fn(child)

          newPopulation.push(child)

        self.populationPoll = newPopulation

        callback()

    )

  _arrRand = (arr) ->
    arr[Math.floor(Math.random() * arr.length)]

  setFitness: (fn) ->
    @fitness_fn = fn

  setMutator: (fn) ->
    @mutator_fn = fn

  setCrossover: (fn) ->
    @crossover_fn = fn

  setRandomSolution: (fn) ->
    @random_solution_fn = fn

  start: (cb) ->
    async.series([
      (cb) => _initPopulation(@, cb)
      (cb) => _evolve(@, cb)
    ], =>
      debug @generationParents
    )

module.exports = Engine