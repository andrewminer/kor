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

        game.pushTransition('fadeOut', 'fadeIn').begin
            .then =>
                entity.y = @y + 1
                game.changeGameMode 'space'

        return w(true)
