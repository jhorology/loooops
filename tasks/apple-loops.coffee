# Logic X Apple loops
#
# notes:
#   - 2019/12/26  v10.4.8 23671 .caf files 
#                          6489 MIDI files
#-------------------------------------------------- 
path     = require 'path'
gulp     = require 'gulp'
progress = require 'smooth-progress'
exec     = require 'gulp-exec'
tap      = require 'gulp-tap'
rename   = require 'gulp-rename'
meta     = require 'apple-loops-meta-reader'
shell    = require 'shelljs'
_        = require 'underscore'
id3      = require 'gulp-maschine-id3'
util     = require '../lib/util'
 
# ======================================================
#  paths, misc settings
# ======================================================
$ = Object.assign {}, (require '../config'),

  # required common settings
  # -----------------------------------------

  task: path.basename __filename, '.coffee'
  vendor: 'Apple'
  package: 'Apple Loops'
  
  src: '/Library/Audio/Apple Loops/Apple'
  # *caution* need around 20G or more disk space.
  samples: '/Volumes/Media/Music/Samples/Apple'

  # local settings
  # -----------------------------------------

  # *caution* need around 20G or more disk space.
  ripped: '/Volumes/Media/Temporary/Apple Loops/Apple'
  #  use Caf Midi Extractor - Utility Program
  #  https://www.logicprohelp.com/forum/viewtopic.php?t=139415
  midiFiles: '/Volumes/Media/Temporary/Apple Loops/Caf Midi Extractor Files'

  # completion metadata
  completionData:
    '01 Hip Hop': [
      {pattern: /^Future Flight/, category: 'Sound Effect', subCategory: 'Sci-Fi'}
      {pattern: /^Gated Synth/,   category: 'Sound Effect', subCategory: 'Sci-Fi'}
      {pattern: /^Spacey Synth/,  category: 'Sound Effect', subCategory: 'Sci-Fi'}
      {pattern: /^Chasing Shadows Clap.Snare 01/,  category: 'Drums', subCategory: 'Claps'}
      {pattern: /^Chasing Shadows Clap.Snare 02/,  category: 'Drums', subCategory: 'Snare'}
      {pattern: /^Chasing Shadows Guitar Lead 03/, category: 'Guitars', subCategory: 'Electric Guitar'}
      {pattern: /^Recollection Bell Pads/,  category: 'Mallets', subCategory: 'Bell'}
      {pattern: /^Roll Deep Clap/,  category: 'Drums', subCategory: 'Snare'}
    ]
    '02 Electro House': [
      {pattern: /^Electro Riser/,       category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Falling Star Effect/, category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Laser Noise Effect/,  category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Warp Speed Effect/,   category: 'Sound Effect', subCategory: 'Motions & Transitions'}
    ]
    '03 Dubstep': [
      {pattern: /^Data Transfer Effect/, category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Diving Synth Effects/, category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Noise Riser Effect/,   category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Noise Sweeper/,        category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Riser Synth Effect/,   category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Rising Synth Effects/, category: 'Sound Effect', subCategory: 'Motions & Transitions'}
    ]
    '04 Modern RnB': [
      {pattern: /^All Systems Go Riser/,  category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Designer Fall Effect/,  category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Designer Riser Effect/, category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Hover Car Riser/,       category: 'Sound Effect', subCategory: 'Motions & Transitions'}
      {pattern: /^Paparazzi FX Synth/,    category: 'Sound Effect', subCategory: 'Motions & Transitions'}
    ]
    '07 Chillwave': [
      {pattern: /^Eight Bit Funk Layers/, category: 'Mixed'}
    ]
    '14 Future Bass': [
      {pattern: /^Colossus Riser 02/,     category: 'Texture/Atmosphere'}
      {pattern: /^Free Fall Snaps 02/,    category: 'Percussion', subCategory: 'Shaker'}
    ]
    '18 Toy Box': [
      {pattern: /^Planetarium FX/,        category: 'Sound Effect', subCategory: 'Sci-Fi'}
    ]
    'Jam Pack 1': [
      {pattern: /^Abstract Atmosphere/,   category: 'Texture/Atmosphere'}
      {pattern: /^Analog Drum Machine/,   category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Ancient Didjeridoo/,    category: 'Other Instrument'}
      {pattern: /^Asian Gamelan/,         category: 'Mallets'}
      {pattern: /^Car Start Loop/,        category: 'Sound Effect'}
      {pattern: /^Cash Register Sounds/,  category: 'Sound Effect'}
      {pattern: /^Club Dance Beat/,       category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Cop Show Clav/,         category: 'Keyboards', subCategory: 'Clavinet'}
      {pattern: /^Effected Drum Kit/,     category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Exotic Beat/,           category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Funky Electric Piano/,  category: 'Keyboards', subCategory: 'Electric Piano'}
      {pattern: /^Glass Breaking Loop/,   category: 'Sound Effect'}
      {pattern: /^Hip Hop Beat/,          category: 'Drums', subCategory: 'Drum Kit'}
      {pattern: /^Jazz Piano Bar/,        category: 'Keyboards', subCategory: 'Piano'}
      {pattern: /^Lounge Vibes/,          category: 'Mallets', subCategory: 'Vibraphone'}
      {pattern: /^Motown Drummer/,        category: 'Drums', subCategory: 'Drum Kit'}
      {pattern: /^Nordic Keyed Fiddle/,   category: 'Strings'}
      {pattern: /^Orchestra Brass/,       category: 'Horn/Wind'}
      {pattern: /^Orchestral Woodwinds/,  category: 'Horn/Wind'}
      {pattern: /^Phone Sound Effect/,    category: 'Sound Effect'}
      {pattern: /^Plucked Balalaika/,     category: 'Strings'}
      {pattern: /^Round Funk Bass/,       category: 'Bass', subCategory: 'Electric Bass'}
      {pattern: /^Swirling Pad/,          category: 'Keyboards', subCategory: 'Synthesizer'}
      {pattern: /^Thick House Bass/,      category: 'Bass', subCategory: 'Electric Bass'}
    ]
    'Jam Pack Remix Tools': [
      {pattern: /^Breaks Biggie Beat/,    category: 'Drums', subCategory: 'Drum Kit'}
      {pattern: /^Breaks DJ Dream Beat/,  category: 'Drums', subCategory: 'Drum Kit'}
      {pattern: /^Breaks Fat Hammer/,     category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Breaks Knocking Beat/,  category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Breaks Pushed Beat/,    category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Breaks Stick Cow Beat/, category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^DnB \w+ Beat/,          category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Downtempo .* Beat/,     category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Electro Breather Beat/, category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Electro Frenzy/,        category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Electro .* Beat/,       category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Euro .* Beat/,          category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Euro .* Pad /,          category: 'Keyboards', subCategory: 'Synthesizer'}
      {pattern: /^Euro Snare Roll/,       category: 'Drums', subCategory: 'Snare'}
      {pattern: /^Garage .* Beat/,        category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Garage .* Fill/,        category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Hip Hop .* Beat/,       category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^House .* Beat/,         category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Jazz Hustle Bass/,      category: 'Bass', subCategory: 'Electric Bass'}
      {pattern: /^Jazz Hustle Flute/,     category: 'Horn/Wind', subCategory: 'Flute'}
      {pattern: /^Jazz Hustle Guitar/,    category: 'Guitars', subCategory: 'Electric Guitar'}
      {pattern: /^Jazz Hustle Sax/,       category: 'Horn/Wind', subCategory: 'Saxophone'}
      {pattern: /^NuJazz .* Beat/,        category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^NuJazz Jam Bass 01/,    category: 'Bass', subCategory: 'Acoustic Beats'}
      {pattern: /^NuJazz Jam Bass/,       category: 'Bass', subCategory: 'Electric Beats'}
      {pattern: /^NuJazz Jam Flute/,      category: 'Horn/Wind', subCategory: 'Flute'}
      {pattern: /^NuJazz Jam Guitar/,     category: 'Guitars', subCategory: 'Electric Guitar'}
      {pattern: /^NuJazz Jam Organ/,      category: 'Keyboards', subCategory: 'Organ'}
      {pattern: /^NuJazz Jam Piano/,      category: 'Keyboards', subCategory: 'Electric Piano'}
      {pattern: /^NuJazz Jam Sax/,        category: 'Horn/Wind', subCategory: 'Saxophone'}
      {pattern: /^NuJazz Jam Strings/,    category: 'Strings'}
      {pattern: /^NuJazz Ladybug Bass 01/, category: 'Bass', subCategory: 'Acoustic Beats'}
      {pattern: /^NuJazz Ladybug Bass 02/, category: 'Bass', subCategory: 'Acoustic Beats'}
      {pattern: /^NuJazz Ladybug Bass/,   category: 'Bass', subCategory: 'Electric Bass'}
      {pattern: /^NuJazz Ladybug Flute/,  category: 'Horn/Wind', subCategory: 'Flute'}
      {pattern: /^NuJazz Ladybug Guitar 01/, category: 'Guitars', subCategory: 'Acoustic Guitar'}
      {pattern: /^NuJazz Ladybug Guitar/,   category: 'Guitars', subCategory: 'Electric Guitar'}
      {pattern: /^NuJazz Ladybug Horn/,   category: 'Horn/Wind'}
      {pattern: /^NuJazz Ladybug Piano 04/, category: 'Keyboards', subCategory: 'Piano'}
      {pattern: /^NuJazz Ladybug Piano/,  category: 'Keyboards', subCategory: 'Electric Piano'}
      {pattern: /^Pop .* Beat/,           category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Remix Conga/,           category: 'Percussion', subCategory: 'Conga'}
      {pattern: /^Remix Cowbell/,         category: 'Percussion', subCategory: 'Cowbell'}
      {pattern: /^Remix Dirty Drum FX/,   category: 'Sound Effect'}
      {pattern: /^Techno .* Beat/,        category: 'Drums', subCategory: 'Electronic Beats'}
      {pattern: /^Trance Cluster Synth/,   category: 'Keyboards', subCategory: 'Synthesizer'}
      {pattern: /^Trance Space Bass/,     category: 'Bass', subCategory: 'Synthetic Bass'}
      {pattern: /^Trance Travel Synth/,   category: 'Keyboards', subCategory: 'Synthesizer'}
      {pattern: /^Trip Hop .* Beat/,      category: 'Drums', subCategory: 'Electronic Beats'}
    ]
    'Jam Pack Rhythm Section': [
      {pattern: /^Backroads Banjo/,       category: 'Guitars', subCategory: 'Banjo'}
      {pattern: /^Backroads Electric/,    category: 'Guitars', subCategory: 'Electric'}
      {pattern: /^Cheerful Mandolin/,     category: 'Guitars', subCategory: 'Mandolin'}
      {pattern: /^Country Perfect Bass/,  category: 'Bass', subCategory: 'Electric Bass'}
      {pattern: /^Down Home Dobro/,       category: 'Guitars', subCategory: 'Slide Guitar'}
      {pattern: /^Folk Pop Acoustic/,     category: 'Guitars', subCategory: 'Acoustic Guitar'}
      {pattern: /^Front Porch Dobro/,     category: 'Guitars', subCategory: 'Acoustic Guitar'}
      {pattern: /^Hardest Working Bass/,  category: 'Bass', subCategory: 'Electric Bass'}
      {pattern: /^Jaws Harp Jingo Jango/, category: 'Strings', subCategory: 'Jews Harp'}
      {pattern: /^Lo Fi Country Drum/,    category: 'Drums', subCategory: 'Drum Kit'}
      {pattern: /^Nashville Pedal Steel/, category: 'Guitars', subCategory: 'Pedal Steel Guitar'}
      {pattern: /^Rural Acoustic Strum/,  category: 'Guitars', subCategory: 'Acoustic Guitar'}
      {pattern: /^Southern Basic Drumset/, category: 'Drums', subCategory: 'Drum Kit'}
      {pattern: /^Southern Fiddle/,       category: 'Strings'}
    ]
    'Jam Pack Symphony Orchestra': [
      {pattern: /^Autumn All/,       category: 'Strings'}
      {pattern: /^Avenger All/,      category: 'Strings'}
      {pattern: /^Clearing All/,     category: 'Mixed'}
      {pattern: /^Clearing Marcato/,category: 'Strings'}
      {pattern: /^Clearing No Percussion/, category: 'Mixed'}
      {pattern: /^Clearing Tremolo/, category: 'Strings'}
      {pattern: /^Cunning All/,      category: 'Strings'}
      {pattern: /^Dogma All/,        category: 'Mixed'}
      {pattern: /^Farewell Staccato/, category: 'Strings'}
      {pattern: /^Gravity All/,      category: 'Mixed'}
      {pattern: /^Hideout All/,      category: 'Horn/Wind'}
      {pattern: /^Longitude All/,    category: 'Horn/Wind'}
      {pattern: /^Memorial All/,     category: 'Horn/Wind'}
      {pattern: /^Officer All 01/,   category: 'Horn/Wind'}
      {pattern: /^Officer All 02/,   category: 'Mixed'}
      {pattern: /^Pugilist All/,     category: 'Strings'}
      {pattern: /^Reunion All/,      category: 'Strings'}
      {pattern: /^Tribute All/,      category: 'Strings'}
      {pattern: / Cello /,           category: 'Strings', subCategory: 'Cello'}
      {pattern: / Cellos /,          category: 'Strings', subCategory: 'Cello'}
      {pattern: / Viola /,           category: 'Strings', subCategory: 'Viola'}
      {pattern: / Violas /,          category: 'Strings', subCategory: 'Viola'}
      {pattern: / Violin /,          category: 'Strings', subCategory: 'Violin'}
      {pattern: / Brass /,           category: 'Horn/Wind'}
      {pattern: / Flute /,           category: 'Horn/Wind', subCategory: 'Flute'}
      {pattern: / Harp /,            category: 'Strings', subCategory: 'Harp'}
      {pattern: / String /,          category: 'Strings'}
      {pattern: / Strings /,         category: 'Strings'}
      {pattern: / Strings$/,         category: 'Strings'}
      {pattern: / Percussion /,      category: 'Percussion'}
      {pattern: / Timpani /,         category: 'Percussion'}
      {pattern: / Woodwinds /,       category: 'Horn/Wind'}
      {pattern: / Basses /,          category: 'Strings', subCategory:'Double Basse'}
      {pattern: / Clarinet /,        category: 'Horn/Wind', subCategory: 'Clarinet'}
      {pattern: / Pizzicato /,       category: 'Strings'}
    ]
    'Jam Pack Voices': [
      {pattern: /^Ruth Background/, category: 'Vocals', subCategory: 'Female'}
    ]
    'Jam Pack World Music': [
      {pattern: /^African Zebra Log Drum/, category: 'Percussion'}
      {pattern: /^Persian Market Tar/,     category: 'Percussion'}
    ]


