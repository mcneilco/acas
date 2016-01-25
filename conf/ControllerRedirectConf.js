(function() {
  (function(exports) {
    return exports.controllerRedirectConf = {
      PROT: {
        entityName: "protocols",
        "default": {
          deepLink: "protocol_base"
        },
        "Bio Activity": {
          deepLink: "primary_screen_protocol"
        },
        relatedFilesRelativePath: "protocols"
      },
      EXPT: {
        entityName: "experiments",
        "default": {
          deepLink: "experiment_base"
        },
        "Bio Activity": {
          deepLink: "primary_screen_experiment"
        },
        relatedFilesRelativePath: "experiments"
      },
      PROJ: {
        entityName: "things/project/project",
        "project": {
          deepLink: "project"
        },
        relatedFilesRelativePath: "entities/projects"
      },
      PT: {
        entityName: "parent thing",
        "default": {
          deepLink: "parent_thing"
        },
        "Bio Activity": {
          deepLink: "thing_parent"
        },
        relatedFilesRelativePath: "entities/parentThings"
      },
      CB: {
        entityName: "things/parent/cationic block",
        "cationic block": {
          deepLink: "cationic_block"
        },
        relatedFilesRelativePath: "entities/cationicBlockParents"
      }
    };
  })((typeof process === "undefined" || !process.versions ? window.controllerRedirectConf = window.controllerRedirectConf || {} : exports));

}).call(this);
