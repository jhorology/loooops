# The Loop Loft
# Doug Wamble The Telecaster Sessions
#   - 6444 wav files
#-------------------------------------------------- 
path       = require 'path'
gulp       = require 'gulp'
progress   = require 'smooth-progress'
tap        = require 'gulp-tap'
id3        = require 'gulp-maschine-id3'
util       = require '../lib/util'

$ = Object.assign {}, (require '../config'),

  # required common settings
  # -----------------------------------------
  task: path.basename __filename, '.coffee'
  vendor: 'The Loop Loft'
  package: 'Doug Wamble Telecaster Sessions'
  src: '/Volumes/Media/Apps/DAW/The Loop Loft/The_LoopLoft_Sessions_Platinum_WAV/DougWamble_TeleSessions_WAV'
  samples: '/Volumes/Media/Music/Samples/The Loop Loft/Doug Wamble Telecaster Sessions'


# ======================================================
#  common tasks  
# ======================================================
util.registerCommonGulpTasks $

# deploy sample files.
# --------------------------------
gulp.task "deploy-#{$.task}-samples", ->
  numFiles = util.countFiles $.src, ".wav"
  count = 0;
  bar = progress
    total: numFiles
    tmpl: "Deploying files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src ["#{$.src}/**/*.wav"]
    .pipe id3 (file, chunks) ->
      basename = path.basename file.path, '.wav'
      names = basename.split '_'
      tempo = parseInt names[1]
      mode = if basename.startsWith 'D_100_' then 'Distorted' else 'clean'
      # return metadata
      name: "#{names[3]}[#{names[1]}] #{names[0]} #{names[2]} #{names[4]}"
      author: 'Doug Wamble'
      vendor: $.vendor
      bankchain: [$.package]
      deviceType: 'LOOP'
      tempo: tempo
      types: [
        ['Guitar']
      ]
      modes: [mode]
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count

