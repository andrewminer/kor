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

        game.pushTransition(worldData.exit.out, worldData.exit.in).begin
            .then =>
                if @world? then @world.leave @_player
                @world = worldData.world
                return @world.enter @_player, worldData.exit

    pushWorld: (worldChange)->
        if not worldChange?.name? then throw new Error 'worldChange.name is required'

        worldChange.enter     ?= {}
        worldChange.enter.out ?= c.transition.fadeOut
        worldChange.enter.in  ?= c.transition.fadeIn
        worldChange.exit      ?= {}
        worldChange.exit.out  ?= c.transition.fadeOut
        worldChange.exit.in   ?= c.transition.fadeIn
        worldChange.exit.x    ?= null
        worldChange.exit.y    ?= null
        worldChange.x         ?= 0
        worldChange.y         ?= 0

        if @world?
            @world.leave @_player
            @_worldStack.push world:@world, exit:worldChange.exit

        @world   = new World this, worldChange.name
        @world.x = worldChange.x
        @world.y = worldChange.y

        @world.enter @_player
            .then ->
                game.pushTransition worldChange.enter.in, worldChange.enter.out

    # GameMode Overrides ###########################################################################

    begin: ->
        @pushWorld
            name: 'cargo_shuttle'
            enter:
                out: c.transition.hide
                in: c.transition.openDoors

    enterMode: ->
        game.keyboard.registerCommands @_player
        super

    leaveMode: ->
        game.keyboard.unregisterCommands @_player
        super

    onGameStep: ->
        return unless @world?
        @world.onGameStep()
