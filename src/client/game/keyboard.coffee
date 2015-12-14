#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

########################################################################################################################

module.exports = class Keyboard

    constructor: ->
        @_activeCommands  = []
        @_lastCommand     = null
        @_keyUpCommands   = {}
        @_keyDownCommands = {}

    # Public Methods ###############################################################################

    dispatchCommands: ->
        command = @command
        return unless command?

        w.try command

    registerCommands: (object)->
        @_registerCommands object, object.keyUpCommands, @_keyUpCommands
        @_registerCommands object, object.keyDownCommands, @_keyDownCommands

    startListening: ->
        @_oldDownHandler = global.onkeydown
        window.onkeydown = (event)=>
            command = @_keyDownCommands[event.keyCode]
            return unless command

            event.preventDefault()
            if @_activeCommands.indexOf(command) is -1
                @_activeCommands.push command

        @_oldUpHandler = global.onkeyup
        window.onkeyup = (event)=>
            command = @_keyDownCommands[event.keyCode]
            if command?
                event.preventDefault()
                @_activeCommands = _(@_activeCommands).without command

            command = @_keyUpCommands[event.keyCode]
            if command?
                event.preventDefault()
                w.try command

        @_listening = true

    stopListening: ->
        return unless @_listening

        window.onkeydown = @_oldDownHandler
        window.onkeyup = @_oldUpHandler

    unregisterCommands: (object)->
        @_unregisterCommands object, object.keyUpCommands, @_keyUpCommands
        @_unregisterCommands object, object.keyDownCommands, @_keyDownCommands

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        command:
            get: ->
                return _.last @_activeCommands

    # Private Methods ##############################################################################

    _registerCommands: (object, source, target)->
        return unless object? and source?

        for keyCode, command of source
            continue unless _.isFunction object[command]
            do (keyCode, command)=>
                target[keyCode] = -> object[command]()

    _unregisterCommands: (object, source, target)->
        return unless source?

        @_activeCommands = []
        for keyCode, command of source
            delete target[keyCode]
