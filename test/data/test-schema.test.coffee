Data_Project = require '../../src/backend/Data-Project'

describe 'data | test-schema', ->

  schema       = null

  beforeEach ->
    project = 'bsimm'
    schema = new Data_Project().project_Schema project

  it 'load team-schema data', ->
    using schema, ->
      @                     ._keys().assert_Is        [  'config'            , 'metadata'           , 'domains'         , 'practices'     , 'activities'                                         ]
      @.config              ._keys().assert_Is        [  'schema'            , 'version'                                                                                                         ]
      @.metadata                    .assert_Is        [  'team'              , 'security-champion'  , 'source-code-repo', 'issue-tracking', 'wiki', 'ci-server', 'created-by' , 'hide-from-stats']
      @.domains             ._keys().assert_Is        [  'Governance'        , 'Intelligence'       , 'SSDL Touchpoints', 'Deployment'                                                           ]
      @.practices           ._keys().assert_Contains  [  'Strategy & Metrics', 'Compliance & Policy', 'Training'                                                                                 ]
      @.activities          ._keys().assert_Contains  [  'SM.1.1'            , 'SM.1.2'             , 'SM.1.3'          , 'SM.1.4'                                                               ]
      @.activities['SM.1.1']        .assert_Is        {  "level" :"1"        , "name" : "Publish process (roles, responsibilities, plan), evolve as necessary"                                   }



