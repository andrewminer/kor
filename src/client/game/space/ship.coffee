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

        @displayName            = ''
        @heading                = new Victor 1, 0
        @light                  = null
        @name                   = name
        @maxStep                = 0
        @portLightPosition      = new Victor()
        @rotationRate           = 0
        @starboardLightPosition = new Victor()
        @thrust                 = 0
        @type                   = 'ship'
        @velocity               = new Victor()

    # Public Methods ###############################################################################

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
        @portLightPosition      = @_unpackVector data.portLightPosition
        @rotationRate           = parseFloat data.rotationRate
        @starboardLightPosition = @_unpackVector data.starboardLightPosition
        @thrust                 = parseFloat data.thrust

    _unpackVector: (vectorData)->
        x = parseFloat vectorData.x
        y = parseFloat vectorData.y
        return new Victor x, y
