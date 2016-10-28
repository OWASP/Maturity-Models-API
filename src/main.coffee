require './extra.methods'
Server = require('./server/Server');

start_Server = (options)->
  using new Server(options), ->
    @.run();
    console.log @.loggly.log "------------------------------------------------------"
    console.log @.loggly.log "Maturity-Model Server started on #{@.server_Url()}"
    return @

module.exports = start_Server