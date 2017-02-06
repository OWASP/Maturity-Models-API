Data_Team    = require './Data-Team'
Data_Project = require './Data-Project'

class Data_Stats
  constructor: ->
    @.data_Team    = new Data_Team()
    @.data_Project = new Data_Project()
    @.score_Yes    = 1
    @.score_No     = 0
    @.score_NA     = 1
    @.score_Maybe  = 1 # 0.2   (for now treat Maybe as yes)

  activity_Scores: (project)=>

    all_Scores = {}
    teams = @.data_Team.teams_Names project
    for team in teams

      team_Data   = @.data_Team.get_Team_Data(project, team)
      if team_Data?.metadata['hide-from-stats'] isnt 'yes'
        if team_Data?.activities
          for key, activity of team_Data?.activities
            if key and activity.value
              all_Scores[key] ?= {}
              all_Scores[key][activity.value] ?= []
              all_Scores[key][activity.value].push team

    return all_Scores

  team_Score: (project, team)=>
    scores = {}

    if project and team
      schema = @.data_Project.project_Schema(project)
      data   = @.data_Team.get_Team_Data(project, team)

      if data and data.metadata['hide-from-stats'] isnt 'yes'     # don't process items that have been marked as hidden
        for key, activity of schema.activities        
          score = scores["level_#{activity.level}"] ?= { value: 0, percentage:'', activities: 0}
          score.activities++                
          value = data.activities?[key]?.value
          if value
            switch value
              when 'Yes'   then score.value += @.score_Yes
              when 'No'    then score.value += @.score_No
              when 'NA'    then score.value += @.score_NA
              when 'Maybe' then score.value += @.score_Maybe
            
        for key,score of scores
          score.value      = score.value.to_Decimal()
          score.percentage = Math.round((score.value / score.activities) * 100) + '%'
    return scores

  teams_Scores: (project)=>
    all_Scores = {}
    for team in @.data_Team.teams_Names(project)
      score = @.team_Score project, team
      if score?.level_1
        all_Scores[team] = score
    all_Scores



module.exports = Data_Stats  