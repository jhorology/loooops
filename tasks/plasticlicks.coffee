# D16 Group Audio Software
# Plasticlicks - Drum Sounds Collection
#   - 6444 wav files
#-------------------------------------------------- 
path       = require 'path'
gulp       = require 'gulp'
progress   = require 'smooth-progress'
tap        = require 'gulp-tap'
decompress = require 'gulp-decompress'
id3        = require 'gulp-maschine-id3'
util       = require '../lib/util'

$ = Object.assign {}, (require '../config'),

  # required common settings
  # -----------------------------------------
  suffix: path.basename __filename, '.coffee'
  vendor: 'D16 Group Audio Software'
  package: 'Plasticlicks'
  src: '/Volumes/Media/Apps/DAW/D16/Plasticlicks - Drum Sounds Collection/Wave files and Akai programs.zip'
  samples: '/Volumes/Media/Music/Samples/D16 Group Audio Software/Plasticlicks'


# ======================================================
#  common tasks  
# ======================================================
util.registerCommonGulpTasks $

# deploy sample files.
# --------------------------------
gulp.task "deploy-#{$.suffix}-samples", ->
  numFiles = util.countFiles $.src, '.wav'
  count = 0;
  bar = progress
    total: numFiles
    tmpl: "Deploying files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src $.src
    .pipe decompress {filter: (entry) -> entry.path[-4..] is '.wav'}
    .pipe id3 (file, chunks) ->
      # remove heading "Plasticlicks/"
      file.path = file.path.replace /^Plasticlicks\//, ''
      basename = path.basename file.path, '.wav'
      type = path.dirname file.path
      # return metadata
      name: basename
      author: $.vendor
      vendor: $.vendor
      bankchain: [$.package]
      deviceType: 'ONESHOT'
      types: [
        ['Drums', type]
      ]
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count
