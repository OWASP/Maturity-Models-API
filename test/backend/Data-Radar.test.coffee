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
    expected_Mapping    = {
      SM: 0.4091,
      CP: 0.8182,
      T: 0.875,
      AM: 0.375,
      SFD: 0.1071,
      SR: 0.45,
      AA: 0.6667,
      CR: 1.3636,
      ST: 2.6667,
      PT: 1.3929,
      SE: 1.5,
      CMVM: 0.8333 }
    expected_Radar_Data = { axes:
      [ { value: 0.4091 },
        { value: 0.8182 },
        { value: 0.875 },
        { value: 0.375 },
        { value: 0.1071 },
        { value: 0.45 },
        { value: 0.6667 },
        { value: 1.3636 },
        { value: 2.6667 },
        { value: 1.3929 },
        { value: 1.5 },
        { value: 0.8333 } ] }
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
        @.axes.first().assert_Is { axis: 'SM', name: "Strategy & Metrics" , key: 'SM', xOffset: 20, value: 0 , size:11}


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

  it 'get_Radar_Data should return empty axes array when no data is provided', ->
    using new Data_Radar(), ->
      using @.get_Radar_Data(null), ->
        @.assert_Is axes: {}

  it 'map_Data should use 0.1 as default value', ->
    using data_Radar, ->
      radar_Fields = @.get_Radar_Fields project
      data         = @.map_Data radar_Fields, { axes: {} }
      data.values().unique().assert_Is [ 0.1 ]


