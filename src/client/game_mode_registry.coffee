#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

# Initial game mode must be listed first!
module.exports =
    "#{c.gameMode.world}": model:require('./game/world/world_mode'), view:require('./views/world_mode_view')
    "#{c.gameMode.space}": model:require('./game/space/space_mode'), view:require('./views/space_mode_view')
