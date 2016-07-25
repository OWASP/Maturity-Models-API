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


module.exports = Api_Logs    