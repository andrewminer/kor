#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

Block          = require './block'
entityRegistry = require '../../entity_registry'

########################################################################################################################

module.exports = class Room

    constructor: (@world, @x, @y)->
        @background = {}
        @blocks     = []
        @data       = null
        @exits      = []
        @entities   = []
        @images     = []
        @spawn      = null
        @tiles      = []

    # Class Methods ################################################################################

    @key: (worldName, x, y)->
        "#{worldName}.#{x},#{y}"

    # Public Methods ###############################################################################

    load: ->
        return w(this) if @data?

        w.promise (resolve, reject)=>
            d3.json "data/world/#{@world.name}/#{@x},#{@y}.json", (error, data)=>
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
        for entity in @entities
            entity.onGameStep()

    testCollisionWith: (entity)->
        direction = null
        promise   = w(true)

        if entity.type is 'player'
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

    Object.defineProperties @prototype,
        key:
            get: -> return Room.key @world.name, @x, @y

    # Private Methods ##############################################################################

    _createEntity: (entityData)->
        Entity = entityRegistry[entityData.type]?.model
        if Entity
            entity = new Entity entityData.x, entityData.y, entityData
        else
            console.error "invalid entity type: #{entityData.type} in #{@key}"

        return entity

    _unpackBackground: (data)->
        return unless data.background?
        if data.background.color?
            @background.color = data.background.color

        if data.background.images?.length
            @background.images = data.background.images

    _unpackData: (data)->
        @data     = data
        @entities = []
        @tiles    = []
        @blocks   = []

        @_unpackBackground data
        @_unpackEntities data
        @_unpackExits data
        @_unpackPlan data
        @_unpackSpawn data

    _unpackEntities: (data)->
        return unless data.entities?

        for entityData in data.entities
            entityData.x = parseFloat entityData.x
            entityData.y = parseFloat entityData.y
            @entities.push @_createEntity entityData

    _unpackExits: (data)->
        return unless data.exits?
        @exits = data.exits

    _unpackPlan: (data)->
        return unless data.plan?

        for x in [0...c.room.width]
            for y in [0...c.room.height]
                imageId = data.plan?[y]?[x]

                if imageId? and imageId isnt ' '
                    image = data.blocks?[imageId]
                    if image?
                        @blocks.push new Block x+1, y+1, image
                        continue

                    image = data.tiles?[imageId]
                    if image?
                        @tiles.push new Block x+1, y+1, image
                        continue

                if imageId isnt ' '
                    console.error "invalid image id: \"#{imageId}\" in #{@key}"

    _unpackSpawn: (data)->
        return unless data.spawn?
        @spawn = data.spawn
