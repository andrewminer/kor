#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

SectorView = require './sector_view'
ShipView   = require './ship_view'
Victor     = require 'victor'
View       = require './view'

########################################################################################################################

module.exports = class SpaceModeView extends View

    constructor: (root, model)->
        super root, model

        @sectorOffset = new Victor 0, 0

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

        super

    refresh: ->
        @_followPlayerShip()
        super

    # Private Methods ##############################################################################

    _followPlayerShip: ->
        return unless @model.playerShip?

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

        @cameraLayer.attr 'transform', "translate(#{-@sectorOffset.x}, #{-@sectorOffset.y})"
