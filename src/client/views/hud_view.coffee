#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

View = require './view'

########################################################################################################################

module.exports = class HudView extends View

    constructor: (root, model)->
        @_muted = false
        super root, model

    # View Overrides ###############################################################################

    render: ->
        @muteIcon = @root.append 'image'
            .attr 'xlink:href', '/images/muted.png'
            .style 'opacity', c.opacity.hidden
        super

    refresh: ->
        @muteIcon
            .attr 'height', c.tile.height
            .attr 'width', c.tile.width
            .attr 'transform', "translate(#{c.canvas.width - c.tile.width * 1.5}, #{c.tile.height / 2})"

        if @_muted isnt @model.sounds.muted
            @_muted = @model.sounds.muted
            @muteIcon.transition()
                .duration c.speed.fast
                .style 'opacity', => if @model.sounds.muted then c.opacity.shown else c.opacity.hidden
        super
