#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

GameMode = require '../game_mode'
Player   = require './player'
Room     = require './room'
World    = require './world'

########################################################################################################################

module.exports = class WorldMode extends GameMode

    constructor: (name)->
        @_player     = new Player
        @_worldStack = []
        super name

    # Public Methods ###############################################################################

    popWorld: ->
        worldData = @_worldStack.pop()
        return unless worldData?

        oldWorld = @world
        newWorld = worldData.world
        @world   = null

        newWorld.enter @_player, worldData.exit
            .then =>
                game.pushTransition worldData.exit.out, worldData.exit.in

                if oldWorld? then oldWorld.leave @_player

                @world = newWorld

    pushWorld: (worldChange)->
        if not worldChange?.name? then throw new Error 'worldChange.name is required'

        worldChange.enter     ?= {}
        worldChange.enter.out ?= c.transition.fadeOut
        worldChange.enter.in  ?= c.transition.fadeIn
        worldChange.exit      ?= {}
        worldChange.exit.out  ?= c.transition.fadeOut
        worldChange.exit.in   ?= c.transition.fadeIn
        worldChange.exit.x    ?= @_player.x
        worldChange.exit.y    ?= @_player.y
        worldChange.x         ?= 0
        worldChange.y         ?= 0

        oldWorld = @world
        newWorld = new World this, worldChange.name
        @world = null

        newWorld.enter @_player
            .then =>
                game.pushTransition worldChange.enter.out, worldChange.enter.in

                if oldWorld? then oldWorld.leave @_player

                @world = newWorld
                @_worldStack.push world:oldWorld, exit:worldChange.exit

    # GameMode Overrides ###########################################################################

    begin: ->
        @pushWorld
            name: 'cargo-shuttle'
            enter:
                out: c.transition.show
                in: c.transition.openDoors

    enterMode: ->
        game.keyboard.allowMultiple = false
        game.keyboard.registerCommands @_player
        super

    leaveMode: ->
        game.keyboard.unregisterCommands @_player
        super

    onGameStep: ->
        return unless @world?
        @world.onGameStep()
