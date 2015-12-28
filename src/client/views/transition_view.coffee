#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

View = require './view'


########################################################################################################################

module.exports = class TransitionView extends View

    # Transition Methods ###########################################################################

    fadeIn: ->
        barnDoors = @barnDoors
        w.promise (resolve, reject)=>
            barnDoors
                .attr 'width', c.canvas.width / 2
                .style 'opacity', c.opacity.shown

            d3.transition()
                .duration c.speed.normal
                .each ->
                    barnDoors.transition().style 'opacity', c.opacity.hidden
                .each 'end', ->
                    resolve()

    fadeOut: ->
        barnDoors = @barnDoors
        w.promise (resolve, reject)->
            barnDoors
                .attr 'width', c.canvas.width / 2
                .style 'opacity', c.opacity.hidden

            d3.transition()
                .duration c.speed.normal
                .each ->
                    barnDoors.transition().style 'opacity', c.opacity.shown
                .each 'end', ->
                    resolve()

    hide: ->
        @barnDoors
            .style 'opacity', c.opacity.hidden
            .attr 'width', c.canvas.width / 2
        return w(true)

    openDoors: ->
        barnDoors = @barnDoors
        w.promise (resolve, reject)->
            barnDoors
                .style 'opacity', c.opacity.shown
                .attr 'width', c.canvas.width / 2

            d3.transition()
                .duration c.speed.slow
                .each ->
                    barnDoors.transition().attr 'width', 0
                .each 'end', ->
                    resolve()

    show: ->
        @barnDoors
            .style 'opacity', c.opacity.shown
            .attr 'width', c.canvas.width / 2
        return w(true)

    closeDoors: ->
        barnDoors = @barnDoors
        w.promise (resolve, reject)->
            barnDoors
                .style 'opacity', c.opacity.shown
                .attr 'width', 0

            d3.transition()
                .duration c.speed.slow
                .each ->
                    barnDoors.transition().attr 'width', c.canvas.width / 2
                .each 'end', ->
                    resolve()

    # View Overrides ###############################################################################

    render: ->
        view = this

        @doorBoxes = @root.selectAll('.door-box').data(['left', 'right'])
        @doorBoxes.enter().append 'g'
            .attr 'class', 'door-box'
            .each (side)->
                box = d3.select this
                box.append 'rect'
                    .attr 'class', 'barn-door'
                    .attr 'height', c.canvas.height
                    .attr 'width', c.canvas.width / 2
                    .style 'fill', 'black'
                    .style 'opacity', c.opacity.shown

        @barnDoors = @root.selectAll '.barn-door'
        super

    refresh: ->
        @doorBoxes
            .each (side)->
                box = d3.select this
                box.attr 'transform', ->
                    return "" if side is 'left'
                    return "translate(#{c.canvas.width},0) scale(-1, 1)" if side is 'right'
        super
