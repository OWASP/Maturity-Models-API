Data_Radar   = require '../../src/backend/Data-Radar'
Data_Team    = require '../../src/backend/Data-Team'

describe 'backend | Data-Project', ->
  data_Radar          = null
  project             = null
  team                = null
  test_Data           = null
  expected_Mapping    = null
  expected_Radar_Data = null

  beforeEach ->
    project             = 'bsimm'
    team                = 'team-A'
    expected_Mapping    = { SM: 0.75, CP: 1.1667, T: 1.3125, AM: 0.9375, SFD: 0.25, SR: 0.75, AA: 3, CR: 3, ST: 3, PT: 2.4375, SE: 1.25, CMVM: 1.0714 }
    expected_Radar_Data = { axes: [ { value: 0.75 },{ value: 1.1667 }, { value: 1.3125 }, { value: 0.9375 }, { value: 0.25 }, { value: 0.75 }, { value: 3 }, { value: 3 }, { value: 3 }, { value: 2.4375 }, { value: 1.25 },{ value: 1.0714 } ] }
    data_Radar          = new Data_Radar()

  it 'constructor',->
    using data_Radar, ->
      @.constructor.name.assert_Is 'Data_Radar'
      @.score_Initial.assert_Is 0
      @.score_Yes    .assert_Is 1
      @.score_Maybe  .assert_Is 0.25
      @.score_Max    .assert_Is 3
      @.key_Yes      .assert_Is 'Yes'
      @.key_Maybe    .assert_Is 'Maybe'
      @.data_Project .constructor.name.assert_Is 'Data_Project'
      @.data_Team    .constructor.name.assert_Is 'Data_Team'


  it 'get_Radar_Fields', ->
    using data_Radar, ->
      using @.get_Radar_Fields(project), ->
        @.axes.assert_Size_Is 12
        @.axes.first().assert_Is { axis: 'SM', name: "Strategy & Metrics" , key: 'SM', xOffset: 20, value: 0},


  it 'get_Radar_Data', ->
    using data_Radar, ->
      data = @.get_Radar_Data project, team
      data.assert_Is expected_Radar_Data


  it 'map_Data (calculates radar values)', ->
    team_Data  = new Data_Team().get_Team_Data project, team

    using data_Radar, ->
      radar_Fields = @.get_Radar_Fields project
      data = @.map_Data radar_Fields, team_Data
      data.assert_Is expected_Mapping

  it 'should return empty axes array when no data is provided', ->
    using new Data_Radar(), ->
      using @.get_Radar_Data(null), ->
        @.assert_Is axes: {}
#        for axe in @.axes
#          axe.value.assert_Is 0.1