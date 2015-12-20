#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

########################################################################################################################

module.exports = class Rectangle

    constructor: (x, y, width, height)->
        @x      = x
        @y      = y
        @width  = width
        @height = height

    # Class Methods ################################################################################

    @atCenter: (x, y, width, height)->
        return new Rectangle x - (width / 2), y - (height / 2), width, height

    @intersect: (a, b)->
        left   = Math.max a.left, b.left
        right  = Math.min a.right, b.right
        return false if left >= right

        top    = Math.max a.top, b.top
        bottom = Math.min a.bottom, b.bottom
        return false if top >= bottom

        return true

    # Public Methods ###############################################################################

    centerAt: (x, y)->
        @x = x - (@width / 2)
        @y = y - (@height / 2)

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        bottom:
            get: -> @y + @height

        center:
            get: -> x:@x + (@width / 2), y:@y + (@height / 2)

        left:
            get: -> @x

        right:
            get: -> @x + @width

        top:
            get: -> @y

    # Object Overrides #############################################################################

    toString: ->
        return "{#{@x}, #{@y}, #{@width}, #{@height}}"
