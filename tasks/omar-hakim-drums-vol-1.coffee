# The Loop Loft
# Omar Hakim Drums Vol 1
#   - 316 wav files
#-------------------------------------------------- 
path       = require 'path'
gulp       = require 'gulp'
progress   = require 'smooth-progress'
tap        = require 'gulp-tap'
id3        = require 'gulp-maschine-id3'
gulpif     = require 'gulp-if'
util       = require '../lib/util'
removeSilence = require '../lib/gulp-remove-silence'

$ = Object.assign {}, (require '../config'),

  # required common settings
  # -----------------------------------------
  task: path.basename __filename, '.coffee'
  vendor: 'The Loop Loft'
  package: 'Omar Hakim Drums VOL 1'
  src: '/Volumes/Media/Apps/DAW/The Loop Loft/The_LoopLoft_Sessions_Platinum_WAV/OmarHakimDrums_WAV'
  samples: '/Volumes/Media/Music/Samples/The Loop Loft/Omar Hakim Drums VOL 1'


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
  gulp.src ["#{$.src}/**/*.{wav,mid}"]
    .pipe gulpif (file) ->
      file.relative.match /^Samples/
    , removeSilence threshold: '-70dB'
    .pipe gulpif (file) ->
       file.extname is '.mid'
    , tap (file) ->
      names = (path.basename file.path, '.mid').split '_'
      tempo = parseInt (names[1].match /([0-9]*)bpm/)[1]
      file.basename = "#{names[2]}[#{tempo}] #{names[0].replace /^MIDI /, ''}.mid"
    .pipe gulpif (file) ->
       file.extname is '.wav'
    , id3 (file, chunks) ->
      names = (path.basename file.path, '.wav').split '_'
      type = ['Drums']
      soundInfo = {}
      if file.relative.match /^Audio Loops/
        soundInfo.deviceType = 'LOOP'
        soundInfo.tempo = parseInt (names[1].match /([0-9]*)bpm/)[1]
        soundInfo.name = "#{names[2]}[#{soundInfo.tempo}] #{names[0]}"
      else if file.relative.match /^Samples/
        soundInfo.name = names.reverse().join ' '
        if names[0] is 'OmarHakim.Fade' and names[1] is 'China'
          soundInfo.name = 'OmarHakim ChinaFade'
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
          else throw new Error "unknown type [#{names[1]}]"
      else
        throw new Error "unknown folder. [#{file.relative}]"
      # return metadata
      Object.assign soundInfo,
        author: 'Omar Hakim'
        vendor: $.vendor
        bankchain: [$.package]
        types: [type]
        modes: ['Acoustic', 'Human']
    .pipe gulp.dest $.samples
    .pipe gulpif (file) ->
       file.extname is '.wav'
    , tap -> bar.tick 1, cur: ++count
