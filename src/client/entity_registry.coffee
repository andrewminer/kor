#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports =
    'pilot-seat':    model:require('./game/world/pilot_seat'), view:require('./views/static_entity_view')
    'static-entity': model:require('./game/static_entity'),    view:require('./views/static_entity_view')
    'teleporter':    model:require('./game/world/teleporter'), view:require('./views/static_entity_view')
