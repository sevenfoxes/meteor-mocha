{EventEmitter}  = require("events")

#/**
# * Initialize a new `Base` reporter.
# *
# * All other reporters generally
# * inherit from this reporter, providing
# * stats such as test duration, number
# * of tests passed / failed etc.
#*
#* @param {Runner} clientRunner
#* @param {Runner} serverRunner
#* @api public
#*/

class ClientServerBaseReporter

  constructor: (@clientRunner, @serverRunner, @options)->
    expect(@clientRunner).to.be.an 'object'
#    expect(@serverRunner).to.be.an 'object'
    expect(@options).to.be.an 'object'

    # In case we only have one runner, i.e MeteorPublishReporter
    if not @serverRunner
      @serverRunner = new EventEmitter()
      @serverRunner.total = 0


    @clientStats = { total: @clientRunner.total, suites: 0, tests: 0, passes: 0, pending: 0, failures: 0 }
    @serverStats = { total: @serverRunner.total, suites: 0, tests: 0, passes: 0, pending: 0, failures: 0 }
    @stats = { total: @serverRunner.total + @clientRunner.total, suites: 0, tests: 0, passes: 0, pending: 0, failures: 0 }
    @failures = []

    @clientRunner.stats = @clientStats
    @serverRunner.stats = @serverStats


  _addEventsToRunner: (where)->

    @["#{where}Runner"].on 'start', =>
      start = new Date()
      @[where+"Stats"].start = start
      # The start time will be the first of the runners that started running
      @stats.start ?= start


    @["#{where}Runner"].on 'suite', (suite)=>
      if not suite.root
        @stats.suites++
        @[where+"Stats"].suites++

    @["#{where}Runner"].on 'test end', (test)=>
      @stats.tests++

    @["#{where}Runner"].on 'pass', (test)=>
      medium = test.slow() / 2

      if test.duration > test.slow()
        test.speed = 'slow'
      else if test.duration > medium
        test.speed = 'medium'
      else
        test.speed = 'fast'

      @[where+"Stats"].passes++
      @stats.passes++

    @["#{where}Runner"].on 'fail', (test, err)=>
      test.err ?= err
      @failures.push(test)
      console.log("test", test)

      @stats.failures++;
      @[where+"Stats"].failures++;


    @["#{where}Runner"].on 'end', =>
      end = new Date()

      @stats.end = end
      @[where+"Stats"].end = end

      @stats.duration = @stats.end - @stats.start
      @[where+"Stats"].duration = @[where+"Stats"].end - @[where+"Stats"].start

    @["#{where}Runner"].on 'pending', =>
      @stats.pending++
      @[where+"Stats"].pending++


module.exports = ClientServerBaseReporter
