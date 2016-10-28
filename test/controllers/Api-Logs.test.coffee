Api_Logs = require '../../src/controllers/Api-Logs'
Server   = require '../../src/server/Server'

describe 'controllers | Api-Logs', ->  
  log_File_Name     = null
  log_File_Contents = null
  tmp_Log_Folder    = null
  api_Logs          = null

  before ->  
    log_File_Name     = 'tmp_log_file - '.add_5_Random_Letters()
    log_File_Contents = 'some log data - '.add_5_Random_Letters()
    tmp_Log_Folder    = './tmp_logs'

    using new Api_Logs(), ->
      api_Logs = @
      @.logs_Folder = tmp_Log_Folder
      @._ensure_Log_Folder_Exists()
      tmp_Log_Folder.path_Combine(log_File_Name).file_Write(log_File_Contents)

  after ->
    tmp_Log_Folder.folder_Delete_Recursive().assert_Is_True()

  it '_ensure_Log_Folder_Exists', ->
    # tested in 'before' (above)

  it 'add_Routes', ->
    using new Api_Logs(), ->
      @.add_Routes()
      
  it 'constructor', ->
    using new Api_Logs(), ->
      @.constructor.name.assert_Is 'Api_Logs'
      @.router.assert_Is_Function()

  it 'file ', ->
    using api_Logs,->
      req = params : index : 0
      res = send: (data)-> data.assert_Is log_File_Contents
      @.file req, res

  it 'file (empty data)', ->
    using new Api_Logs(), ->
      req = {}
      res = send: (data) -> data.assert_Is 'not found'
      @.file req, res

  it 'file (bad data)', ->
    using new Api_Logs(), ->
      req = params : index : 'AAAAA'
      res = send: (data)-> data.assert_Is 'not found'
      @.file req, res
    
  it 'list', ->
    using api_Logs,->
      res =
        send: (data)->
          data.assert_Contains [log_File_Name]
      @.list null, res

  it 'path', ->
    using api_Logs,->
      res =
        send: (data)->
          data.assert_Folder_Exists()
      @.path null, res

  # loggly support
  it 'loggly_Token', ->
    using api_Logs,->
      delete process.env.LOGGLY_TOKEN         # ensure there is no value set
      assert_Is_Null @.loggly_Token()         # ensure results null
      process.env.LOGGLY_TOKEN = 'abc'        # set environment value
      @.loggly_Token().assert_Is 'abc'        # confirm it
      delete process.env.LOGGLY_TOKEN         # remove it


  it 'add_Loggly_Support', (done)->
    token = 'an-token-'.add_5_Random_Letters()
    winston = require('winston');
    winston_Add_Function = winston.add                        # keep copy of winston.add function
    winston_Log_Function = winston.log                        # keep copy of winston.add function

    winston.add = (transport, options)->
      transport.assert_Is winston.transports.Loggly
      options.assert_Is
        token     : token
        subdomain : 'owasp'
        tags      : ["Winston-NodeJS"],
        json      : true
      winston.add = winston_Add_Function                      # restore winston.add function
      delete process.env.LOGGLY_TOKEN

    winston.log = (level, message)->                          # override winston.log for the first log call
      level.assert_Is 'info'
      message.assert_Is 'Maturity Model server started'

    app =
      use: (callback)->                                       # callback will be api_Logs.log_Data_From_Request
        callback.assert_Is_Function()

        winston.log = (level, log_Data)->                     # override winston.log for the second log call
          level.assert_Is 'info'
          log_Data.method.assert_Is 'an_method'
          winston.log = winston_Log_Function                  # restore winston.log function
        callback method: 'an_method', null, done              # simulate express call (sending 'done' function as 'next' )

    using api_Logs,->
      process.env.LOGGLY_TOKEN = token
      @.add_Loggly_Support app


  it 'log_Data_From_Request', ->
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

    expected_Log_Data =
#      date      : new Date().toUTCString()
#      level     :'INFO'
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


    using api_Logs,->
      assert_Is_Null @.log_Data_From_Request()
      log_Data = @.log_Data_From_Request req
      log_Data.assert_Is expected_Log_Data
