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
