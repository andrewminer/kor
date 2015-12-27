#
# Copyright © 2015 by Redwood Labs
# All rights reserved.
#

EXTERNAL_LIBS = [
    'backbone'
    'd3'
    'howler'
    'jquery'
    'underscore'
    'underscore.inflections'
    'victor'
    'when'
]

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
                    dest:   './dist/static/'
                ]

        clean:
            assets: ['./dist/static/data', './dist/static/images']
            dist: ['./dist']
            templates: ['./src/client/templates.js']

        jade:
            pages:
                options:
                    pretty: true
                files: [
                    expand: true
                    cwd:  './src/client/pages'
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
                    './src/client/templates.js': ['./src/client/pages/**/!(index)*.jade']

        sass:
            all:
                files:
                    './dist/static/main.css': ['./src/client/styles/main.scss']

        uglify:
            scripts:
                options:
                    maxLineLen: 20
                files: [
                    expand: true
                    cwd: './dist/static'
                    src: '**/*.js'
                    dest: './dist/static'
                ]

        watch:
            assets:
                files: ['./src/assets/**/*']
                tasks: ['copy:assets']
            client_source:
                files: ['./src/{client,common}/**/*.coffee']
                tasks: ['browserify:internal']
            server_source:
                files: ['./src/{common,server}/**/*.coffee']
                tasks: ['copy:server_source']
            jade_pages:
                files: ['./src/**/index.jade']
                tasks: ['jade:pages']
            jade_templates:
                files: ['./src/**/!(index).jade']
                tasks: ['jade:templates', 'browserify:internal']
            sass:
                files: ['./src/**/*.scss']
                tasks: ['sass']

    grunt.registerTask 'default', ['build', 'start']

    grunt.registerTask 'browserify:internal', "Bundle source files needed in the browser", ->
        grunt.file.mkdir './dist/static'
        done = this.async()

        args = [].concat ("--external=#{lib}" for lib in EXTERNAL_LIBS), [
            '--extension=.coffee'
            '--outfile=./dist/static/internal.js'
            '--transform=coffeeify'
            './src/client/client.coffee'
        ]

        options = cmd:'browserify', args:args
        grunt.util.spawn options, (error)->
            console.log error if error?
            done()

    grunt.registerTask 'browserify:external', "Bundle 3rd-party libraries used in the app", ->
        grunt.file.mkdir './dist/static'
        done = this.async()

        args = [].concat ("--require=#{lib}" for lib in EXTERNAL_LIBS), [
            '--outfile=./dist/static/external.js'
        ]

        options = cmd:'browserify', args:args
        grunt.util.spawn options, (error)->
            console.log error if error?
            done()

    grunt.registerTask 'build', ['jade', 'copy', 'sass', 'browserify:internal', 'browserify:external']

    grunt.registerTask 'deploy', ['clean', 'build', 'uglify', 's3:upload']

    grunt.registerTask 's3:upload', 'uploads all static content to S3', ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/deploy', opts:{stdio:'inherit'}, -> done()

    grunt.registerTask 'start', "Start the server at port 8080", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/start', opts:{stdio:'inherit'}, -> done()

