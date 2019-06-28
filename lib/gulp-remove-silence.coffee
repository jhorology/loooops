###
  remove silence from end
###

data = require 'gulp-data'
{ spawn } = require 'child_process'

defaultOpts =
 threshold: '-90dB'

module.exports = (opts) ->
  data (file, done) ->
    try
      file.contents = await _sox file.path, Object.assign defaultOpts, opts
      done()
    catch err
      done err
    
_sox = (file, opts) ->
  args = [
    file, '-t', 'wav', '-',
    'reverse'
    'silence', '-l', '1', '0', opts.threshold
    'reverse'
  ]
  new Promise (resolve, reject) ->
    buffer = Buffer.alloc(0)
    error = Buffer.alloc(0)
    sox = undefined
    try
      sox = spawn 'sox', args, stdio: 'pipe'
      sox.stdout.on 'data', (data) ->
        buffer = Buffer.concat [buffer, data]
      sox.stderr.on 'data', (data) ->
        error = Buffer.concat [error, data]
      sox.on 'close', (code) ->
        if code is 0
          resolve buffer
        else
          reject new Error "Sox Execution Error code:#{code} stderr:#{error.toString()}"
    catch err
      reject err
