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
        @_modeViews      = {}
        @_transitionLayer = null
        @_transitionView  = null
        super root, model

    # View Overrides ###############################################################################

    render: ->
        modeViews = @_modeViews

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
                modeViews[gameMode.name] = view

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
        promise     = w(true)
        currentMode = @model.gameMode
        modeChanged = currentMode isnt @_displayedMode

        if modeChanged
            if currentMode? then @root.selectAll(".#{currentMode.name}").style 'opacity', c.opacity.shown
            if @_displayedMode? then @root.selectAll(".#{@_displayedMode.name}").style 'opacity', c.opacity.hidden
            @_displayedMode = currentMode

        if currentMode?
            view = @_modeViews[currentMode.name]
            if view? then promise = view.refresh()

        return promise
