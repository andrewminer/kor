#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class ClientConnection

    constructor: (socket)->
        if not socket? then throw new Error 'socket is required'
        @_clientSocket = socket
        @_clientSocket.on 'message', (data)=> @_onMessage data

    # Public Methods ###############################################################################

    onConnect: ->
        console.info "client #{@_clientSocket.id} connected"
        @_clientSocket.emit 'message', status:'connected', message:'Hello client!'

    onDisconnect: ->
        console.info "client #{@_clientSocket.id} disconnected"

    # Private Methods ##############################################################################

    _onMessage: (data)->
        console.log "client #{@_clientSocket.id} sent: #{JSON.stringify(data)}"
