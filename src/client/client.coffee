#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

############################################################################################################

# Allow Node.js-style `global` in addition to `window`
if typeof(global) is 'undefined'
    window.global = window

global._ = require '../common/underscore'
global.c = require '../common/constants'
global.w = require 'when'

########################################################################################################################

Game     = require './game/game'
GameView = require './views/game_view'


root = d3.select('.game-screen').append 'svg'
    .attr 'width', c.canvas.width
    .attr 'height', c.canvas.height

global.game = new Game
game.view = new GameView root, game
game.view.render()

game.begin()

console.log "client is ready"
