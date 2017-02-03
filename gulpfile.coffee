gulp = require('gulp')
gutil = require('gutil')
coffee = require('gulp-coffee')
del = require('del')
flatten = require('gulp-flatten')
rename = require('gulp-rename')
plumber = require('gulp-plumber')
jeditor = require('gulp-json-editor')
argv = require('yargs').argv
path = require('path')
run = require('gulp-run')
gulpif = require('gulp-if')
_ = require('underscore')

# ---------------------------------------------- Utility Functions

onError = (err) ->
  gutil.log err
  @emit 'end'
  return

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
console.log 'working directory \'' + __dirname + '\''
console.log 'setting build to: ' + build
console.log 'setting source directories to: ' + JSON.stringify(sources)

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

getPythonPath = (path) ->
  module = path.dirname.split('/')[0]
  if path.basename == 'python' and path.extname == ''
    path.basename = ''
    path.dirname = ''
  outputDirname = module + '/' + path.dirname.replace(module + '/src/server/python', '')
  path.dirname = outputDirname
  return

# ------------------------------------------------- configs

globalCoffeeOptions = {sourcemaps:true}
globalCopyOptions = {}
globalExecuteOptions = {cwd: build,env: process.env}
globalWatchOptions =
  interval: 1000
  debounceDelay: 500
  mode: 'poll'

taskConfigs =
  coffee: [
      taskName: "root"
      src: getGlob('*.coffee')
      dest: build
      options: _.extend globalCoffeeOptions, {}
    ,
      taskName: "publicConf"
      src: getGlob('public_conf/*.coffee')
      dest: build + '/src/javascripts/ServerAPI'
      options: _.extend globalCoffeeOptions, {}
    ,
      taskName: "rootConf"
      src: getGlob('conf/*.coffee')
      dest: build + '/conf'
      options: _.extend globalCoffeeOptions, {}
    ,
      taskName: "conf"
      src: getGlob('modules/**/conf/*.coffee')
      dest: build + '/public/javascripts/conf'
      options: _.extend globalCoffeeOptions, {}
      renameFunction: getFirstFolderName
    ,
      taskName: "client"
      src: getGlob('modules/**/src/client/*.coffee')
      dest: build + '/public/javascripts/src'
      options: _.extend globalCoffeeOptions, {}
      renameFunction: getFirstFolderName
    ,
      taskName: "routes"
      src: getGlob('modules/**/src/server/routes/*.coffee')
      dest: build + '/routes'
      options: _.extend globalCoffeeOptions, {}
      flatten: true
    ,
      taskName: "server"
      src: getGlob('modules/**/src/server/*.coffee')
      dest: build + '/src/javascripts'
      options: _.extend globalCoffeeOptions, {}
      renameFunction: getFirstFolderName
    ,
      taskName: "spec"
      src: getGlob('modules/**/spec/*.coffee')
      dest: build + '/public/javascripts/spec'
      options: _.extend globalCoffeeOptions, {}
      renameFunction: getFirstFolderName
    ,
      taskName: "testFixtures"
      src: getGlob('modules/**/spec/testFixtures/*.coffee')
      dest: build + '/public/javascripts/spec'
      options: _.extend globalCoffeeOptions, {}
      renameFunction: getTestFixuresPath
    ,
      taskName: "serviceTests"
      src: getGlob('modules/**/spec/serviceTests/*.coffee', 'modules/public/conf/serviceTests/*.coffee')
      dest: build + '/src/spec'
      options: _.extend globalCoffeeOptions, {}
      renameFunction: getFirstFolderName
  ],
  execute: [
        taskName: "npmInstall"
        command: 'npm'
        args: [ 'install' ]
        options: _.extend globalExecuteOptions, cwd: build
      ,
        taskName: "prepare_config_files"
        command: 'node'
        args: ['PrepareConfigFiles.js']
        options: _.extend globalExecuteOptions, cwd: build + '/src/javascripts/BuildUtilities'
        src: [
          build + '/conf/*.properties'
          build + '/conf/*.properties.example'
          build + 'src/r/*'
          build + '/src/javascripts/BuildUtilities/PrepareConfigFiles.js'
        ]
      ,
        taskName: "prepareTestJSON"
        command: 'node'
        args: ['PrepareTestJSON.js']
        options: _.extend globalExecuteOptions, cwd: build + '/src/javascripts/BuildUtilities'
        src: [ build + '/public/javascripts/spec/testFixtures/*.js' ]
      ,
        taskName: "prepareModuleIncludes"
        command: 'node'
        args: ['PrepareModuleIncludes.js']
        options: _.extend globalExecuteOptions, cwd: build + '/src/javascripts/BuildUtilities'
        src: [
          build + '/src/javascripts/BuildUtilities/PrepareModuleIncludes.js'
          build + '/app_template.js'
          build + '/public/stylesheets/**.css'
          build + '/public/html/**.html'
          build + '/public/javascripts/**.js'
          build + '/public/javascripts/spec/testFixtures/**.js'
          build + '/public/javascripts/spec/**.js'
        ]
  ],

  copy: [
      taskName: "bin"
      src: getGlob('bin/**')
      dest: build + '/bin'
      options: _.extend globalCopyOptions, {}
    ,
      taskName: "public"
      src: getGlob('public/**')
      dest: build + '/public'
      options: _.extend globalCopyOptions, {}
    ,
      taskName: "conf"
      src: getGlob('conf/**', '!conf/*.coffee')
      dest: build + '/conf'
      options: _.extend globalCopyOptions, {}
    ,
      taskName: "nodeModulesCustomized"
      src: getGlob('node_modules_customized/**')
      dest: build+"/node_modules_customized"
      options: _.extend globalCopyOptions, {}
    ,
      taskName: "jade"
      src: getGlob('modules/**/src/client/*.jade*')
      dest: build + '/views'
      options: _.extend globalCopyOptions, {}
      flatten: true
    ,
      taskName: "r"
      src: getGlob('modules/**/src/server/r/**')
      dest: build + '/src/r'
      options: _.extend globalCopyOptions, {}
      renameFunction: getRPath
    ,
      taskName: "python"
      src: getGlob('modules/**/src/server/python/**')
      dest: build + '/src/python'
      options: _.extend globalCopyOptions, {}
      renameFunction: getPythonPath
    ,
      taskName: "serverR"
      src: getGlob('modules/**/src/server/*.{R,r}')
      dest: build + '/src/r'
      options: _.extend globalCopyOptions, {}
      renameFunction: getFirstFolderName
    ,
    #   taskName: "html"
    #   src: getGlob('modules/**/src/client/*.html')
    #   dest: build + '/public/html'
    #   options: _.extend globalCopyOptions, {}
    #   renameFunction: getFirstFolderName
    # ,
    #   taskName: "css"
    #   src: getGlob('modules/**/src/client/*.css')
    #   dest: build + '/public/stylesheets'
    #   options: _.extend globalCopyOptions, {}
    #   renameFunction: getFirstFolderName
    # ,
      taskName: "serviceTestsR"
      src: getGlob('modules/**/spec/serviceTests/*.{R,r}')
      dest: build + '/src/r/spec'
      options: _.extend globalCopyOptions, {}
      renameFunction: getFirstFolderName
    ,
      taskName: "routesJS"
      src: getGlob('modules/**/src/server/routes/*.js')
      dest: build + '/routes'
      options: _.extend globalCopyOptions, {}
      flatten: true
    ,
      taskName: "CmpdReg"
      src: getGlob('modules/CmpdReg/src/client/**', 'modules/CmpdReg/src/marvinjs/**')
      dest: build + '/public/CmpdReg'
      options: _.extend globalCopyOptions, {}
  ],
  others:
    packageJSON:
      taskName: "packageJSON"
      src: getGlob('*package.json')
      dest: build


