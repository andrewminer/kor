#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

ClientConnection = require './client_connection'
WebSocket        = require 'socket.io'

########################################################################################################################

module.exports = class ClientPool

    constructor: (server)->
        if not server? then throw new Error 'server is required'

        @_clients      = {}
        @_server       = server
        @_serverSocket = null
        @_stopping     = null

    # Public Methods ###############################################################################

    start: (options={})->
        return if @_serverSocket?

        options.allowUpgrades ?= true
        options.path          ?= '/clientConnection'
        options.serveClient   ?= false
        options.transports    ?= ['websocket']

        @_serverSocket = new WebSocket @_server, options
        @_serverSocket.on c.io.event.connection, (s)=> @_onConnection s
        @_serverSocket.on c.io.event.disconnect, (s)=> @_onDisconnect s

        console.log "ws://... ready"

    stop: ->
        return w(true) unless @_serverSocket?

        if not @_stopping?
            @_stopping = w.defer()
            @_serverSocket.emit c.io.event.goodbye

        return @_stopping.promise

    # Private Methods ##############################################################################

    _onConnection: (clientSocket)->
        clientConnection = new ClientConnection clientSocket
        clientConnection.onConnect()

        @_clients[clientSocket.id] = clientConnection

    _onDisconnect: (clientSocket)->
        clientConnection = @_clients[clientSocket.id]
        return unless clientConnection

        clientConnection.onDisconnect()
        delete @_clients[clientSocket.id]

        if @_stopping? and _.keys(@_clients).length is 0
            @_stopping.resolve()
            @_stopping = null
