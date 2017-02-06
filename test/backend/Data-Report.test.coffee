Data_Reports = require '../../src/backend/Data-Reports'

describe.only 'backend | Data_Reports', ->

  data_Reports = null
  project      = null
  team         = null

  beforeEach ->
    project   = 'bsimm'
    team      = 'team-A'
    data_Reports = new Data_Reports()

  it 'constructor', ->
    using data_Reports, ->
      @.data_Team   .constructor.name.assert_Is 'Data_Team'
      @.data_Project.constructor.name.assert_Is 'Data_Project'

#      console.log  @.data_Team.data_Project._keys()
#      console.log  @.data_Team.data_Project.project_Path_Root(project).parent_Folder().folder_Name()
#      console.log @.data_Team._keys()

  it 'create_Report_For_All_Teams', ->
    using data_Reports, ->
      assert_Is_Null @.create_Report_For_All_Teams()
      using @.create_Report_For_All_Teams(project), ->
        @.file_Name().assert_Is 'teams.md'
        @.assert_File_Exists()

  it 'create_Report_For_Team', ->
    using data_Reports, ->
      assert_Is_Null @.create_Report_For_Team()
      assert_Is_Null @.create_Report_For_Team(project)
      using @.create_Report_For_Team(project, team), ->
        @.file_Name().assert_Is 'team-A.md'
        @.assert_File_Exists()


  it 'reports_Path', ->
    using data_Reports, ->
      assert_Is_Null @.reports_Path()
      using @.reports_Path(project), ->
          @.parent_Folder().assert_Is data_Reports.data_Project.project_Path_Root(project)
          @.parent_Folder().file_Name().assert_Is 'BSIMM-Graphs-Data'
          @.file_Name().assert_Is 'reports'
          @.assert_Folder_Exists()



