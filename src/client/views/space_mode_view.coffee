#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

ShipView = require './ship_view'
View = require './view'

########################################################################################################################

module.exports = class SpaceModeView extends View

    constructor: (root, model)->
        super root, model

    # View Overrides ###############################################################################

    render: ->
        @planetLayer = @root.append 'g'
            .attr 'class', 'planet-layer'
            .attr 'transform', "translate(#{c.canvas.width / 2}, #{c.canvas.height / 2})"

        @planetLayer.append 'rect'
            .attr 'width', 100
            .attr 'height', 2
            .style 'fill', 'red'

        @planetLayer.append 'rect'
            .attr 'width', 2
            .attr 'height', 100
            .style 'fill', 'blue'

        @shipLayer = @root.append 'g'
            .attr 'class', 'ship-layer'
            .attr 'transform', "translate(#{c.canvas.width / 2}, #{c.canvas.height / 2})"

        @shipView = @addChild new ShipView @shipLayer, @model.playerShip
        @shipView.render()

        super

    refresh: ->
        super
