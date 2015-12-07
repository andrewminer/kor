#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

EventEmitter = require 'events'
Room         = require './room'

########################################################################################################################

module.exports = class World extends EventEmitter

    constructor: (@game, @name)->
        if not @game? then throw new Error 'game is required'
        if not @name? then throw new Error 'name is required'

        @x          = 0
        @y          = 0
        @player     = null
        @room       = null
        @roomCache  = {}
        @roomPath   = []
        @transition = null

    # Public Methods ###############################################################################

    enter: (player, spawn)->
        @player    = player
        @roomCache = {}
        @roomPath  = []
        @worldX    = 0
        @worldY    = 0

        @room = new Room this, @x, @y
        @room.game = @game

        @roomCache[@room.key] = @room
        @roomPath.push @room

        @room.load()
            .then =>
                @room.spawn = spawn if spawn?
                @room.enter player

    leave: (player)->
        @player = null

    changeRoom: (direction)->
        newLocation = x:@x, y:@y
        spawn = x:@player.x, y:@player.y
        if direction is c.direction.east  then newLocation.x++; spawn.x = 1
        if direction is c.direction.north then newLocation.y--; spawn.y = c.room.height
        if direction is c.direction.south then newLocation.y++; spawn.y = 1
        if direction is c.direction.west  then newLocation.x--; spawn.x = c.room.width

        nextRoom = @roomCache[Room.key(@name, newLocation.x, newLocation.y)]
        if not nextRoom?
            nextRoom = new Room this, newLocation.x, newLocation.y
            nextRoom.game = @game
            @roomCache[nextRoom.key] = nextRoom

        nextRoom.load()
            .then =>
                @x = newLocation.x
                @y = newLocation.y

                nextRoom.spawn = spawn
                nextRoom.enter @player
                @roomPath.push nextRoom
                @room = nextRoom
            .catch (e)->
                console.error "failed to enter next room"
                console.error e

    onGameStep: ->
        @room.onGameStep()

    pop: ->
        @game.popWorld()

    # Object Overrides #############################################################################

    toString: ->
        return "World{name:#{@name}, x:#{@x}, y:#{@y}}"
