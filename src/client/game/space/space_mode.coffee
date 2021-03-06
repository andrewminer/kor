#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

GameMode   = require '../game_mode'
PlayerShip = require './player_ship'
Sector     = require './sector'

########################################################################################################################

module.exports = class SpaceMode extends GameMode

    constructor: (name)->
        @playerShip = new PlayerShip 'cargo-shuttle'
        @sector     = new Sector 0, 0
        super name

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        keyUpCommands:
            get: ->
                27: '_returnToShip' # esc

    # GameMode Overrides ###########################################################################

    begin: ->
        w.all @sector.load(), @playerShip.load()
            .then =>
                @playerShip.enterSector @sector

    enterMode: ->
        game.keyboard.allowMultiple = true
        game.keyboard.registerCommands this
        game.keyboard.registerCommands @playerShip
        super

    leaveMode: ->
        game.keyboard.unregisterCommands @playerShip
        game.keyboard.unregisterCommands this
        super

    onGameStep: ->
        @sector.onGameStep()
        @playerShip.onGameStep()

    # Private Methods ##############################################################################

    _returnToShip: ->
        game.pushTransition 'fadeOut', 'fadeIn'
        game.changeGameMode 'world'
        return w(true)
