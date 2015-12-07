#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

########################################################################################################################

module.exports = class Keyboard

    constructor: ->
        @_commands = []
        @_keyCodes = {}

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        command:
            get: ->
                return _.last @_commands

    # Public Methods ###############################################################################

    registerCommands: (commandMap)->
        for keyCode, command of commandMap
            @_keyCodes[keyCode] = command

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
        return unless @_listening is true

        window.onkeydown = @_oldDownHandler
        window.onkeyup = @_oldUpHandler
