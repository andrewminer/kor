#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

Entity = require '../entity'
Victor = require 'victor'

########################################################################################################################

POSITION_ADJUST_THRESHOLD = 0.125

########################################################################################################################

module.exports = class PlayerShip extends Entity

    constructor: (x, y)->
        super x, y

        @heading      = new Victor()
        @velocity     = new Victor()
        @maxStep      = 2
        @ticksPerStep = 20
        @type         = 'player_ship'

    # Public Methods ###############################################################################

    onEnteredSector: (sector)->
        @sector = sector

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        keyDownCommands:
            get: ->
                37: '_onWest'  # left arrow
                38: '_onNorth' # up arrow
                39: '_onEast'  # right arrow
                40: '_onSouth' # down arrow
                65: '_onWest'  # 'a' key
                68: '_onEast'  # 'd' key
                83: '_onSouth' # 's' key
                87: '_onNorth' # 'w' key

    # Entity Overrides #############################################################################

    onGameStep: ->
        # do nothing. player only updates when moving.

    _updateArea: ->
        super

        # the top half of the player's box doesn't count for collisions
        @area.top = @_y

    # Object Overrides #############################################################################

    toString: ->
        return "PlayerShip{heading:#{@heading}, x:#{@x}, y:#{@y}}"
