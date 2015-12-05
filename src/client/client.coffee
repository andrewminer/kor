#
# Copyright (C) 2015 by Redwood Labs
# All rights reserved.
#

############################################################################################################

# Allow Node.js-style `global` in addition to `window`
if typeof(global) is 'undefined'
    window.global = window

global._ = require '../common/underscore'
global.w = require 'when'

console.log "client is ready"
