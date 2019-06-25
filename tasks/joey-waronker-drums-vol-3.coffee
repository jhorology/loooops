# The Loop Loft
# Omar Hakim Drums Vol 3
#   - 212 wav files
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
  package: 'Joey Waronker Drums VOL 3'
  src: '/Volumes/Media/Apps/DAW/The Loop Loft/The_LoopLoft_Sessions_Platinum_WAV/JoeyWaronkerVol3_WAV'
  samples: '/Volumes/Media/Music/Samples/The Loop Loft/Joey Waronker Drums VOL 3'


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
      dirname = path.dirname file.relative
      soundInfo = {}
      type = undefined
      if dirname.startsWith 'Loops'
        soundInfo.deviceType = 'LOOP'
        type = ['Drums']
        soundInfo.tempo = parseInt (names[2].match /([0-9]*)bpm/)[1]
        soundInfo.name = "#{names[0]}[#{soundInfo.tempo}] #{names[1]}"
      else if dirname.startsWith 'Samples'
        soundInfo.name = "#{names[1]} #{names[0]}"
        soundInfo.deviceType = 'ONESHOT'
        type = drums names[0]
      else
        throw new Error "unknown folder, #{dirname}"
      # return metadata
      Object.assign soundInfo,
        author: 'Joey Waronker'
        vendor: $.vendor
        bankchain: [$.package]
        types: [type]
        modes: ['Acoustic', 'Human']
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count


drums = (name) ->
  switch
    when name.match /CrossStick/ then ['Drums', 'Cross Stick']
    when name.match /Ride/ then ['Drums', 'Ride Cymbal']
    when name.match /Cymbal/ then ['Drums', 'Cymbal']
    when name.match /Tom/ then ['Drums', 'Tom']
    when name.match /HiHatClosed/ then ['Drums', 'Hi-Hat Closed']
    when name.match /HiHatOpen/ then ['Drums', 'Hi-Hat Open']
    when name.match /HiHatSemiOpen/ then ['Drums', 'Hi-Hat Open']
    when name.match /HiHatPedal/ then ['Drums', 'Hi-Hat Pedal']
    when name.match /Kick/ then ['Drums', 'Kick']
    when name.match /SnareRim/ then ['Drums', 'Snare Rimshot']
    when name.match /Snare/ then ['Drums', 'Snare']
    when name.match /Metal/ then ['Drums', 'SFX']
    else throw new Error "unknown drums type [#{name}]"
