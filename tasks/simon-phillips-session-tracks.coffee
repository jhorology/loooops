# The Loop Loft
# Simon Phillips Session Tracks
#   - 599 wav files
#-------------------------------------------------- 
path       = require 'path'
gulp       = require 'gulp'
progress   = require 'smooth-progress'
tap        = require 'gulp-tap'
decompress = require 'gulp-decompress'
id3        = require 'gulp-maschine-id3'
gulpif     = require 'gulp-if'
util       = require '../lib/util'
removeSilence = require '../lib/gulp-remove-silence'

$ = Object.assign {}, (require '../config'),

  # required common settings
  # -----------------------------------------
  task: path.basename __filename, '.coffee'
  vendor: 'The Loop Loft'
  package: 'Simon Phillips Session Tracks'
  src: '/Volumes/Media/Apps/DAW/The Loop Loft/SimonPhillips_Stereo_WAV'
  samples: '/Volumes/Media/Music/Samples/The Loop Loft/Simon Phillips Session Tracks'

# ======================================================
#  common tasks  
# ======================================================
util.registerCommonGulpTasks $

# deploy sample files.
# --------------------------------
gulp.task "deploy-#{$.task}-samples", ->
  numFiles = (util.countFiles $.src, ".wav") + (util.countFiles $.src, ".WAV") 
  count = 0;
  console.info numFiles
  bar = progress
    total: numFiles
    tmpl: "Deploying files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src ["#{$.src}/**/*.{wav,WAV}"]
    .pipe gulpif (file) ->
      file.relative.match /^OneShot_Samples/
    , removeSilence threshold: '-70dB'
    .pipe gulpif (file) ->
       file.extname is '.wav' or file.extname is '.WAV'
    , id3 (file, chunks) ->
      file.extname = '.wav'
      names = (path.basename file.path, '.wav').split '_'
      type = ['Drums']
      soundInfo = {}
      if file.relative.match /^OneShot_Samples/
        soundInfo.deviceType = 'ONESHOT'
        soundInfo.name = 'SimonPhillips ' + names.join ' '
        type.push switch
          when names[0].match /Crash/ then 'Crash Cymbal'
          when names[0].match /HatClosed/ then 'Hi-Hat Closed'
          when names[0].match /HatFoot/ then 'Hi-Hat Pedal'
          when names[0].match /HatOpen|HatHalf/ then 'Hi-Hat Open'
          when names[0].match /Ride/ then 'Ride Cymbal'
          when names[0].match /Kick/ then 'Kick'
          when names[0].match /Sidestick/ then 'Snare Side Stick'
          when names[0].match /Snare/ then 'Snare'
          when names[0].match /Tom/ then 'Tom'
          else throw new Error "Unknown type [#{name}]"
      else
        soundInfo.deviceType = 'LOOP'
        soundInfo.tempo = parseFloat (names[0].match /^([0-9\.]*)/)[1]
        soundInfo.name = if file.relative.startsWith '4_Fast_Previews'
          name = "Preview[#{soundInfo.tempo}] #{(names.slice 1, -1).join ' '}"
        else
          dirname = ((path.dirname file.relative).split path.sep)[0]
          "#{((dirname.split '_').slice 1).join ' '}[#{soundInfo.tempo}] #{(names.slice 1).join ' '}"
      # return metadata
      Object.assign soundInfo,
        author: 'Simon Phillips'
        vendor: $.vendor
        bankchain: [$.package]
        types: [type]
        modes: ['Acoustic', 'Human']
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count

