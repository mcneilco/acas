
var gulp = require('gulp'),
    gutil = require('gutil'),
    coffee = require('gulp-coffee'),
    del = require('del'),
    flatten = require('gulp-flatten'),
    rename = require('gulp-rename'),
    plumber = require('gulp-plumber'),
    jeditor = require('gulp-json-editor'),
    argv = require('yargs').argv;
    path = require('path')
    // browserify = require('gulp-browserify'),
    run = require('gulp-run');

    _ = require('underscore')


build =  argv.buildPath || process.env.BUILD_PATH || ''
if(build == "") {
  build = "build"
}
if ((argv.sourceDirectories != null) | (process.env.SOURCE_DIRECTORIES != null)) {
  sources = (argv.sourceDirectories || process.env.SOURCE_DIRECTORIES).split(",");
} else {
  sources = [];
  if (!argv.customonly || true) {
    acas_base = path.relative('.', argv.acasBase || process.env.ACAS_BASE || '');
    if (acas_base === "") {
      acas_base = ".";
    }
    sources.push(acas_base);
  }
  if (!argv.baseonly || true) {
    acas_custom = path.relative('.', argv.acasCustom || process.env.ACAS_CUSTOM || '');
    if (acas_custom === "") {
      acas_custom = "acas_custom";
    }
    sources.push(acas_custom);
  }
  acas_shared = path.relative('.', argv.acasShared || process.env.ACAS_SHARED || '');
  if (acas_shared === "") {
    acas_shared = "acas_shared";
  }
  sources.push(acas_shared);
}
console.log("working directory '" + __dirname + "'");
console.log("setting build to: " + build);
console.log("setting source directories to: " + (JSON.stringify(sources)));

// ---------------------------------------------- Utility Functions

function onError(err) {
  gutil.log(err)
  this.emit('end');
}
getGlob = function(paths) {
  var args = Array.prototype.slice.call(arguments);
  answer = sources.map(function(i) {
    return args.map(function(p) {
      if(p[0] == "!") {
        return "!" + i + "/" + p.substring(1)
      } else {
        return i + "/" + p;
      }
    })
  })
  return [].concat.apply([], answer);
};

getFirstFolderName = function(path) {
  path.dirname = path.dirname.split('/')[0];
};
getRPath = function(path) {
  module = path.dirname.split('/')[0];
  if(path.basename == 'r' && path.extname == '') {
    path.basename = ""
    path.dirname = ""
  }
  outputDirname = module+"/"+path.dirname.replace(module+'/src/server/r','')
  path.dirname = outputDirname
};

getPythonPath = function(path) {
  module = path.dirname.split('/')[0];
  if(path.basename == 'python' && path.extname == '') {
    path.basename = ""
    path.dirname = ""
  }
  outputDirname = module+"/"+path.dirname.replace(module+'/src/server/python','')
  path.dirname = outputDirname
};

