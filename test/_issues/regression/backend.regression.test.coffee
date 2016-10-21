Data_Radar = require '../../../src/backend/Data-Radar'
Data_Team  = require '../../../src/backend/Data-Team'

describe 'bugs | backend | Data-Project', ->


  it 'JS Decimal bug is causing Radar calculations to be wrong #80', ->
    project      = 'bsimm'
    team         = 'team-A'
    data_Radar   = new Data_Radar()
    data_Team    = new Data_Team()
    test_Data    = data_Team.get_Team_Data(project, team)
    radar_Fields = data_Radar.get_Radar_Fields project
    result       = data_Radar.map_Data radar_Fields, test_Data

    wrong_Value   = 0.6000000000000001
    result['CMVM'].assert_Is_Not wrong_Value          # was wrong value originally
    result['SE'  ].assert_Is_Not wrong_Value

    result['CMVM'].assert_Is 1.0714
    result['SE'  ].assert_Is 1.25

  it 'Fix Radar bug in OwaspSAMM graph - #164', ->
    project = 'samm'
    using  new Data_Radar(), ->
      using @.get_Radar_Fields(project), ->
        @.axes.assert_Size_Is 12
        @.axes.second().assert_Is_Not { axis: "Conf & Vuln Management" , xOffset: -110, value: 0}    # this was wrong (using BSIMM value)
        @.axes.second().assert_Is_Not { axis: "Operational Enablement" , xOffset: -110, value: 0}    # this is what it should be (SAMM value)