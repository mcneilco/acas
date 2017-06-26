# ---------------------------------------------- Requires

gulp = require('gulp')
coffee = require('gulp-coffee')
flatten = require('gulp-flatten')
rename = require('gulp-rename')
plumber = require('gulp-plumber')
jeditor = require('gulp-json-editor')
argv = require('yargs').argv
path = require('path')
gulpif = require('gulp-if')
_ = require('underscore')
notify = require("gulp-notify")
coffeeify = require('gulp-coffeeify')

node = undefined
os = require('os');

# ---------------------------------------------- Functions
getGlob = (paths) ->
  args = Array::slice.call(arguments)
  answer = sources.map((i) ->
    args.map (p) ->
      if p[0] == '!'
        '!' + i + '/' + p.substring(1)
      else
        i + '/' + p
  )
  [].concat.apply [], answer

getFirstFolderName = (path) ->
  path.dirname = path.dirname.split('/')[0]
  return path

getRPath = (path) ->
  module = path.dirname.split('/')[0]
  if path.basename == 'r' and path.extname == ''
    path.basename = ''
    path.dirname = ''
  outputDirname = module + '/' + path.dirname.replace(module + '/src/server/r', '')
  path.dirname = outputDirname
  return path

getLegacyRPath = (path) ->
  console.warn  "Warning: All R code in modules path 'modules/**/src/server/**/*.{R,r}' should be moved to 'modules/**/src/server/r/*.{R,r}'"
  module = path.dirname.split('/')[0]
  additionalPath =  path.dirname.replace(module + '/src/server/', '')
  console.log "Warning: Please move '#{path.dirname}/#{path.basename}#{path.extname}' to '#{module}/src/server/r/#{additionalPath}/#{path.basename}#{path.extname}'"
  if path.basename == 'r' and path.extname == ''
    path.basename = ''
    path.dirname = ''
  outputDirname = module + '/' + path.dirname.replace(module + '/src/server/', '')
  path.dirname = outputDirname
  return path

editPackageJson = () ->
  func = jeditor((json) ->
      delete json.scripts.postinstall
      json
    )
  return func

getTestFixuresPath = (path) ->
  path = getFirstFolderName(path)
  path.dirname += '/testFixtures'
  return path

getServiceTestsPath = (path) ->
  path = getFirstFolderName(path)
  path.dirname += '/serviceTests'
  return path

getPythonPath = (path) ->
  module = path.dirname.split('/')[0]
  if path.basename == 'python' and path.extname == ''
    path.basename = ''
    path.dirname = ''
  outputDirname = module + '/' + path.dirname.replace(module + '/src/server/python', '')
  path.dirname = outputDirname
  return

# ------------------------------------------------- Read Inputs

build = argv.buildPath or process.env.BUILD_PATH or ''
if build == ''
  build = 'build'
if argv.sourceDirectories? | process.env.SOURCE_DIRECTORIES?
  sources = (argv.sourceDirectories or process.env.SOURCE_DIRECTORIES).split(',')
else
  sources = []
  if !argv.customonly or true
    acas_base = path.relative('.', argv.acasBase or process.env.ACAS_BASE or '')
    if acas_base == ''
      acas_base = '.'
    sources.push acas_base
  if !argv.baseonly or true
    acas_custom = path.relative('.', argv.acasCustom or process.env.ACAS_CUSTOM or '')
    if acas_custom == ''
      acas_custom = 'acas_custom'
    sources.push acas_custom
  acas_shared = path.relative('.', argv.acasShared or process.env.ACAS_SHARED or '')
  if acas_shared == ''
    acas_shared = 'acas_shared'
  sources.push acas_shared
startupArgs = []
if argv.debugbrk
  startupArgs.push "--debug-brk=5858"
startupArgs.push "app.js"
if argv.stubsMode
  startupArgs.push "stubsMode"

console.log 'working directory \'' + __dirname + '\''
console.log 'setting build to: ' + build
console.log 'setting source directories to: ' + JSON.stringify(sources)

# ------------------------------------------------- Setup Configs

globalCoffeeOptions = {sourcemaps:true}
globalCopyOptions = {}
globalExecuteOptions = {cwd: build, env: process.env}
globalWatchOptions =
  interval: 1000
  debounceDelay: 500
  usePolling: true
#  mode: 'poll'

