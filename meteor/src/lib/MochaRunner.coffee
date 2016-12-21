{_}                   = require("underscore")
Test                  = require("mocha/lib/test")
Suite                 = require("mocha/lib/suite")
utils                 = require("mocha/lib/utils")
{Mongo}               = require("meteor/mongo")
{Mocha}               = require("meteor/practicalmeteor:mocha-core")
{EventEmitter}        = require("events")
{ObjectLogger}        = require("meteor/practicalmeteor:loglevel")
MeteorPublishReporter = require("./../reporters/MeteorPublishReporter")
log = new ObjectLogger('MochaRunner', 'info')

class MochaRunner extends EventEmitter

  @instance: null

  @get: ->
    MochaRunner.instance ?= new MochaRunner()

  VERSION: "2.4.5_6"
  serverRunEvents: null
  publishers: {}


  constructor: ->
    try
      log.enter 'constructor'
      @utils = utils;
      @serverRunEvents = new Mongo.Collection('mochaBlanketServerRunEvents')
      if Meteor.isServer
        Meteor.methods({
          "mocha/runServerTestsBlanket": @runServerTests.bind(@)
        })
        @publish()

    finally
      log.return()


  publish: ->
    try
      log.enter("publish")
      self = @
      Meteor.publish 'mochaServerRunEvents', (runId)->
        try
          log.enter 'publish.mochaServerRunEvents'
          check(runId, String);
          expect(@ready).to.be.a('function')
          self.publishers[runId] ?= @
          @ready()
          # You can't return any other value but a Cursor, otherwise it will throw an exception
          return undefined
        catch ex
          log.error ex.stack if ex.stack?
          throw new Meteor.Error('unknown-error', (if ex.message? then ex.message else undefined), (if ex.stack? then ex.stack else undefined))
        finally
          log.return()
    finally
      log.return()


  runServerTests: (runId, grep)=>
    try
      log.enter("runServerTests", runId)
      check(runId, String);
      check(grep, Match.Optional(Match.OneOf(null, String)));
      expect(runId).to.be.a("string")
      expect(@publishers[runId], "publisher").to.be.an("object")
      expect(Meteor.isServer).to.be.true
      mochaRunner = new Mocha()
      @_addTestsToMochaRunner(mocha.suite, mochaRunner.suite)

      mochaRunner.reporter(MeteorPublishReporter, {
        grep: @escapeGrep(grep)
        publisher: @publishers[runId]
      })

      log.info "Starting server side tests with run id #{runId}"
      mochaRunner.run (failures)->
        log.warn 'failures:', failures

    finally
      log.return()


  # Recursive function that starts with global suites and adds all sub suites within each global suite
  _addTestsToMochaRunner: (fromSuite, toSuite)->
    try
      log.enter("_addTestToMochaRunner")

      addHooks = (hookName)->
        for hook in fromSuite["_#{hookName}"]
          toSuite[hookName](hook.title, hook.fn)
        log.debug("Hook #{hookName} for '#{fromSuite.fullTitle()}' added.")

      addHooks("beforeAll")
      addHooks("afterAll")
      addHooks("beforeEach")
      addHooks("afterEach")

      for test in fromSuite.tests
        test = new Test(test.title, test.fn)
        toSuite.addTest(test)
        log.debug("Tests for '#{fromSuite.fullTitle()}' added.")

      for suite in fromSuite.suites
        newSuite = Suite.create(toSuite, suite.title)
        newSuite.timeout(suite.timeout())
        log.debug("Suite #{newSuite.fullTitle()}  added to '#{fromSuite.fullTitle()}'.")
        @_addTestsToMochaRunner(suite, newSuite)

    finally
      log.return()


  runEverywhere: ->
    try
      log.enter 'runEverywhere'
      expect(Meteor.isClient).to.be.true

      @runId = Random.id()
      @serverRunSubscriptionHandle = Meteor.subscribe 'mochaServerRunEvents', @runId, {
        onReady: _.bind(@onServerRunSubscriptionReady, @)
        onError: _.bind(@onServerRunSubscriptionError, @)
      }

    finally
      log.return()


  setReporter: (@reporter)->

  escapeGrep: (grep = '')->
    try
      log.enter("escapeGrep", grep)
      matchOperatorsRe = /[|\\{}()[\]^$+*?.]/g;
      grep.replace(matchOperatorsRe,  '\\$&')
      return new RegExp(grep)
    finally
      log.return()


  onServerRunSubscriptionReady: =>
    try
      log.enter 'onServerRunSubscriptionReady'
      ClientServerReporter = require("./../reporters/ClientServerReporter")
      { REPORTERS, reporters} = require("../reporters")
      query = utils.parseQuery(location.search || '');

      Meteor.call "mocha/runServerTests", @runId,  query.grep, (err)->
        log.debug "tests started"
        log.error(err) if err

      Tracker.autorun =>
        event = @serverRunEvents.findOne({event: "run mocha"})
        if event?.data.reporter? and _.contains(REPORTERS, event.data.reporter)
          reporter = reporters[event.data.reporter]
          @setReporter reporter

        if event?.data.runOrder is "serial"
          reporter = new ClientServerReporter(null, {runOrder: "serial"})
        else if event?.data.runOrder is "parallel"
          mocha.reporter(ClientServerReporter)
          mocha.run(->)



    finally
      log.return()


  onServerRunSubscriptionError: (meteorError)->
    try
      log.enter 'onServerRunSubscriptionError'
      log.error meteorError
    finally
      log.return()


module.exports = MochaRunner.get()
