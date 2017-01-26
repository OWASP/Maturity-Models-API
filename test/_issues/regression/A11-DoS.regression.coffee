require '../../../src/extra.methods'
Data_Project = require '../../../src/backend/Data-Project'
Data_Team   = require '../../../src/backend/Data-Team'
async        = require 'async'

# These tests represent regression tests for DoS attacks

describe '_issues | regression | A11 - DoS', ->

# https://github.com/DinisCruz/BSIMM-Graphs/issues/121
  it 'Issue 121 - Race condition on set_File_Data_Json method', (done)->
    # results:
    #   when count is 10   -> takes 106 ms       (80 ms    with no logging)
    #   when count is 100  -> takes 740 ms       (541 ms   with no logging)
    #   when count is 1000 -> takes 6,878 ms     (5,387 ms with no logging)
    using new Data_Team(), ->
      count         = 5                                                                   # number of attempts to do
      project       = 'bsimm'                                                             # target project
      team          = "save-test"                                                         # target team
      default_Value = 'will-be': 'changed by tests'                                       # default value of file_Data
      value_To_Skip = 9                                                                   # skip one to make sure logic is working

      save_File = (index, next)=>
        if index is value_To_Skip                                                         # skip this one
          #console.log "[skip ] #{index}"
          return next()
        #console.log "[start] #{index}"                                                   # log start

        10.random().wait =>                                                               # small random delay to force proper async
          file_Data = @.get_Team_Data(project,team)                                       # get data
          (file_Data[index] is undefined).assert_Is_True()                                # confirm value is not set already
          file_Data[index] = index                                                        # set test value
          @.set_Team_Data_Json(project,team, file_Data.json_Str()).assert_Is_True()       # save it
          @.get_Team_Data(project,team).assert_Is file_Data                               # confirm save happened ok
          #console.log "[end  ] #{index}"                                                 # log end
          next()

      values = [0..count]                                                                 # async array
      async.each values, save_File, =>                                                    # async call
        file_Data = @.get_Team_Data(project,team)                                         # get data (after last async execution
        for index in values                                                               # check that all values are in there
          if index is value_To_Skip                                                       # except this one
            (file_Data[index] is undefined).assert_Is_True()
          else
            file_Data[index].assert_Is index
        @.set_Team_Data_Json(project,team, default_Value.json_Str()).assert_Is_True()     # restore file to default value
        done()

  # https://github.com/DinisCruz/BSIMM-Graphs/issues/72
  # this issue is now even less problematic (after recent refactorings)
  # update (Oct 2016) after fix to "Performance issue on multiple Data_Project methods" #167
  #    this is even faster
  it 'Issue 72 - Project list gets data from File System and could cause DoS', ()->
    using new Data_Project(), ->
      start = Date.now();
      test_List = (index, next)=>
        @.projects().assert_Is_Object()
        next()

      #items = [0..0     ]  # 1    takes 0ms    (before it was 15ms   )
      items = [0..10   ]    # 10   takes 0ms    before #167 it was  20ms    (before it was 50ms   )
      items = [0..100  ]    # 100  takes 1ms    before #167 it was 70ms   (before it was 250ms  )
      items = [0..1000 ]    # 1000 takes 3ms    before #167 it was 320ms  (before it was 2250ms )
      #items = [0..5000 ]   # 5000 takes 15ms   before #167 it was 1698ms (before it was 12000ms)
      async.each items, test_List, ->
        duration = Date.now() - start
        #console.log duration
        duration.assert_In_Between 0, 40        # in travis we had execution times of less than 25ms


