Data_Radar = require '../../src/backend/Data-Radar'
Data_Team  = require '../../src/backend/Data-Team'

describe 'backend | Data-Project', ->
  data_Radar          = null
  project             = null
  team                = null
  test_Data           = null
  expected_Mapping    = null
  expected_Radar_Data = null

  beforeEach ->
    project = 'bsimm'
    team    = 'team-A'
    test_Data = new Data_Team().get_Team_Data(project, team)
    expected_Mapping    = { SM: 0.75, CMVM: 1.0714, SE: 1.25, PT: 2.4375, ST: 3, CR: 3, AA: 3, SR: 0.75, SFD: 0.25, AM: 0.9375, T: 1.3125, CP: 1.1667 }
    expected_Radar_Data = { axes: [ { value: 0.75 },{ value: 1.0714 },{ value: 1.25 },{ value: 2.4375 },{ value: 3 },{ value: 3 },{ value: 3 },{ value: 0.75 },{ value: 0.25 },{ value: 0.9375 },{ value: 1.3125 }, { value: 1.1667 } ] }
    data_Radar = new Data_Radar()

  it 'constructor',->
    using data_Radar, ->
      @.constructor.name.assert_Is 'Data_Radar'            


  it 'get_Radar_Fields', ->
    using data_Radar, ->
      using @.get_Radar_Fields(), ->
        @.axes.assert_Size_Is 12
        @.axes.first().assert_Is { axis: "Strategy & Metrics" , xOffset: 1, value: 0},

  it 'get_Radar_Data', ->
    using data_Radar, ->
      data = @.get_Radar_Data test_Data
      data.assert_Is expected_Radar_Data

  it 'map_Data (calculates radar values)', ->
    using data_Radar, ->
      data = @.map_Data test_Data
      data.assert_Is expected_Mapping

  it 'should return 0.1 on all fields when no data is provided', ->
    using new Data_Radar(), ->
      using @.get_Radar_Data(null), ->
        for axe in @.axes
          axe.value.assert_Is 0.1

  it 'Issue xyz - JS Decimal bug is causing Radar calculations to be wrong', ->
    using data_Radar, ->

      result =  @.map_Data(test_Data)

      wrong_Value   = 0.6000000000000001      
      result['CMVM'].assert_Is_Not wrong_Value
      result['SE'  ].assert_Is_Not wrong_Value

      result['CMVM'].assert_Is 1.0714
      result['SE'  ].assert_Is 1.25