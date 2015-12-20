#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

Scales = require './scales'
View = require './view'

########################################################################################################################

module.exports = class PlayerView extends View

    # View Overrides ###############################################################################

    refresh: ->
        data  = if @model.x? and @model.y? then [@model] else []
        origin = x:Scales.room.x(@model.x), y:Scales.room.x(@model.y)

        view = @root.selectAll('.player').data(data)
        view.enter().append 'g'
            .attr 'class', 'player'
            .append 'image'
                .attr 'xlink:href', (d)-> "images/entities/player-#{d.facing}-#{d.step}.png"
                .attr('x', 0).attr('y', 0).attr('height', c.tile.height).attr('width', c.tile.width)
                .attr 'transform', "translate(#{-c.tile.width / 2}, #{-c.tile.height / 2})"

        view.select('image').attr 'xlink:href', (d)-> "images/entities/player-#{d.facing}-#{d.step}.png"

        view.exit().remove()

        super
