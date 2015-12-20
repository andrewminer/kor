#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

SectorView = require './sector_view'
ShipView   = require './ship_view'
View       = require './view'

########################################################################################################################

module.exports = class SpaceModeView extends View

    # View Overrides ###############################################################################

    render: ->
        @sectorLayer = @root.append 'g'
            .attr 'class', 'sector-layer'
            .attr 'transform', "translate(#{c.canvas.width / 2}, #{c.canvas.height / 2})"
        @sectorView = @addChild new SectorView @sectorLayer, @model.sector
        @sectorView.render()

        @shipLayer = @root.append 'g'
            .attr 'class', 'ship-layer'
            .attr 'transform', "translate(#{c.canvas.width / 2}, #{c.canvas.height / 2})"
        @shipView = @addChild new ShipView @shipLayer, @model.playerShip
        @shipView.render()

        super
