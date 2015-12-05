#
# Copyright (C) 2015 by Redwood Labs
# All rights reserved.
#

module.exports = (grunt)->

    grunt.loadTasks tasks for tasks in grunt.file.expand './node_modules/grunt-*/tasks'

    grunt.config.init

        copy:
            server_source:
                files: [
                    expand: true
                    cwd:    './src/server'
                    src:    '**/*.coffee'
                    dest:   './dist/'
                    ext:    '.coffee'
                ]
            common_source:
                files: [
                    expand: true
                    cwd:    './src/common'
                    src:    '**/*.coffee'
                    dest:   './dist/'
                    ext:    '.coffee'
                ]
            assets:
                files: [
                    expand: true
                    cwd:    './src/assets/'
                    src:    '**/*'
                    dest:   './dist/static'
                ]

        clean:
            dist: ['./dist']
            templates: ['./src/client/templates.js']

        jade:
            pages:
                options:
                    pretty: true
                files: [
                    expand: true
                    cwd:  './src/client'
                    src:  '**/index.jade'
                    dest: './dist/static'
                    ext:  '.html'
                ]
            templates:
                options:
                    client: true
                    node: true
                    processName: (f)->
                        f = f.replace /^.*\/\(.*\)$/, '$1'
                        f = f.replace '.jade', ''
                        f = f.replace /\//g, '_'
                        return f
                files:
                    './src/client/templates.js': ['./src/client/!{layouts}/**/!(index)*.jade']

        sass:
            all:
                files:
                    './dist/static/main.css': ['./src/**/*.scss']

        watch:
            client_source:
                files: ['./src/{client,common}/**/*.coffee']
                tasks: ['browserify']
            server_source:
                files: ['./src/{common,server}/**/*.coffee']
                tasks: ['copy:server_source']
            jade_pages:
                files: ['./src/**/index.jade']
                tasks: ['jade:pages']
            jade_templates:
                files: ['./src/**/!(index).jade']
                tasks: ['jade:templates', 'browserify']
            sass:
                files: ['./src/**/*.scss']
                tasks: ['sass']

    grunt.registerTask 'default', ['build', 'start']

    grunt.registerTask 'browserify', "Bundle source files needed in the browser", ->
        grunt.file.mkdir './dist/static'

        done = this.async()
        options = cmd:'browserify', args:[
            '--debug'
            '--full-paths'
            '--extension=.coffee'
            '--transform=coffeeify'
            '--outfile=./dist/static/client.js'
            './src/client/client.coffee'
        ]
        grunt.util.spawn options, (error)->
            console.log error if error?
            done()

    grunt.registerTask 'build', ['jade', 'copy', 'sass', 'browserify']

    grunt.registerTask 'start', "Start the server at port 8080", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/start', opts:{stdio:'inherit'}, -> done()
