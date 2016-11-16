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
      #@.activity_Scores(null).assert_Is {}
      #@.activity_Scores(-1  ).assert_Is {}
      #@.activity_Scores(""  ).assert_Is {}

      result = @.activity_Scores project

      console.log result

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


  # happens when number of teams is 150+
#  it 'Issue x - performance issue with @.teams_Scores', ->
#    @.timeout 4000
#
#    using data_Stats, ->
#      teams =  @.data_Team.teams_Names(project)
#      #teams.size().assert_Is_Bigger_Than 150
#      start =  Date.now()
#      using @.teams_Scores(project),->
#        console.log "final:  > " +  (Date.now() - start)
#        #(Date.now() - start).assert_Is_Bigger_Than 400  # this shouldn't be so high
#        #(Date.now() - start).assert_Is_Bigger_Than 3000  # this shouldn't be so high
#
#        #@[team].level_1.value.assert_Is_19.4