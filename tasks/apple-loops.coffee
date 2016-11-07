path     = require 'path'
gulp     = require 'gulp'
shell    = require 'shelljs'
util     = require '../lib/util'
progress = require 'smooth-progress'
meta     = require 'apple-loops-meta-reader'
exec     = require 'gulp-exec'
tap      = require 'gulp-tap'
rename   = require 'gulp-rename'
id3      = require '../lib/gulp-maschine-id3'
 
$ = Object.assign {}, (require '../config'),
  suffix: path.basename __filename, '.coffee'
  
  src: '/Library/Audio/Apple Loops/Apple'
  # *caution* need around 20G or more disk space.
  ripped: '/Volumes/Macintosh HD/Temporary/Apple Loops/Apple'
  # *caution* need around 20G or more disk space.
  deploy: '/Volumes/Macintosh HD/Music/Samples/Apple'

# clean ripped files.
# --------------------------------
gulp.task "clean-ripped-#{$.suffix}", ->
  if shell.test '-e', $.ripped
    shell.rm '-rf', $.ripped

# convert .caf -> .wav
# --------------------------------
gulp.task "rip-#{$.suffix}", ["clean-ripped-#{$.suffix}"], ->
  numFiles = util.countFiles $.src, '.caf'
  throw new Error '.caf files doesn\'t exist' unless numFiles
  count = 0;
  bar = progress
    total: numFiles
    tmpl: "Converting files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src ["#{$.src}/**/*.caf"]
    .pipe tap (file) ->
      file.distPath = (path.join $.ripped, file.relative)[..-5] + '.wav'
      file.distDir = path.dirname file.distPath
    .pipe exec [
      'mkdir -p "<%= file.distDir %>"'
      'afconvert -f WAVE -d LEI16 "<%= file.path %>" "<%= file.distPath %>"'
      ].join ' && '
    , $.execOopts
    .pipe exec.reporter $.execReportOpts
    .pipe tap (file) ->
      file.contents = util.json2buffer meta.read(file.path),
    .pipe rename extname: '.json'
    .pipe gulp.dest $.ripped
    .pipe tap -> bar.tick 1, cur: ++count

# clean deployed files.
# --------------------------------
gulp.task "clean-deployed-#{$.suffix}", ->
  if shell.test '-e', $.deploy
    shell.rm '-rf', $.deploy
    
# deploy maschine-aware .wav files.
# --------------------------------
gulp.task "deploy-#{$.suffix}", ["clean-deployed-#{$.suffix}"], ->
  numFiles = util.countFiles $.ripped, '.wav'
  throw new Error 'ripped .wav files doesn\'t exist' unless numFiles
  count = 0;
  bar = progress
    total: numFiles
    tmpl: "Deploying files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src ["#{$.ripped}/**/*.wav"]
    .pipe id3 (file, chunks) ->
      # read apple loops metadata
      apple = util.readJson "#{(path.join $.ripped, file.relative)[..-5]}.json"
      name = path.basename file.path, '.wav'
      # add bpm + key to sample name
      info = []
      info.push apple.meta?.tempo
      info.push apple.meta?.keySignature
      info.push apple.meta?.keyType
      info = info.filter (i) -> i
      name += " [#{info.join ' '}]" if info.length
      # rename file
      file.path = path.join (path.dirname file.path), "#{name}.wav"
      # author
      author = apple.information?.artist
      author = 'Apple' unless author
      # bank
      bank = (file.relative.split path.sep)[0]
      # bank = (file.relative.split path.sep)[0].replace /^[0-9][0-9] (.*)$/, '$1'
      # category
      types = []
      types.push apple.meta.category if apple.meta?.category
      types.push apple.meta.subcategory if apple.meta?.subcategory
      types.push 'Unknown' unless types.length
      # return metadata
      name: name
      author: author
      vendor: 'Apple'
      comment: apple.information?.comments
      bankchain: ['Apple Loops', bank]
      types: [types]
      modes: apple.meta?.descriptors
    .pipe gulp.dest $.deploy
    .pipe tap -> bar.tick 1, cur: ++count
