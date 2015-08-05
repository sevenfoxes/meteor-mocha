log = new ObjectLogger('HtmlReporter', 'info')

practical.mocha ?= {}

class practical.mocha.HtmlReporter extends practical.mocha.BaseReporter

  constructor: (@clientRunner, @serverRunner, @options = {})->
    try
      log.enter('constructor')
      @addReporterHtml()

      @reporter = new practical.mocha.reporters.HTML(@clientRunner)
      @serverReporter = new practical.mocha.reporters.HTML(@serverRunner, {
        elementIdPrefix: 'server-'
      })
    finally
      log.return()


  addReporterHtml: ()=>
    try
      log.enter("addReporterHtml")
      div = document.createElement('div')

      div.innerHTML = '<div class="content">
        <div class="test-wrapper">
          <h1 class="title">Client tests</h1>

          <div id="mocha" class="mocha"></div>
        </div>

        <div class="divider"></div>

        <div class="test-wrapper">
          <h1 class="title">Server tests</h1>

          <div id="server-mocha" class="mocha"></div>
        </div>
      </div>'

      document.body.appendChild(div)
    finally
      log.return()


Meteor.startup ->
  MochaRunner.setReporter(practical.mocha.HtmlReporter)
