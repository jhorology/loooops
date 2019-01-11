path       = require 'path'
gulp       = require 'gulp'
coffeelint = require 'gulp-coffeelint'
del        = require 'del'
requireDir = require 'require-dir'
fwdRef     = require 'undertaker-forward-reference'

gulp.registry fwdRef()
dir        = requireDir './tasks'
allTasks   = gulp.tree().nodes

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
  , gulp.task 'coffeelint'

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
gulp.task 'clean-all',
  gulp.series 'clean', ->
    del [
      'dist'
      'temp'
      'node_modules'
    ]

# deploy all
# --------------------------------
gulp.task 'deploy',
  gulp.series.apply this,
    (("deploy-#{suffix}" for suffix of dir).filter (task) -> task in allTasks)
