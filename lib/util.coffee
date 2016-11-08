_        = require 'underscore'
fs       = require 'fs'
path     = require 'path'
beautify = require 'js-beautify'
shell    = require 'shelljs'
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
    parseInt (shell.exec cmd, silent: off).stdout
