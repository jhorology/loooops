# KORG Gadget 2 Abu Dhabi factory samples
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
  suffix: path.basename __filename, '.coffee'
  vendor: 'KORG'
  package: 'AbuDhabi'
  src: '/Library/Application Support/KORG/Gadget/factory samples/Abu Dhabi/Factory'
  samples: '/Volumes/Media/Music/Samples/KORG/Gadget/Abu Dhabi'
  # already have NKS resources
  nks: on

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
  gulp.src ["#{$.src}/**/*.wav"]
    .pipe id3 (file, chunks) ->
      folder = (path.dirname file.relative).split path.sep
      basename = path.basename file.path, '.wav'
      # return metadata
      name: basename
      author: $.vendor
      vendor: $.vendor
      bankchain: [$.package]
      deviceType: 'LOOP'
      types: [[(basename.split ' ')[0]]]
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count