# ======================================================
#  common tasks  
# ======================================================
util.registerCommonGulpTasks $

# ======================================================
#  preparing tasks  
# ======================================================

# clean ripped files.
# --------------------------------
gulp.task "clean-ripped-#{$.task}", (done) ->
  if shell.test '-e', $.ripped
    shell.rm '-rf', $.ripped
  done()
   
# convert .caf -> .wav + .json(metadata)
# --------------------------------
gulp.task "rip-#{$.task}", ->
  numFiles = util.countFiles $.src, '.caf'
  throw new Error '.caf files doesn\'t exist' unless numFiles
  count = 0;
  bar = progress
    total: numFiles
    tmpl: " Converting files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src ["#{$.src}/**/*.caf"]
    .pipe tap (file) ->
      file.distPath = (path.join $.ripped, file.relative)[..-5] + '.wav'
      file.distDir = path.dirname file.distPath
    .pipe exec [
      'mkdir -p "<%= file.distDir %>"'
      'afconvert -f WAVE -d LEI16 "<%= file.path %>" "<%= file.distPath %>"'
      ].join ' && '
    , $.execOpts
    .pipe exec.reporter $.execReportOpts
    .pipe tap (file) ->
      file.contents = util.json2buffer meta.read(file.path),
    .pipe rename extname: '.json'
    .pipe gulp.dest $.ripped
    .pipe tap -> bar.tick 1, cur: ++count