// ------------------------------------------------- configs

  var paths = {
    // browserify: {
    //   src: [build+"/public/javascripts/src/ExcelApp/ExcelApp.js"],
    //   dest: build+"/public/javascripts/src/ExcelApp/ExcelApp.js"
    // },
    npmInstall: {
      command: "npm install",
      options: {
        cwd: build,
        verbosity: 3
      }
    },
    prepareConfigFiles: {
      src: [build+"/conf/*.properties",build+"/conf/*.properties.example",build+"src/r/*",build+"/src/javascripts/BuildUtilities/PrepareConfigFiles.js"],
      options: {
        cwd: build+"/src/javascripts/BuildUtilities"
      },
      script: "PrepareConfigFiles.js"
    },
    prepareTestJSON: {
      src: [build+"/public/javascripts/spec/testFixtures/*.js"],
      options: {
        cwd: build+"/src/javascripts/BuildUtilities"
      },
      script: "PrepareTestJSON.js"
    },
    prepareModuleIncludes: {
      src: [build+"/src/javascripts/BuildUtilities/PrepareModuleIncludes.js",
      					//app_template
      					build+"/app_template.js",
      					//styleFiles
      					build+"/public/stylesheets/**.css",
      					//templateFiles
      					build+"/public/html/**.html",
      					//appScriptsInJavascripts
      					build+"/public/javascripts/**.js",
      					//testJSONInJavascripts
      					build+"/public/javascripts/spec/testFixtures/**.js",
      					//specScriptsInJavascripts
      					build+"/public/javascripts/spec/**.js",
      	],
      options: {
        cwd: "build/src/javascripts/BuildUtilities"
      },
      script: "PrepareModuleIncludes.js"
    },
    rootCoffee: {
      src: getGlob('*.coffee'),
      dest: build
    },
    packageJSON: {
      src: getGlob('*package.json'),
      dest: build
    },
    publicConf: {
      src: getGlob('public_conf/*.coffee'),
      dest: build+"/src/javascripts/ServerAPI"
    },
    public: {
      src: getGlob('public/**'),
      dest: build+"/public"
    },
    bin: {
      src: getGlob('bin/**'),
      dest: build+"/bin"
    },
    conf: {
      src: getGlob('conf/**','!conf/*.coffee'),
      dest: build+"/conf"
    },
    modules: {
      conf: {
        src: getGlob('modules/**/conf/*.coffee'),
        dest: build+"/public/javascripts/conf"
      },
      jade: {
        src: getGlob('modules/**/src/client/*.jade*'),
        dest: build+"/views"
      },
      client: {
        src: getGlob('modules/**/src/client/*.coffee'),
        dest: build+"/public/javascripts/src"
      },
      routes: {
        src: getGlob('modules/**/src/server/routes/*.coffee'),
        dest: build+"/routes"
      },
      server: {
        src: getGlob('modules/**/src/server/*.coffee'),
        dest: build+"/src/javascripts"
      },
      spec: {
        src: getGlob('modules/**/spec/*.coffee'),
        dest: build+"/public/javascripts/spec"
      },
      serviceTests: {
        src: getGlob("modules/**/spec/serviceTests/*.coffee","modules/public/conf/serviceTests/*.coffee"),
        dest: build+"/src/spec"
      },
      r: {
        src: getGlob("modules/**/src/server/r/**"),
        dest: build+"/src/r"
      },
      python: {
        src: getGlob("modules/**/src/server/python/**"),
        dest: build+"/src/python"
      },
      serverR: {
        src: getGlob('modules/**/src/server/*.{R,r}'),
        dest: build+"/src/r"
      },
      serviceTestsR: {
        src: getGlob('modules/**/spec/serviceTests/*.{R,r}'),
        dest: build+"/src/r/spec"
      },
      routesJS: {
        src: getGlob('modules/**/src/server/routes/*.js'),
        dest: build+"/routes"
      },
      CmpdReg: {
        src: getGlob("modules/CmpdReg/src/client/**","modules/CmpdReg/src/marvinjs/**"),
        dest: build+"/public/CmpdReg"
      }
    }
  };

// ---------------------------------------------- Gulp Tasks
gulp.task('rootCoffee', function () {
  return gulp.src(paths.rootCoffee.src)
    .pipe(plumber())
    .pipe(rename(getFirstFolderName))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.rootCoffee.dest))
});
gulp.task('bin', function () {
  return gulp.src(paths.bin.src)
    .pipe(gulp.dest(paths.bin.dest))
});
gulp.task('packageJSON', function (done) {
  gulp.src("./package.json")
    .pipe(jeditor(function(json) {
      delete json.scripts.postinstall
      return json; // must return JSON object.
    }))
    .pipe(gulp.dest(build));
    done()
});

