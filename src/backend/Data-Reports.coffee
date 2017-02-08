Data_Team = require './Data-Team'

String::line_Before = -> '\n' + String(@)

String::line = (count)->
  count = 1 if not count
  result = String(@)
  for i in [0...count]
      result += '\n'
  result

class Data_Reports
  constructor: ()->
    @.data_Team     = new Data_Team();
    @.data_Project  = @.data_Team.data_Project

  create_Report_For_All_Teams: (project)=>
    file = @.reports_Path(project)?.path_Combine('readme.md')
    if file
      content  = "## Teams in project #{project}:\n\n"
      for team in @.data_Team.teams_Names(project)
        content += "- [#{team}](#{team}/readme.md)\n"
        @.create_Report_For_Team project, team
      content.save_As(file)
    return file || null

  create_Report_For_Team: (project, team)=>
    folder = @.reports_Path(project)?.path_Combine(team)?.folder_Create()

    if folder?.folder_Exists() and team
      file   = folder.path_Combine("readme.md")
      if file
        content   = "## Team: #{team}".line(2)
        team_Data = @.data_Team.get_Team_Data(project, team)
        schema    = @.data_Project.project_Schema(project)

        # Metadata
        content += "### Metadata".line() +
                   "| key | value | ".line()  +
                   "|-----|-------| ".line()

        for key, value of team_Data.metadata
          content += "| #{key} | #{value} |".line()

        # Activities
        content += "### Activities".line_Before().line() +
                   "| key | level | activity | value | proof | ".line()  +
                   "|-----|-------|----------|-------|-------|".line()

        for key, activity of team_Data.activities
          level = schema.activities[key]?.level
          name  = schema.activities[key]?.name
          content += "| #{key} | #{level} | #{name} |#{activity.value} | #{activity.proof}".line()


        content += "".line(3) + "[back to main page](../readme.md)"
        content.save_As(file)

    return file || null


  reports_Path: (project)=>
    path = @.data_Project.project_Path_Root(project)?.path_Combine('reports')         # add 'reports' to the current project root
                         .folder_Create()                                             # ensure folder exists
    return path || null                                                               # return null if path was not valid

module.exports = Data_Reports