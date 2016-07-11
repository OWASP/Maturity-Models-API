Api_Base   = require './Api-Base'
Routes       = require '../server/Routes'

#express      = require 'express'

class Api_Routes extends Api_Base
  constructor: (options)->
    @.options      = options || {}
    #@.router       = express.Router()
    @.app          = @.options.app
    @.routes       = new Routes(app:@.app)
    super()

  add_Routes: ()=>
    @.add_Route 'get', '/routes'         , @.list
    @.add_Route 'get', '/routes/list'    , @.list_Raw
    @.add_Route 'get', '/routes/list-raw', @.list_Fixed
    @

      
  list: (req, res)=>
    data =
      raw  : @.routes.list_Raw()
      fixed: @.routes.list_Fixed()
    res.send data

  list_Fixed: (req, res)=>
    res.send @.routes.list_Fixed()    

  list_Raw: (req, res)=>
    res.send @.routes.list_Raw()


module.exports = Api_Routes