_        = require 'underscore'
fs       = require 'fs'
path     = require 'path'
gulp     = require 'gulp'
beautify = require 'js-beautify'
shell    = require 'shelljs'
run      = require 'run-sequence'
$        = require '../config'

module.exports =
  # json object or string to buffer
  json2buffer: (json, print) ->
    str = beautify (if _.isString json then json else (JSON.stringify json)), indent_size: $.json_indent
    console.info result if print
    new Buffer str

  # read json file
  readJson: (file) ->
    buf = file
    if _.isString file
      buf = fs.readFileSync file
    JSON.parse buf.toString()

  countFiles: (dir, ext) ->
    extArchive = path.extname dir
    cmd = switch extArchive.toLowerCase()
      when '.zip'
        "unzip -l '#{dir}' | grep '#{ext}' | wc -l"
      else
        "find '#{dir}' -name '*#{ext}' | wc -l"
    parseInt (shell.exec cmd, silent: on).stdout

  registCommonGulpTasks: ($) ->
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
    #    dist_database files should be placed in following directories.
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
