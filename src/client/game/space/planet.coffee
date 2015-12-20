#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

Entity = require '../entity'
Victor = require 'victor'

########################################################################################################################

module.exports = class Planet extends Entity

    constructor: (data={})->
        @planets = []
        super 0, 0

        @_unpackData data
        @_recomputePosition()

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        key:
            get: -> return @name

    # Entity Overrides #############################################################################

    onGameStep: ->
        @ticks += 1
        @_recomputePosition()

        for planet in @planets
            planet.onGameStep()

    # Private Methods ##############################################################################

    _recomputePosition: ->
        position = new Victor @orbit, 0
        position.rotateToDeg (@ticks * @speed) + @angle
        @x = position.x
        @y = position.y

    _unpackData: (data)->
        @name   = data.name
        @image  = data.image
        @angle  = if _.isString(data.angle) then parseFloat(data.angle) else Math.random() * 360.0
        @orbit  = c.space.orbitRatio * parseFloat data.orbit
        @radius = c.space.radiusRatio * parseFloat data.radius
        @speed  = c.space.speedRatio * parseFloat data.speed

        @planets = []
        if data.planets?
            for planetData in data.planets
                @planets.push new Planet planetData
