Data_Project = require './Data-Project'

class Data_Team
  constructor: ()->
    @.data_Project    = new Data_Project();
    @.new_Team_Prefix = 'team-'

  delete_Team: (project, team)->
    team_Path = @.team_Path project, team  
    if team_Path
      if team_Path.file_Delete()
        @.data_Project.clear_Caches()                        # so that deleted file is not shown anymore
        return true
    return false

  teams_Names: (project)=>
    (file.file_Name_Without_Extension() for file in @.teams_Paths(project))

  # Issue: DoS on Data-Project technique to map projects and project's teams #108
  teams_Paths: (project)=>
    @.data_Project.project_Files(project)

  team_Path: (project, team)=>
    if project and team
      for file in @.teams_Paths(project)                   # this can be optimized with a cache
        if file.file_Name_Without_Extension() is team
          return file          
    return null

  get_Team_Data: (project, team) ->
    file = @.team_Path project, team

    if file and file.file_Exists()
      switch file.file_Extension()
        when '.json'
          return file.load_Json()
        when '.coffee'                                # Issue 69 - Support for coffee file to create dynamic data set's allow RCE
          try
            require('coffee-script/register');        # ensure that coffee-script parsing is registered
            data_Or_Function = require(file)
            if data_Or_Function instanceof Function   # check if what was received from the coffee script is an object or an function
              return data_Or_Function()
            else
              return data_Or_Function
          catch err
            console.log err                           # need better solution to log these errors
    return null

  new_Team: (project)->
    target_Folder = @.data_Project.project_Path_Teams(project)
    if target_Folder
      target_Folder = target_Folder.path_Combine 'new_teams' # for now put them here
                                   .folder_Create()          # create if it doesn't exist
      team_Name     = @.new_Team_Prefix + 5.random_Letters()
      target_File   = "#{target_Folder}/#{team_Name}.json"
      default_Data  = {}
      default_Data.save_Json target_File
      if target_File.file_Exists()
        @.data_Project.clear_Caches()                        # so that new file is picked up
        return team_Name
      
    return null
    
  
  # Issue 26 - Data_Files.set_File_Data - DoS via file_Contents
  # Issue 121 - Race condition on set_File_Data_Json method
  # RISK-5: set_File_Data does not provide detailed information on why it failed  - https://maturity-models.atlassian.net/browse/RISK-5

  set_Team_Data_Json: (project, team, json_Data) ->
    if not team or not json_Data                        # check if both values are set
      return null

    if typeof json_Data isnt 'string'                   # check if json_Data is a string
      return null

    try                                                 # confirm that json_Data parses OK into JSON
      JSON.parse json_Data
    catch
      return null

    file_Path = @.team_Path project, team               # resolve team path based on team name

    if file_Path is null or file_Path.file_Not_Exists() # check if was able to resolve it
      return null
       
    if file_Path.file_Extension() isnt '.json'          # check that the team_Path file extension is .json
      return null


    file_Path.file_Write json_Data                      # after all checks save file

    return file_Path.file_Contents() is json_Data       # confirm file was saved ok
    
module.exports = Data_Team
