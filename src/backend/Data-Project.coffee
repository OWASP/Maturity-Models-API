cache_Projects      = null
cache_project_Files = {}

class Data_Project
  constructor: ()->
    @.data_Path       = __dirname.path_Combine('../../../../data')
    @.config_File     = "maturity-model.json"
    @.schema_File     = "schema.json"

  clear_Caches: ()->
    cache_Projects      = null
    cache_project_Files = {}

  project_Files: (id)=>
    return cache_project_Files[id] if cache_project_Files[id]  # return cached version if exists
    result = {}
    project = @.projects()[id]                                 # get list of projects
    if project                                                 # if project object exist
      for file in project.path_Teams.files_Recursive()         # find all files recursively (so that folders can be used to organise files)
        if file.file_Extension() in ['.json', '.coffee']       # only support .json and .coffee files
          result[file.file_Name_Without_Extension()] = file
    return (cache_project_Files[id] = result)                  # cache results in cache_project_Files

  project_Schema: (id)=>
    return using (@.projects()[id]),->
      if @.path_Schema?.file_Exists()
          return @.path_Schema.load_Json()
      return {}

  project_Path_Root: (project)=>
    projects = @.projects()
    if projects[project]
      return projects[project].path_Root
    return null

  project_Path_Teams: (project)=>
    projects = @.projects()
    if projects[project]
      return projects[project].path_Teams
    return null  

  # returns a list of current projects (which are defined by a folder containing an maturity-model.json )
  projects: ()=>
    return cache_Projects if cache_Projects                     # return cached version if exists
    projects = {}
    for folder in @.data_Path?.folders()                        # get folders in @.data_Path
      config_File = folder.path_Combine @.config_File           # calculate path to @.config_File
      if config_File.file_Exists()                              # if it exists
        data = config_File.load_Json()                          # load it
        if data and data.key                                    # if data is loaded ok
          projects[data.key] =                                  # set project object values
            path_Root  : folder
            path_Config: folder.path_Combine @.config_File
            path_Schema: folder.path_Combine @.schema_File
            path_Teams : folder.path_Combine 'teams'
            data: data
    return (cache_Projects = projects)                          # cache results in cache_Projects

  ids: ()=>
    @.projects()._keys()
      
module.exports = Data_Project

 