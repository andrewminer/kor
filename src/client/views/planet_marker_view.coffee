#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

View = require './view'

########################################################################################################################

module.exports = class PlanetMarkerView extends View

    # View Overrides ###############################################################################

    render: ->
        @markerImage = @root.append 'image'
            .attr 'class', 'marker'
            .attr 'height', c.tile.height
            .attr 'width', c.tile.width
            .attr 'xlink:href', '/images/planet-marker.png'

        @planetImage = @root.append 'image'
            .attr 'class', 'planet'
            .attr 'height', c.tile.height / 4
            .attr 'width', c.tile.height / 4
            .attr 'xlink:href', "/images/entities/#{@model.image}.png"
        super
