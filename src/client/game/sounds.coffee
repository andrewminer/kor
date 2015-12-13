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
            rocket_thrusters: new Howl
                urls: [ '/sounds/rocket_thrusters.mp3' ]
                loop: true
                volume: 0.25
        @_muted = false

    # Public Methods ###############################################################################

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
        if @_muted then Howler.unmute() else Howler.mute()
        @_muted = not @_muted
