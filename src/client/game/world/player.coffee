#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

Entity = require '../entity'
Room   = require './room'

########################################################################################################################

POSITION_ADJUST_THRESHOLD = 0.125

########################################################################################################################

module.exports = class Player extends Entity

    constructor: ->
        super c.room.width / 2, c.room.height / 2

        @facing  = c.direction.north
        @maxStep = 1
        @room    = null
        @speed   = 5 * (1 / c.animation.frameRate)
        @type    = 'player'

    # Public Methods ###############################################################################

    onEnteredRoom: (newRoom)->
        @room = newRoom

    stepBack: ->
        switch @facing
            when c.direction.north then @y += 1
            when c.direction.east  then @x -= 1
            when c.direction.south then @y -= 1
            when c.direction.west  then @x += 1

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
        return "Player{facing:#{@facing}, x:#{@x}, y:#{@y}}"

    # Private Methods ##############################################################################

    _adjustPosition: (axis)->
        current = this[axis]
        if (current % 1) < POSITION_ADJUST_THRESHOLD
            this[axis] = Math.floor current
        else if (current % 1) > (1 - POSITION_ADJUST_THRESHOLD)
            this[axis] = Math.floor current + 1

    _onEast: ->
        @facing = c.direction.east
        @x += @speed
        @_adjustPosition 'y'

        return @_resolveCollisions()

    _onNorth: ->
        @facing = c.direction.north
        @y -= @speed
        @_adjustPosition 'x'

        return @_resolveCollisions()

    _onSouth: ->
        @facing = c.direction.south
        @y += @speed
        @_adjustPosition 'x'

        return @_resolveCollisions()

    _onWest: ->
        @facing = c.direction.west
        @x -= @speed
        @_adjustPosition 'y'

        return @_resolveCollisions()

    _resolveCollisions: ->
        return w(true) unless @room?
        promises = []

        for block in @room.blocks
            continue unless Entity.haveCollided this, block
            promises.push this.onCollisionWith block
            promises.push block.onCollisionWith this

        for entity in @room.entities
            continue unless Entity.haveCollided this, entity
            promises.push this.onCollisionWith entity
            promises.push entity.onCollisionWith this

        w.all(promises).then =>
            @room.testCollisionWith this
