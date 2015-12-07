#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

exports.room = {}
exports.room.x = d3.scale.linear().domain([0.5, c.room.width + 0.5]).range([0, c.canvas.width])
exports.room.y = d3.scale.linear().domain([0.5, c.room.height + 0.5]).range([0, c.canvas.height])

exports.world = {}
exports.world.x = d3.scale.linear().domain([0, 1]).range([0, c.canvas.width])
exports.world.y = d3.scale.linear().domain([0, 1]).range([0, c.canvas.height])
