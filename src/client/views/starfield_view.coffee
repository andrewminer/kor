#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

Scales = require './scales'
View   = require './view'

########################################################################################################################

module.exports = class StarfieldView extends View

    @::STARFIELD_COUNT    = 10

    constructor: (root)->
        @_nextId = 0
        @_tileData = []

        for y in [0...c.room.height]
            for x in [0...c.room.width]
                @_tileData.push x: x + 0.5, y: y + 0.5, imageNumber: 1 + Math.floor(Math.random() * @STARFIELD_COUNT)

        super root

    # Overrideable Methods #########################################################################

    render: ->
        @tiles = @root.selectAll('.star-tile').data @_tileData

        @tiles.enter().append 'image'
            .attr 'class', 'star-tile'
            .attr 'x', (tile)-> Scales.room.x tile.x
            .attr 'y', (tile)-> Scales.room.y tile.y
            .attr 'width', c.tile.width
            .attr 'height', c.tile.height
            .attr 'xlink:href', (tile)-> "/images/entities/starfield-#{tile.imageNumber}.png"
            .style 'opacity', c.opacity.shown
        super
