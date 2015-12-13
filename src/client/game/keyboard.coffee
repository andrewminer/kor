#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

########################################################################################################################

module.exports = class Keyboard

    constructor: ->
        @_commands    = []
        @_lastCommand = null
        @_keyCodes    = {}

    # Public Methods ###############################################################################

    dispatchCommands: ->
        command = @command
        return unless command?

        w.try command

    registerCommands: (object)->
        commandMap = object.keyboardCommands
        return unless commandMap?

        for keyCode, command of commandMap
            continue unless _.isFunction object[command]
            do (keyCode, command)=>
                @_keyCodes[keyCode] = -> object[command]()

    startListening: ->
        @_oldDownHandler = global.onkeydown
        window.onkeydown = (event)=>
            commandName = @_keyCodes[event.keyCode]
            return unless commandName

            event.preventDefault()
            if @_commands.indexOf(commandName) is -1
                @_commands.push commandName

        @_oldUpHandler = global.onkeyup
        window.onkeyup = (event)=>
            commandName = @_keyCodes[event.keyCode]
            return unless commandName

            event.preventDefault()
            @_commands = _(@_commands).without commandName

        @_listening = true

    stopListening: ->
        return unless @_listening

        window.onkeydown = @_oldDownHandler
        window.onkeyup = @_oldUpHandler

    unregisterCommands: (object)->
        commandMap = object.keyboardCommands
        return unless commandMap?

        for keyCode, command of commandMap
            delete @_keyCodes[keyCode]

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        command:
            get: ->
                return _.last @_commands
