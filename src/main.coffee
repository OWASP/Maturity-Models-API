require './extra.methods'
Server = require('./server/Server');

start_Server = (options)->
  using new Server(options), ->
    @.run();
    console.log @.loggly.log mode: 'server-msg',msg: "Maturity-Model Server started on #{@.server_Url()}"
    return @

module.exports = start_Server