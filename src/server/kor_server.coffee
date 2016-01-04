#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

ClientPool = require './client_pool'
express    = require 'express'
http       = require 'http'
middleware = require './middleware'
routes     = require './routes'

############################################################################################################

module.exports = class KorServer

    constructor: (port)->
        if not port? then throw new Error 'port is mandatory'
        if not _.isNumber port then throw new Error 'port must be a number'
        @port = parseInt port

        app = express()
        app.disable 'etag'

        middleware.installBefore app
        app.use routes
        middleware.installAfter app

        @httpServer = http.createServer app
        @clientPool = new ClientPool @httpServer

    start: ->
        w.promise (resolve, reject)=>
            @httpServer.once 'error', (error)-> reject error
            @httpServer.listen @port, =>
                console.log "http://... ready on port #{@port}"
                @clientPool.start()
                console.log "Kor is ready.\n\n"
                resolve this

    stop: ->
        @clientPool.stop()
            .then =>
                w.promise (resolve, reject)=>
                    console.log "server is shutting down"
                    @httpServer.close() =>
                        resolve this