gulp.task('conf', function () {
  return gulp.src(paths.conf.src)
    .pipe(gulp.dest(paths.conf.dest))
});
gulp.task('public', function () {
  return gulp.src(paths.public.src)
    .pipe(gulp.dest(paths.public.dest))
});
gulp.task('modules:jade', function () {
  return gulp.src(paths.modules.jade.src)
    .pipe(flatten())
    .pipe(gulp.dest(paths.modules.jade.dest))
});
gulp.task('modules:r', function () {
  return gulp.src(paths.modules.r.src)
    .pipe(rename(getRPath))
    .pipe(gulp.dest(paths.modules.r.dest))
});
gulp.task('modules:python', function () {
  return gulp.src(paths.modules.python.src)
    .pipe(rename(getPythonPath))
    .pipe(gulp.dest(paths.modules.python.dest))
});
gulp.task('modules:serverR', function () {
  return gulp.src(paths.modules.serverR.src)
    .pipe(rename(getFirstFolderName))
    .pipe(gulp.dest(paths.modules.serverR.dest))
});
gulp.task('modules:serviceTestsR', function () {
  return gulp.src(paths.modules.serviceTestsR.src)
    .pipe(rename(getFirstFolderName))
    .pipe(gulp.dest(paths.modules.serviceTestsR.dest))
});
gulp.task('modules:routes', function () {
  return gulp.src(paths.modules.routes.src)
    .pipe(plumber())
    .pipe(coffee({bare: true}))
    .pipe(flatten())
    .pipe(gulp.dest(paths.modules.routes.dest))
});
gulp.task('modules:client', function () {
  return gulp.src(paths.modules.client.src)
    .pipe(plumber())
    .pipe(rename(getFirstFolderName))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.modules.client.dest))
});
gulp.task('modules:server', function () {
  return gulp.src(paths.modules.server.src)
    .pipe(plumber())
    .pipe(rename(getFirstFolderName))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.modules.server.dest))
});
gulp.task('modules:spec', function () {
  return gulp.src(paths.modules.spec.src)
    .pipe(plumber())
    .pipe(rename(getFirstFolderName))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.modules.spec.dest))
});
gulp.task('modules:spec', function () {
  return gulp.src(paths.modules.spec.src)
    .pipe(plumber())
    .pipe(rename(getFirstFolderName))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.modules.spec.dest))
});
gulp.task('modules:conf', function () {
  return gulp.src(paths.modules.conf.src)
    .pipe(plumber())
    .pipe(rename(getFirstFolderName))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.modules.conf.dest))
});
gulp.task('modules:serviceTests', function () {
  return gulp.src(paths.modules.serviceTests.src)
    .pipe(plumber())
    .pipe(rename(getFirstFolderName))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.modules.serviceTests.dest))
});
gulp.task('publicConf', function () {
  return gulp.src(paths.publicConf.src)
    .pipe(plumber())
    .pipe(rename(getFirstFolderName))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.publicConf.dest))
});
gulp.task('modules:routesJS', function () {
  return gulp.src(paths.modules.routesJS.src)
    .pipe(plumber())
    .pipe(flatten())
    .pipe(gulp.dest(paths.modules.routesJS.dest))
});
gulp.task('modules:CmpdReg', function () {
  return gulp.src(paths.modules.CmpdReg.src)
    .pipe(plumber())
    .pipe(gulp.dest(paths.modules.CmpdReg.dest))
});
gulp.task('prepareConfigFiles', function (done) {
  gulp.src(paths.prepareConfigFiles.script,paths.prepareConfigFiles.options)             // get input files.
    .pipe(plumber())
    .pipe(run('node',paths.prepareConfigFiles.options))
  done()
})
gulp.task('prepareModuleIncludes', function (done) {
  gulp.src(paths.prepareModuleIncludes.script,paths.prepareModuleIncludes.options)             // get input files.
    .pipe(plumber())
    .pipe(run('node',paths.prepareModuleIncludes.options))
  done()
})
gulp.task('prepareTestJSON', function (done) {
  gulp.src(paths.prepareTestJSON.script,paths.prepareTestJSON.options)             // get input files.
    .pipe(plumber())
    .pipe(run('node',paths.prepareTestJSON.options))
  done()
})
gulp.task('npmInstall', function (done) {
  return run(paths.npmInstall.command,paths.npmInstall.options).exec()    // prints "Hello World\n".
})
// gulp.task('browserify', function() {
//     // Single entry point to browserify
//     gulp.src(paths.browserify.src)
//         .pipe(plumber())
//         .pipe(browserify())
//         .pipe(gulp.dest(paths.browserify.dest))
// });

