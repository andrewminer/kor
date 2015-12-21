#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

Planet = require './planet'
Victor = require 'victor'

########################################################################################################################

module.exports = class Sector

    constructor: (x, y)->
        if not x? then throw new Error 'x is required'
        if not y? then throw new Error 'y is required'

        @id         = _.uniqueId 'sector-'
        @name       = ''
        @planets    = []
        @playerShip = null
        @spawn      = angle:0.0, orbit:0.0
        @x          = x
        @y          = y

    # Public Methods ###############################################################################

    findAllPlanets: (options={})->
        options.depth   ?= Number.MAX_VALUE
        options.planet  ?= this
        options.results ?= []
        return if options.depth is 0

        for childPlanet in options.planet.planets
            options.results.push childPlanet
            @findAllPlanets depth:options.depth - 1, planet:childPlanet, results:options.results

        return options.results

    onPlayerShipEntered: (playerShip)->
        @playerShip = playerShip

        position = new Victor @spawn.orbit
        position.rotateToDeg @spawn.angle
        @playerShip.x = position.x
        @playerShip.y = position.y

    load: ->
        w.promise (resolve, reject)=>
            d3.json "data/sector/#{@key}.json", (error, data)=>
                if error?
                    reject error
                else
                    @_unpackData data
                    resolve this

    onGameStep: ->
        for planet in @findAllPlanets()
            planet.onGameStep()
            planet.applyGravitation @playerShip

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        key:
            get: -> return "#{@x},#{@y}"

    # Private Methods ##############################################################################

    _unpackData: (data)->
        @name = data.name
        @spawn =
            angle: parseFloat data.spawn.angle
            orbit: c.space.orbitRatio * parseFloat data.spawn.orbit

        @planets = []
        if data.planets?
            for planetData in data.planets
                @planets.push new Planet planetData
