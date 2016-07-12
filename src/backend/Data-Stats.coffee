Data_Team    = require './Data-Team'
Data_Project = require './Data-Project'

class Data_Stats
  constructor: ->
    @.data_Team    = new Data_Team()
    @.data_Project = new Data_Project()
    @.score_Yes    = 1
    @.score_No     = 0
    @.score_NA     = 1
    @.score_Maybe  = 0.2

  team_Score: (project, team)=>
    scores = {}

    if project and team
      schema = @.data_Project.project_Schema(project)
      data   = @.data_Team.get_Team_Data(project, team)
      if data
        for key, activity of schema.activities        
          score = scores["level_#{activity.level}"] ?= { value: 0, percentage:'', activities: 0}
          score.activities++                
          value = data.activities?[key]
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
    for team in @.data_Team.teams_Names project
      all_Scores[team] = @.team_Score project, team
    all_Scores

module.exports = Data_Stats  