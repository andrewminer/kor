#
# Copyright (C) 2014 by Andrew Miner
# All rights reserved.
#

Entity = require '../entity'

########################################################################################################################

module.exports = class Block extends Entity

    constructor: (x, y, @type)->
        super x, y

    onCollisionWith: (entity)->
        if entity.type is 'player'
            if entity.facing is c.direction.east  then entity.x -= (entity.area.right - @area.left)
            if entity.facing is c.direction.north then entity.y += (@area.bottom - entity.area.top)
            if entity.facing is c.direction.south then entity.y -= (entity.area.bottom - @area.top)
            if entity.facing is c.direction.west  then entity.x += (@area.right - entity.area.left)

        return w(true)
