#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

View = require './view'

########################################################################################################################

OPEN = 0
CLOSED = c.canvas.width / 2

########################################################################################################################

module.exports = class TransitionView extends View

    # Transition Methods ###########################################################################

    fadeIn: ->
        barnDoors = @barnDoors
        w.promise (resolve, reject)=>
            barnDoors
                .attr 'width', CLOSED
                .style 'opacity', c.opacity.shown

            d3.transition()
                .duration c.speed.normal
                .each ->
                    barnDoors.transition().style 'opacity', c.opacity.hidden
                .each 'end', -> resolve()

    fadeOut: ->
        barnDoors = @barnDoors
        w.promise (resolve, reject)=>
            barnDoors
                .attr 'width', CLOSED
                .style 'opacity', c.opacity.hidden

            d3.transition()
                .duration c.speed.normal
                .each ->
                    barnDoors.transition().style 'opacity', c.opacity.shown
                .each 'end', -> resolve()

    hide: ->
        @barnDoors
            .style 'opacity', c.opacity.hidden
            .attr 'width', CLOSED
        return w(true)

    openDoors: ->
        barnDoors = @barnDoors
        w.promise (resolve, reject)->
            barnDoors
                .style 'opacity', c.opacity.shown
                .attr 'width', CLOSED

            d3.transition()
                .duration c.speed.slow
                .each ->
                    barnDoors.transition().attr 'width', OPEN
                .each 'end', ->
                    resolve()

    show: ->
        @barnDoors
            .style 'opacity', c.opacity.shown
            .attr 'width', CLOSED
        return w(true)

    closeDoors: ->
        barnDoors = @barnDoors
        w.promise (resolve, reject)->
            barnDoors
                .style 'opacity', c.opacity.shown
                .attr 'width', OPEN

            d3.transition()
                .duration c.speed.slow
                .each ->
                    barnDoors.transition().attr 'width', CLOSED
                .each 'end', -> resolve()

    # View Overrides ###############################################################################

    render: ->
        view = this

        boxes = @root.selectAll('.barn-door').data(['left', 'right'])
        boxes.enter().append 'g'
            .each (side)->
                box = d3.select this
                box.attr 'transform', ->
                    return "" if side is 'left'
                    return "translate(#{c.canvas.width},0) scale(-1, 1)" if side is 'right'
                box.append 'rect'
                    .attr 'class', 'barn-door'
                    .attr 'height', c.canvas.height
                    .attr 'width', CLOSED
                    .attr 'x', 0
                    .attr 'y', 0
                    .style 'fill', 'black'
                    .style 'opacity', c.opacity.shown

        @barnDoors = @root.selectAll('.barn-door')
        super
