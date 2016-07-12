Data_Team = require '../../src/backend/Data-Team'

describe 'backend | Data-Team', ->
  data_Team = null
  project   = null

  beforeEach ->
    project    = 'bsimm'
    data_Team = new Data_Team()

  it 'constructor',->
    using data_Team, ->
      @.constructor.name.assert_Is 'Data_Team'
      
  it 'delete_Team', ->
    using data_Team, ->
      console.log @.delete_Team()

  it 'teams_Names', ->
    using data_Team, ->
      @.teams_Names(project).assert_Not_Empty()
      @.teams_Names(project).first().assert_Is @.teams_Paths(project).first().file_Name_Without_Extension()


  it 'teams_Paths', ->
    using data_Team, ->
      @.teams_Paths(project).assert_Not_Empty()
      @.teams_Paths(project).first().assert_File_Exists()

  it 'find_Team', ->
    using data_Team, ->
      team_A = @.find_Team project, 'team-A'
      team_A.assert_File_Exists()

      assert_Is_Null @.find_Team 'demo', 'Team-A'  # search is case sensitive
      assert_Is_Null @.find_Team 'demo', 'aaaaaa'
      assert_Is_Null @.find_Team 'demo', null
      assert_Is_Null @.find_Team null, 'team-A'
      assert_Is_Null @.find_Team 'aaaa', 'team-A'

  it 'get_Team_Data', ()->
    project  = 'bsimm'
    filename = 'team-A'
    using data_Team, ->
      @.get_Team_Data project, filename
          .metadata.team.assert_Is 'Team A'

  it 'new_Team', ->
    project  = 'bsimm'
    using data_Team, ->
      new_File_Id   = @.new_Team project
      new_File_Path = @.find_Team project, new_File_Id
      new_File_Path.assert_File_Exists()

  it 'set_Team_Data_Json', ->
    project     = 'bsimm'
    target_File = 'team-C'
    good_Value  = 'Team C'
    temp_Value  = 'BBBBB'

    using data_Team.get_Team_Data(project, target_File), ->                 # get data
      @.metadata.team.assert_Is good_Value
      @.metadata.team        =  temp_Value                                  # change value
      data_Team.set_Team_Data_Json project, target_File, @.json_Str()       # save it
                .assert_Is_True()                                           # confirm save was ok

    using data_Team.get_Team_Data(project,target_File), ->                  # get new copy of data
      @.metadata.team.assert_Is temp_Value                                  # check value has been changed
      @.metadata.team         = good_Value                                  # restore original value
      data_Team.set_Team_Data_Json project,target_File, @.json_Pretty()     # save it again

    using data_Team.get_Team_Data(project,target_File), ->                  # get another copy of data
      @.metadata.team.assert_Is good_Value                                  # confirm original value is there

  it 'set_Team_Data_Json (bad json)', ()->
    target_File = 'team-C'
    bad_Json    = '{ not-good : json } '
    using data_Team, ->
      assert_Is_Null data_Team.set_Team_Data_Json target_File, bad_Json

  it 'set_Team_Data_Json (not able to create new file)', ()->
    filename = 'temp_file.json'
    contents = '{ "aaa" : 123 }'
    using data_Team, ->
      @.set_Team_Data_Json filename, contents
      assert_Is_Null @.get_Team_Data filename, contents
      
 
  it 'set_Team_Data_Json (bad data)', ()->
    using data_Team, ->
      assert_Is_Null @.set_Team_Data_Json()
      assert_Is_Null @.set_Team_Data_Json 'aaa'
      assert_Is_Null @.set_Team_Data_Json null, 'bbbb'
      assert_Is_Null @.set_Team_Data_Json 'aaa', {}
      
        

  