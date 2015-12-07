#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

exports.animation = {}
exports.animation.frameRate     = 32
exports.animation.frameDuration = 1000 / exports.animation.frameRate

exports.canvas = {}
exports.canvas.width = 1024
exports.canvas.height = 768

exports.direction = {}
exports.direction.north = 'n'
exports.direction.south = 's'
exports.direction.east  = 'e'
exports.direction.west  = 'w'
exports.direction.up    = 'u'
exports.direction.down  = 'd'

exports.event             = {}
exports.event.game        = {}
exports.event.game.begin  = 'game:begin'
exports.event.game.pause  = 'game:pause'
exports.event.game.resume = 'game:resume'
exports.event.game.end    = 'game:end'

exports.opacity = {}
exports.opacity.hidden = 1e-6
exports.opacity.shown  = 1

exports.room = {}
exports.room.width = 16
exports.room.height = 12

exports.speed = {}
exports.speed.slow   = 1000
exports.speed.normal = exports.speed.slow / 2
exports.speed.fast   = exports.speed.normal / 2

exports.tile = {}
exports.tile.width = 64
exports.tile.height = 64

exports.transition = {}
exports.transition.fadeOut    = 'fadeOut'
exports.transition.fadeIn     = 'fadeIn'
exports.transition.openDoors  = 'openDoors'
exports.transition.closeDoors = 'closeDoors'
