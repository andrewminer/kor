#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class View

    constructor: (root, model)->
        @_children = []
        @_model    = model
        @parent    = null
        @root      = root

    # Public Methods ###############################################################################

    addChild: (child)->
        child.parent = this
        @_children.push child
        return child

    removeChild: (child)->
        for currentChild, index in @_children
            if currentChild is child
                @_children.splice index, 1
                return

    removeFromParent: ->
        return unless @parent?
        @parent.removeChild this

    # Overrideable Methods #########################################################################

    render: ->
        @refresh()
        # subclasses should implement this to perform any special one-time rendering when they are newly created and
        # then call 'super'

    refresh: ->
        # subclasses should implement this to perform any element enter/update/exit activity during the normal game loop
        # and then call 'super'
        w.all (child.refresh() for child in @children)

    remove: ->
        # subclasses should implement this to remove any elements they control and then call 'super'
        w.all (child.remove() for child in @children)

    onModelChanged: (oldModel, newModel)->
        # do nothing. subclasses may override if necessary

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        children:
            get: ->
                return @_children[..]

        model:
            get: ->
                return @_model

            set: (newModel)->
                return unless newModel isnt @_model
                oldModel = @_model
                @_model = newModel
                @onModelChanged oldModel, newModel

        root:
            get: ->
                return @_root

            set: (newRoot)->
                if @_root? then throw new Error 'root may only be set once'
                if not newRoot then throw new Error 'root may not be null'
                @_root = newRoot
