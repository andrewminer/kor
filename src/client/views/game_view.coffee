#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

View      = require './view'
WorldView = require './world_view'

########################################################################################################################

module.exports = class GameView extends View

    # View Overrides ###############################################################################

    render: ->
        @worldBox  = @root.append('g').attr('class', 'world')
        @worldView = @addChild new WorldView @worldBox, @model.world
        @worldView.render()

    refresh: ->
        return unless @worldView?
        @worldView.model = @model.world
        super
