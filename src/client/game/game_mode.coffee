#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

########################################################################################################################

module.exports = class GameMode

    constructor: (name)->
        if not name? then throw new Error 'name is required'
        @name = name
        @_isActive = false

    # Public Methods ###############################################################################

    begin: ->
        # Subclasses may override this method to perform any work required when the game starts. They need not call the
        # parent class's implementation.

    enterMode: ->
        # Subclasses may override this method to perform work when they become the active game mode. Commonly, this
        # will involve registering keyboard handlers and the like. They must call the parent class's implementation.
        @_isActive = true

    leaveMode: ->
        # Subclasses may override this method to perform work when they become inactive. Commonly, this will involve
        # unregistering keyboard handlers and the like. They must call the parent class's implementation.
        @_isActive = false

    onGameStep: ->
        # Subclasses may override this method to perform work which must happen on every game step. They need not call
        # the parent class's implementation.

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        isActive:
            get: -> return @_isActive
