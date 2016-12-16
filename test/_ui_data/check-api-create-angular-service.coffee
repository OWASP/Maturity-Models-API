# these are a special types of tests that will create a coffee file in the UI project which feeds the results 
# of the API calls directly into the $httpBackend

Server  = require '../../src/server/Server'
request = require 'supertest'


describe '_ui_data | create api , create angular service' ,->
  server       = null
  app          = null
  version      = '/api/v1'
  path_UI_Code = './code/ui/data'

  before ->
    server = new Server().setup_Server().add_Controllers()
    app    = server.app

  save_Data_Into_Data_Folder = (path, data)->
    file_Path = "#{path_UI_Code}/#{path.to_Safe_String()}.coffee"
    file_Path.parent_Folder().folder_Create()
    file_Data = "angular.module('MM_Graph').run ($httpBackend)-> $httpBackend.whenGET('#{path}').respond #{data.json_Str()}"
    file_Data.save_As file_Path
    file_Path.assert_File_Exists()


  make_Request_And_Save = (path)->
    request(app)
      .get(path).expect(200)
      .expect (res)->
        save_Data_Into_Data_Folder path, res.body

  #misc
  it 'api/v1/routes'              , -> make_Request_And_Save "#{version}/routes"
  it 'api/v1/project/list'        , -> make_Request_And_Save "#{version}/project/list"

  #bsimm
  it '/data/bsimm/level-1/radar'  , -> make_Request_And_Save "#{version}/data/bsimm/level-1/radar"
  it '/data/bsimm/level-2/radar'  , -> make_Request_And_Save "#{version}/data/bsimm/level-2/radar"
  it '/data/bsimm/level-3/radar'  , -> make_Request_And_Save "#{version}/data/bsimm/level-3/radar"
  it '/data/bsimm/team-A/score'   , -> make_Request_And_Save "#{version}/data/bsimm/team-A/score"
  it '/data/bsimm/team-A/radar'   , -> make_Request_And_Save "#{version}/data/bsimm/team-A/radar"
  it '/data/bsimm/radar/fields'   , -> make_Request_And_Save "#{version}/data/bsimm/radar/fields"
  it '/team/bsimm/new'            , -> make_Request_And_Save "#{version}/team/bsimm/new"
  it '/team/bsimm/get/team-A'     , -> make_Request_And_Save "#{version}/team/bsimm/get/team-A"

  it '/project/get/bsimm'         , -> make_Request_And_Save "#{version}/project/get/bsimm"
  it '/project/schema/bsimm'      , -> make_Request_And_Save "#{version}/project/schema/bsimm"
  it '/project/scores/bsimm'      , -> make_Request_And_Save "#{version}/project/scores/bsimm"
  it '/project/activities/bsimm'  , -> make_Request_And_Save "#{version}/project/activities/bsimm"

  #samm
  it '/project/activities/samm'   , -> make_Request_And_Save "#{version}/project/activities/samm"
  it '/project/scores/samm'       , -> make_Request_And_Save "#{version}/project/scores/samm"
  it '/project/schema/samm'       , -> make_Request_And_Save "#{version}/project/schema/samm"
  it '/team/samm/get/team-A'      , -> make_Request_And_Save "#{version}/team/samm/get/team-A"
  it '/team/samm/get/team-E'      , -> make_Request_And_Save "#{version}/team/samm/get/team-E"
