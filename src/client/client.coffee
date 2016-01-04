#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

############################################################################################################

# Allow Node.js-style `global` in addition to `window`
if typeof(global) is 'undefined'
    window.global = window

global._  = require '../common/underscore'
global.$  = require 'jquery'
global.c  = require '../common/constants'
global.π  = Math.PI
global.ε  = 0.0001
global.d3 = require 'd3'
global.w  = require 'when'

global.Backbone = require 'backbone'
global.Backbone.$ = $

########################################################################################################################

connect  = require 'socket.io-client'
Game     = require './game/game'
GameView = require './views/game_view'
scales   = require './views/scales'

socket = connect 'http://localhost:8080', path:'/clientConnection', transports:['websocket']
socket.emit c.io.event.message, status:'launched', message:'Hello server!'
socket.on c.io.event.connect, ->
    console.info "connected to server"
socket.on c.io.event.disconnect, ->
    console.info "disconnected from server"
socket.on c.io.event.message, (data)->
    console.info "server said: #{JSON.stringify(data)}"
socket.on c.io.event.goodbye, ->
    console.warn 'server is disconnecting'
    # socket.disconnect()

root = d3.select('.game-screen').append 'svg'
c.readCanvas $('.game-screen svg')
scales.computeScales()

global.game = new Game
game.view = new GameView root, game
game.view.render()

game.begin()

console.log "client is ready"
