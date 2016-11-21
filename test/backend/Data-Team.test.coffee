Data_Team = require '../../src/backend/Data-Team'

describe 'backend | Data-Team', ->
  data_Team = null
  project   = null  
  team      = null

  beforeEach ->
    project   = 'bsimm'
    team      = 'team-A'
    data_Team = new Data_Team()
    data_Team.data_Project.clear_Caches()

  it 'constructor',->
    using data_Team, ->
      @.constructor.name.assert_Is 'Data_Team'
      @.new_Team_Prefix .assert_Is 'team-'

  it 'check_Activity_Data', ->
    using data_Team, ->

      team_Data  = @.get_Team_Data project, team

      test_Key   = 'XYZ.1.9'
      test_Value = 'Thinking about it'
      team_Data.activities[test_Key] = test_Value

      @.check_Activity_Data team_Data                                               # test when value is a string
      team_Data.activities[test_Key].assert_Is value: test_Value, proof: ''
      team_Data.activities[test_Key] = { an : 'object'}

      @.check_Activity_Data team_Data                                                 # test when value is an object
      team_Data.activities[test_Key].assert_Is { an : 'object', value: ''}

  it 'check_Activity_Values', ->
    using data_Team, ->
      team_Data = activities: {}
      schema    = @.data_Project.project_Schema project

      team_Data.activities._keys().size().assert_Is 0                                 # no mappings after team is created
      @.check_Activity_Values project, team_Data
      team_Data.activities._keys().assert_Is schema.activities._keys()                # these should be one mapping per schema.activities
      for key,data of team_Data.activities
        data.value.assert_Is 'No'                                                     # and they all should be no

  it 'check_Metadata_Field', ->
    using data_Team, ->
      expected_Metadata_Fields =  [ 'abc' ,
                                    'team', 'security-champion', 'source-code-repo',
                                    'issue-tracking', 'wiki','ci-server','created-by','hide-from-stats']

      team_Data = @.get_Team_Data project, team                     # get team data
      original_Metadata   = team_Data.metadata.json_Str()           # store copy of metadata (as a serialised JSON)
      team_Data.metadata  = 'abc' : '123'                           # modify metadata

      @.check_Metadata_Field project, team_Data                     # should add missing metadata fields
      team_Data.metadata._keys().assert_Is expected_Metadata_Fields # confirm expected fields
      team_Data = @.get_Team_Data project, team
      team_Data.metadata.json_Str().assert_Is original_Metadata     # confirm original file was not modified

  it 'check_Metadata_Field (error handling)', ->
    using data_Team, ->
      assert_Is_Null @.check_Metadata_Field null   , null
      assert_Is_Null @.check_Metadata_Field 'bismm', null
      @.check_Metadata_Field(null, {}).assert_Is {}

      saved_Method = @.data_Project.project_Schema

      @.data_Project.project_Schema = (project)->                                                         # check when project_Schema returns null
        project.assert_Is 'project_name'
        return null
      assert_Is_Undefined @.check_Metadata_Field 'project_name'
      @.check_Metadata_Field('project_name', {}).assert_Is {}

      @.data_Project.project_Schema = ()-> return metadata: {}                                            # check when project_Schema returns an empty object
      @.check_Metadata_Field('project_name', {}).assert_Is activities: {}, metadata: {}

      @.data_Project.project_Schema = ()-> return metadata: []
      @.check_Metadata_Field('project_name', {}).assert_Is activities: {}, metadata: {}                   # check when project_Schema returns an empty array


      @.data_Project.project_Schema = ()-> return metadata: [ 'aaa']                                      # check when project_Schema returns an value
      @.check_Metadata_Field('project_name', {}).assert_Is activities: {}, metadata: {aaa: ''}

      @.data_Project.project_Schema = ()-> return metadata: [ 'aaa', bbb:'xxx']                           # check when project_Schema returns an value and an object
      @.check_Metadata_Field('project_name', {}).assert_Is activities: {}, metadata: { aaa: '', '[object Object]': ''}    # this is ok(ish) for now

      @.data_Project.project_Schema = saved_Method

  it 'delete_Team', ->
    using data_Team, ->
      temp_Team = @.new_Team( project           ).assert_Size_Is(10).str()
      team_Path = @.team_Path(project, temp_Team).assert_File_Exists()
      @.get_Team_Data(        project, temp_Team).assert_Is_Object()
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
      data = @.get_Team_Data project, team
      data.metadata.team.assert_Is 'Team A'
      data.metadata._keys().assert_Is [ 'team','security-champion', 'source-code-repo','issue-tracking', 'wiki', 'ci-server', 'created-by' , 'hide-from-stats']

  it 'new_Team', ->    
    using data_Team, ->
      new_File_Id   = @.new_Team project
      new_File_Id.assert_Contains @.new_Team_Prefix
      new_File_Path = @.team_Path project, new_File_Id
      new_File_Path.assert_File_Exists()
      @.delete_Team(project, new_File_Id).assert_Is_True()
      new_File_Path.assert_File_Not_Exists()

  it 'rename_Team', ->
    using data_Team, ->
      team_Name = @.new_Team project
      new_Name  = 'new_name_'.add_5_Random_Letters()
      @.team_Path(project, team_Name).assert_Contains team_Name
      @.rename_Team project, team_Name, new_Name
      @.delete_Team(project, team_Name).assert_Is_False()
      @.delete_Team(project, new_Name ).assert_Is_True()

  it 'rename_Team (with bad data)', ->
    using data_Team, ->
      @.rename_Team(                           ).assert_Is_False()
      @.rename_Team(project                    ).assert_Is_False()
      @.rename_Team('aaaa'                     ).assert_Is_False()
      @.rename_Team(project, 'aabbcc'          ).assert_Is_False()
      @.rename_Team(project, 'aabbcc', 'cccc'  ).assert_Is_False()
      @.rename_Team(project, 'team-A', 'team-A').assert_Is_False()


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

      
        

  