# KORG Gadget 2 Bilbaof factory samples
#-------------------------------------------------- 
path     = require 'path'
gulp     = require 'gulp'
progress = require 'smooth-progress'
tap      = require 'gulp-tap'
id3      = require 'gulp-maschine-id3'
_        = require 'underscore'
util     = require '../lib/util'

# ======================================================
#  paths, misc settings
# ======================================================
$ = Object.assign {}, (require '../config'),

  # required common settings
  # -----------------------------------------
  suffix: path.basename __filename, '.coffee'
  vendor: 'KORG'
  package: 'Bilbao'
  src: '/Library/Application Support/KORG/Gadget/factory samples/Bilbao'
  samples: '/Volumes/Media/Music/Samples/KORG/Gadget/Bilbao'
  # already have NKS resources
  nks: on

  # local settings
  # -----------------------------------------
  types:
    BD: 'Kick'
    CP: 'Clap'
    CY: 'Cymbal'
    FX: ['Sound Effects']
    HH: 'Hi-Hat'
    HT: 'Hit'
    SD: 'Snare'
    TM: 'Tom'
    PC: ['Percussion']
    VO: ['Vocal']
    
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
      kitName = path.dirname file.relative
      basename = path.basename file.path, '.wav'
      abbrev = (basename.split '_')[0]
      type = $.types[abbrev]
      type = ['Drums', type] if _.isString type
      # return metadata
      name: "#{kitName} #{basename}"
      author: $.vendor
      vendor: $.vendor
      bankchain: [$.package]
      deviceType: 'ONESHOT'
      types: [type]
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count