taskConfigs =
  coffee: [
      taskName: "root"
      src: getGlob('*.coffee')
      dest: build
      options: _.extend _.clone(globalCoffeeOptions), {}
    ,
      taskName: "publicConf"
      src: getGlob('public_conf/*.coffee')
      dest: build + '/src/javascripts/ServerAPI'
      options: _.extend _.clone(globalCoffeeOptions), {}
    ,
      taskName: "rootConf"
      src: getGlob('conf/*.coffee')
      dest: build + '/conf'
      options: _.extend _.clone(globalCoffeeOptions), {}
    ,
      taskName: "conf"
      src: getGlob('modules/**/conf/*.coffee')
      dest: build + '/public/javascripts/conf'
      options: _.extend _.clone(globalCoffeeOptions), {}
      renameFunction: getFirstFolderName
    ,
      taskName: "client"
      src: getGlob('modules/**/src/client/*.coffee')
      dest: build + '/public/javascripts/src'
      options: _.extend _.clone(globalCoffeeOptions), {}
      renameFunction: getFirstFolderName
    ,
      taskName: "routes"
      src: getGlob('modules/**/src/server/routes/*.coffee')
      dest: build + '/routes'
      options: _.extend _.clone(globalCoffeeOptions), {}
      flatten: true
    ,
      taskName: "server"
      src: getGlob('modules/**/src/server/*.coffee')
      dest: build + '/src/javascripts'
      options: _.extend _.clone(globalCoffeeOptions), {}
      renameFunction: getFirstFolderName
    ,
      taskName: "spec"
      src: getGlob('modules/**/spec/*.coffee')
      dest: build + '/public/javascripts/spec'
      options: _.extend _.clone(globalCoffeeOptions), {}
      renameFunction: getFirstFolderName
    ,
      taskName: "testFixtures"
      src: getGlob('modules/**/spec/testFixtures/*.coffee')
      dest: build + '/public/javascripts/spec'
      options: _.extend _.clone(globalCoffeeOptions), {}
      renameFunction: getTestFixuresPath
    ,
      taskName: "serviceTests"
      src: getGlob('modules/**/spec/serviceTests/*.coffee', 'modules/public/conf/serviceTests/*.coffee')
      dest: build + '/src/spec'
      options: _.extend _.clone(globalCoffeeOptions), {}
      renameFunction: getServiceTestsPath
  ],
  execute: [
        taskName: "npmInstall"
        command: 'npm'
        args: [ 'install' ]
        options: _.extend _.clone(globalExecuteOptions), cwd: build
      ,
        taskName: "prepare_config_files"
        command: 'node'
        args: ['PrepareConfigFiles.js']
        options: _.extend _.clone(globalExecuteOptions), cwd: build + '/src/javascripts/BuildUtilities'
        src: [
          build + '/conf/*.properties'
          build + '/conf/*.properties.example'
          build + '/src/r/*'
          build + '/src/javascripts/BuildUtilities/PrepareConfigFiles.js'
        ]
      ,
        taskName: "prepareTestJSON"
        command: 'node'
        args: ['PrepareTestJSON.js']
        options: _.extend _.clone(globalExecuteOptions), cwd: build + '/src/javascripts/BuildUtilities'
        src: [ build + '/public/javascripts/spec/testFixtures/*.js' ]
      ,
        taskName: "prepareModuleIncludes"
        command: 'node'
        args: ['PrepareModuleIncludes.js']
        options: _.extend _.clone(globalExecuteOptions), cwd: build + '/src/javascripts/BuildUtilities'
        src: [
          build + '/src/javascripts/BuildUtilities/PrepareModuleIncludes.js'
          build + '/app_template.js'
          build + '/public/stylesheets/**.css'
          build + '/public/html/**.html'
          build + '/public/javascripts/**.js'
          build + '/public/javascripts/spec/testFixtures/**.js'
          build + '/public/javascripts/spec/**.js'
        ]
      ,
        taskName: "prepareModuleConfJSON"
        command: 'node'
        args: ['PrepareModuleConfJSON.js']
        options: _.extend _.clone(globalExecuteOptions), cwd: build + '/src/javascripts/BuildUtilities'
        src: [ build + '/public/javascripts/conf/**/*.js' ]
  ],
  copy: [
      taskName: "bin"
      src: getGlob('bin/**')
      dest: build + '/bin'
      options: _.extend _.clone(globalCopyOptions), {}
    ,
      taskName: "public"
      src: getGlob('public/**')
      dest: build + '/public'
      options: _.extend _.clone(globalCopyOptions), {}
    ,
      taskName: "conf"
      src: getGlob('conf/**', '!conf/*.coffee')
      dest: build + '/conf'
      options: _.extend _.clone(globalCopyOptions), {}
    ,
      taskName: "moduleConf"
      src: getGlob('modules/**/conf/**', '!modules/**/conf/*.coffee')
      dest: build + '/public/conf'
      options: _.extend _.clone(globalCopyOptions), {}
      renameFunction: getFirstFolderName
    ,
      taskName: "nodeModulesCustomized"
      src: getGlob('node_modules_customized/**')
      dest: build+"/node_modules_customized"
      options: _.extend _.clone(globalCopyOptions), {}
    ,
      taskName: "jade"
      src: getGlob('modules/**/src/client/*.jade*')
      dest: build + '/views'
      options: _.extend _.clone(globalCopyOptions), {}
      flatten: true
    ,
      taskName: "r"
      src: getGlob('modules/**/src/server/r/**')
      dest: build + '/src/r'
      options: _.extend _.clone(globalCopyOptions), {}
      renameFunction: getRPath
    ,
      taskName: "python"
      src: getGlob('modules/**/src/server/python/**')
      dest: build + '/src/python'
      options: _.extend _.clone(globalCopyOptions), {}
      renameFunction: getPythonPath
    ,
      taskName: "serverR"
      src: getGlob('modules/**/src/server/*.{R,r}')
      dest: build + '/src/r'
      options: _.extend _.clone(globalCopyOptions), {}
      renameFunction: getFirstFolderName
    ,
      taskName: "legacyServerR"
      src: getGlob('modules/**/src/server/**/*.{R,r}', '!modules/**/src/server/*.{R,r}','!modules/**/src/server/r/*.{R,r}')
      dest: build + '/src/r'
      options: _.extend _.clone(globalCopyOptions), {}
      renameFunction: getLegacyRPath
    ,
      taskName: "html"
      src: getGlob('modules/**/src/client/*.html')
      dest: build + '/public/html'
      options: _.extend _.clone(globalCopyOptions), {}
      renameFunction: getFirstFolderName
    ,
      taskName: "css"
      src: getGlob('modules/**/src/client/*.css')
      dest: build + '/public/stylesheets'
      options: _.extend _.clone(globalCopyOptions), {}
      renameFunction: getFirstFolderName
    ,
      taskName: "serviceTestsR"
      src: getGlob('modules/**/spec/serviceTests/*.{R,r}')
      dest: build + '/src/r/spec'
      options: _.extend _.clone(globalCopyOptions), {}
      renameFunction: getFirstFolderName
    ,
      taskName: "routesJS"
      src: getGlob('modules/**/src/server/routes/*.js')
      dest: build + '/routes'
      options: _.extend _.clone(globalCopyOptions), {}
      flatten: true
    ,
      taskName: "CmpdReg"
      src: getGlob('modules/CmpdReg/src/**')
      dest: build + '/public/CmpdReg'
      options: _.extend _.clone(globalCopyOptions), {}
  ],
  others:
    packageJSON:
      taskName: "packageJSON"
      src: getGlob('*package.json')
      dest: build
    app:
      taskName: "app"
      command: 'node'
      args: startupArgs
      options: _.extend _.clone(globalExecuteOptions), cwd: build
      src: [
        build + '/conf/compiled/*'
        build + '/app.js'
        build + '/views/*'
        build + '/routes/*'
        build + '/src/javascripts/**'
        build + '/spec/javascripts/**'
      ]

