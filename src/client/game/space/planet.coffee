#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

Entity = require '../entity'
Orbit  = require './orbit'
Victor = require 'victor'

########################################################################################################################

module.exports = class Planet extends Entity

    constructor: (data={})->
        @orbitingShips = []
        @planets = []
        super 0, 0

        @_unpackData data
        @_recomputePosition()

    # Public Methods ###############################################################################

    # Disabled for now as the effects of gravitation as it's implemented don't make for a very good game experience.
    # This code may be re-enabled if better ideas of how to take advantage of it come up.
    #
    # applyGravitation: (ship)->
    #     toPlanet = new Victor(@x, @y).subtract new Victor(ship.x, ship.y)
    #     r = Math.max toPlanet.length(), @radius * 2
    #     g = c.space.G * @mass / (r * r)
    #     a = new Victor g / ship.mass, 0
    #     a.rotateTo toPlanet.angle()
    #     ship.acceleration.add a

    captureShip: (ship)->
        return unless @shipsOrbit
        return unless Orbit.canCapture this, ship
        return if @_isOrbiting ship

        @orbitingShips.push new Orbit this, ship

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        absolutePosition:
            get: ->
                if not @orbiting?
                    return new Victor @x, @y
                else
                    return @orbiting.absolutePosition.add new Victor @x, @y

        key:
            get: -> return @name

        velocity:
            get: ->
                speedPx = @speed / 360.0 * (2.0 * π * @orbit)
                new Victor(speedPx, 0).rotateToDeg((@ticks * @speed) + @angle + 90)

    # Entity Overrides #############################################################################

    onGameStep: ->
        @ticks += 1
        @_recomputePosition()

        index = 0
        while index < @orbitingShips.length
            orbit = @orbitingShips[index]
            orbit.onGameStep()

            if orbit.isValid
                index += 1
            else
                orbit.cancel()
                @orbitingShips.splice index, 1

        for planet in @planets
            planet.onGameStep()

    # Private Methods ##############################################################################

    _isOrbiting: (ship)->
        for orbit in @orbitingShips
            return true if orbit.ship is ship

        return false

    _recomputePosition: ->
        position = new Victor @orbit, 0
        position.rotateToDeg (@ticks * @speed) + @angle
        @x = position.x
        @y = position.y

    _unpackData: (data)->
        @canTeleport = !! data.canTeleport
        @name        = data.name.toLowerCase()
        @displayName = data.name
        @image       = data.image
        @angle       = if data.angle? then parseFloat(data.angle) else Math.random() * 360.0
        @mass        = c.space.massRatio * parseFloat data.mass
        @orbit       = c.space.orbitRatio * parseFloat data.orbit
        @shipsOrbit  = !! if data.shipsOrbit? then data.shipsOrbit else true
        @radius      = c.space.radiusRatio * parseFloat data.radius
        @speed       = c.space.speedRatio * parseFloat data.speed

        @planets = []
        if data.planets?
            for planetData in data.planets
                planet = new Planet planetData
                planet.orbiting = this
                @planets.push planet
