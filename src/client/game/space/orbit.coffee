#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

Victor = require 'victor'

########################################################################################################################

module.exports = class Orbit

    constructor: (planet, ship)->
        if not planet? then throw new Error 'planet is required'
        if not ship? then throw new Error 'ship is required'

        @planet = planet
        @ship   = ship

        @radius   = 0
        @_angleDeg = 0
        @_speed    = 0

        @_computeInitialCoordinates()
        @onGameStep()

        @ship.orbit    = this
        @ship.velocity = new Victor 0, 0

    # Class Methods ################################################################################

    @canCapture: (planet, ship)->
        return false if ship.isThrusting

        relativeVelocity = planet.velocity.clone().subtract(ship.velocity)
        return false if relativeVelocity.lengthSq() > c.orbit.maxCaptureSpeedSq

        return false if Orbit.computeDistance(planet, ship) > planet.radius * c.orbit.distanceRatio

        return true

    @computeDistance: (planet, ship)->
        return Math.abs planet.absolutePosition.subtract(new Victor(ship.x, ship.y)).length()

    @isValid: (planet, ship)->
        return false if ship.isThrusting
        return true

    # Public Methods ###############################################################################

    cancel: ->
        @ship.velocity = @velocity
        @ship.orbit = null

    onGameStep: ->
        @_angleDeg += @_speed
        position = new Victor(@radius).rotateToDeg(@_angleDeg)
        shipPosition = @planet.absolutePosition.add position

        @ship.x       = shipPosition.x
        @ship.y       = shipPosition.y
        @ship.heading = new Victor(1, 0).rotateToDeg(@_angleDeg + 90)

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        isValid:
            get: -> return Orbit.isValid @planet, @ship

        velocity:
            get: ->
                shipRelativeVelocity = new Victor(@_speed, 0).rotateTo(@ship.heading.angle())
                return shipRelativeVelocity.add @planet.velocity

    # Private Methods ##############################################################################

    _computeInitialCoordinates: ->
        planetPosition = @planet.absolutePosition
        toShip         = new Victor(@ship.x, @ship.y).subtract planetPosition
        @radius        = Math.abs toShip.length()
        @_angleDeg     = toShip.angleDeg()

        relativeVelocity = @ship.velocity.clone().subtract @planet.velocity
        orbitalSpeed     = relativeVelocity.length() * 360.0 / (2.0 * π * @radius)
        @_speed          = Math.max c.orbit.minSpeed, Math.min c.orbit.maxSpeed, orbitalSpeed
