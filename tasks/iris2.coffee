# iZotope iris 2 sample Library
#   - 4568 wav files
#-------------------------------------------------- 
path     = require 'path'
zlib     = require 'zlib'
gulp     = require 'gulp'
shell    = require 'shelljs'
progress = require 'smooth-progress'
run      = require 'run-sequence'
tap      = require 'gulp-tap'
rename   = require 'gulp-rename'
unzip    = require 'gulp-unzip'
id3      = require 'gulp-maschine-id3'
util     = require '../lib/util'

$ = Object.assign {}, (require '../config'),
  suffix: path.basename __filename, '.coffee'

  vendor: 'iZotope'
  package: 'Iris 2 Library'
  src: '/Library/Application Support/iZotope/Iris 2/Iris 2 Library/Samples'
  samples: '/Volumes/Macintosh HD/Music/Samples/iZotope/Iris 2 Library'

# deploy sample files.
# --------------------------------
gulp.task "deploy-#{$.suffix}-samples", ["clean-#{$.suffix}-samples"], ->
  numFiles = util.countFiles $.src, '.wav'
  count = 0;
  bar = progress
    total: numFiles
    tmpl: "Deploying files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src ["#{$.src}/**/*.wav"]
    .pipe id3 (file, chunks) ->
      folder = (path.dirname file.relative).split path.sep
      # return metadata
      name: path.basename file.path, '.wav'
      author: $.vendor
      vendor: $.vendor
      bankchain: [$.package]
      types: switch
        # don't need 'Instruments' layer
        when folder.length > 1 and folder[0] is 'Instruments'
          [folder[1..]]
        when folder[0] is 'Synthesizers'
          # reduce for display
          folder[0] = "Synth"
          folder[2].replace /^Moog Modular /, '' if folder.length > 2
          [folder]
        else
          [folder]
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count

# deploy image resources
#  notes:
#    maschie doesn't recoginize vendor folder for sample.
#    image files should be placed in following directories.
#      images for NKSF             - <NI Content location>/NI Resources/image/<vendor>/<root of bankchain>
#      images for maschine samples - <NI Content location>/NI Resources/image/<root of bankchain>
# --------------------------------
gulp.task "deploy-#{$.suffix}-image", ["clean-#{$.suffix}-image"], ->
  gulp.src "resources/image/#{$.package.toLowerCase()}/**/*.{json,meta,png}"
    .pipe gulp.dest "#{$.NI.resources}/image/#{$.package.toLowerCase()}"

# deploy dist_database resources
#  notes:
#    maschie doesn't recoginize vendor folder for sample.
#    image files should be placed in following directories.
#      database resource files for NKSF             - <NI Content location>/NI Resources/dist_database/<vendor>/<root of bankchain>
#      database resource files for maschine samples - <NI Content location>/NI Resources/dist_database/<root of bankchain>
# --------------------------------
gulp.task "deploy-#{$.suffix}-dist_database", ["clean-#{$.suffix}-dist_database"], ->
  gulp.src "resources/dist_database/#{$.package.toLowerCase()}/**/*.{json,meta,png}"
    .pipe gulp.dest "#{$.NI.resources}/dist_database/#{$.package.toLowerCase()}"

# deploy all
# --------------------------------
gulp.task "deploy-#{$.suffix}", (cb) ->
  run [
    "deploy-#{$.suffix}-image"
    "deploy-#{$.suffix}-dist_database"
  ]
  , "deploy-#{$.suffix}-samples"
  , cb

# deploy all
# --------------------------------
gulp.task "deploy-#{$.suffix}-resources", (cb) ->
  run [
    "deploy-#{$.suffix}-image"
    "deploy-#{$.suffix}-dist_database"
  ], cb

# clean deployed sample files.
# --------------------------------
gulp.task "clean-#{$.suffix}-samples", ->
  if shell.test '-e', $.samples
    shell.rm '-rf', $.samples

# clean image resources
# --------------------------------
gulp.task "clean-#{$.suffix}-image", ->
  image = "#{$.NI.resources}/image/#{$.package.toLowerCase()}"
  if shell.test '-e', image
    shell.rm '-rf', image

# clean dist_database resources
# --------------------------------
gulp.task "clean-#{$.suffix}-dist_database", ->
  dist_database = "#{$.NI.resources}/dist_database/#{$.package.toLowerCase()}"
  if shell.test '-e', dist_database
    shell.rm '-rf', dist_database

# clean all
# --------------------------------
gulp.task "clean-#{$.suffix}", (cb) ->
  run [
    "clean-#{$.suffix}-samples"
    "clean-#{$.suffix}-image"
    "clean-#{$.suffix}-dist_database"
  ], cb
  
# clean resource files
# --------------------------------
gulp.task "clean-#{$.suffix}-resources", (cb) ->
  run [
    "clean-#{$.suffix}-image"
    "clean-#{$.suffix}-dist_database"
  ], cb
