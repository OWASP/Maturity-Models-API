Data_Radar = require '../../../src/backend/Data-Radar'
Data_Team  = require '../../../src/backend/Data-Team'

describe 'bugs | backend | Data-Project', ->

  it 'Fix Radar bug in OwaspSAMM graph - #164 (prob with get_Radar_Data)', ->
    project = 'samm'
    team    = 'level-1'
    using  new Data_Radar(), ->
      using @.get_Radar_Data(project,team), ->
        #console.log @
        @.axes.assert_Size_Is 12
        @.axes[0  ].value.assert_Is 1.125
        @.axes[1  ].value.assert_Is 1
        @.axes[11 ].value.assert_Is 1
        (@.axes[0 ].value is undefined).assert_Is_False()
        (@.axes[1 ].value is undefined).assert_Is_False()
        (@.axes[11].value is undefined).assert_Is_False()

  # the bug is happening in the map_Data function

  it 'Fix Radar bug in OwaspSAMM graph - #164 (map_Data method)  ', ->
    keys_BSIMM = [ 'SM', 'CP', 'T' , 'AM', 'SFD', 'SR', 'AA', 'CR', 'ST', 'PT', 'SE', 'CMVM' ]
    keys_SAMM  = [ 'SM', 'PC', 'EG', 'TA', 'SR' , 'SA', 'DR', 'IR', 'ST', 'IM', 'EH', 'OE'   ]
    data_Radar = new Data_Radar()
    data_Team  = new Data_Team()
    team_Data_SAAM   = data_Team.get_Team_Data 'samm' , 'level-1'
    team_Data_BSIMM  = data_Team.get_Team_Data 'bsimm', 'level-1'

    radar_Fields_SAMM  = data_Radar.get_Radar_Fields 'samm'
    radar_Fields_BSIMM = data_Radar.get_Radar_Fields 'bsimm'
    mapping_SAMM       = data_Radar.map_Data radar_Fields_SAMM, team_Data_SAAM
    mapping_BSIMM      = data_Radar.map_Data radar_Fields_BSIMM, team_Data_BSIMM


    mapping_BSIMM._keys().assert_Is keys_BSIMM          # ok
    mapping_SAMM ._keys().assert_Is keys_SAMM          # wrong