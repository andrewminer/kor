#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

View = require './view'

########################################################################################################################

module.exports = class StaticEntityView extends View

    constructor: (root, model)->
        super root, model

    # View Overrides ###############################################################################

    render: ->
        @imageView = @root.append 'image'
            .attr('x', 0).attr('y', 0).attr('height', c.canvas.cellSize).attr('width', c.canvas.cellSize)
            .attr 'transform', "translate(#{-c.canvas.cellSize / 2}, #{-c.canvas.cellSize / 2})"
        super

    refresh: ->
        imageBase = []
        if @model.image? then imageBase.push @model.image
        if @model.variant? then imageBase.push @model.variant
        if @model.step? then imageBase.push @model.step

        @imageView.attr 'xlink:href', "images/#{imageBase.join('-')}.png"
        super
