#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

entityRegistry = require '../entity_registry'
Scales         = require './scales'
View           = require './view'

########################################################################################################################

module.exports = class RoomView extends View

    render: ->
        @backgroundLayer = @root.append('g').attr('class', 'background-layer')
        @tileLayer       = @root.append('g').attr('class', 'tile-layer')
        @blockLayer      = @root.append('g').attr('class', 'block-layer')
        @entityLayer     = @root.append('g').attr('class', 'entity-layer')

        @entityViews = {}

        super

    refresh: ->
        @_refreshBackground()
        @_refreshTiles()
        @_refreshBlocks()
        @_refreshEntities()
        super

    # Private Methods ##############################################################################

    _refreshBackground: ->
        background = @backgroundLayer.selectAll('.background-rect').data([@model.background])
        background.enter().append 'rect'
            .attr 'class', 'background-rect'

        background
            .style 'fill', (color)-> color
            .attr('x', 0).attr('y', 0).attr('width', c.canvas.width).attr('height', c.canvas.height)

        background.exit().remove()

    _refreshBlocks: ->
        blockViews = @blockLayer.selectAll('.block').data(@model.blocks)
        blockViews.enter().append 'image'
            .attr 'class', 'block'
            .attr 'xlink:href', (block)-> "images/entities/#{block.type}.png"
            .attr('x', (block)-> Scales.room.x(block.x)).attr('y', (block)-> Scales.room.y(block.y))
            .attr('height', c.tile.height).attr('width', c.tile.width)
            .attr 'transform', "translate(#{-c.tile.width / 2}, #{-c.tile.height / 2})"

        blockViews.exit().remove()

    _refreshEntities: ->
        parentView = this
        model = @model

        entityBoxes = @entityLayer.selectAll('.entity').data(@model.entities, (entity)-> entity.id)

        entityBoxes.enter().append 'g'
            .attr 'class', 'entity'
            .each (entity)->
                entityBox = d3.select this

                entityView = parentView.entityViews[entity.id]
                if not entityView?
                    EntityView = entityRegistry[entity.type]?.view
                    if EntityView?
                        entityView = parentView.addChild new EntityView entityBox, entity
                        parentView.entityViews[entity.id] = entityView
                        entityView.render()
                    else
                        console.error "missing view for: #{entity.type} in room #{model.worldX},#{model.worldY}"

        entityBoxes
            .attr 'transform', (d)-> "translate(#{Scales.room.x(d.x)},#{Scales.room.y(d.y)})"

        entityBoxes.exit().remove()

    _refreshTiles: ->
        tileViews = @tileLayer.selectAll('.tile').data(@model.tiles)
        tileViews.enter().append 'image'
            .attr 'class', 'tile'
            .attr 'xlink:href', (tile)-> "images/entities/#{tile.type}.png"
            .attr('x', (tile)-> Scales.room.x(tile.x)).attr('y', (tile)-> Scales.room.y(tile.y))
            .attr('height', c.tile.height).attr('width', c.tile.width)
            .attr 'transform', "translate(#{-c.tile.width / 2}, #{-c.tile.height / 2})"

        tileViews.exit().remove()
