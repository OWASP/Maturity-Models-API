Data_Team = require '../../src/backend/Data-Team'

describe 'backend | Data-Team', ->
  data_Team = null
  project   = null  
  team      = null

  beforeEach ->
    project   = 'bsimm'
    team      = 'team-A'
    data_Team = new Data_Team()

  it 'constructor',->
    using data_Team, ->
      @.constructor.name.assert_Is 'Data_Team'
      @.new_Team_Prefix .assert_Is 'team-' 

  it 'delete_Team', ->
    using data_Team, ->
      temp_Team = @.new_Team( project           ).assert_Size_Is(10).str()
      team_Path = @.team_Path(project, temp_Team).assert_File_Exists()
      @.get_Team_Data(        project, temp_Team).assert_Is {}
      @.delete_Team(          project, temp_Team).assert_Is_True()

      team_Path.assert_File_Not_Exists()
      assert_Is_Null @.get_Team_Data project, temp_Team

      @.delete_Team( project, temp_Team).assert_Is_False()                # try to delete again
      @.delete_Team( project, null     ).assert_Is_False()                # try with bad team name
      @.delete_Team( null   , temp_Team).assert_Is_False()                # try with bad project name
      @.delete_Team( null   , null     ).assert_Is_False()                # try with both bad

  it 'teams_Names', ->
    using data_Team, ->
      @.teams_Names(project).assert_Not_Empty()
      @.teams_Names(project).first().assert_Is @.teams_Paths(project).first().file_Name_Without_Extension()


  it 'teams_Paths', ->
    using data_Team, ->
      @.teams_Paths(project).assert_Not_Empty()
      @.teams_Paths(project).first().assert_File_Exists()

  it 'team_Path', ->
    using data_Team, ->
      team_A = @.team_Path project, 'team-A'
      team_A.assert_File_Exists()

      assert_Is_Null @.team_Path 'demo', 'Team-A'  # search is case sensitive
      assert_Is_Null @.team_Path 'demo', 'aaaaaa'
      assert_Is_Null @.team_Path 'demo',  null
      assert_Is_Null @.team_Path  null , 'team-A'
      assert_Is_Null @.team_Path 'aaaa', 'team-A'

  it 'get_Team_Data', ()->    
    using data_Team, ->      
      @.get_Team_Data project, team
          .metadata.team.assert_Is 'Team A'

  it 'get_Team_Data (coffee)',()->
    using data_Team, ->
      team = 'team-random'
      @.get_Team_Data project, team
          .metadata.team.assert_Is 'Team Random'

  it 'get_Team_Data (bad coffee file)',()->    
    using data_Team, ->
      teams_Path  =  @.data_Project.project_Path_Teams project
      test_Coffee = (team_Name, team_Code, expected_Result)=>
        teams_Path.path_Combine(team_Name + '.coffee').file_Create team_Code
        if expected_Result
          @.get_Team_Data(project, team_Name).assert_Is expected_Result
        else
          assert_Is_Null @.get_Team_Data(project, team_Name)
        @.delete_Team(project, team_Name).assert_Is_True()
        assert_Is_Null @.get_Team_Data(project, team_Name)

      test_Coffee '_temp-team_1', 'module.exports = -> 40 +2', 42
      test_Coffee '_temp-team_2', 'module.exports = -> 40 +3', 43
      test_Coffee '_temp-team_3', 'module.exports = 40 +3'   , 43
      test_Coffee '_temp-team_4', 'AAA.exports    = 40 +3'   , null


  it 'new_Team', ->    
    using data_Team, ->
      new_File_Id   = @.new_Team project
      new_File_Id.assert_Contains @.new_Team_Prefix
      new_File_Path = @.team_Path project, new_File_Id
      new_File_Path.assert_File_Exists()

  it 'set_Team_Data_Json', ->    
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
      assert_Is_Null data_Team.set_Team_Data_Json project, target_File, bad_Json

  it 'set_Team_Data_Json (not able to create new file)', ()->
    filename = 'temp_file.json'
    contents = '{ "aaa" : 123 }'
    using data_Team, ->
      @.set_Team_Data_Json project, filename, contents
      assert_Is_Null @.get_Team_Data filename, contents

  it 'set_Team_Data_Json (can not edit coffee files', ()->
    filename = 'team-random'
    contents = '{ }'
    using data_Team, ->
      @.set_Team_Data_Json project, filename, contents
      assert_Is_Null @.get_Team_Data filename, contents
      
 
  it 'set_Team_Data_Json (bad data)', ()->
    using data_Team, ->
      assert_Is_Null @.set_Team_Data_Json()
      assert_Is_Null @.set_Team_Data_Json 'aaa'
      assert_Is_Null @.set_Team_Data_Json null, 'bbbb'
      assert_Is_Null @.set_Team_Data_Json 'aaa', null
      assert_Is_Null @.set_Team_Data_Json 'aaa', 'bbb', {}
      assert_Is_Null @.set_Team_Data_Json 'aaa', 'bbb', 'ccccc'
      assert_Is_Null @.set_Team_Data_Json 'aaa', 'bbb', '{}'

      
        

  