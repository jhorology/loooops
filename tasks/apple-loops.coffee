path     = require 'path'
gulp     = require 'gulp'
progress = require 'smooth-progress'
exec     = require 'gulp-exec'
tap      = require 'gulp-tap'
rename   = require 'gulp-rename'
meta     = require 'apple-loops-meta-reader'
id3      = require 'gulp-maschine-id3'
util     = require '../lib/util'
 
# ======================================================
#  paths, misc settings
# ======================================================
$ = Object.assign {}, (require '../config'),

  # required common settings
  # -----------------------------------------

  suffix: path.basename __filename, '.coffee'
  vendor: 'Apple'
  package: 'Apple Loops'
  
  src: '/Library/Audio/Apple Loops/Apple'
  # *caution* need around 20G or more disk space.
  samples: '/Volumes/Macintosh HD/Music/Samples/Apple'

  # local settings
  # -----------------------------------------

  # *caution* need around 20G or more disk space.
  ripped: '/Volumes/Macintosh HD/Temporary/Apple Loops/Apple'

# ======================================================
#  preparing tasks  
# ======================================================

# convert .caf -> .wav + .json(metadata)
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

# clean ripped files.
# --------------------------------
gulp.task "clean-ripped-#{$.suffix}", ->
  if shell.test '-e', $.ripped
    shell.rm '-rf', $.ripped

# ======================================================
#  common tasks  
# ======================================================
util.registCommonGulpTasks $

# deploy maschine-aware .wav files.
# --------------------------------
gulp.task "deploy-#{$.suffix}-samples", ["clean-#{$.suffix}-samples"], ->
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
      # author
      author = apple.information?.artist or $.vendor
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
      vendor: $.vendor
      comment: apple.information?.comments
      bankchain: [$.package, bank]
      types: [types]
      modes: apple.meta?.descriptors
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count

