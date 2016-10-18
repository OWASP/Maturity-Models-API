class Data_Radar

  constructor: (options)->    
    @.options      = options || {}
    @.score_Initial = 0
    @.score_Yes     = 1
    @.score_Maybe   = 0.25
    @.score_Max     = 3
    @.key_Yes       = 'Yes'
    @.key_Maybe     = 'Maybe'

  get_Radar_Data: (file_Data)=>
    data = []
    data.push @.get_Radar_Fields()
    #data.push @.get_Default_Data()           #todo this needs to be implemented as supporting multiple data sets
    #data.push map_Team_Data(level_1_Data)
    data.push @.get_Team_Data @.mapData(file_Data)
    data
      
  get_Radar_Fields: ()->
    axes: [
      { axis: "Strategy & Metrics"        , xOffset: 1    , value: 0},
      { axis: "Conf & Vuln Management"    , xOffset: -110 , value: 0},
      { axis: "Software Environment"      , xOffset: -30  , value: 0},
      { axis: "Penetration Testing"       , xOffset: 1    , value: 0},
      { axis: "Security Testing"          , xOffset: -25  , value: 0},
      { axis: "Code Review"               , xOffset: -60  , value: 0},
      { axis: "Architecture Analysis"     , xOffset: 1    , value: 0},
      { axis: "Standards & Requirements"  , xOffset: 100  , value: 0},
      { axis: "Security Features & Design", xOffset: 30   , value: 0},
      { axis: "Attack Models"             , xOffset: 1    , value: 0},
      { axis: "Training"                  , xOffset: 30   , value: 0},
      { axis: "Compliance and Policy"     , xOffset: 100  , value: 0},
    ]
    
  get_Team_Data: (data)->
    {
      axes: [
        {value: data.SM   },  # Strategy & Metrics
        {value: data.CMVM },  # Configuration & Vulnerability Management
        {value: data.SE   },  # Software Environment
        {value: data.PT   },  # Penetration Testing
        {value: data.ST   },  # Security Testing
        {value: data.CR   },  # Code Review
        {value: data.AA   },  # Architecture Analysis
        {value: data.SR   },  # Standards & Requirements
        {value: data.SFD  },  # Security Features & Design
        {value: data.AM   },  # Attack Models
        {value: data.T    },  # Training
        {value: data.CP   },  # Compliance and Policy
      ]
    }  

  mapData: (file_Data)=>
    calculate = (prefix)=>
      score  = 0
      result = prefix: prefix, count :0 , yes_Count : 0, maybe_Count : 0
      for key,value of file_Data?.activities when key.starts_With(prefix)           #
        result.count++
        if value is @.key_Yes                                                       # add Yes value
          result.yes_Count++
        if value is @.key_Maybe                                                     # add Maybe value
          result.maybe_Count++
      score = ((result.yes_Count * @.score_Yes) + (result.maybe_Count * @.score_Maybe)) / result.count
      if score
        return (score * @.score_Max).to_Decimal()                                     # use to_Decimal, due to JS Decimal addition bug
      return 0.1


    data =
      SM  : calculate 'SM.'   # Governance
      CMVM: calculate 'CMVM.' # Deployment
      SE  : calculate 'SE.'   # Deployment
      PT  : calculate 'PT.'   # Deployment
      ST  : calculate 'ST.'   # SSDL
      CR  : calculate 'CR.'   # SSDL
      AA  : calculate 'AA.'   # SSDL
      SR  : calculate 'SR.'   # Intelligence
      SFD : calculate 'SFD.'  # Intelligence
      AM  : calculate 'AM.'   # Intelligence
      T   : calculate 'T.'    # Governance
      CP  : calculate 'CP.'   # Governance

    return data

module.exports = Data_Radar