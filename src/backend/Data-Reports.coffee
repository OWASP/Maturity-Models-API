Data_Team = require './Data-Team'

class Data_Reports
  constructor: ()->
    @.data_Team     = new Data_Team();
    @.data_Project  = @.data_Team.data_Project

  create_Report_For_All_Teams: (project)=>
    file = @.reports_Path(project)?.path_Combine('teams.md')
    if file
      content  = "## Teams in project #{project}:\n\n"
      for team in @.data_Team.teams_Names(project)
        content += "- [#{team}](#{team}.md)\n"
      content.save_As(file)
    return file || null

  create_Report_For_Team: (project, team)=>
    folder = @.reports_Path(project)?.path_Combine(team)?.folder_Create()
    console.log folder
    if folder?.folder_Exists() and team
      file   = folder.path_Combine("#{team}.md")
      if file
        content  = "## Team: #{team}\n\n"

        content += '```markdown\n'
        content += @.data_Team.get_Team_Data(project, team).metadata.json_Pretty()
        content += '```'

        content.save_As(file)

    return file || null


  reports_Path: (project)=>
    path = @.data_Project.project_Path_Root(project)?.path_Combine('reports')         # add 'reports' to the current project root
                         .folder_Create()                                             # ensure folder exists
    return path || null                                                               # return null if path was not valid

module.exports = Data_Reports