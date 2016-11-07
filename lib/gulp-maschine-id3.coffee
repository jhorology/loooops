# Gulp plugin for adding maschine metadata to wav file
#
# - API
#  - id3(data)
#   - data
#     object or function to provide metadata
#   - data.name        String
#   - data.vendor      String
#   - data.author      String
#   - data.bankchain   Array of String
#   - data.types       2 dimensional Array of String
#   - data.modes       Array of String (currently unsupported)
#   - function(file, chunks[,callback])
#     function to provide metadata
#     - file instance of vinyl file
#     - chunks Array of object
#        RIFF chunks of source file
#        element properties
#          - id    String chunk id
#          - data  Buffer contents of chunk
#     - callback function(err, metadata)
#       callback function to support non-blocking call.
# 
# - Usage 
#     id3 = require './lib/gulp-maschine-id3'
#     gulp.task 'hoge', ->
#       gulp.src ["src/**/*.wav"]
#         .pipe id3 (file, chunks) ->
#           name: "Hogehoge"
#           vendor: "Hahaha"
#           author: "Hehehe"
#           bankchain: ['Fugafuga', 'Fuga 1.1 Library']
#           types: [
#             ['Bass', 'Synth Bass']
#           ]
#           modes: ['weird', 'dirty', 'insane', 'ugly']
#         .pipe gulp.dest "dist"
#
# 
assert       = require 'assert'
through      = require 'through2'
gutil        = require 'gulp-util'
_            = require 'underscore'
reader       = require 'riff-reader'
riffBuilder  = require './riff-builder'
riffReader   = require 'riff-reader'

PLUGIN_NAME  = 'maschine-id3'
# remove unnecessary chunk
REMOVE_UNNECESSARY_CHUNKS = on

module.exports = (data) ->
  through.obj (file, enc, cb) ->
    alreadyCalled = off
    id3 = (err, metadata) =>
      if alreadyCalled
        @emit 'error', new gutil.PluginError PLUGIN_NAME, 'duplicate callback calls.'
        return
      alreadyCalled = on
      if err
        @emit 'error', new gutil.PluginError PLUGIN_NAME, err
        return cb()
      try
        if metadata
          _id3 file, metadata
        @push file
      catch error
        @emit 'error', new gutil.PluginError PLUGIN_NAME, error
      cb()

    unless file
      id3 'Files can not be empty'
      return

    if file.isStream()
      id3 'Streaming not supported'
      return

    if _.isFunction data
      try
        chunks = _parseSourceWavChunks file
        metadata = data.call @, file, chunks, id3
      catch error
        id3 error
      if data.length <= 2
        id3 undefined, metadata
    else
      try
        _parseSourceWavChunks file
      catch error
        return error
      id3 undefined, data

_parseSourceWavChunks = (file) ->
  chunks = []
  src = if file.isBuffer() then file.contents else file.path
  json = undefined
  reader(src, 'WAVE').readSync (id, data) ->
    chunks.push
      id: id
      data: data
  ids = chunks.map (chunk) -> chunk.id
  assert.ok ('fmt ' in ids), "[fmt ] chunk is not contained in file."
  assert.ok ('data' in ids), "[data] chunk is not contained in file."
  file.chunks = chunks

_id3 = (file, metadata) ->
  chunks = if REMOVE_UNNECESSARY_CHUNKS
    file.chunks.filter (c) -> c.id in ['fmt ', 'data']
  else
    # remove 'ID3 ' chunk if already exits.
    file.chunks.filter (c) -> c.id isnt 'ID3 '
  # build wav file
  wav = riffBuilder 'WAVE'
  wav.pushChunk chunk.id, chunk.data for chunk in chunks
  wav.pushChunk 'ID3 ', _build_id3_chunk metadata
  file.contents =  wav.buffer()

