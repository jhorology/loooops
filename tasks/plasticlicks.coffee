path     = require 'path'
gulp     = require 'gulp'
shell    = require 'shelljs'
util     = require '../lib/util'
progress = require 'smooth-progress'
tap      = require 'gulp-tap'
rename   = require 'gulp-rename'
unzip    = require 'gulp-unzip'
zlib     = require 'zlib'
id3      = require '../lib/gulp-maschine-id3'
 
$ = Object.assign {}, (require '../config'),
  suffix: path.basename __filename, '.coffee'

  zip: '/Volumes/Macintosh HD/Apps/DAW/D16/Plasticlicks - Drum Sounds Collection/Wave files and Akai programs.zip'
  deploy: '/Volumes/Macintosh HD/Music/Samples/D16 Group Audio Software/Plasticlicks'

# clean deployed files.
# --------------------------------
gulp.task "clean-deployed-#{$.suffix}", ->
  if shell.test '-e', $.deploy
    shell.rm '-rf', $.deploy

# deploy maschine-aware .wav files.
# --------------------------------
gulp.task "deploy-#{$.suffix}", ["clean-deployed-#{$.suffix}"], ->
  numFiles = util.countFiles $.zip, '.wav'
  count = 0;
  bar = progress
    total: numFiles
    tmpl: "Deploying files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src $.zip
    .pipe unzip {filter: (entry) -> entry.path[-4..] is '.wav'}
    .pipe id3 (file, chunks) ->
      # remove heading "Plasticlicks/"
      file.path = file.path.replace /^Plasticlicks\//, ''
      basename = path.basename file.path
      type = path.dirname file.path
      # return metadata
      name: basename
      author: 'D16 Group Audio Software'
      vendor: 'D16 Group Audio Software'
      bankchain: ['Plasticlick']
      types: [
        ['Drum', type]
      ]
    .pipe gulp.dest $.deploy
    .pipe tap -> bar.tick 1, cur: ++count
