#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

{Howl}   = require 'howler'
{Howler} = require 'howler'

########################################################################################################################

module.exports = class SoundPlayer

    constructor: ->
        @_loops =
            nature_ambiance: new Howl
                urls: [ '/sounds/nature_ambiance.mp3' ]
                loop: true
                volume: 0.25
            rocket_thrusters: new Howl
                urls: [ '/sounds/rocket_thrusters.mp3' ]
                loop: true
                volume: 0.25

        @mute()

    # Public Methods ###############################################################################

    mute: ->
        Howler.mute()
        @_muted = true

    startLoop: (name)->
        sound = @_loops[name]
        if not sound?
            console.error "unknown sound loop: #{name}"
            return

        sound.play()

    stopLoop: (name)->
        sound = @_loops[name]
        if not sound?
            console.error "unknown sound loop: #{name}"
            return

        sound.pause()

    toggleMute: ->
        if @_muted then @unmute() else @mute()

    unmute: ->
        Howler.unmute()
        @_muted = false

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        muted:
            get: -> @_muted
            set: (muted)->
                if muted then @mute() else @unmute()
