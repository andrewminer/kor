#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

Entity = require '../entity'
Victor = require 'victor'

########################################################################################################################

module.exports = class Ship extends Entity

    constructor: (name, x, y)->
        if not name? then throw new Error 'name is required'
        super x, y

        @acceleration           = new Victor 0, 0
        @displayName            = ''
        @heading                = new Victor 1, 0
        @light                  = null
        @mass                   = 1
        @name                   = name
        @maxStep                = 0
        @maxSpeed               = 0
        @orbit                  = null
        @portLightPosition      = new Victor 0, 0
        @rotationRate           = 0
        @starboardLightPosition = new Victor 0, 0
        @thrust                 = 0
        @type                   = 'ship'
        @velocity               = new Victor 0, 0

    # Public Methods ###############################################################################

    onGameStep: ->
        @velocity.add @acceleration

        if @velocity.length() > @maxSpeed
            @velocity.multiplyScalar @maxSpeed / @velocity.length()

        @x += @velocity.x
        @y += @velocity.y

        @acceleration = new Victor 0, 0

    load: ->
        w.promise (resolve, reject)=>
            d3.json "data/ship/#{@name}.json", (error, data)=>
                if error?
                    reject error
                else
                    @_unpackData data
                    resolve this

    # Private Methods ##############################################################################

    _unpackData: (data)->
        @displayName            = data.displayName
        @maxSpeed               = parseFloat data.maxSpeed
        @portLightPosition      = @_unpackVector data.portLightPosition
        @rotationRate           = parseFloat data.rotationRate
        @starboardLightPosition = @_unpackVector data.starboardLightPosition
        @thrust                 = parseFloat data.thrust

    _unpackVector: (vectorData)->
        x = parseFloat vectorData.x
        y = parseFloat vectorData.y
        return new Victor x, y
