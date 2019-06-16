# The Loop Loft
# Omar Hakim Drums Vol 2
#   - 259 wav files
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
  package: 'Omar Hakim Drums VOL 2'
  src: '/Volumes/Media/Apps/DAW/The Loop Loft/The_LoopLoft_Sessions_Platinum_WAV/OmarHakimDrums2_WAV'
  samples: '/Volumes/Media/Music/Samples/The Loop Loft/Omar Hakim Drums VOL 2'


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
      tempo = parseInt (basename.split '_')[1]
      mode = if basename.startsWith 'D_100_' then 'Distorted' else 'clean'
      type = ['Drums']
      soundInfo = {}
      if file.relative.startsWith 'Audio Loops'
        soundInfo.deviceType = 'LOOP'
        soundInfo.tempo = parseInt (basename.match /_([0-9]*)bpm/)[1]
      else
        soundInfo.deviceType = 'ONESHOT'
        type.push switch
          when basename.match /Snare/ then 'Snare'
          when basename.match /China/ then 'China Cymbal'
          when basename.match /Crash/ then 'Crash Cymbal'
          when basename.match /Splash/ then 'Crash Cymbal'
          when basename.match /CrossStick/ then 'Snare Rimshot'
          when basename.match /HatClosed/ then 'Hi-Hat Closed'
          when basename.match /HatFoot/ then 'Hi-Hat Pedal'
          when basename.match /HatOpen/ then 'Hi-Hat Open'
          when basename.match /Kick/ then 'Kick'
          when basename.match /RideBell/ then 'Ride Bell'
          when basename.match /Ride/ then 'Ride Cymbal'
          when basename.match /Tom/ then 'Tom'
      # return metadata
      Object.assign soundInfo,
        name: basename
        author: 'Omar Hakim'
        vendor: $.vendor
        bankchain: [$.package]
        types: [type]
        modes: ['Acoustic', 'Human']
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count

