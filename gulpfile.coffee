path       = require 'path'
gulp       = require 'gulp'
coffeelint = require 'gulp-coffeelint'
del        = require 'del'
requireDir = require 'require-dir'
dir        = requireDir './tasks'

allTasks = Object.keys gulp.tasks

# coffeelint
# --------------------------------
gulp.task 'coffeelint', ->
  gulp.src [
    '*.coffee'
    'lib/*.coffee'
  ]
    .pipe coffeelint 'coffeelint.json'
    .pipe coffeelint.reporter()

# watch
# --------------------------------
gulp.task 'watch', ->
  gulp.watch [
    './*.coffee'
    './lib/*.coffee'
  ]
  , ['coffeelint']

# clean
# --------------------------------
gulp.task 'clean', ->
  del [
    './**/*~'
    './**/*.log'
    './**/.DS_Store'
  ]

# clean-all
# --------------------------------
gulp.task 'clean-all', ['clean'], ->
  del [
    'dist'
    'temp'
    'node_modules'
  ]

# deploy all
# --------------------------------
gulp.task 'deploy', (("deploy-#{suffix}" for suffix of dir).filter (task) -> task in allTasks)
