Api_Base     = require './Api-Base'
Data_Project = require '../backend/Data-Project'

class Api_Project extends Api_Base
  constructor: ()->
    @.data_Project = new Data_Project()
    super()

  add_Routes: ()=>
    @.add_Route 'get', '/project/caches/clear'           , @.caches_Clear
    @.add_Route 'get', '/project/get/:project'           , @.get
    @.add_Route 'get', '/project/list'                   , @.list
    @.add_Route 'get', '/project/schema/:project'        , @.schema
    @.add_Route 'get', '/project/schema-details/:project', @.schema_Details
    @

  caches_Clear: (req,res)=>
    @.data_Project.clear_Caches()
    res.json { status: 'OK' }

  get: (req,res)=>
    project = req.params?.project
    res.json @.data_Project.project_Files(project)._keys()

  list: (req,res)=>
    res.json @.data_Project.ids()

  schema: (req,res)=>
    project = req.params?.project
    res.json @.data_Project.project_Schema(project)

  schema_Details: (req,res)=>
    project = req.params?.project
    res.json @.data_Project.project_Schema_Details(project)

module.exports = Api_Project