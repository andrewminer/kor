#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports =
    'starfield': model:require('./game/starfield'), view:require('./views/static_entity_view')
    'static-entity': model:require('./game/static_entity'), view:require('./views/static_entity_view')
