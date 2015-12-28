#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

GameModeRegistry = require '../game_mode_registry'
HudView          = require './hud_view'
StarfieldView    = require './starfield_view'
TransitionView   = require './transition_view'
View             = require './view'
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
        @starfieldLayer = @root.append('g').attr('class', 'starfield')
        @starfieldView = @addChild new StarfieldView @starfieldLayer
        @starfieldView.render()

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
        @transitionView  = @addChild new TransitionView @transitionLayer
        @transitionView.render()

        @hudLayer = @root.append('g').attr('class', 'hud-layer')
        @hudView = @addChild new HudView @hudLayer, @model
        @hudView.render()

        super

    refresh: ->
        promise = w(true)

        transition = @model.popTransition()
        if transition
            if _.isFunction @transitionView[transition.begin]
                promise = promise.then => @transitionView[transition.begin]()

            promise = promise.then => @_refreshModeView()
            promise = promise.then => super

            if _.isFunction @transitionView[transition.end]
                promise = promise.then => @transitionView[transition.end]()
        else
            promise = promise.then => @_refreshModeView()

        return promise

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
            if view? then promise = promise.then -> view.refresh()

        return promise
