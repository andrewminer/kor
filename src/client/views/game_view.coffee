#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

GameModeRegistry = require '../game_mode_registry'
View             = require './view'
TransitionView   = require './transition_view'
WorldView        = require './world_view'

########################################################################################################################

module.exports = class GameView extends View

    constructor: (root, model)->
        @_displayedMode   = null
        @_modelViews      = {}
        @_transitionLayer = null
        @_transitionView  = null
        super root, model

    # View Overrides ###############################################################################

    render: ->
        modelViews = @_modelViews

        @gameModeLayers = @root.selectAll('.mode-layer').data(@model.allGameModes)
        @gameModeLayers.enter().append('g')
            .attr 'class', (gameMode)-> "mode-layer #{gameMode.name}"
            .attr 'width', '100%'
            .attr 'height', '100%'
            .style 'opacity', c.opacity.hidden
            .each (gameMode)->
                layer = d3.select this
                ViewClass = GameModeRegistry[gameMode.name].view
                view = new ViewClass layer, gameMode
                view.render()
                modelViews[gameMode.name] = view

        @transitionLayer = @root.append('g').attr('class', 'transition-layer')
        @transitionView  = new TransitionView @transitionLayer
        @transitionView.render()

        super

    refresh: ->
        promises = [@_refreshModeView()]

        while true
            promise    = w(true)
            transition = @model.popTransition()
            break unless transition?

            do (transition)=>
                if _.isFunction @transitionView[transition.begin?.name]
                    promise = promise
                        .then => @transitionView[transition.begin.name]()
                        .then => transition.begin.resolve(true)

                promise = promise.then => @_refreshModeView()
                didRefresh = true

                if _.isFunction @transitionView[transition.end?.name]
                    promise = promise
                        .then => @transitionView[transition.end.name]()
                        .then => transition.end.resolve(true)

                promises.push promise

        return w.all promises

    # Private Methods ##############################################################################

    _refreshModeView: ->
        currentMode = @model.gameMode
        modeChanged = currentMode? and currentMode isnt @_displayedMode
        promise = w(true)

        if currentMode?
            promise = promise.then => @_modelViews[currentMode.name].refresh()

        if @_displayedMode? and @_displayedMode isnt currentMode
            promise = promise.then => @_modelViews[@_displayedMode.name].refresh()

        if modeChanged
            w.promise (resolve, reject)=>
                if @_displayedMode
                    hideOld = @root.selectAll(".#{@_displayedMode.name}")
                        .transition()
                            .duration c.speed.normal / 2
                            .style 'opacity', c.opacity.hidden

                    hideOld.transition().selectAll(".#{currentMode.name}")
                        .duration c.speed.normal / 2
                        .style 'opacity', c.opacity.shown
                        .each 'end', ->
                            resolve()
                else
                    @root.selectAll(".#{currentMode.name}")
                        .transition()
                            .duration c.speed.normal
                            .style 'opacity', c.opacity.visible
                            .each 'end', ->
                                resolve()

        @_displayedMode = currentMode
        return promise
