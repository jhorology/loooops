_        = require 'underscore'
fs       = require 'fs'
path     = require 'path'
gulp     = require 'gulp'
beautify = require 'js-beautify'
shell    = require 'shelljs'
$        = require '../config'

module.exports =
  # json object or string to buffer
  json2buffer: (json, print) ->
    str = beautify (if _.isString json then json else (JSON.stringify json)), indent_size: $.json_indent
    console.info result if print
    Buffer.from str, 'utf-8'

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

  registerCommonGulpTasks: ($) ->
    # clean sample files.
    # --------------------------------
    gulp.task "clean-#{$.suffix}-samples", (done) ->
      if shell.test '-e', $.samples
        shell.rm '-rf', $.samples
      done()
    # clean image resources
    # --------------------------------
    gulp.task "clean-#{$.suffix}-image", (done) ->
      image = "#{$.NI.resources}/image/#{$.package.toLowerCase()}"
      if shell.test '-e', image
        shell.rm '-rf', image
      done()
    # clean dist_database resources
    # --------------------------------
    gulp.task "clean-#{$.suffix}-dist_database", (done) ->
      dist_database = "#{$.NI.resources}/dist_database/#{$.package.toLowerCase()}"
      if shell.test '-e', dist_database
        shell.rm '-rf', dist_database
      done()
      
    # clean resource files
    # --------------------------------
    gulp.task "clean-#{$.suffix}-resources",
      gulp.parallel \
        "clean-#{$.suffix}-image",
        "clean-#{$.suffix}-dist_database"
        
    # clean all
    # --------------------------------
    gulp.task "clean-#{$.suffix}",
      gulp.parallel \
        "clean-#{$.suffix}-resources",
        "clean-#{$.suffix}-samples"
  
      
    # deploy image resources
    #  notes:
    #    maschie doesn't recoginize vendor folder for sample.
    #    image files should be placed in following directories.
    #      images for NKSF             - <NI Content location>/NI Resources/image/<vendor>/<root of bankchain>
    #      images for maschine samples - <NI Content location>/NI Resources/image/<root of bankchain>
    # --------------------------------
    gulp.task "deploy-#{$.suffix}-image", ->
      gulp.src "resources/image/#{$.package.toLowerCase()}/**/*.{json,meta,png}"
        .pipe gulp.dest "#{$.NI.resources}/image/#{$.package.toLowerCase()}"
        .pipe gulp.dest "#{$.NI.resources}/image/#{$.vendor.toLowerCase()}/#{$.package.toLowerCase()}"
  
    # deploy dist_database resources
    #  notes:
    #    maschie doesn't recoginize vendor folder for sample.
    #    dist_database files should be placed in following directories.
    #      database resource files for NKSF             -
    #        <NI Content location>/NI Resources/dist_database/<vendor>/<root of bankchain>
    #      database resource files for maschine samples -
    #        <NI Content location>/NI Resources/dist_database/<root of bankchain>
    # --------------------------------
    gulp.task "deploy-#{$.suffix}-dist_database", ->
      gulp.src "resources/dist_database/#{$.package.toLowerCase()}/**/*.{json,meta,png}"
        .pipe gulp.dest "#{$.NI.resources}/dist_database/#{$.package.toLowerCase()}"
        .pipe gulp.dest "#{$.NI.resources}/dist_database/#{$.vendor.toLowerCase()}/#{$.package.toLowerCase()}"

    # deploy all resources
    # --------------------------------
    gulp.task "deploy-#{$.suffix}-resources",
      gulp.parallel \
        "deploy-#{$.suffix}-image",
        "deploy-#{$.suffix}-dist_database"

    # deploy all
    # --------------------------------
    gulp.task "deploy-#{$.suffix}",
      if $.nks
        gulp.series \
          "clean-#{$.suffix}-samples",
          "deploy-#{$.suffix}-samples"
      else
        gulp.series \
          "clean-#{$.suffix}",
          gulp.parallel \
            "deploy-#{$.suffix}-resources",
            "deploy-#{$.suffix}-samples"
      
