#
# Copyright © 2015 by Andrew Miner
# All rights reserved.
#

########################################################################################################################

module.exports = class MainPageController extends Backbone.View

    constructor: (options={})->
        options.el = 'body'
        super options
