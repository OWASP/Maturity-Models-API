describe 'data | test-data', ->
  
  it '(regression) Issue #113 - Upgrade team data to latest schema (check all json files)', ->

    check_Folder = (teams_Data)->
      files = teams_Data.files_Recursive('.json')
      for file in files
        file_Data = file.load_Json()
        file_Data.activities?._keys().assert_Not_Contains 'Governance'

    check_Folder './data/BSIMM-Graphs-Data/teams'
    check_Folder './data/OpenSAMM-Graphs-Data/teams'
