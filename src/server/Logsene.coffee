winston  = require('winston');


class Logsene
  constructor: ->
    @.logger = null
    @.app    = null

  options: ()=>
    token     : @.token(),
    subdomain : "owasp",
    tags      : ["Winston-NodeJS"],
    json      :true


  log: (data)=>
    @.logger?.info  data
    data

  token: ()=>
    return process.env.LOGSENE_TOKEN || null


  setup: (app)=>
    @.app = app
    if not @.token()
      console.log 'Logging is not enabled. Set process.env.LOGSENE_TOKEN to the desired Logsene account token'
    else
      @.logsene = require('winston-logsene')

      @.options =
        token: @.token()
        ssl: 'true'

      console.log "Adding Logsene support using token: #{@.token()}"

      logsene_Options = transports: [ new @.logsene(@.options)]

      @.logger = new winston.Logger logsene_Options


      #@.logger.on 'error',  ()->
      #  console.error('error in winston-logsene', arguments)  # https://github.com/sematext/winston-logsene/issues/8


      app?.use (req, res, next) =>
        @.log_Just_Path    req
        @.log_Request_Data req
        next?()
    @

  log_Just_Path: (req)=>
    console.log 'path: ' + req?.path                # for now also log this
    log_Data =
      path:  req?.path
      mode: 'just-path'
    @.log log_Data

  log_Request_Data: (req)=>
    log_Data =
      method      : req.method
      protocol    : req.protocol
      version     : req.httpVersionMajor + '.' + req.httpVersionMinor
      hostname    : req.hostname
      path        : req.path
      query       : req.query #Object.keys(req.query).length ? req.query: '',
      session     : req.sessionID
      body        : req.body
      url         : req.originalUrl
      headers     : req.headers
      mode        : 'request-data'

    @.log log_Data

module.exports = Logsene