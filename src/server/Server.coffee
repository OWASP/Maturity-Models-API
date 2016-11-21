require 'fluentnode'

FileStreamRotator = require('file-stream-rotator')

express           = require 'express'
load              = require 'express-load'
bodyParser        = require('body-parser');
d3                = require 'd3'
morgan            = require 'morgan'
Routes            = require './Routes'
Loggly            = require './Loggly'
Logsene           = require './Logsene'
Redirects         = require './Redirects'             # todo: move to a log service


class Server
  constructor: (options)->
    @.app      = null
    @.options  = options || {}
    @.server   = null
    @.port     = @.options.port || process.env.PORT || 3000

  setup_Server: =>    
    @.app = express()
    @.app.d3 = d3

    #bodyParser
    @.app.use bodyParser.json()

    # test route
    @.app.get '/ping', (req, res) =>          # todo: move to another location
      res.end 'pong'
    @

  add_Angular_Route: ()=>
    @.app.get '/view*', (req, res) =>
      res.sendFile __dirname.path_Combine('../../../ui/.dist/html/index.html')
    @

  add_Bower_Support: ()=>
    @.app.use '/lib',  express.static __dirname.path_Combine('../../../ui/bower_components')
    @.app.use '/ui' ,  express.static __dirname.path_Combine('../../../ui/.dist')
    @

  add_Controllers: ->
    api_Path  = '/api/v1'
    Api_Data    = require '../controllers/Api-Data'             # Refactor how controllers are loaded #96
    Api_Team    = require '../controllers/Api-Team'
    Api_Project = require '../controllers/Api-Project'
    Api_Routes  = require '../controllers/Api-Routes'

    @.app.use api_Path , new Api_Data(   ).add_Routes().router
    @.app.use api_Path , new Api_Team(   ).add_Routes().router
    @.app.use api_Path , new Api_Project().add_Routes().router
    
    @.app.use api_Path , new Api_Routes(app:@.app).add_Routes().router
    @
    
  add_Redirects: ->
    new Redirects(app:@.app).add_Redirects()
    @

  setup_Logging: =>
    #@.loggly = new Loggly().setup(@.app)
    @.logsene = new Logsene().setup(@.app)


  start_Server: =>
    @.server = @.app.listen @.port
  
  server_Url: =>
    "http://localhost:#{@.port}"

  routes: =>
    new Routes(app:@.app).list_Raw()

  run: (random_Port)=>
    if random_Port
      @.port = 23000 + 3000.random()
    @.setup_Server()
    @.setup_Logging()
    @.add_Angular_Route()
    @.add_Bower_Support()
    @.add_Controllers()
    @.add_Redirects()
    @.start_Server()

  stop: (callback)=>
    if @.server
      @.server.close =>
        callback() if callback

module.exports = Server