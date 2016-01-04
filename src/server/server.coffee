#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

KorServer = require './kor_server'

########################################################################################################################

global._ = require './underscore'
global.c = require './constants'
global.w = require 'when'

########################################################################################################################

port = parseInt process.argv[2]
port = if _.isNaN port then c.server.defaultPort else port

server = new KorServer port
server.start()

process.on 'SIGINT', ->
    server.stop().finally ->
        process.exit()
