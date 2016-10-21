Data_Project = require '../../src/backend/Data-Project'
Data_Team    = require '../../src/backend/Data-Team'

class Data_Radar

  constructor: (options)->    
    @.options      = options || {}
    @.score_Initial = 0
    @.score_Yes     = 1
    @.score_Maybe   = 0.25
    @.score_Max     = 3
    @.key_Yes       = 'Yes'
    @.key_Maybe     = 'Maybe'
    @.data_Project  = new Data_Project()
    @.data_Team     = new Data_Team()


  get_Radar_Fields: (project)=>

    result = axes : []
    schema = @.data_Project.project_Schema project
    for name, practice of schema.practices
      result.axes.push { axis: name , key: practice.key, xOffset: 1, value: 0 }

    return result
#    axes: [
#      { axis: "Strategy & Metrics"        , xOffset: 1    , value: 0},
#      { axis: "Conf & Vuln Management"    , xOffset: -110 , value: 0},
#      { axis: "Software Environment"      , xOffset: -30  , value: 0},
#      { axis: "Penetration Testing"       , xOffset: 1    , value: 0},
#      { axis: "Security Testing"          , xOffset: -25  , value: 0},
#      { axis: "Code Review"               , xOffset: -60  , value: 0},
#      { axis: "Architecture Analysis"     , xOffset: 1    , value: 0},
#      { axis: "Standards & Requirements"  , xOffset: 100  , value: 0},
#      { axis: "Security Features & Design", xOffset: 30   , value: 0},
#      { axis: "Attack Models"             , xOffset: 1    , value: 0},
#      { axis: "Training"                  , xOffset: 30   , value: 0},
#      { axis: "Compliance and Policy"     , xOffset: 100  , value: 0},
#    ]

  get_Radar_Data: (project, team)=>
    team_Data    = @.data_Team.get_Team_Data project, team
    radar_Fields = @.get_Radar_Fields project
    data         = @.map_Data radar_Fields, team_Data
    result       = axes: []
    for field in radar_Fields.axes
      result.axes.push { value: data[field.key]   }
    return result

  map_Data: (radar_Fields, team_Data)=>
    calculate = (prefix)=>
      score  = 0
      result = prefix: prefix, count :0 , yes_Count : 0, maybe_Count : 0
      for key,value of team_Data?.activities when key.starts_With(prefix)           #
        result.count++
        if value is @.key_Yes                                                       # add Yes value
          result.yes_Count++
        if value is @.key_Maybe                                                     # add Maybe value
          result.maybe_Count++
      score = ((result.yes_Count * @.score_Yes) + (result.maybe_Count * @.score_Maybe)) / result.count
      if score
        return (score * @.score_Max).to_Decimal()                                     # use to_Decimal, due to JS Decimal addition bug
      return 0.1


    result = {}
    for field in radar_Fields.axes
      result[field.key] = calculate field.key + "."
    return result
#      SM  : calculate 'SM.'   # Governance
#      CMVM: calculate 'CMVM.' # Deployment
#      SE  : calculate 'SE.'   # Deployment
#      PT  : calculate 'PT.'   # Deployment
#      ST  : calculate 'ST.'   # SSDL
#      CR  : calculate 'CR.'   # SSDL
#      AA  : calculate 'AA.'   # SSDL
#      SR  : calculate 'SR.'   # Intelligence
#      SFD : calculate 'SFD.'  # Intelligence
#      AM  : calculate 'AM.'   # Intelligence
#      T   : calculate 'T.'    # Governance
#      CP  : calculate 'CP.'   # Governance

    return data

module.exports = Data_Radar