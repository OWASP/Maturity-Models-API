Data_Files   = require '../backend/Data-Files'
Data_Project = require '../backend/Data-Project'

class Routes
  constructor: (options)->
    @.options = options || {}
    @.app     = @.options.app
    @.data_Files   = new Data_Files()
    @.data_Project = new Data_Project()


  list_Raw: ()=>
    values = []
    if  @.app
      map_Stack = (prefix, stack)->                                         # method to map the express routes
        for item in stack                                                   # walk the stack object
          if item.route                                                     # if there is a route
            values.add(prefix + item.route.path)                            #   add it's path (using provided prefix)
          if item.handle?.stack                                             # if there are sub routes
            baseUrl = item.regexp.str().after('/^\\')                       #   hack to extract the base url
                                       .before_Last('\\/?(?=\\/|$)/i')      #   so that we don't have to change the use function (as seen here http://stackoverflow.com/a/31501504/262379)
                                       .remove('\\')                        #   (cases when there is a / in the url)

            map_Stack  baseUrl, item.handle.stack                           #   recursive call using the baseUrl calculated above
            
      map_Stack '', @.app._router?.stack                                    # start the mapping at the root
    
    values

  list_Fixed: ()=>
    keyword = ':team'
    default_Project = 'bsimm'      # Issue 129 - Routes.list_Fixed add logic to also map other variables (like project)
    list    = @.list_Raw()
    values  = list                 # create copy we can use without breaking the for loop
    for item,index in list
      #console.log item
      # if item.contains[':project']
      #  list[index] = item.replace ':project', project

      if item.contains keyword

        values = values.remove_If_Contains(item)

        for file in @.data_Files.files_Names(default_Project)
          values.add(item.replace(keyword, file)
                         .replace ':project', default_Project)
    values

module.exports = Routes
