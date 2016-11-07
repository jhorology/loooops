_        = require 'underscore'
fs       = require 'fs'
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
    parseInt ((shell.exec "find '#{dir}' -name '*#{ext}' | wc -l", silent: on).stdout);