//gulp.task('build', gulp.series('bin','public','modules:routes',"modules:client"))
gulp.task('build', gulp.series('packageJSON','npmInstall','modules:CmpdReg','modules:routesJS','modules:serviceTestsR', 'modules:serverR','rootCoffee', 'modules:jade', 'modules:r','modules:python','bin', 'conf','modules:client','modules:routes','modules:server','modules:spec','modules:serviceTests','modules:conf','publicConf','prepareModuleIncludes','prepareTestJSON'))

//'public'

// ---------------------------------------------- Gulp Watch
watchOptions = {
        interval: 1000, // default 100
        debounceDelay: 500, // default 500
        mode: 'poll'
    }
gulp.task('watch:rootCoffee', function () {
  gulp.watch(paths.rootCoffee.src, watchOptions, gulp.series('rootCoffee'));
});
gulp.task('watch:packageJSON', function () {
  gulp.watch(paths.packageJSON.src, watchOptions, gulp.series('packageJSON'));
});
gulp.task('watch:bin', function () {
  gulp.watch(paths.bin.src, watchOptions, gulp.series('bin'));
});
gulp.task('watch:conf', function () {
  gulp.watch(paths.conf.src, watchOptions, gulp.series('conf'));
});
gulp.task('watch:public', function () {
  gulp.watch(paths.public.src, watchOptions, gulp.series('public'));
});
gulp.task('watch:modules:jade', function () {
  gulp.watch(paths.modules.jade.src, watchOptions, gulp.series('modules:jade'));
});
gulp.task('watch:modules:r', function () {
  gulp.watch(paths.modules.r.src, watchOptions, gulp.series('modules:r'));
});
gulp.task('watch:modules:python', function () {
  gulp.watch(paths.modules.python.src, watchOptions, gulp.series('modules:python'));
});
gulp.task('watch:modules:serverR', function () {
  gulp.watch(paths.modules.serverR.src, watchOptions, gulp.series('modules:serverR'));
});
gulp.task('watch:modules:client', function () {
  gulp.watch(paths.modules.client.src, watchOptions, gulp.series('modules:client'));
});
gulp.task('watch:modules:routes', function () {
  gulp.watch(paths.modules.routes.src, watchOptions, gulp.series('modules:routes'));
});
gulp.task('watch:modules:server', function () {
  gulp.watch(paths.modules.server.src, watchOptions, gulp.series('modules:server'));
});
gulp.task('watch:modules:spec', function () {
  gulp.watch(paths.modules.spec.src, watchOptions, gulp.series('modules:spec'));
});
gulp.task('watch:modules:serviceTests', function () {
  gulp.watch(paths.modules.spec.src, watchOptions, gulp.series('modules:serviceTests'));
});
gulp.task('watch:modules:conf', function () {
  gulp.watch(paths.modules.conf.src, watchOptions, gulp.series('modules:conf'));
});
gulp.task('watch:publicConf', function () {
  gulp.watch(paths.publicConf.src, watchOptions, gulp.series('publicConf'));
});
gulp.task('watch:modules:serviceTestsR', function () {
  gulp.watch(paths.modules.serviceTestsR.src, watchOptions, gulp.series('modules:serviceTestsR'));
});
gulp.task('watch:modules:routesJS', function () {
  gulp.watch(paths.modules.routesJS.src, watchOptions, gulp.series('modules:routesJS'));
});
gulp.task('watch:modules:CmpdReg', function () {
  gulp.watch(paths.modules.CmpdReg.src, watchOptions, gulp.series('modules:CmpdReg'));
});
gulp.task('watch:prepareConfigFiles', function () {
  gulp.watch(paths.prepareConfigFiles.src, gulp.series('prepareConfigFiles'));
});
gulp.task('watch:prepareModuleIncludes', function () {
  gulp.watch(paths.prepareModuleIncludes.src, gulp.series('prepareModuleIncludes'));
});
gulp.task('watch:prepareTestJSON', function () {
  gulp.watch(paths.prepareTestJSON.src, gulp.series('prepareTestJSON'));
});

