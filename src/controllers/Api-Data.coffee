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
    @.add_Route 'get' , '/project/scores/:project'       , @.teams_Scores       # rename to /teams/scores/:project
    @.add_Route 'get' , '/project/activities/:project'   , @.activities_Scores  # rename to /teams/activities/:project
    @.add_Route 'get' , '/teams/proofs/:project'         , @.teams_Proofs
    @.add_Route 'get' , '/data/:project/radar/fields'    , @.radar_Fields       # todo: rename to deal with 'radar' name conflic
    @.add_Route 'get' , '/data/:project/:team/radar'     , @.team_Radar
    @.add_Route 'get' , '/data/:project/:team/score'     , @.team_Score
    @

  activities_Scores : (req, res)=>
    project = req.params?.project
    res.json @.data_Stats.activity_Scores project

  radar_Fields: (req, res)=>
    project = req.params?.project
    res.json @.data_Radar.get_Radar_Fields project

  teams_Scores: (req, res)=>
    project = req.params?.project
    res.json @.data_Stats.teams_Scores project

  team_Radar: (req, res)=>
    project = req.params?.project
    team    = req.params?.team

    if project and team
      radar_Data  = @.data_Radar.get_Radar_Data project, team
      res.json radar_Data


  team_Score: (req, res)=>
    project = req.params?.project
    team    = req.params?.team
    res.json @.data_Stats.team_Score project, team


  teams_Proofs:  (req,res)=>
    project = req.params?.project
    res.json @.data_Team.teams_Proofs project


module.exports = Api_Data