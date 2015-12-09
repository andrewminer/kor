#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

EventEmitter = require 'events'
Keyboard     = require './keyboard'
Player       = require './planet/player'
Room         = require './planet/room'
SoundPlayer  = require './sounds'
World        = require './planet/world'

########################################################################################################################

CLEAR_COMMAND_TIMEOUT = 1000

########################################################################################################################

module.exports = class Game extends EventEmitter

    @KEYBOARD_COMMANDS =
        80:  'pause' # 'p' key
        81:  'quit'  # 'q' key

    constructor: ->
        @_runLoopId   = null
        @_paused      = true
        @_player      = null
        @_transitions = null
        @sounds       = new SoundPlayer
        @view         = null
        @_worldStack  = []

        @_keyboard = new Keyboard
        @_keyboard.registerCommands Player.KEYBOARD_COMMANDS
        @_keyboard.registerCommands Game.KEYBOARD_COMMANDS

    # Public Methods ###############################################################################

    begin: ->
        @_player = new Player
        @_keyboard.startListening()
        @_runLoopId = setInterval (=> @dispatchKeyboardEvents(@_keyboard)), c.animation.frameDuration

        @pushWorld name:'cargo_shuttle', transition:in:c.transition.openDoors
            .done => @resume()

        @emit c.event.game.begin

    # Property Methods #############################################################################

    popWorld: ->
        worldData = @_worldStack.pop()
        return unless worldData?

        if @world? then @world.leave @_player

        @world = worldData.world
        @world.transition = start:worldData.exit.out, end:worldData.exit.in

        return @world.enter @_player, worldData.exit

    pushWorld: (worldChange)->
        worldChange           ?= {}
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

        if @world? then @world.leave @_player
        @_worldStack.push world:@world, exit:worldChange.exit

        @world            = new World this, worldChange.name
        @world.transition = start:worldChange.enter.out, end:worldChange.enter.in
        @world.x          = worldChange.x
        @world.y          = worldChange.y

        return @world.enter @_player

    dispatchKeyboardEvents: (keyboard)->
        command = @_keyboard.command
        return unless command
        return if @_lastCommand? and command is @_lastCommand

        if command is 'quit'
            @quit()
        else if command is 'pause'
            @paused = if @paused then false else true

        @_lastCommand = command
        clearTimeout @_commandClearId if @_commandClearId?
        @_commandClearId = setTimeout (-> @_lastCommand = null), CLEAR_COMMAND_TIMEOUT

    pause: ->
        return if @_paused
        @_paused = true

    resume: ->
        return if not @_paused
        @_paused = false
        @_onGameStep()

    quit: ->
        @_keyboard.stopListening()
        clearInterval @_runLoopId
        @_runLoopId = null

    # Private Methods ##############################################################################

    _onGameStep: ->
        return w(true) if @paused

        @_player.dispatchKeyboardEvents(@_keyboard)
            .then =>
                @world.onGameStep()
                @view.refresh()
            .then().delay(c.animation.frameDuration)
            .done =>
                @_onGameStep()
