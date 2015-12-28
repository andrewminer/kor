#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

StaticEntity = require '../static_entity'

########################################################################################################################

module.exports = class PilotSeat extends StaticEntity

    # Private Methods ##############################################################################

    onCollisionWith: (entity)->
        return w(true) unless entity.type is 'player'
        return unless game.gameMode.name is 'world'

        entity.stepBack()
        game.changeGameMode 'space'
        game.pushTransition 'fadeOut', 'fadeIn'
        return w(true)
