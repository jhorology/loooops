path     = require 'path'
gulp     = require 'gulp'
shell    = require 'shelljs'
progress = require 'smooth-progress'
run      = require 'run-sequence'
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
  suffix: path.basename __filename, '.coffee'

  vendor: 'Apple'
  package: 'Apple Loops'
  
  src: '/Library/Audio/Apple Loops/Apple'
  # *caution* need around 20G or more disk space.
  samples: '/Volumes/Macintosh HD/Music/Samples/Apple'

  # *caution* need around 20G or more disk space.
  ripped: '/Volumes/Macintosh HD/Temporary/Apple Loops/Apple'


# ======================================================
#  preparing tasks  
# ======================================================


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

# clean ripped files.
# --------------------------------
gulp.task "clean-ripped-#{$.suffix}", ->
  if shell.test '-e', $.ripped
    shell.rm '-rf', $.ripped

# ======================================================
#  common tasks  
# ======================================================

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

# deploy all
# --------------------------------
gulp.task "deploy-#{$.suffix}", (cb) ->
  run [
    "deploy-#{$.suffix}-image"
    "deploy-#{$.suffix}-dist_database"
  ]
  , "deploy-#{$.suffix}-samples"
  , cb

# deploy image resources
#  notes:
#    maschie doesn't recoginize vendor folder for sample.
#    image files should be placed in following directories.
#      images for NKSF             - <NI Content location>/NI Resources/image/<vendor>/<root of bankchain>
#      images for maschine samples - <NI Content location>/NI Resources/image/<root of bankchain>
# --------------------------------
gulp.task "deploy-#{$.suffix}-image", ["clean-#{$.suffix}-image"], ->
  gulp.src "resources/image/#{$.package.toLowerCase()}/**/*.{json,meta,png}"
    .pipe gulp.dest "#{$.NI.resources}/image/#{$.package.toLowerCase()}"

# deploy dist_database resources
#  notes:
#    maschie doesn't recoginize vendor folder for sample.
#    image files should be placed in following directories.
#      database resource files for NKSF             - <NI Content location>/NI Resources/dist_database/<vendor>/<root of bankchain>
#      database resource files for maschine samples - <NI Content location>/NI Resources/dist_database/<root of bankchain>
# --------------------------------
gulp.task "deploy-#{$.suffix}-dist_database", ["clean-#{$.suffix}-dist_database"], ->
  gulp.src "resources/dist_database/#{$.package.toLowerCase()}/**/*.{json,meta,png}"
    .pipe gulp.dest "#{$.NI.resources}/dist_database/#{$.package.toLowerCase()}"

# deploy all
# --------------------------------
gulp.task "deploy-#{$.suffix}-resources", (cb) ->
  run [
    "deploy-#{$.suffix}-image"
    "deploy-#{$.suffix}-dist_database"
  ], cb

# clean sample files.
# --------------------------------
gulp.task "clean-#{$.suffix}-samples", ->
  if shell.test '-e', $.samples
    shell.rm '-rf', $.samples

# clean image resources
# --------------------------------
gulp.task "clean-#{$.suffix}-image", ->
  image = "#{$.NI.resources}/image/#{$.package.toLowerCase()}"
  if shell.test '-e', image
    shell.rm '-rf', image

# clean dist_database resources
# --------------------------------
gulp.task "clean-#{$.suffix}-dist_database", ->
  dist_database = "#{$.NI.resources}/dist_database/#{$.package.toLowerCase()}"
  if shell.test '-e', dist_database
    shell.rm '-rf', dist_database

# clean all
# --------------------------------
gulp.task "clean-#{$.suffix}", (cb) ->
  run [
    "clean-#{$.suffix}-samples"
    "clean-#{$.suffix}-image"
    "clean-#{$.suffix}-dist_database"
  ], cb
  
# clean resource files
# --------------------------------
gulp.task "clean-#{$.suffix}-resources", (cb) ->
  run [
    "clean-#{$.suffix}-image"
    "clean-#{$.suffix}-dist_database"
  ], cb
