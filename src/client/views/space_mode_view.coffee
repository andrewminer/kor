#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

View = require './view'

########################################################################################################################

module.exports = class SpaceModeView extends View

    constructor: (root, model)->
        super root, model

    # View Overrides ###############################################################################

    render: ->
        @planetLayer = @root.append('g')
            .attr 'class', 'planet-layer'

        @planetLayer.append('rect')
            .attr 'x', c.canvas.width / 2
            .attr 'y', c.canvas.height / 2
            .attr 'width', 100
            .attr 'height', 2
            .style 'fill', 'red'

        @planetLayer.append('rect')
            .attr 'x', c.canvas.width / 2
            .attr 'y', c.canvas.height / 2
            .attr 'width', 2
            .attr 'height', 100
            .style 'fill', 'blue'

        super

    refresh: ->
        super
