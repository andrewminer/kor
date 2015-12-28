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

Game     = require './game/game'
GameView = require './views/game_view'
scales   = require './views/scales'

root = d3.select('.game-screen').append 'svg'
c.readCanvas $('.game-screen svg')
scales.computeScales()

global.game = new Game
game.view = new GameView root, game
game.view.render()

game.begin()

console.log "client is ready"
