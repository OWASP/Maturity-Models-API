Loggly   = require '../../src/server/Loggly'

describe 'server | Loggly', ->
  loggly = null

  beforeEach ->
    delete process.env.LOGGLY_TOKEN           # ensure there is no value set
    loggly =new Loggly()

  it 'options', ->
    using loggly,->
      @.options().assert_Is
        token     : null
        subdomain : 'owasp'
        tags      : [ 'Winston-NodeJS' ]
        json      : true

  it 'token', ->
    using loggly,->

      assert_Is_Null @.token()                # ensure results null
      process.env.LOGGLY_TOKEN = 'abc'        # set environment value
      @.token().assert_Is 'abc'               # confirm it
      delete process.env.LOGGLY_TOKEN         # remove it
      @.setup()


  it 'setup', (done)->
    token = 'an-token-'.add_5_Random_Letters()
    using loggly,->
      log_Messages = []
      app =
        use: (callback)->                                               # callback will be api_Logs.log_Data_From_Request
          callback.assert_Is_Function()

          loggly.logger.log = (level, data)=>
            level.assert_Is 'info'
            log_Messages.push data

          callback { path:'an-url'}, null, ->                           # simulate express call (sending 'check_Log_Messages' function as 'next' )
            log_Messages.assert_Size_Is 2
            log_Messages[0].assert_Is path:'an-url', mode: 'just-path'
            log_Messages[1].mode.assert_Is 'request-data'

      process.env.LOGGLY_TOKEN = token

      @.setup app


      done()

  it 'log', ->
    using loggly,->
      @.logger = info: (data)=>
        data.assert_Is data: 'data'
      @.log data: 'data'

  it 'log_Just_Path', ->
    using loggly,->
      @.log = (data)->
        data.assert_Is { path: 'an-path', mode: 'just-path' }

      @.log_Just_Path path: 'an-path'


  it 'log_Request_Data', ->
    req =
      method           : ''.add_5_Random_Letters()
      protocol         : ''.add_5_Random_Letters()
      httpVersionMajor : ''.add_5_Random_Letters()
      httpVersionMinor : ''.add_5_Random_Letters()
      hostname         : ''.add_5_Random_Letters()
      path             : ''.add_5_Random_Letters()
      query            : ''.add_5_Random_Letters()
      sessionID        : ''.add_5_Random_Letters()
      body             : ''.add_5_Random_Letters()
      originalUrl      : ''.add_5_Random_Letters()
      headers          : ''.add_5_Random_Letters()

    expected_Data =
      method    : req.method
      protocol  : req.protocol
      version   : req.httpVersionMajor + '.' + req.httpVersionMinor
      hostname  : req.hostname
      path      : req.path
      query     : req.query
      session   : req.sessionID
      body      : req.body
      url       : req.originalUrl
      headers   : req.headers
      mode      : 'request-data'


    using loggly,->
      @.log = (data)->
        data.assert_Is expected_Data

      @.log_Request_Data req
