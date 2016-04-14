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

  generateStats = ->


  constructor: (@clientRunner, @serverRunner, @options)->
    expect(@clientRunner).to.be.an 'object'
    expect(@serverRunner).to.be.an 'object'
    expect(@options).to.be.an 'object'

    @clientStats = {total: @clientRunner.total, suites: 0, tests: 0, passes: 0, pending: 0, failures: 0}
    @serverStats = {total: @serverRunner.total, suites: 0, tests: 0, passes: 0, pending: 0, failures: 0}
    @stats = {total: @serverRunner.total + @clientRunner.total, suites: 0, tests: 0, passes: 0, pending: 0, failures: 0}
    @failures = []

    @clientRunner.stats = @clientStats
    @serverRunner.stats = @serverStats

    @_addEventsToRunner("server")
    @_addEventsToRunner("client")

  _addEventsToRunner: (where)->

    @["#{where}Runner"].on 'start', =>
      start = new Date()
      @[where+"Stats"].start = start
      # The start time will be the first of the runners that started running
      @stats.start ?= start

      #The total and other stats of the server runner are sent with the 'start' event,
      #so we need to update the total of the stats
      if where is 'server'
        @stats.total = @serverRunner.total + @clientRunner.total
        @serverStats.total = @serverRunner.total


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
      if where is 'server'
        test.isServer = true
      else
        test.isClient = true

      @failures.push(test)

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
