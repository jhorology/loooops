# iZotope iris 2 sample Library
#   - 4568 wav files
#-------------------------------------------------- 
path     = require 'path'
gulp     = require 'gulp'
progress = require 'smooth-progress'
tap      = require 'gulp-tap'
id3      = require 'gulp-maschine-id3'
util     = require '../lib/util'

# ======================================================
#  paths, misc settings
# ======================================================
$ = Object.assign {}, (require '../config'),

  # required common settings
  # -----------------------------------------
  task: path.basename __filename, '.coffee'
  vendor: 'iZotope, Inc.'
  package: 'iZotope Iris 2'
  src: '/Volumes/Media/Music/iZotope/Iris 2/Iris 2 Library/Samples'
  samples: '/Volumes/Media/Music/Samples/iZotope/iZotope Iris 2'
  # already have NKS resources
  noResources: on

# ======================================================
#  common tasks  
# ======================================================
util.registerCommonGulpTasks $

# deploy sample files.
# --------------------------------
gulp.task "deploy-#{$.task}-samples", ->
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
      console.log file.path, $.package
      name: path.basename file.path, '.wav'
      author: $.vendor
      vendor: $.vendor
      bankchain: [$.package]
      deviceType: 'ONESHOT'
      types: switch
        # don't need 'Instruments' layer
        when folder.length > 1 and folder[0] is 'Instruments'
          [folder[1..]]
        when folder[0] is 'Synthesizers'
          # reduce for display
          folder[0] = "Synth"
          folder[2] = folder[2].replace /^Moog Modular /, '' if folder.length > 2
          [folder]
        else
          [folder]
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count