createExecuteTask = (options) =>
  taskName = "execute:#{options.taskName}"
  watch = options.watch
  gulp.task taskName, (cb) ->
    spawn = require('child_process').spawn
    command = spawn(options.command, options.args, options.options)
    process.on 'exit', ->
      command.kill()
      return
    command.stdout.on 'data', (data) ->
      process.stdout.write "#{data}"
      return
    command.stderr.on 'data', (data) ->
      process.stdout.write "#{data}"
      return
    command.on 'exit', (code) ->
      cb code
  unless watch == false
    watchTaskName = "watch:#{taskName}"
    watchOptions = watch?.options ? {}
    gulp.task watchTaskName, ->
      gulp.watch options.src, watchOptions, gulp.series(taskName)
        .on('error', console.error)

      return
    watchTasks.push watchTaskName
  return taskName


onError = (err) ->
  process.stdout.write '\x07'
  if os.platform() == 'darwin'
    return notify.onError(
      title: '<%= error.message %>'
      # subtitle: 'Failure!'
      message: 'Error: <%= error.stack %>'
      sound: false) err
  else
    return notify.onError((options, callback) ->
      console.log "\x1b[34m[#{options.message}]\x1b[0m \x1b[31mError: #{options.stack}\x1b[0m"
      return
    ) err
  @emit 'end'


