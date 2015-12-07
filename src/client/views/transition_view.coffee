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

    # Public Methods ###############################################################################

    fadeIn: ->
        w.promise (resolve, reject)=>
            @barnDoors
                .attr 'width', CLOSED
                .style 'opacity', c.opacity.shown
                .transition()
                    .duration c.speed.normal
                    .style 'opacity', c.opacity.hidden
                    .each 'end', -> resolve()

    fadeOut: ->
        w.promise (resolve, reject)=>
            @barnDoors
                .attr 'width', CLOSED
                .style 'opacity', c.opacity.hidden
                .transition()
                    .duration c.speed.normal
                    .style 'opacity', c.opacity.shown
                    .each 'end', -> resolve()

    hide: ->
        @barnDoors
            .style 'opacity', c.opacity.hidden
            .attr 'width', CLOSED
        return w(true)

    openDoors: ->
        w.promise (resolve, reject)=>
            @barnDoors
                .style 'opacity', c.opacity.shown
                .attr 'width', CLOSED
                .transition()
                    .duration c.speed.slow
                    .attr 'width', OPEN
                    .each 'end', -> resolve()

    show: ->
        @barnDoors
            .style 'opacity', c.opacity.shown
            .attr 'width', CLOSED
        return w(true)

    shutDoors: ->
        w.promise (resolve, reject)=>
            @barnDoors
                .style 'opacity', c.opacity.shown
                .attr 'width', OPEN
                .transition()
                    .duration c.speed.slow
                    .attr 'width', CLOSED
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
                    .style('opacity', c.opacity.shown).style('fill', 'black')
                    .attr('x', 0).attr('y', 0).attr('height', c.canvas.height).attr('width', CLOSED)

        @barnDoors = @root.selectAll('rect')
        super
