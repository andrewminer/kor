#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

StaticEntity = require './static_entity'

########################################################################################################################

module.exports = class Starfield extends StaticEntity

    constructor: (x, y, data)->
        super x, y, data
        @step = 1 + Math.floor Math.random() * 5
