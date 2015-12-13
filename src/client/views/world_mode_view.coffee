#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

View      = require './view'
WorldView = require './world_view'

########################################################################################################################

module.exports = class WorldModeView extends View

    constructor: (root, model)->
        super root, model

    # View Overrides ###############################################################################

    render: ->
        @worldBox  = @root.append('g').attr('class', 'world')
        @worldView = @addChild new WorldView @worldBox, @model.world
        @worldView.render()
        super

    refresh: ->
        return unless @worldView?
        @worldView.model = @model.world
        super