# deploy maschine-aware .wav files.
# --------------------------------
gulp.task "deploy-#{$.task}-samples", ->
  numFiles = util.countFiles $.ripped, '.wav'
  throw new Error 'ripped .wav files doesn\'t exist' unless numFiles
  count = 0;
  bar = progress
    total: numFiles
    tmpl: " Deploying files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src ["#{$.ripped}/**/*.wav"]
    .pipe id3 (file, chunks) ->
      # read apple loops metadata
      apple = util.readJson "#{(path.join $.ripped, file.relative)[..-5]}.json"
      name = fileName = path.basename file.path, '.wav'
      # add bpm + key to sample name
      name += " [#{apple.meta?.tempo}]" if apple.meta?.tempo
      name += " #{apple.meta?.keySignature}" if apple.meta?.keySignature
      name += "m" if apple.meta?.keyType is 'minor'
      # author
      author = apple.information?.artist or $.vendor
      # bank
      bank = (file.relative.split path.sep)[0]
      # bank = (file.relative.split path.sep)[0].replace /^[0-9][0-9] (.*)$/, '$1'
      # category
      types = []
      types.push apple.meta.category if apple.meta?.category
      types.push apple.meta.subcategory if apple.meta?.subcategory
      unless types.length
        defs = $.completionData[bank]
        def = _.find defs, (def)-> def.pattern.test fileName if defs
        if (def)
          types.push def.category if def.category
          types.push def.subCategory if def.subCategory
          # console.warn "#completed bank:#{bank} file:#{fileName} type:#{types}"
        else
          console.warn "#unknown bank:#{bank} file:#{fileName}"
          types.push 'Unknown'
      # categolized by folder
      dirname = path.dirname file.path
      basename = path.basename file.path
      if types.length is 2
        file.path = path.join dirname, types[0], types[1], basename
      else if types.length is 1
        file.path = path.join dirname, types[0], basename
      # return metadata
      name: name
      author: author
      vendor: $.vendor
      comment: apple.information?.comments
      deviceType: if apple.meta?.tempo then 'LOOP' else 'ONESHOT'
      bankchain: [$.package, bank]
      tempo: apple.meta?.tempo
      types: [types]
      modes: apple.meta?.descriptors
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count


