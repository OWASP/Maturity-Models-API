Data_Radar   = require '../../../src/backend/Data-Radar'


describe 'bugs | backend | Data-Project', ->

  it.only 'bug on radar calculation', ->
    project       = 'bsimm'
    team          = 'team-A'
    data_Radar    = new Data_Radar()
    test_Data     = activities :  'SM.1.1': { value: 'Yes', proof: '' }, 'SM.1.2': { value: 'Yes', proof: '' }
    radar_Fields  = data_Radar.get_Radar_Fields project

    assert_Is_Undefined radar_Fields.axes[5].size               # this value needs to be defined

    result        = data_Radar.map_Data radar_Fields, test_Data

    result.SM.assert_Is 3                                       # this value is wrong, since is based number of fields in test_Data

