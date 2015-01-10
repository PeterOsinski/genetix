// Generated by CoffeeScript 1.8.0
(function() {
  var Engine, async, debug, _;

  async = require('async');

  debug = (require('debug'))('ga');

  _ = require('lodash');

  Engine = (function() {
    var _arrRand, _breakEvolution, _evolve, _initPopulation, _startGeneration;

    function Engine(populationSize, surviveGeneration, generations, mutatePropability, crossoverPropability) {
      this.populationSize = populationSize;
      this.surviveGeneration = surviveGeneration;
      this.generations = generations;
      this.mutatePropability = mutatePropability != null ? mutatePropability : 0.2;
      this.crossoverPropability = crossoverPropability != null ? crossoverPropability : 0.8;
      this.populationPoll = [];
      this.generationResult = [];
      this.generationParents = [];
      this.generation = 0;
    }

    _initPopulation = function(self, callback) {
      debug('Initializing population');
      return async.times(self.populationSize, function(n, cb) {
        return self.random_solution_fn(function(solution) {
          self.populationPoll.push(solution);
          return cb();
        });
      }, function(err) {
        if (err) {
          debug(err);
        }
        debug('Population initialized');
        return callback();
      });
    };

    _evolve = function(self, callback) {
      debug('Evoluting population');
      return async.times(self.generations, function(n, cb) {
        return _startGeneration(self, cb);
      }, function(err) {
        if (err) {
          debug(err);
        }
        debug('Population evolved');
        return callback();
      });
    };

    _breakEvolution = function(self) {
      if (typeof self.stop_fn === "function" ? self.stop_fn(self.generationParents.slice(0, 1).pop()) : void 0) {
        return true;
      }
    };

    _startGeneration = function(self, callback) {
      var children;
      self.generation++;
      self.generationResult = [];
      self.generationParents = [];
      children = [];
      return async.eachLimit(self.populationPoll, 1, function(item, cb) {
        return self.fitness_fn(item, function(solution) {
          self.generationResult.push({
            item: item,
            solution: solution
          });
          return cb();
        });
      }, function(err) {
        var child, firstMax, i, newPopulation, p1, p2, secondMax, _i, _ref;
        firstMax = 0;
        secondMax = 0;
        newPopulation = [];
        self.generationParents = _.sortBy(self.generationResult, 'solution').reverse().slice(0, self.surviveGeneration);
        if (_breakEvolution(self) === true) {
          return callback(true);
        }
        for (i = _i = 1, _ref = self.populationSize; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          p1 = _arrRand(self.generationParents).item;
          p2 = _arrRand(self.generationParents).item;
          if (Math.random() <= self.crossoverPropability) {
            child = self.crossover_fn(p1, p2);
          } else {
            child = p1;
          }
          if (Math.random() <= self.mutatePropability) {
            child = self.mutator_fn(child);
          }
          newPopulation.push(child);
        }
        self.populationPoll = newPopulation;
        return callback();
      });
    };

    _arrRand = function(arr) {
      return arr[Math.floor(Math.random() * arr.length)];
    };

    Engine.prototype.setFitness = function(fn) {
      return this.fitness_fn = fn;
    };

    Engine.prototype.setMutator = function(fn) {
      return this.mutator_fn = fn;
    };

    Engine.prototype.setCrossover = function(fn) {
      return this.crossover_fn = fn;
    };

    Engine.prototype.setRandomSolution = function(fn) {
      return this.random_solution_fn = fn;
    };

    Engine.prototype.setStop = function(fn) {
      return this.stop_fn = fn;
    };

    Engine.prototype.start = function(callback) {
      return async.series([
        (function(_this) {
          return function(cb) {
            return _initPopulation(_this, cb);
          };
        })(this), (function(_this) {
          return function(cb) {
            return _evolve(_this, cb);
          };
        })(this)
      ], (function(_this) {
        return function() {
          return typeof callback === "function" ? callback({
            bestSolution: _this.generationParents.slice(0, 1).pop(),
            generations: _this.generation
          }) : void 0;
        };
      })(this));
    };

    return Engine;

  })();

  module.exports = Engine;

}).call(this);
