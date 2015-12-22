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

        @sector       = null
        @thrustingFor = 0
        @type         = 'player_ship'

    # Public Methods ###############################################################################

    enterSector: (sector)->
        @sector = sector
        @sector.onPlayerShipEntered this

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

    # Entity Overrides #############################################################################

    onGameStep: ->
        @thrustingFor -= 1

        if @isThrusting
            thrustVector = new Victor @_availableThrust(), 0
            thrustVector.rotateTo @heading.angle()
            @acceleration.add thrustVector

        super

    # Object Overrides #############################################################################

    toString: ->
        return "PlayerShip{heading:#{@heading}, x:#{@x}, y:#{@y}}"

    # Private Methods ##############################################################################

    _availableThrust: ->
        thrustVector = new Victor @thrust, 0
        thrustVector.rotateTo @heading.angle()
        currentSpeed = @velocity.length()
        adjustedSpeed = @velocity.clone().add(thrustVector).length()

        if adjustedSpeed > @maxSpeed
            return Math.max 0, @maxSpeed - currentSpeed
        else
            return @thrust

    _normalizeAngle: (angle)->
        while angle > 180
            angle -= 360
        while angle < -180
            angle += 360
        return angle

    _rotateLeft: ->
        @heading.rotateToDeg @heading.angleDeg() - @rotationRate

    _rotateRight: ->
        @heading.rotateToDeg @heading.angleDeg() + @rotationRate

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
        availableThrust = @_availableThrust()
        console.log "availableThrust: #{availableThrust}"
        if @_availableThrust() > 0
            @thrustingFor = @THRUST_DURATION
