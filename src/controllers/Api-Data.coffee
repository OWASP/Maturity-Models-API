Api_Base     = require './Api-Base'
Data_Radar   = require '../backend/Data-Radar'
Data_Team    = require '../backend/Data-Team'
Data_Stats   = require '../backend/Data-Stats'

class Api_Data extends Api_Base
  constructor: ->
    @.data_Radar = new Data_Radar()
    @.data_Team  = new Data_Team()
    @.data_Stats = new Data_Stats()

    super()

  add_Routes: ->
    @.add_Route 'get' , '/project/scores/:project'    , @.teams_Scores
    @.add_Route 'get' , '/data/:project/:team/radar'  , @.team_Radar
    @.add_Route 'get' , '/data/:project/:team/score'  , @.team_Score
    @

  teams_Scores : (req, res)=>
    project = req.params?.project
    res.json @.data_Stats.teams_Scores project

  team_Radar: (req, res)=>
    project = req.params?.project
    team    = req.params?.team

    if project and team
      file_Data  = @.data_Team.get_Team_Data project, team
      radar_Data = @.data_Radar.get_Radar_Data file_Data
      res.json radar_Data

  team_Score: (req, res)=>
    project = req.params?.project
    team    = req.params?.team
    res.json @.data_Stats.team_Score project, team



module.exports = Api_Data