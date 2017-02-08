Api_Base     = require './Api-Base'
Data_Team    = require '../backend/Data-Team'
Data_Reports = require '../backend/Data-Reports'
Routes       = require '../server/Routes'

class Api_Team extends Api_Base
  constructor: (options)->
    @.options         = options || {}
    @.data_Reports    = new Data_Reports()
    @.data_Team       = @.data_Reports.data_Team
    #@.data_Team       = new Data_Team()

    super()

  add_Routes: ()=>
    @.add_Route 'get' , '/team/:project/list'               , @.list
    @.add_Route 'get' , '/team/:project/delete/:team'       , @.delete
    @.add_Route 'get' , '/team/:project/get/:team'          , @.get
    @.add_Route 'get' , '/team/:project/new'                , @.new
    @.add_Route 'get' , '/team/:project/rename/:team/:name' , @.rename
    @.add_Route 'post', '/team/:project/save/:team'         , @.save
    @

  delete: (req, res)=>
    project = req.params?.project
    team    = req.params?.team
    if @.data_Team.delete_Team project, team
      res.send status: 'Team Deleted'
    else
      res.send error: 'Team deletion failed'
      
  get: (req, res)=>
    project = req.params?.project
    team    = req.params?.team                            # get team name from path
                                                          # validation is needed here, see https://github.com/DinisCruz/BSIMM-Graphs/issues/18
    data = @.data_Team.get_Team_Data project, team        # get data
    if data

      res.setHeader('Content-Type', 'application/json');  # Issue 135 - API-Team add better way to handle pretty support and set JSON header
      
      if req.query?.pretty is ""                          # Issue 135 - API-Team add better way to handle pretty support and set JSON header
        return res.send data.json_Pretty()
      else
        return res.send data
    else
      res.send { error: 'not found' }

  new: (req, res)=>
    project   = req.params?.project
    team_Name = @.data_Team.new_Team project
    if team_Name
      res.send status: 'Ok', team_Name: team_Name
    else
      res.send error: 'New team creation failed'

  list: (req, res)=>
    project = req.params?.project
    res.send @.data_Team.teams_Names(project)

  rename: (req,res)=>
    project = req.params?.project
    team    = req.params?.team
    name    = req.params?.name
    res.send @.data_Team.rename_Team project, team, name

  save: (req, res)=>
    project  = req.params?.project
    filename = req.params?.team                                  # get filename from QueryString
    if typeof req.body is 'object'
      data = req.body.json_Pretty()
    else
      data = req.body                                              # from post body
    if filename and data                                           # check that both exist
      if @.data_Team.set_Team_Data_Json project, filename, data    # if set_Team_Data_Json was ok
        if @.data_Reports.create_Report_For_Team project, filename # if report was created ok
          return res.send status: 'file saved ok'                   # send an ok status
    res.send error: 'save failed'                                   # if something failed send generic error message

module.exports = Api_Team











