#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

GameModeRegistry = require '../game_mode_registry'
GameView         = require '../views/game_view'
Keyboard         = require './keyboard'
SoundPlayer      = require './sounds'

########################################################################################################################

module.exports = class Game

    constructor: ->
        @_allGameModes = {}
        @_keyboard     = new Keyboard
        @_gameMode     = null
        @_paused       = true
        @_sounds       = new SoundPlayer
        @_transition   = null
        @_view         = null

        for gameModeName, gameModeEntry of GameModeRegistry
            GameModeClass = gameModeEntry.model
            gameMode = new GameModeClass gameModeName, this
            @_allGameModes[gameModeName] = gameMode

    # Public Methods ###############################################################################

    begin: ->
        @_keyboard.registerCommands this
        @_keyboard.startListening()

        promises = []
        for gameMode in @allGameModes
            promises.push gameMode.begin()

        w.all promises
            .then =>
                @changeGameMode _.keys(@_allGameModes)[0]
                @resume()

    changeGameMode: (gameModeName)->
        gameMode = @_allGameModes[gameModeName]
        if not gameMode? then throw new Error "unsupported game mode: #{gameModeName}"
        return if gameMode is @_gameMode

        if @_gameMode? then @_gameMode.leaveMode()
        @_gameMode = gameMode
        @_gameMode.enterMode()

    getGameMode: (name)->
        return @_allGameModes[name]

    pause: ->
        return if @_paused
        @_paused = true

    pushTransition: (begin, end)->
        if not @_transition?
            @_transition = begin:begin, end:end

        return this

    popTransition: ->
        result = @_transition
        @_transition = null
        return result

    quit: ->
        @_keyboard.unregisterCommands this
        @_keyboard.stopListening()

        @pushTransition('closeDoors', 'show').begin
            .then =>
                @sounds.mute()
                @_paused = true

    resume: ->
        return if not @_paused
        @_paused = false
        @_onGameStep()

    toggleMute: ->
        @sounds.toggleMute()

    togglePause: ->
        if @paused then @resume() else @pause()

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        allGameModes:
            get: -> return _.values @_allGameModes

        gameMode:
            get: -> return @_gameMode

        keyboard:
            get: -> return @_keyboard

        keyUpCommands:
            get: ->
                77: 'toggleMute'  # 'm' key
                80: 'togglePause' # 'p' key
                81: 'quit'        # 'q' key

        paused:
            get: -> return @_paused

        sounds:
            get: -> return @_sounds

        view:
            get: -> return @_view
            set: (view)-> @_view = view

    # Private Methods ##############################################################################

    _onGameStep: ->
        return w(true) if @paused

        start = Date.now()
        w(true)
            .then => @keyboard.dispatchCommands()
            .timeout 1111
            .catch (e)=> console.error "error during keyboard dispatch: #{e.stack}"

            .then =>
                promises = []
                for name, gameMode of @_allGameModes
                    promises.push gameMode.onGameStep()
                w.all promises
            .timeout 1111
            .catch (e)=> console.error "error during game step: #{e.stack}"

            .then => @view.refresh()
            .timeout 1111
            .catch (e)=> console.error "error during view refresh: #{e.stack}"

            .delay c.animation.frameDuration - (Date.now() - start)
            .done => @_onGameStep()