gulp.task('watch', gulp.parallel('watch:prepareTestJSON','watch:prepareModuleIncludes','watch:prepareConfigFiles','watch:modules:CmpdReg','watch:modules:serverR','watch:rootCoffee','watch:modules:jade', 'watch:modules:r', 'watch:modules:python', 'watch:bin', 'watch:conf','watch:modules:client','watch:modules:routes','watch:modules:server','watch:modules:spec','watch:modules:serviceTests','watch:modules:conf','watch:publicConf','watch:packageJSON','watch:modules:serviceTestsR','watch:modules:routesJS'));


// -------------------------------------------- Default task
//gulp.task('default', gulp.series('build', gulp.parallel('watch')));

gulp.task('default', gulp.series('build', gulp.parallel('watch')));







//
//
//
//
// /* Not all tasks need to use streams, a gulpfile is just another node program
//  * and you can use all packages available on npm, but it must return either a
//  * Promise, a Stream or take a callback and call it
//  */
// function clean() {
//   // You can use multiple globbing patterns as you would with `gulp.src`,
//   // for example if you are using del 2.0 or above, return its promise
//   return del([ 'build' ]);
// }
//
// /*
//  * Define our tasks using plain functions
//  */
// function styles() {
//   return gulp.src(paths.styles.src)
//     .pipe(less())
//     .pipe(cleanCSS())
//     // pass in options to the stream
//     .pipe(rename({
//       basename: 'main',
//       suffix: '.min'
//     }))
//     .pipe(gulp.dest(paths.styles.dest));
// }
// getGlob = function(path) {
//   return sources.map(function(i) {
//     return i + "/" + path;
//   });
// }
// // function fileWatch() {
// //     // Endless stream mode
// //     return watch(getGlob(paths.public.lib.src), { ignoreInitial: false })
// //         .pipe(gulp.dest(paths.public.lib.dest));
// // };
//
// // function fileWatch() {
// //     // Endless stream mode
// //     return watch(getGlob(paths.public.lib.src), { ignoreInitial: false })
// //         .pipe(gulp.dest(paths.public.lib.dest));
// // };
//
// function scripts() {
//   return gulp.src(paths.scripts.src, { sourcemaps: true })
//     .pipe(babel())
//     .pipe(uglify())
//     .pipe(concat('main.min.js'))
//     .pipe(gulp.dest(paths.scripts.dest));
// }
//
// function publicLib() {
//   console.log("running"+getGlob(paths.public.lib.src))
//   return gulp.src(getGlob(paths.public.lib.src))
//     .pipe(gulp.dest('build'));
// }
// function buildAndWatch() {
//
// }
//
// // function watch() {
// //   gulp.watch(paths.public.lib.src, publicLib);
// //   // gulp.watch(paths.styles.src, styles);
// // }
//
// /*
//  * You can use CommonJS `exports` module notation to declare tasks
//  */
// exports.clean = clean;
// exports.styles = styles;
// exports.scripts = scripts;
// // exports.watch = watch;
//
// /*
//  * Specify if tasks run in series or parallel using `gulp.series` and `gulp.parallel`
//  */
// var build = gulp.series(clean, gulp.parallel(styles, scripts));
//
// /*
//  * You can still use `gulp.task` to expose tasks
//  */
// gulp.task('build', build);
//
// /*
//  * Define default task that can be called by just running `gulp` from cli
//  */
// // gulp.task('default', buildAndWatch);
