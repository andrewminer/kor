#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

Scales = require './scales'
View   = require './view'

########################################################################################################################

module.exports = class StarfieldView extends View

    @::STAR_SWAP_INTERVAL = 100
    @::STARFIELD_COUNT = 10

    constructor: (root)->
        @_nextId = 0
        @_tileData = []

        for y in [0...c.room.height]
            for x in [0...c.room.width]
                @_tileData.push @_createTileData x + 0.5, y + 0.5

        setInterval (=> @_swapStars()), @STAR_SWAP_INTERVAL

        super root

    # Overrideable Methods #########################################################################

    refresh: ->
        tiles = @root.selectAll('.star-tile').data @_tileData, (tile)-> tile.id

        tiles.enter().append 'image'
            .attr 'class', 'star-tile'
            .attr 'x', (tile)-> Scales.room.x tile.x
            .attr 'y', (tile)-> Scales.room.y tile.y
            .attr 'width', c.tile.width
            .attr 'height', c.tile.height
            .attr 'xlink:href', (tile)-> "/images/entities/starfield-#{tile.imageNumber}.png"
            .style 'opacity', c.opacity.hidden
            .transition()
                .duration c.speed.slow * 4
                .style 'opacity', c.opacity.shown

        tiles.exit().transition()
            .duration c.speed.slow * 4
            .style 'opacity', c.opacity.hidden
            .remove()

        super

    # Private Methods ##############################################################################

    _createTileData: (x, y)->
        id:          @_nextId++
        x:           x
        y:           y
        imageNumber: 1 + Math.floor(Math.random() * @STARFIELD_COUNT)

    _swapStars: ->
        i = Math.floor(Math.random() * @_tileData.length)

        tile = @_tileData.splice(i, 1)[0]
        @_tileData.push @_createTileData tile.x, tile.y

        @refresh()
