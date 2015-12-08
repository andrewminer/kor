#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

Entity = require './entity'

########################################################################################################################

module.exports = class StaticEntity extends Entity

    constructor: (x, y, data)->
        super x, y

        @image         = data.image       if data.image?
        @image        ?= data.type        if data.type?
        @maxStep       = data['max-step'] if data['max-step']?
        @ticksPerStep  = data.ticks       if data['ticks-per-step']?
        @type          = data.type        if data.type?

        @type         ?= 'invisible'
        @maxStep      ?= 0
        @step          = 0
        @ticksPerStep ?= 4

