Data_Project = require './Data-Project'

class Data_Team
  constructor: ()->
    @.data_Project    = new Data_Project();
    @.new_Team_Prefix = 'team-'

  check_Activity_Data: (team_Data)=>                              # this function will ensure that the team_Data activities have the correct structure
    if team_Data?.activities
      for key of team_Data.activities
        value = team_Data.activities[key]
        if typeof value is 'object'
          if not team_Data.activities[key].value                  # ensure that this value exists
            team_Data.activities[key].value = ''
        else
          team_Data.activities[key] = { value: value , proof: ''} # change into new structure for team_Data.activities[key]
    team_Data

  check_Activity_Values: (project, team_Data)=>                            # this function will ensure that there is at least a NO value for each activity (i.e. not empty activity values allowed)
    if team_Data?.activities
      schema    = @.data_Project.project_Schema project
      for activity of schema.activities
        if not team_Data.activities[activity]
          team_Data.activities[activity] = { value: 'No', proof: '' }
          #console.log activity
    return team_Data

  check_Metadata_Field: (project, team_Data)=>                    # this function will ensure that the team_Data object contains all schema.metadata fields
    if project and team_Data
      schema = @.data_Project.project_Schema project              # get schema for project
      if schema?.metadata                                         # if we got a valid metadata value
        team_Data.metadata   = team_Data?.metadata   || {}        # ensure team_Data.metadata exists
        team_Data.activities = team_Data?.activities || {}        # ensure team_Data.activites exists
        for field in schema?.metadata                             # for each field
          if not team_Data.metadata[field]                        # if it doesn't exist in team_Data.metadata
            team_Data.metadata[field] = ''                        # create that field set it to ''
    team_Data

  create_Team: ()=> @.new_Team.apply @, arguments

  delete_Team: (project, team)->
    team_Path = @.team_Path project, team  
    if team_Path
      if team_Path.file_Delete()
        @.data_Project.clear_Caches()                        # so that deleted file is not shown anymore
        return true
    return false

  teams: (project)=>
    @.data_Project.project_Files(project)

  teams_Names: (project)=>
    @.teams(project)._keys()

  teams_Paths: (project)=>
    @.teams(project).values()

  teams_Proofs: (project)=>
    proofs = {}
    for team in @.teams_Names(project)
      data = @.get_Team_Data project, team
      for key, value of data?.activities
        proofs[key]      ?= {}
        proofs[key][team] = value
    return proofs

  team_Path: (project, team)=>
    if project and team
      team_Paths = @.teams(project)
      if team_Paths[team]
        return team_Paths[team]
    return null

  get_Team_Data: (project, team) ->
    file = @.team_Path project, team
    if file and file.file_Exists()
      switch file.file_Extension()
        when '.json'                                            # only support .json files
          team_Data = file.load_Json()
          @.check_Metadata_Field project, team_Data             # fix metadata
          @.check_Activity_Data team_Data                       # fix activities
          @.check_Activity_Values project, team_Data            # fix empty activity values
          return team_Data
    return null

  new_Team: (project, name, contents)=>
    target_Folder = @.data_Project.project_Path_Teams(project)
    if target_Folder
      target_Folder = target_Folder.path_Combine 'new_teams'              # for now put them here
                                   .folder_Create()                       # create if it doesn't exist
      team_Name     = name || @.new_Team_Prefix + 5.random_Letters()      # use provided name or assign a random one
      team_Name     = team_Name.to_Safe_String()                          # ensure value is safe
      if team_Name and @.team_Path(team_Name) is null                     # check that fixed name doesn't exist
        target_File   = "#{target_Folder}/#{team_Name}.json"              # hard-code extension to .json
        if target_File.not_Exists()                                       # confirm file doesn't exist
          default_Data  = contents || {}                                  # use provided contents or use {}
          default_Data.save_Json target_File                              # create file
          if target_File.file_Exists()                                    # check file creation
            @.data_Project.clear_Caches()                                 # so that new file is picked up
            return team_Name
      
    return null
    
  rename_Team: (project, current_Name, new_Name)=>
    if not (project and current_Name and new_Name)                        # ensure we have values on all fields
      return false
    team_Path = @.team_Path project, current_Name
    if team_Path is null or team_Path.file_Not_Exists()                   # check if target team exists
      return false
    if @.team_Path(project, new_Name)                                     # check if name is already used by another team
      return false
    team_Data = @.get_Team_Data project,current_Name                      # get existing team data
    if @.new_Team(project, new_Name, team_Data) is new_Name               # create new team from current team's data
      @.delete_Team project, current_Name                                 # delete if creation was ok

    return @.team_Path(project, new_Name)?.file_Exists()                  # confirm new team was created ok

  # use to save object (vs set_Team_Data_Json which takes a string)
  save_Team: (project, team, data)=>
    @.set_Team_Data_Json project, team, data.json_Str()


# RISK - Data_Files.set_File_Data - DoS via file_Contents #26
  # RISK - Race condition on set_File_Data_Json method #121
  # RISK - set_File_Data does not provide detailed information on why it failed  - https://maturity-models.atlassian.net/browse/RISK-5
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

    file_Path.file_Write json_Data                      # after all checks save file

    return file_Path.file_Contents() is json_Data       # confirm file was saved ok
    
module.exports = Data_Team
