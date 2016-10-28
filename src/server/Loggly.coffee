winston  = require('winston');


class Loggly
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
    return process.env.LOGGLY_TOKEN || null


  setup: (app)=>
    @.app = app
    if @.token()
      require('winston-loggly-bulk');
      console.log 'Adding loggly support'


      logger_Options = transports: [ new winston.transports.Loggly(@.options())]

      @.logger = new winston.Logger logger_Options
      #@.logger = new (winston.Logger)(transports: [ new winston.transports.Loggly(@.options())])
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

module.exports = Loggly