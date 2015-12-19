#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

Ship   = require './ship'
Victor = require 'victor'

########################################################################################################################

POSITION_ADJUST_THRESHOLD = 0.125

########################################################################################################################

module.exports = class PlayerShip extends Ship

    @::THRUST_DURATION = 8

    constructor: (name, x, y)->
        super name, x, y

        @sector = null
        @type   = 'player_ship'

    # Public Methods ###############################################################################

    onEnteredSector: (sector)->
        @sector = sector

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        keyDownCommands:
            get: ->
                37: '_rotateLeft'    # left arrow
                38: '_thrust'        # up arrow
                39: '_rotateRight'   # right arrow
                40: '_rotateReverse' # down arrow
                65: '_rotateLeft'    # 'a' key
                68: '_rotateRight'   # 'd' key
                83: '_rotateReverse' # 's' key
                87: '_thrust'        # 'w' key

        isThrusting:
            get: ->
                @thrustingFor > 0

    # Object Overrides #############################################################################

    toString: ->
        return "PlayerShip{heading:#{@heading}, x:#{@x}, y:#{@y}}"

    # Private Methods ##############################################################################

    _normalizeAngle: (angle)->
        while angle > 180
            angle -= 360
        while angle < -180
            angle += 360
        return angle

    _rotateLeft: ->
        @heading.rotateToDeg @heading.angleDeg() - @rotationRate
        console.log "rotated by #{@rotationRate}° to #{@heading.angleDeg()}°"

    _rotateRight: ->
        @heading.rotateToDeg @heading.angleDeg() + @rotationRate
        console.log "rotated by #{-@rotationRate}° to #{@heading.angleDeg()}°"

    _rotateReverse: ->
        targetAngle = @_normalizeAngle @velocity.angleDeg() + 180

        rotationRate = Math.min(@rotationRate, Math.abs(targetAngle - @heading.angleDeg()))
        left = @_normalizeAngle @heading.angleDeg() - rotationRate
        right = @_normalizeAngle @heading.angleDeg() + rotationRate

        if Math.abs(targetAngle - left) < Math.abs(targetAngle - right)
            @heading.rotateToDeg left
        else
            @heading.rotateToDeg right

    _thrust: ->
        thrustVector = new Victor @thrust, 0
        thrustVector.rotateTo @heading.angle()
        @velocity.add thrustVector
        @thrustingFor = @THRUST_DURATION
