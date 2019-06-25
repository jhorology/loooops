# The Loop Loft
# Omar Hakim Drums Vol 2
#   - 325 wav files
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
  package: 'Joey Waronker Drums VOL 2'
  src: '/Volumes/Media/Apps/DAW/The Loop Loft/The_LoopLoft_Sessions_Platinum_WAV/JoeyWaronkerDrums2_WAV'
  samples: '/Volumes/Media/Music/Samples/The Loop Loft/Joey Waronker Drums VOL 2'


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
        type = switch
          when dirname.endsWith 'Drums'
            ['Drums']
          when dirname.endsWith 'Percussion'
            percussion names[1]
          else throw new Error "Unknown types. [#{dirname}]"
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


percussion = (name) ->
  switch
    when name.match /Chime/ then ['Percussion', 'Chime']
    when name.match /MetalCan/ then ['Percussion', 'Metal Can']
    when name.match /Scrape/ then ['Percussion', 'Scrape']
    when name.match /Shaker/ then ['Percussion', 'Shaker']
    when name.match /TinCan/ then ['Percussion', 'Tin Can']
    when name.match /Metal/ then ['Percussion', 'Metal']
    when name.match /Castanets/ then ['Percussion', 'Castanets']
    when name.match /Mallet/ then ['Percussion', 'Mallet']
    when name.match /Tambourine/ then ['Percussion', 'Tambourine']
    when name.match /Guiro/ then ['Percussion', 'Guiro']
    when name.match /Maraca/ then ['Percussion', 'Maracas']
    when name.match /Cow[B|b]ell/ then ['Percussion', 'Cowbell']
    when name.match /Bell/ then ['Percussion', 'Bell']
    when name.match /Bongo/ then ['Percussion', 'Bongo']
    when name.match /Triangle/ then ['Percussion', 'Triangle']
    when name.match /Click/ then ['Percussion', 'Click']
    when name.match /Wood/ then ['Percussion', 'Wood']
    when name.match /Anvil/ then ['Percussion', 'Metal']
    when name.match /Box/ then ['Percussion', 'Other']
    when name.match /Conga/ then ['Percussion', 'Conga']
    else throw new Error "unknown percussion type [#{name}]"

drums = (name) ->
  switch
    when name.match /Tom/ then ['Drums', 'Tom']
    when name.match /Crash/ then ['Drums', 'Crash Cymbal']
    when name.match /HatClosed/ then ['Drums', 'Hi-Hat Closed']
    when name.match /HatOpen/ then ['Drums', 'Hi-Hat Open']
    when name.match /Kick/ then ['Drums', 'Kick']
    when name.match /Ride/ then ['Drums', 'Ride Cymbal']
    when name.match /Snare/ then ['Drums', 'Snare']
    when name.match /XStick/ then ['Drums', 'Cross Stick']
    else throw new Error "unknown drums type [#{name}]"
