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
    ###
      notes:
        image files should be placed in following directories.
          maschine before v2.8.0
            <NI Content location>/NI Resources/image/<root of bankchain>
          Komplete Kontrol v2.1.0 or later, Maschine v2.8.0 or later
            <NI Content location>/NI Resources/image/<vendor>/<root of bankchain>
              
        dist_database files should be placed in following directories.
          maschine before v2.8.0
            <NI Content location>/NI Resources/dist_database/<root of bankchain>
          Komplete Kontrol v2.1.0 or later, Maschine v2.8.0 or later
            <NI Content location>/NI Resources/dist_database/<vendor>/<root of bankchain>
    ###
    image = "#{$.NI.resources}/image/#{$.vendor.toLowerCase()}/#{$.package.toLowerCase()}"
    dist_database = "#{$.NI.resources}/dist_database/#{$.package.toLowerCase()}"
    
    # clean sample files.
    # --------------------------------
    gulp.task "clean-#{$.task}-samples", (done) ->
      if shell.test '-e', $.samples
        shell.rm '-rf', $.samples
      done()

    # clean image resources
    # --------------------------------
    gulp.task "clean-#{$.task}-image", (done) ->
      if shell.test '-e', image
        shell.rm '-rf', image
      done()

    # clean dist_database resources
    # --------------------------------
    gulp.task "clean-#{$.task}-dist_database", (done) ->
      if shell.test '-e', dist_database
        shell.rm '-rf', dist_database
      done()
      
    # clean resource files
    # --------------------------------
    gulp.task "clean-#{$.task}-resources",
      gulp.parallel \
        "clean-#{$.task}-image",
        "clean-#{$.task}-dist_database"
        
    # clean all
    # --------------------------------
    gulp.task "clean-#{$.task}",
      gulp.parallel \
        "clean-#{$.task}-resources",
        "clean-#{$.task}-samples"
  
      
    # deploy image resources
    # --------------------------------
    gulp.task "deploy-#{$.task}-image", ->
      gulp.src "resources/image/#{$.package.toLowerCase()}/**/*.{json,meta,png}"
        .pipe gulp.dest image
  
    # deploy dist_database resources
    # --------------------------------
    gulp.task "deploy-#{$.task}-dist_database", ->
      gulp.src "resources/dist_database/#{$.package.toLowerCase()}/**/*.{json,meta,png}"
        .pipe gulp.dest dist_database

    # deploy all resources
    # --------------------------------
    gulp.task "deploy-#{$.task}-resources",
      gulp.parallel \
        "deploy-#{$.task}-image",
        "deploy-#{$.task}-dist_database"

    # deploy all
    # --------------------------------
    gulp.task "deploy-#{$.task}",
      if $.noResources
        gulp.series \
          "clean-#{$.task}-samples",
          "deploy-#{$.task}-samples"
      else
        gulp.series \
          "clean-#{$.task}",
          gulp.parallel \
            "deploy-#{$.task}-resources",
            "deploy-#{$.task}-samples"
      
