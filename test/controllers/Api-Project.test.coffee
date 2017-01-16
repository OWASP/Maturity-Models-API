Api_Project = require '../../src/controllers/Api-Project'

describe 'controllers | Api-Project', ->
  api_Project = null

  before ->
    using new Api_Project(), ->
      api_Project = @

  it 'constructor', ->
    using api_Project, ->
      @.constructor.name.assert_Is 'Api_Project'      
      @.data_Project.constructor.name.assert_Is 'Data_Project'
      @.router.assert_Is_Function()

  it 'add_Routes', ()->
    using new Api_Project(), ->
      @.add_Routes()
      @.router.stack.assert_Size_Is 5

  it 'caches_Clear', ()->
    res =
      json: (data)->
        data.assert_Is status : 'OK'

    using new Api_Project(), ->
      @.caches_Clear(null, res)

  it 'get (null)', ()->
    req = params : team : null
    res = json: (data)-> data.assert_Is []
    new Api_Project().get(req, res)

  it 'get (bsimm)', ()->
    req =
      params : project : 'bsimm'

    res =
      json: (data)->
        data.assert_Contains [ 'team-A','team-B']

    using new Api_Project(), ->
      @.get(req, res)

  it 'get (samm)', ()->
    req =
      params : project : 'samm'

    res =
      json: (data)->
        data.assert_Contains ['team-F']

    using new Api_Project(), ->
      @.get(req, res)

  it 'list', ()->
    res =
      json: (data)->
        data.assert_Contains ['bsimm', 'samm']

    using new Api_Project(), ->
      @.list(null, res)

  it 'schema', ()->
    req =
      params : project : 'bsimm'

    res =
      json: (data)->
        data.config.schema.assert_Is 'bsimm'

    using new Api_Project(), ->
      @.schema(req, res)

  it 'schema-details', ()->
    req =
      params : project : 'bsimm'

    res =
      json: (data)->
        data.activities['SM.1.1']._keys().assert_Is [ 'description', 'resources', 'objective', 'proof' ]

    using new Api_Project(), ->
      @.schema_Details(req, res)
