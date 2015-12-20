#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

########################################################################################################################

module.exports = class Entity

    constructor: (x, y)->
        @area         = {}
        @id           = _.uniqueId 'entity-'
        @maxStep      = 0
        @step         = 0
        @ticks        = 0
        @ticksPerStep = 4
        @x            = x or 0
        @y            = y or 0

    # Class Methods ################################################################################

    @haveCollided: (a, b)->
        left   = Math.max a.area.left, b.area.left
        right  = Math.min a.area.right, b.area.right
        return false if left >= right

        top    = Math.max a.area.top, b.area.top
        bottom = Math.min a.area.bottom, b.area.bottom
        return false if top >= bottom

        return true

    # Public Methods ###############################################################################

    stepAnimation: ->
        @ticks++
        if @ticks is @ticksPerStep
            @ticks = 0
            @step += 1
            @step = 0 if @step > @maxStep

    # Property Methods #############################################################################

    getX: ->
        return @_x

    setX: (v)->
        @_x = v
        @_updateArea()

    getY: ->
        return @_y

    setY: (v)->
        @_y = v
        @_updateArea()

    Object.defineProperties @prototype,
        x: { get:@::getX, set:@::setX }
        y: { get:@::getY, set:@::setY }

    # Overrideable Methods #########################################################################

    onCollisionWith: (entity)->
        # do nothing. subclasses may override to provide collision behavior.  If so, they must return a promise which
        # resolves after any game-pausing events have finished (e.g., transitioning to a new game state)
        return w(true)

    onGameStep: ->
        # subclasses may override to perform to activity each game tick, but they should be sure to call the super
        # class's implementation when finished.

    # Private Methods ##############################################################################

    _stepAnimation: ->
        @ticks++
        if @ticks is @ticksPerStep
            @ticks = 0
            @step += 1
            @step = 0 if @step > @maxStep

    _updateArea: ->
        @area.left   = @_x - 0.5
        @area.right  = @_x + 0.5
        @area.top    = @_y - 0.5
        @area.bottom = @_y + 0.5