# ---------------------------------------------- Gulp Tasks
watchTasks = []
createExecuteTask = (options) ->
  taskName = "execute:#{options.taskName}"
  # watch = options.watch
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
  # unless watch == false
  #   watchTaskName = "watch:#{taskName}"
  #   watchOptions = watch?.options ? {}
  #   gulp.task watchTaskName, ->
  #     gulp.watch options.src, watchOptions, gulp.series(taskName)
  #     return
  #   console.log "adding task #{watchTaskName}"
  #   watchTasks.push watchTaskName
  return taskName

createTask = (options, type) ->
  taskName = "#{type}:#{options.taskName}"
  taskOptions = options.options
  src = options.src
  dest = options.dest
  watch = options.watch
  shouldFlatten = options.flatten ? false
  renameFunction = options.renameFunction
  gulp.task taskName, ->
    gulp.src(src, _.extend(taskOptions, {since: gulp.lastRun(taskName)}))
    .pipe(plumber())
    .pipe(gulpif(shouldFlatten,flatten()))
    .pipe(gulpif(renameFunction?,rename(renameFunction)))
    .pipe(gulpif(type=="coffee",coffee(bare: true)))
    .pipe gulp.dest(dest)
  unless watch == false
    watchTaskName = "watch:#{taskName}"
    watchOptions = watch?.options ? {}
    gulp.task watchTaskName, ->
      gulp.watch src, watchOptions, gulp.series(taskName)
      return
    watchTasks.push watchTaskName
  return taskName

coffeeTasks = (createTask(taskConfig,'coffee') for taskConfig in taskConfigs.coffee)
gulp.task 'coffee', gulp.parallel coffeeTasks
copyTasks = (createTask(taskConfig,'copy') for taskConfig in taskConfigs.copy)
gulp.task "copy:#{taskConfigs.others.packageJSON.taskName}", (done) ->
  gulp.src(taskConfigs.others.packageJSON.src).pipe(jeditor((json) ->
    delete json.scripts.postinstall
    json
    # must return JSON object.
  )).pipe gulp.dest(taskConfigs.others.packageJSON.dest)
  done()
  return
copyTasks.push "copy:#{taskConfigs.others.packageJSON.taskName}"
gulp.task "watch:#{taskConfigs.others.packageJSON.taskName}", ->
  gulp.watch taskConfigs.others.packageJSON.src, globalWatchOptions, gulp.series('copy:packageJSON')
watchTasks.push "watch:#{taskConfigs.others.packageJSON.taskName}"
gulp.task 'copy', gulp.parallel copyTasks


executeTasks = (createExecuteTask(taskConfig) for taskConfig in taskConfigs.execute)
if !argv.conf
  executeTasks = _.filter executeTasks, (item) -> item != "execute:prepare_config_files"

gulp.task 'execute', gulp.series executeTasks

gulp.task 'watch', gulp.parallel watchTasks

gulp.task('build', gulp.series(gulp.parallel('copy','coffee'), 'execute'));

gulp.task 'default', gulp.series('watch')
