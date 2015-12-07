#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

Block          = require './block'
entityRegistry = require '../../entity_registry'
EventEmitter   = require 'events'

########################################################################################################################

module.exports = class Room extends EventEmitter

    constructor: (@world, @x, @y)->
        @blocks     = []
        @background = "#FFFFFF"
        @data       = null
        @exits      = []
        @entities   = []
        @images     = []
        @spawn      = null
        @tiles      = []

        Object.defineProperty this, 'key', get:@getKey, set:@setKey

    # Class Methods ################################################################################

    @key: (type, x, y)->
        "#{type}.#{x},#{y}"

    # Public Methods ###############################################################################

    load: ->
        if @data? then return w(this)

        w.promise (resolve, reject)=>
            d3.json "data/#{@key}.json", (error, data)=>
                if error?
                    reject error
                else
                    @_unpackData data
                    resolve this

    enter: (player)->
        spawn  = @spawn
        spawn ?= x:(c.room.width + 1) / 2, y:(c.room.height + 1) / 2

        player.x = spawn.x
        player.y = spawn.y
        player.onEnteredRoom this

    onGameStep: ->
        entity.onGameStep() for entity in @entities

    testCollisionWith: (entity)->
        direction = null
        promise   = w(true)

        if entity.constructor.name is 'Player'
            if entity.y < 1             then direction = c.direction.north; entity.y = 1
            if entity.y > c.room.height then direction = c.direction.south; entity.y = c.room.height
            if entity.x < 1             then direction = c.direction.west; entity.x = 1
            if entity.x > c.room.width  then direction = c.direction.east; entity.x = c.room.width

            if direction?
                if direction in @exits
                    promise = @world.pop()
                else
                    promise = @world.changeRoom direction

        return promise

    # Property Methods ############################################################################

    getKey: ->
        return Room.key @world.name, @x, @y

    setKey: (v)->
        throw new Error 'key is read-only'

    # Private Methods ##############################################################################

    _unpackData: (data)->
        @data = data

        @background  = data.background  if data.background?
        @blockImages = data.blockImages if data.blockImages?
        @exits       = data.exits       if data.exits?
        @plan        = data.plan        if data.plan?
        @spawn       = data.spawn       if data.spawn?
        @tileImages  = data.tileImages  if data.tileImages?

        @blocks = []
        @tiles = []
        for x in [0...c.room.width]
            for y in [0...c.room.height]
                imageId = @data.plan?[y]?[x]
                continue unless imageId?
                continue if imageId is ' '

                image = @blockImages?[imageId]
                if image?
                    @blocks.push new Block x+1, y+1, image
                    continue

                image = @tileImages?[imageId]
                if image?
                    @tiles.push new Block x+1, y+1, image
                    continue

                console.error "invalid image id: \"#{imageId}\""

        @entities = []
        if data.entities
            for entityData in data.entities
                Entity = entityRegistry[entityData.type]?.model
                if Entity
                    entity = new Entity entityData.x, entityData.y, entityData
                    entity.game = @game
                    @entities.push entity
                else
                    console.error "invalid entity type: #{entityData.type} in #{@key}"
