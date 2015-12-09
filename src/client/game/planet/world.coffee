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

        @ambientSound = null
        @data         = null
        @player       = null
        @room         = null
        @roomCache    = {}
        @roomPath     = []
        @transition   = null
        @x            = 0
        @y            = 0

    # Public Methods ###############################################################################

    enter: (player, spawn)->
        @player    = player
        @roomCache = {}
        @roomPath  = []
        @worldX    = 0
        @worldY    = 0

        @load().then =>
            if @ambientSound?
                @game.sounds.startLoop @ambientSound

            @room = new Room this, @x, @y
            @room.game = @game

            @roomCache[@room.key] = @room
            @roomPath.push @room

            @room.load().then =>
                @room.spawn = spawn if spawn?
                @room.enter player

    load: ->
        if @data? then return w(this)

        w.promise (resolve, reject)=>
            d3.json "data/#{@key}.json", (error, data)=>
                if error?
                    reject error
                else
                    @_unpackData data
                    resolve this

    leave: (player)->
        @player = null
        if @ambientSound?
            @game.sounds.stopLoop @ambientSound

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

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        key:
            get: -> return @name

    # Object Overrides #############################################################################

    toString: ->
        return "World{name:#{@name}, x:#{@x}, y:#{@y}}"

    # Private Methods ##############################################################################

    _unpackData: (data)->
        @data = data
        @ambientSound = data.ambientSound if data.ambientSound?
