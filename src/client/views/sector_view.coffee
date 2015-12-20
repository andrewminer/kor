#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

View = require './view'

########################################################################################################################

module.exports = class SectorView extends View

    constructor: (root, model)->
        @_planetViews = {}
        super root, model

    # View Overrides ###############################################################################

    render: ->
        @planetBox = @root.append 'g'
            .attr 'class', 'planet-box'

        @childPlanetLayer = @root.append 'g'
            .attr 'class', 'child-planet-layer'
        super

    refresh: ->
        @_refreshPlanet()
        @_refreshChildPlanets()
        super

    # Private Methods ##############################################################################

    _refreshChildPlanets: ->
        self = this

        childPlanetBoxes = @childPlanetLayer.selectAll(".#{@model.id}-child-planet").data(@model.planets, (p)-> p.id)
        childPlanetBoxes.enter().append('g')
            .attr 'class', "#{@model.id}-child-planet"
            .each (planet)->
                planetBox  = d3.select this
                planetView = self.addChild new SectorView planetBox, planet
                planetView.render()
                self._planetViews[planet.key] = planetView

        childPlanetBoxes
            .attr 'transform', (planet)-> "translate(#{planet.x}, #{planet.y})"

        childPlanetBoxes.exit()
            .each (planet)->
                planetView = self._planetViews[planet.key]
                planetView.removeFromParent()
                delete self._planetViews[planet.key]
            .remove()

    _refreshPlanet: ->
        data = if @model.image? and @model.radius? then [@model] else []

        planetImage = @planetBox.selectAll('image').data(data)

        planetImage.enter().append('image')
            .attr 'x', (planet)-> -planet.radius
            .attr 'y', (planet)-> -planet.radius
            .attr 'height', (planet)-> planet.radius * 2
            .attr 'width', (planet)-> planet.radius * 2

        planetImage
            .attr 'xlink:href', (planet)-> "/images/entities/#{planet.image}.png"

        planetImage.exit().remove()
