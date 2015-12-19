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

    # Entity Overrides #############################################################################

    onGameStep: ->
        @thrustingFor -= 1

    # Object Overrides #############################################################################

    toString: ->
        return "PlayerShip{heading:#{@heading}, x:#{@x}, y:#{@y}}"

    # Private Methods ##############################################################################

    _rotateLeft: ->
        @heading.rotateToDeg @heading.angleDeg() + @rotationRate
        console.log "rotated by #{@rotationRate}° to #{@heading.angleDeg()}°"

    _rotateRight: ->
        @heading.rotateToDeg @heading.angleDeg() - @rotationRate
        console.log "rotated by #{-@rotationRate}° to #{@heading.angleDeg()}°"

    _rotateReverse: ->
        rotationRate = @rotationRate * (if @heading.angleDeg() - @velocity.angleDeg() <= 180 then -1 else +1)
        @heading.rotateToDeg @heading.angleDeg() + @rotationRate

    _thrust: ->
        velocityAngle = @velocity.angle()
        @velocity.rotate(0).addX(@thrust).rotate(velocityAngle)
        @thrustingFor = @THRUST_DURATION
