#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

View = require './view'

########################################################################################################################

module.exports = class ShipView extends View

    constructor: (root, model)->
        super root, model

    # View Overrides ###############################################################################

    render: ->
        @shipBox = @root.append 'g'
            .attr 'class', 'ship-box'

        @shipImage = @shipBox.append 'image'
            .attr 'width', c.tile.width
            .attr 'height', c.tile.height
            .attr 'transform', "translate(-#{c.tile.width / 2}, -#{c.tile.height / 2})"
        super

    refresh: ->
        @shipBox
            .attr 'transform', "
                rotate(#{-@model.heading.angleDeg()})
                translate(#{@model.x}, #{@model.y})
            "

        name = @model.name
        if @model.isThrusting then name = "#{@model.name}-thrust"
        @shipImage
            .attr 'xlink:href', "images/entities/#{name}.png"

        super
