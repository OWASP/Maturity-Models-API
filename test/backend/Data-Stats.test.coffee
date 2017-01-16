Data_Stats = require '../../src/backend/Data-Stats'


describe 'backend | Data-Stats', ->
  data_Stats = null
  project    = null
  team       = null

  beforeEach ->
    project    = 'bsimm'
    team       = 'team-A'
    data_Stats = new Data_Stats()

  it 'constructor',->
    using data_Stats, ->
      @.constructor.name.assert_Is 'Data_Stats'
      @.data_Team   .constructor.name.assert_Is 'Data_Team'
      @.data_Project.constructor.name.assert_Is 'Data_Project'

  it 'activity_Scores', ->
    using data_Stats, ->
      result = @.activity_Scores project
      result['SM.1.1'].Yes.assert_Contains ['team-A', 'team-B']
      result['SM.1.1'].No.size().assert_Is_Bigger_Than 0
      result._keys().size().assert_Is_Bigger_Than 100

  it 'activity_Scores (hide-from-stats workflow)', ->
    using data_Stats, ->
      team_Name = @.data_Team.create_Team(project)
      @.activity_Scores(project)['SM.1.1'].No.assert_Contains team_Name
      team_Data = @.data_Team.get_Team_Data project, team_Name
      team_Data.metadata['hide-from-stats'] = 'yes'
      @.data_Team.save_Team(project, team_Name, team_Data).assert_Is_True()
      @.data_Team.get_Team_Data(project, team_Name).metadata['hide-from-stats'].assert_Is 'yes'
      @.activity_Scores(project)['SM.1.1'].No.assert_Not_Contains team_Name
      @.activity_Scores(project)['SM.1.1'].Yes.assert_Not_Contains team_Name

      team_Data.metadata['hide-from-stats'] = 'no'
      @.data_Team.save_Team(project, team_Name, team_Data).assert_Is_True()
      @.data_Team.get_Team_Data(project, team_Name).metadata['hide-from-stats'].assert_Is 'no'
      @.activity_Scores(project)['SM.1.1'].No.assert_Contains team_Name
      @.activity_Scores(project)['SM.1.1'].Yes.assert_Not_Contains team_Name

      @.data_Team.delete_Team(project, team_Name).assert_Is_True()

  it 'team_Score', ->
    using data_Stats, ->
      using @.team_Score(project, team),->
        @.assert_Is  { 'level_1':
                          value     : 19.4
                          percentage: '50%'
                          activities: 39
                       'level_2':
                          value     : 13.4
                          percentage: '34%'
                          activities: 40
                       'level_3':
                          value     : 4.8
                          percentage: '15%'
                          activities: 33 }

  it 'team_Score (no project or team)', ->
    using data_Stats, ->
      using @.team_Score(),->
        @.assert_Is {} 

  it 'teams_Scores', ->
    @.timeout 4000
    using data_Stats, ->
      using @.teams_Scores(project),->
        @[team].level_1.value.assert_Is 19.4


  it 'check performance issue with @.teams_Scores', ->

    using data_Stats, ->
      start =  Date.now()
      using @.teams_Scores(project),->
        #console.log (Date.now() - start)
        (Date.now() - start).assert_In_Between 1, 100
        @[team].level_1.value.assert_Is 19.4