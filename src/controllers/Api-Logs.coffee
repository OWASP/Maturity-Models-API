Api_Base = require './Api-Base'

class Api_Logs extends Api_Base
  constructor: (options)->
    @.options     = options || {}
    @.logs_Folder = __dirname.path_Combine('../../../../logs') # Issue 126 - Consolidate location of logs folder path
    @._ensure_Log_Folder_Exists()
    super()

  _ensure_Log_Folder_Exists: ()->    
    if @.logs_Folder.folder_Not_Exists()                            # note: docker was having a problem with the creation of this folder
      @.logs_Folder.folder_Create()                                 #       which is why this is now done on the Docker file (need to find root cause)
                                                                    # Issue 97 - Find root cause of logs folder not created in docker
  add_Routes: ()=>
    @.add_Route 'get', '/logs/path'       , @.path
    @.add_Route 'get', '/logs/list'       , @.list
    @.add_Route 'get', '/logs/file/:index', @.file
    @

  list: (req, res)=>
    res.send @.logs_Folder.files().file_Names()

  file: (req, res)=>
    index = parseInt(req.params?.index)
    if is_Number(index)
      file_Name = @.logs_Folder.files().file_Names()[index]
      if file_Name
        file_Path = @.logs_Folder.path_Combine file_Name        
        if file_Path.file_Exists()
          return res.send  file_Path.file_Contents()

    res.send 'not found'    

  path: (req, res)=>
    res.send @.logs_Folder


  # Loggly support

  loggly_Token: ()=>
    return process.env.LOGGLY_TOKEN || null

  add_Loggly_Support: (app)=>
    token = @.loggly_Token()
    if token
      console.log 'Adding loggly support'
      winston = require('winston');
      require('winston-loggly-bulk');
      options =
        token     : token,
        subdomain : "owasp",
        tags      : ["Winston-NodeJS"],
        json      :true

      winston.remove(winston.transports.Console)
      winston.add winston.transports.Loggly,options

      winston.log 'info','Maturity Model server started'

      app?.use (req, res, next) =>
        log_Data = @.log_Data_From_Request req
        winston.log 'info', log_Data
        next?()


  log_Data_From_Request: (req)=>

    return null if not req

 #   level = 'INFO'

    log_Data =
#      'date'        : new Date().toUTCString()
#      'level'       : level
      'method'      : req.method
      'protocol'    : req.protocol,
      'version'     : req.httpVersionMajor + '.' + req.httpVersionMinor
      'hostname'    : req.hostname
      'path'        : req.path
      'query'       : req.query #Object.keys(req.query).length ? req.query: '',
      'session'     : req.sessionID
      'body'        : req.body
      'url'         : req.originalUrl
      #'user_agent'  : req.headers?['user-agent']
      #'referrer'    : req.headers?['referer'] || req.headers?['referrer']
      'headers'     : req.headers

    return log_Data


module.exports = Api_Logs    