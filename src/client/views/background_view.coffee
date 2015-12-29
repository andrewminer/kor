#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

Scales = require './scales'
View   = require './view'

########################################################################################################################

module.exports = class BackgroundView extends View

    constructor: (root, model)->
        @_backgroundColor = model.color or 'black'
        @_tileData = []
        super root, model

        @_computeTiles()


    # Overrideable Methods #########################################################################

    render: ->
        @backgroundRect = @root.append 'rect'
            .attr 'width',       c.canvas.width
            .attr 'height',      c.canvas.height
            .style 'background', @_backgroundColor

        @tiles = @root.selectAll('.background-tile').data @_tileData
        @tiles.enter().append 'image'
            .attr 'class', 'background-tile'
            .attr 'x', (tile)-> Scales.room.x tile.x
            .attr 'y', (tile)-> Scales.room.y tile.y
            .attr 'width', c.tile.width
            .attr 'height', c.tile.height
            .attr 'xlink:href', (tile)-> "/images/tiles/#{tile.image}.png"
            .style 'opacity', c.opacity.shown

        super

    # Private Methods ##############################################################################

    _computeTiles: ->
        @_tileData = []
        return unless @model.images? and @model.images.length > 0

        for y in [0...c.room.height]
            for x in [0...c.room.width]
                number = Math.floor Math.random() * @model.images.length
                @_tileData.push x:x + 0.5, y:y + 0.5, image:@model.images[number]
