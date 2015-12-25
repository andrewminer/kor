#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

Rectangle  = require '../../common/rectangle'
SectorView = require './sector_view'
ShipView   = require './ship_view'
Victor     = require 'victor'
View       = require './view'

########################################################################################################################

module.exports = class SpaceModeView extends View

    constructor: (root, model)->
        super root, model

        @sectorOffset = null
        @orbitRadius = null

    # View Overrides ###############################################################################

    render: ->
        @root.attr 'transform', "translate(#{c.canvas.width / 2}, #{c.canvas.height / 2})"

        @cameraLayer = @root.append 'g'
            .attr 'class', 'camera-layer'

        @sectorLayer = @cameraLayer.append 'g'
            .attr 'class', 'sector-layer'
        @sectorView = @addChild new SectorView @sectorLayer, @model.sector
        @sectorView.render()

        @shipLayer = @cameraLayer.append 'g'
            .attr 'class', 'ship-layer'
        @shipView = @addChild new ShipView @shipLayer, @model.playerShip
        @shipView.render()

        @markerLayer = @cameraLayer.append 'g'
            .attr 'class', 'marker-layer'

        super

    refresh: ->
        @_followPlayerShip()
        @_refreshPlanetMarkers()

        super

    # Private Methods ##############################################################################

    _followPlayerShip: ->
        return unless @model.playerShip?
        return unless @model.playerShip.x isnt 0 and @model.playerShip.y isnt 0

        if not @sectorOffset
            @sectorOffset = new Victor @model.playerShip.x, @model.playerShip.y

        if not @model.playerShip.orbit?
            @orbitRadius = null

            tetherWidth = c.canvas.width * c.tether.max
            if @model.playerShip.x > @sectorOffset.x + tetherWidth
                @sectorOffset.x = @model.playerShip.x - tetherWidth
            else if @model.playerShip.x < @sectorOffset.x - tetherWidth
                @sectorOffset.x = @model.playerShip.x + tetherWidth
            else if @model.playerShip.x > @sectorOffset.x
                @sectorOffset.x += Math.min c.tether.speed, @model.playerShip.x - @sectorOffset.x
            else if @model.playerShip.x < @sectorOffset.x
                @sectorOffset.x -= Math.min c.tether.speed, @sectorOffset.x - @model.playerShip.x

            tetherHeight = c.canvas.height * c.tether.max
            if @model.playerShip.y > @sectorOffset.y + tetherHeight
                @sectorOffset.y = @model.playerShip.y - tetherHeight
            else if @model.playerShip.y < @sectorOffset.y - tetherHeight
                @sectorOffset.y = @model.playerShip.y + tetherHeight
            else if @model.playerShip.y > @sectorOffset.y
                @sectorOffset.y += Math.min c.tether.speed, @model.playerShip.y - @sectorOffset.y
            else if @model.playerShip.y < @sectorOffset.y
                @sectorOffset.y -= Math.min c.tether.speed, @sectorOffset.y - @model.playerShip.y
        else
            planetPosition = @model.playerShip.orbit.planet.absolutePosition
            fromPlanet = @sectorOffset.clone().subtract planetPosition

            if not @orbitRadius?
                @orbitRadius = fromPlanet.length()

            if @orbitRadius is 0
                @sectorOffset = planetPosition
            else
                @orbitRadius = Math.max 0, @orbitRadius - c.tether.speed
                fromPlanet.normalize().multiplyScalar @orbitRadius
                @sectorOffset = planetPosition.add fromPlanet

        @cameraLayer.attr 'transform', "translate(#{-@sectorOffset.x}, #{-@sectorOffset.y})"

    _refreshPlanetMarkers: ->
        return unless @sectorOffset

        viewport = Rectangle.atCenter @sectorOffset.x, @sectorOffset.y, c.canvas.width, c.canvas.height
        sectorOffset = @sectorOffset

        allPlanets = []
        if @model?.sector?
            allPlanets = @model.sector.findAllPlanets depth:2

        distantPlanets = []
        for planet in allPlanets
            planetBox = Rectangle.atCenter planet.x, planet.y, planet.radius * 2, planet.radius * 2
            if not Rectangle.intersect viewport, planetBox
                distantPlanets.push planet

        distantPlanets.sort (a, b)->
            distanceSqA = new Victor(a.x, a.y).distanceSq(sectorOffset)
            distanceSqB = new Victor(b.x, b.y).distanceSq(sectorOffset)

            if distanceSqA isnt distanceSqB
                return if distanceSqA > distanceSqB then -1 else +1
            return 0

        markers = @markerLayer.selectAll('.planet-marker').data(distantPlanets, (p)-> p.id)
        markers.enter().append 'g'
            .attr 'class', 'planet-marker'
            .each (planet)->
                markerBox = d3.select this
                pointerImage = markerBox.append 'image'
                    .attr 'class', 'pointer'
                    .attr 'transform', "translate(#{c.tile.width / 2}, #{c.tile.height / 2})"
                    .attr 'height', c.tile.height
                    .attr 'width', c.tile.width
                    .attr 'xlink:href', '/images/planet-marker.png'

                planetImage = markerBox.append 'image'
                    .attr 'class', 'planet'
                    .attr 'transform', "translate(#{c.tile.width / 3}, #{c.tile.height / 3})"
                    .attr 'height', c.tile.height / 3
                    .attr 'width', c.tile.height / 3
                    .attr 'xlink:href', "/images/entities/#{planet.image}.png"

        zIndex = 1
        markers
            .attr 'transform', (planet)=>
                x = Math.max viewport.left, Math.min viewport.right - c.tile.width, planet.x
                y = Math.max viewport.top, Math.min viewport.bottom - c.tile.height, planet.y
                return "translate(#{x},#{y})"
            .each (planet)->
                d3.select(this).style 'z-index', zIndex++
                toPlanet = new Victor(planet.x, planet.y).subtract sectorOffset
                pointer = d3.select(this).select('image.pointer')
                pointer.attr 'transform', "rotate(#{toPlanet.angleDeg()}, #{c.tile.width / 2}, #{c.tile.height / 2})"

        markers.exit().remove()
