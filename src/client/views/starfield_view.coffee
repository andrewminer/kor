#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

Scales = require './scales'
View   = require './view'

########################################################################################################################

module.exports = class StarfieldView extends View

    constructor: (root)->
        super root

    # Overrideable Methods #########################################################################

    render: ->
        tiles = []
        for x in [0...c.room.width]
            for y in [0...c.room.height]
                tiles.push x:x + 0.5, y:y + 0.5, id:(1 + Math.floor(Math.random() * 10))

        @tiles = @root.selectAll('.star-tile').data(tiles)
        @tiles.enter().append 'image'
            .attr 'class', 'star-tile'
            .attr 'x', (tile)-> Scales.room.x tile.x
            .attr 'y', (tile)-> Scales.room.y tile.y
            .attr 'width', c.tile.width
            .attr 'height', c.tile.height
            .attr 'xlink:href', (tile)-> "/images/entities/starfield-#{tile.id}.png"

        super
