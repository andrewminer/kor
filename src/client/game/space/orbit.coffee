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

        @_radius   = 0
        @_angleDeg = 0
        @_speed    = 0

        @_computeInitialCoordinates()
        @onGameStep()

        @ship.velocity = new Victor 0, 0

    # Class Methods ################################################################################

    @canCapture: (planet, ship)->
        return false if ship.isThrusting
        return false if ship.velocity.lengthSq() > c.orbit.maxCaptureSpeedSq
        return false if Orbit.computeDistance(planet, ship) > planet.radius * c.orbit.distanceRatio
        return true

    @computeDistance: (planet, ship)->
        return Math.abs new Victor(planet.x, planet.y).subtract(new Victor(ship.x, ship.y)).length()

    @isValid: (planet, ship)->
        return false if ship.isThrusting
        return true

    # Public Methods ###############################################################################

    onGameStep: ->
        @_angleDeg += @_speed
        position = new Victor(@_radius).rotateToDeg(@_angleDeg)

        @ship.x       = @planet.x + position.x
        @ship.y       = @planet.y + position.y
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
        toShip           = new Victor(@ship.x, @ship.y).subtract new Victor(@planet.x, @planet.y)
        relativeVelocity = @ship.velocity.clone().subtract @planet.velocity
        orbitalSpeed     = relativeVelocity.length() * 360 / 2 * π * @_radius

        @_radius         = Math.abs toShip.length()
        @_angleDeg       = toShip.angleDeg()
        @_speed          = Math.max c.orbit.minSpeed, Math.min c.orbit.maxSpeed, orbitalSpeed
        console.log "
            toShip: #{toShip},
            radius: #{@_radius},
            angle: #{@_angleDeg},
            velocity: #{@ship.velocity.length()}
            speed: #{@_speed}
        "
