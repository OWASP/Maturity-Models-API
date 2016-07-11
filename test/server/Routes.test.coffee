Routes   = require '../../src/server/Routes'
Server   = require '../../src/server/Server'
expresss = require 'express' 

describe 'server | Routes', ->
  
  app = null
  
  beforeEach ->
    app = new Server().setup_Server().app
    
  it 'construtor', ->
    using new Routes(app: 'app'),->
      @.options.assert_Is app: 'app'
      @.app.assert_Is 'app'
      @.data_Files  .constructor.name.assert_Is 'Data_Files'      

  it 'list_Raw', ->
    using new Routes() , ->
      @.list_Raw().assert_Is []
    
    using new Routes(app: app) , ->
      @.list_Raw().assert_Is 	[ '/ping']

  it 'list_Fixed', ->
    using new Routes() , ->
      @.list_Fixed().assert_Is []

    using new Routes(app: app) , ->
      @.list_Fixed().assert_Is 	[ '/ping']

  it 'list (with Router() routes)', ->
    app._router.stack.size().assert_Is 4                     # default mappings

    router = expresss.Router()
    router.get  '/test---123', ->                              # create new routes using Router
    router.post '/test---456', ->
    app   .use  '/aaaa---789', router                          # add it to the main route
    app._router.stack.size().assert_Is 5

    #console.log app._router.stack
    using new Routes(app: app) , ->
      @.list_Raw().assert_Is [ '/ping'
                           '/aaaa---789/test---123'
                           '/aaaa---789/test---456' ]

  # Issue 128 - Add add test for Routes.list_Fixed
  #it 'list_Fixed', ->
