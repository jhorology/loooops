fs         = require 'fs'
path       = require 'path'
gulp       = require 'gulp'
_          = require 'underscore'
coffeelint = require 'gulp-coffeelint'
exec       = require 'gulp-exec'
rename     = require 'gulp-rename'
tap        = require 'gulp-tap'
del        = require 'del'
beautify    = require 'js-beautify'

$ =
  json_indent: 2
  # gulp-exec options
  execOpts:
    continueOnError: false # default = false, true means don't emit error event
    pipeStdout: false      # default = false, true means stdout is written to file.contents
  execReportOpts:
    err: true              # default = true, false means don't write err
    stderr: true           # default = true, false means don't write stderr
    stdout: true           # default = true, false means don't write stdout

  appleLoops:
    dir: '/Library/Audio/Apple Loops/Apple'
    # *caution* neeed around 20G or more disk space.
    ripped: '/Volumes/Macintosh HD/Temporary/Apple Loops/Apple'
    # *caution* neeed around 20G or more disk space.
    deploy: '/Volumes/Macintosh HD/Music/Samples/Apple'

# coffeelint
# --------------------------------
gulp.task 'coffeelint', ->
  gulp.src [
    '*.coffee'
    'lib/*.coffee'
  ]
    .pipe coffeelint 'coffeelint.json'
    .pipe coffeelint.reporter()

# watch
# --------------------------------
gulp.task 'watch', ->
  gulp.watch [
    './*.coffee'
    './lib/*.coffee'
  ]
  , ['coffeelint']

# clean
# --------------------------------
gulp.task 'clean', ->
  del [
    './**/*~'
    './**/*.log'
    './**/.DS_Store'
  ]

# clean-all
# --------------------------------
gulp.task 'clean-all', ['clean'], ->
  del [
    'dist'
    'temp'
    'node_modules'
  ]

gulp.task 'rip-apple-loops', ->
  meta = require 'apple-loops-meta-reader'
  gulp.src ["#{$.appleLoops.dir}/**/*.caf"]
    .pipe tap (file) ->
      file.distPath = (path.join $.appleLoops.ripped, file.relative)[..-5] + '.wav'
      file.distDir = path.dirname file.distPath
    .pipe exec [
      'mkdir -p "<%= file.distDir %>"'
      'afconvert -f WAVE -d LEI16 "<%= file.path %>" "<%= file.distPath %>"'
      ].join ' && '
    , $.execOopts
    .pipe exec.reporter $.execReportOpts
    .pipe tap (file) ->
      file.contents = _json2buffer meta.read(file.path),
    .pipe rename extname: '.json'
    .pipe gulp.dest $.appleLoops.ripped

gulp.task 'deploy-apple-loops', ->
  id3  = require './lib/gulp-maschine-id3'
  gulp.src ["#{$.appleLoops.ripped}/**/*.wav"]
    .pipe id3 (file, chunks) ->
      # read apple loops metadata
      apple = _readJson "#{(path.join $.appleLoops.ripped, file.relative)[..-5]}.json"
      name = path.basename file.path, '.wav'
      # add bpm + key to sample name
      info =[]
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
      vendor: 'Apple'
      author: author
      bankchain: ['Apple Loops', bank]
      types: [types]
      modes: apple.meta?.descriptors
    .pipe gulp.dest $.appleLoops.deploy

# json object or string to buffer
_json2buffer = (json, print) ->
  str = beautify (if _.isString json then json else (JSON.stringify json)), indent_size: $.json_indent
  console.info result if print
  new Buffer str

# read json file
_readJson = (file) ->
  buf = file
  if _.isString file
    buf = fs.readFileSync file
  JSON.parse buf.toString()