# build ID3 chunk contents
_build_id3_chunk = (metadata) ->
  geobFrame = _build_geob_frame metadata
  header = new BufferBuilder()
    .push 'ID3'            # magic
    .push [0x04,0x00]      # id3 version 2.4.0
    .push 0x00             # flags
    .pushSyncsafeInt geobFrame.length + 1024  # size

  Buffer.concat [
    header.buf             # ID3v2 header 10 byte
    geobFrame              # GEOB frame
    Buffer.alloc 1024, 0   # end-mark 4 byte  + reserve area
  ]

# build ID3 GEOB frame
_build_geob_frame = (metadata) ->
  contents = new BufferBuilder()
    # unknown, It seems all expansions sample are same.
    .pushHex '000000'
    .push 'com.native-instruments.nisound.soundinfo\u0000'
    # unknown, It seems all expansions sample are same.
    .pushHex '020000000100000000000000'
    # sample name
    .pushUcs2String metadata.name
    # vendor name
    .pushUcs2String metadata.vendor
    # author name
    .pushUcs2String metadata.author
    # unknown, It seems all expansions sample are same.
    .pushHex '0000000000000000ffffffffffffffff000000000000000000000000000000000000000001000000'
    # bankchain
    .pushUcs2StringArray metadata.bankchain
    # types (category)
    .pushUcs2StringArray _types metadata.types
    # maybe modes ?
    # .pushUcs2StringArray metadata.modes
    .pushHex '00000000'
    # properties, It seems all expansions sample are same.
    .pushKeyValuePairs [
       ['color',           '0']
       ['devicetypeflags', '0']
       ['soundtype',       '0']
       ['tempo',           '0']
       ['verl',            '1.7.13']
       ['verm',            '1.7.13']
       ['visib',           '0']
    ]
   # header
  header = new BufferBuilder()
    .push 'GEOB'                          # frame Id
    .pushSyncsafeInt contents.buf.length  # data size
    .push [0x00, 0x00]                    # flags

  Buffer.concat [header.buf, contents.buf]


_types = (types) ->
  list = []
  for t in types
    if t and t.length and t[0]
      list.push "\\:#{t[0]}"
  for t in types
    if t and t.length > 1 and t[0] and t[1]
      list.push "\\:#{t[0]}\\:#{t[1]}"
  _.uniq list

class BufferBuilder
  constructor: ->
    @buf = new Buffer 0
  #
  # @value byte or byte array or string
  push: (value) ->
    switch
      when _.isNumber value
        # byte
        @buf = Buffer.concat [@buf, new Buffer [value]]
      else
        # string or byte array
        @buf = Buffer.concat [@buf, new Buffer value]
    @

  pushUInt32LE: (value) ->
    b = new Buffer 4
    b.writeUInt32LE value
    @buf = Buffer.concat [@buf, b]
    @

  # 7bit * 4 = 28 bit
  pushSyncsafeInt: (size) ->
    b = []
    b.push ((size >> 21) & 0x0000007f)
    b.push ((size >> 14) & 0x0000007f)
    b.push ((size >>  7) & 0x0000007f)
    b.push (size & 0x0000007f)
    @push b
    @

  pushHex: (value) ->
    @buf = Buffer.concat [@buf, (new Buffer value, 'hex') ]
    @

  pushUcs2String: (value) ->
    l = if value and value.length then value.length else 0
    @pushUInt32LE l
    @buf = Buffer.concat [@buf, (new Buffer value, 'ucs2')] if l
    @

  pushUcs2StringArray: (value) ->
    if (_.isArray value) and value.length
      @pushUInt32LE value.length
      @pushUcs2String v for v in value
    else
      @pushUInt32LE 0
    @

  pushKeyValuePairs: (value) ->
    if (_.isArray value) and value.length
      @pushUInt32LE value.length
      for pair in value
        @pushUcs2String "\\@#{pair[0]}"
        @pushUcs2String pair[1]
    else
      @pushUInt32LE 0
    @
