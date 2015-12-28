#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

exports.animation = {}
exports.animation.frameRate     = 32
exports.animation.frameDuration = 1000 / exports.animation.frameRate

exports.canvas        = {}
exports.canvas.width  = 1024
exports.canvas.height = 768
exports.canvas.max    = Math.max(exports.canvas.width, exports.canvas.height)

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

exports.gameMode       = {}
exports.gameMode.space = 'space'
exports.gameMode.world = 'world'

exports.orbit                   = {}
exports.orbit.distanceRatio     = 4
exports.orbit.maxCaptureSpeedSq = 3 * 3
exports.orbit.maxSpeed          = 4
exports.orbit.minSpeed          = 2
exports.orbit.orbitIncrement    = 2
exports.orbit.velocityIncrement = 0.5

exports.opacity = {}
exports.opacity.hidden = 1e-6
exports.opacity.shown  = 1

exports.room = {}
exports.room.width = 16
exports.room.height = 12

exports.space             = {}
exports.space.G           = 200
exports.space.massRatio   = 1
exports.space.orbitRatio  = 6000
exports.space.radiusRatio = 20
exports.space.speedRatio  = 360 / 20 / 60 / exports.animation.frameRate

exports.speed = {}
exports.speed.slow   = 1000
exports.speed.normal = exports.speed.slow / 2
exports.speed.fast   = exports.speed.normal / 2
exports.speed.block  = 75

exports.teleportTarget        = {}
exports.teleportTarget.planet = 'planet'
exports.teleportTarget.ship   = 'ship'

exports.tether       = {}
exports.tether.max   = 0.33
exports.tether.speed = exports.canvas.max * exports.tether.max / 10 / exports.animation.frameRate

exports.tile = {}
exports.tile.width = 64
exports.tile.height = 64

exports.transition = {}
exports.transition.fadeOut    = 'fadeOut'
exports.transition.fadeIn     = 'fadeIn'
exports.transition.hide       = 'hide'
exports.transition.openDoors  = 'openDoors'
exports.transition.closeDoors = 'closeDoors'
exports.transition.show       = 'show'

exports.readCanvas = ($canvas)->
    availableWidth = $canvas.parent().width()
    availableHeight = $canvas.parent().height()

    if availableWidth >= availableHeight
        height = availableHeight
        width  = availableHeight * exports.canvas.width / exports.canvas.height
        top    = 0
        left   = Math.floor (availableWidth - width) / 2
    else
        width  = availableWidth
        height = availableWidth * exports.canvas.height / exports.canvas.width
        top    = Math.floor (availableHeight - height) / 2
        left   = 0

    $canvas.css top:"#{top}px", left:"#{left}px", width:"#{width}px", height:"#{height}px"
    exports.canvas.width = width
    exports.canvas.height = height
    exports.tile.width = width / exports.room.width
    exports.tile.height = height / exports.room.height
