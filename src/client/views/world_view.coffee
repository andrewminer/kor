#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

PlayerView     = require './player_view'
RoomView       = require './room_view'
Scales         = require './scales'
StarfieldView  = require './starfield_view'
View           = require './view'

########################################################################################################################

module.exports = class WorldView extends View

    constructor: (root, model)->
        super root, model

        @playerLayer    = null
        @playerView     = null
        @lastPosition   = null
        @roomLayer      = null
        @roomViews      = {}
        @starfieldLayer = null

    # View Overrides ###############################################################################

    render: ->
        @starfieldLayer  = @root.append('g').attr('class', 'starfield')
        @roomLayer       = @root.append('g').attr('class', 'room-layer')
        @playerLayer     = @root.append('g').attr('class', 'player-layer')

        @starfieldView = @addChild new StarfieldView @starfieldLayer
        @starfieldView.render()

        super

    refresh: ->
        super

        w(true)
            .then =>
                @_changeToNewRoom()
            .then =>
                if @model? then @lastPosition = x:@model.x, y:@model.y

                @_refreshLayers()
                @_refreshRooms()
                @_refreshPlayer()

    _onModelChanged: (oldModel, newModel)->
        @lastPosition = null

    # Private Methods ##############################################################################

    _changeToNewRoom: ->
        return w(true) unless @model?
        return w(true) unless @lastPosition?
        return w(true) if @lastPosition.x is @model.x and @lastPosition.y is @model.y

        @playerView.refresh()
        @_refreshRooms()

        blockCount = if @lastPosition.x isnt @model.x then c.room.width else c.room.height
        w.promise (resolve, reject)=>
            d3.transition()
                .duration c.speed.block * blockCount
                .each =>
                    offset = x:Scales.room.x(@model.player.x), y:Scales.room.y(@model.player.y)
                    @root.select('.player-box').transition()
                        .attr 'transform', "translate(#{offset.x},#{offset.y})"

                    @_refreshLayers animated:true
                .each 'end', =>
                    resolve()

    _refreshLayers: (animated=false)->
        return unless @model?

        roomLayer = d3.select '.room-layer'
        if animated then roomLayer = roomLayer.transition()

        offset = x:Scales.world.x(@model.x), y:Scales.world.y(@model.y)
        roomLayer.attr 'transform', "translate(#{-offset.x},#{-offset.y})"

    _refreshPlayer: ->
        return unless @model?

        parentView = this
        playerData = _.compact [@model.player]
        playerBox  = @playerLayer.selectAll('.player-box').data(playerData)

        playerBox.enter().append('g')
            .attr 'class', 'player-box'
            .each (player)->
                box = d3.select this
                if not parentView.playerView?
                    parentView.playerView = parentView.addChild new PlayerView box, player
                    parentView.playerView.render()

        playerBox.attr 'transform', (player)->
            "translate(#{Scales.room.x(player.x)},#{Scales.room.y(player.y)})"

        playerBox.exit()
            .each (player)-> parentView.playerView = null
            .remove()

    _refreshRooms: ->
        return unless @model?

        parentView = this
        roomData   = (room for key, room of @model.roomCache)
        roomBoxes  = @roomLayer.selectAll('.room-box').data(roomData, (room)-> room.key)

        roomBoxes.enter().append('g')
            .attr 'class', 'room-box'
            .attr 'transform', (room)-> "translate(#{Scales.world.x(room.x)},#{Scales.world.y(room.y)})"
            .each (room)->
                roomBox = d3.select this
                roomView = parentView.roomViews[room.key]
                if not roomView?
                    roomView = parentView.addChild new RoomView roomBox, room
                    roomView.render()

        roomBoxes.exit()
            .each (room)-> delete parentView.roomViews[room.key]
            .remove()
