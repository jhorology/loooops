# The Loop Loft
# Omar Hakim Drums Vol 1
#   - 381 wav files
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
  package: 'Joey Waronker Drums VOL 1'
  src: '/Volumes/Media/Apps/DAW/The Loop Loft/The_LoopLoft_Sessions_Platinum_WAV/JoeyWaronkerDrums_WAV'
  samples: '/Volumes/Media/Music/Samples/The Loop Loft/Joey Waronker Drums VOL 1'


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
      names = (path.basename file.path, '.wav').split '_'
      tempo = parseInt (names[2].match /([0-9]*)bpm/)[1]
      file.basename = "#{names[1]}[#{tempo}] #{names[0].replace /^MIDI /, ''}.mid"
    .pipe gulpif (file) ->
       file.extname is '.wav'
    , id3 (file, chunks) ->
      names = (path.basename file.path, '.wav').split '_'
      dirname = path.dirname file.relative
      soundInfo = {}
      type = undefined
      if dirname.startsWith 'Audio Loops'
        soundInfo.deviceType = 'LOOP'
        type = switch
          when dirname.endsWith 'Drums'
            ['Drums']
          when dirname.endsWith 'Percussion'
            percussion names[0]
          else throw new Error "Unknown types. [#{dirname}]"
        soundInfo.tempo = parseInt (names[2].match /([0-9]*)bpm/)[1]
        soundInfo.name = "#{names[1]}[#{soundInfo.tempo}] #{names[0]}"
      else if dirname.startsWith 'Samples'
        soundInfo.name = "#{names[2]} #{if names.length is 4 then (names[3] + ' ') else ''} #{names[0]} #{names[1]}"
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
    .pipe gulpif (file) ->
       file.extname is '.wav'
    , tap -> bar.tick 1, cur: ++count


percussion = (name) ->
  switch
    when name.match /Cabasa/ then ['Percussion', 'Cabasa']
    when name.match /Cowbell/ then ['Percussion', 'Cowbell']
    when name.match /Crotales/ then ['Percussion', 'Crotales']
    when name.match /PaintCan/ then ['Percussion', 'PaintCan']
    when name.match /Shaker/ then ['Percussion', 'Shaker']
    when name.match /Tambo/ then ['Percussion', 'Tambourine']
    when name.match /Triangle/ then ['Percussion', 'Triangle']
    when name.match /Efx/ then ['Percussion', 'Other']
    when name.match /Cymbals/ then ['Percussion', 'Cymbals']
    when name.match /Agogo/ then ['Percussion', 'Agogo']
    when name.match /Metal/ then ['Percussion', 'Other']
    when name.match /Wood/ then ['Percussion', 'Wood']
    else throw new Error "unknown percussion type [#{name}]"

drums = (name) ->
  switch
    when name.match /Crash/ then ['Drums', 'Crash Cymbal']
    when name.match /Tom/ then ['Drums', 'Tom']
    when name.match /HiHatClosed/ then ['Drums', 'Hi-Hat Closed']
    when name.match /HiHatFoot/ then ['Drums', 'Hi-Hat Pedal']
    when name.match /HiHatOpen/ then ['Drums', 'Hi-Hat Open']
    when name.match /Kick/ then ['Drums', 'Kick']
    when name.match /Ride/ then ['Drums', 'Ride Cymbal']
    when name.match /Snare/ then ['Drums', 'Snare']
    when name.match /CrossStick/ then ['Drums', 'Cross Stick']
    else throw new Error "unknown drums type [#{name}]"
