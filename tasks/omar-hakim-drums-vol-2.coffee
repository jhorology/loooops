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
      names = (path.basename file.path, '.wav').split '_'
      type = ['Drums']
      soundInfo = {}
      if file.relative.startsWith 'Audio Loops'
        soundInfo.deviceType = 'LOOP'
        soundInfo.tempo = parseInt (names[2].match /([0-9]*)bpm/)[1]
        soundInfo.name = "#{names[1]}[#{soundInfo.tempo}] #{names[0]}"
      else
        soundInfo.name = names.reverse().join ' '
        soundInfo.deviceType = 'ONESHOT'
        type.push switch
          when names[1].match /Snare/ then 'Snare'
          when names[1].match /China/ then 'China Cymbal'
          when names[1].match /Crash/ then 'Crash Cymbal'
          when names[1].match /Splash/ then 'Crash Cymbal'
          when names[1].match /CrossStick/ then 'Cross Stick'
          when names[1].match /HatClosed/ then 'Hi-Hat Closed'
          when names[1].match /HatFoot/ then 'Hi-Hat Pedal'
          when names[1].match /HatOpen/ then 'Hi-Hat Open'
          when names[1].match /Kick/ then 'Kick'
          when names[1].match /RideBell/ then 'Ride Bell'
          when names[1].match /Ride/ then 'Ride Cymbal'
          when names[1].match /Tom/ then 'Tom'
      # return metadata
      Object.assign soundInfo,
        author: 'Omar Hakim'
        vendor: $.vendor
        bankchain: [$.package]
        types: [type]
        modes: ['Acoustic', 'Human']
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count