# deploy maschine-aware .wav files.
# --------------------------------
gulp.task "deploy-#{$.task}-midi-files", ->
  numFiles = util.countFiles $.midiFiles, '.mid'
  throw new Error 'ripped .mid files doesn\'t exist' unless numFiles
  count = 0;
  bar = progress
    total: numFiles
    tmpl: " Deploying files... [:bar] :cur/#{numFiles} :percent :eta"
    width: 40
  gulp.src ["#{$.midiFiles}/**/*.mid"]
    .pipe tap (file) ->
      basename = path.basename file.path, '.caf.mid'
      relativeDir = path.dirname file.relative
      # read apple loops metadata
      apple = util.readJson (path.join $.ripped, relativeDir, basename) + '.json'
      name = basename
      # add bpm + key to sample name
      name += " [#{apple.meta?.tempo}]" if apple.meta?.tempo
      name += " #{apple.meta?.keySignature}" if apple.meta?.keySignature
      name += "m" if apple.meta?.keyType is 'minor'
      # bank
      bank = (file.relative.split path.sep)[0]
      # bank = (file.relative.split path.sep)[0].replace /^[0-9][0-9] (.*)$/, '$1'
      # category
      types = []
      types.push apple.meta.category if apple.meta?.category
      types.push apple.meta.subcategory if apple.meta?.subcategory
      unless types.length
        defs = $.completionData[bank]
        def = _.find defs, (def)-> def.pattern.test basename if defs
        if (def)
          types.push def.category if def.category
          types.push def.subCategory if def.subCategory
        else
          console.warn "#unknown bank:#{bank} file:#{basename}"
          types.push 'Unknown'
      # categolized by folder
      dirname = path.dirname file.path
      if types.length is 2
        file.path = path.join dirname, types[0], types[1], name + '.mid'
      else if types.length is 1
        file.path = path.join dirname, types[0], name + '.mid'
    .pipe gulp.dest $.samples
    .pipe tap -> bar.tick 1, cur: ++count


