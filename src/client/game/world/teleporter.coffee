#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

StaticEntity = require '../static_entity'

########################################################################################################################

module.exports = class Teleporter extends StaticEntity

    constructor: (x, y, data)->
        super x, y, data
        @_unpackData data

    # Entity Overrides ##############################################################################

    onCollisionWith: (entity)->
        return w(true) unless entity.type is 'player'

        gameMode = game.gameMode
        return w(true) unless gameMode.name is 'world'

        if @target is c.teleportTarget.planet
            playerShip = game.getGameMode(c.gameMode.space).playerShip
            planet = playerShip.orbit?.planet
            return w(true) unless planet? and planet.canTeleport

            entity.stepBack()
            gameMode.pushWorld
                name: planet.name
                exit:
                    x: entity.x
                    y: entity.y
        else if @target is c.teleportTarget.ship
            gameMode.popWorld()

        return w(true)

    # Private Methods ##############################################################################

    _unpackData: (data)->
        @x      = parseFloat data.x
        @y      = parseFloat data.y
        @target = if data.target in [c.teleportTarget.ship, c.teleportTarget.planet] then data.target