createTask = (options, type) ->
  taskName = "#{type}:#{options.taskName}"
  taskOptions = options.options
  src = options.src
  dest = options.dest
  watch = options.watch
  shouldFlatten = options.flatten ? false
  renameFunction = options.renameFunction
  shouldCoffeify = (file) ->
    if type=="coffee" && (file.path.indexOf("client/ExcelApp") > -1)
       return true
    else
      return false
  shouldCoffee = (file) ->
    if type=="coffee" && !(file.path.indexOf("client/ExcelApp") > -1)
       return true
    else
      return false
  gulp.task taskName, ->
    gulp.src(src, _.extend(taskOptions, {since: gulp.lastRun(taskName)}))
    .pipe(plumber({errorHandler: onError}))
    .pipe(gulpif(shouldFlatten,flatten()))
    .pipe(gulpif(shouldCoffeify, coffeeify({options:{paths:[build]}})))
    .pipe(gulpif(shouldCoffee,coffee(bare: true)))
    .pipe(gulpif(renameFunction?,rename(renameFunction)))
    .pipe gulp.dest(dest)
  unless watch == false
    watchTaskName = "watch:#{taskName}"
    watchOptions = watch?.options ? {}
    gulp.task watchTaskName, ->
      gulp.watch src, watchOptions, gulp.series(taskName)
      return
    watchTasks.push watchTaskName
  return taskName


# ---------------------------------------------- Create Tasks
watchTasks = []

# --------- Coffee/Watch:Coffee Tasks
coffeeTasks = (createTask(taskConfig,'coffee') for taskConfig in taskConfigs.coffee)
coffeeTasks = _.filter coffeeTasks, (item) -> item != "coffee:publicConf"
gulp.task 'coffee', gulp.parallel coffeeTasks

# --------- Copy/Watch:Copy Tasks
copyTasks = (createTask(taskConfig,'copy') for taskConfig in taskConfigs.copy)

# --------- Execute/Watch:Execute Tasks
executeTasks = (createExecuteTask(taskConfig) for taskConfig in taskConfigs.execute)

# --------- If --conf not passed in then remove prepare_config_files from the execute task
if !argv.conf
  executeTasks = _.filter executeTasks, (item) -> item != "execute:prepare_config_files"

# --------- Package JSON Copy/Watch Task
gulp.task "copy:#{taskConfigs.others.packageJSON.taskName}", (done) ->
  gulp.src(taskConfigs.others.packageJSON.src).pipe(jeditor((json) ->
    delete json.scripts.postinstall
    json
  )).pipe gulp.dest(taskConfigs.others.packageJSON.dest)
  done()
  return
copyTasks.push "copy:#{taskConfigs.others.packageJSON.taskName}"

gulp.task "watch:#{taskConfigs.others.packageJSON.taskName}", ->
  gulp.watch taskConfigs.others.packageJSON.src, _.clone(globalWatchOptions), gulp.series('copy:packageJSON')
watchTasks.push "watch:#{taskConfigs.others.packageJSON.taskName}"

# --------- App start, watch and restart tasks
gulp.task 'app', (done) =>
  if node?
    node.kill()
  spawn = require('child_process').spawn
  node = spawn('node', [ 'app.js' ], stdio: 'inherit')
  node.on 'close', (code) ->
    if code == 8
      gulp.log 'Error detected, waiting for changes...'
    return
  done()
  return

gulp.task "watch:#{taskConfigs.others.app.taskName}", ->
  gulp.watch taskConfigs.others.app.src, _.clone(globalWatchOptions), gulp.series('app')

# --------- Remove module conf json unless running dev
unless argv._[0] == "dev"
  executeTasks = _.filter executeTasks, (item) -> item != "execute:prepareModuleConfJSON"

# --------- Copy Task
gulp.task 'copy', gulp.parallel copyTasks

# --------- Execute Task
gulp.task 'execute', gulp.series executeTasks

# --------- Watch Task
gulp.task 'watch', gulp.parallel watchTasks

# --------- Build Task
gulp.task('build', gulp.series(gulp.parallel('copy','coffee'), 'coffee:publicConf', 'execute'));

# --------- Dev Task
gulp.task('dev', gulp.series(gulp.series('build'), gulp.parallel('watch', 'watch:app', 'app')));

# --------- Default Task
gulp.task 'default', gulp.series('build', 'watch')


