(function() {
  (function(exports) {
    return exports.controllerRedirectConf = {
      PROT: {
        entityName: "protocols",
        stub: true,
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
        stub: false,
        "default": {
          deepLink: "experiment_base"
        },
        "Bio Activity": {
          deepLink: "primary_screen_experiment"
        },
        relatedFilesRelativePath: "experiments"
      },
      PT: {
        entityName: "parent thing",
        stub: false,
        "default": {
          deepLink: "parent_thing"
        },
        "Bio Activity": {
          deepLink: "thing_parent"
        },
        relatedFilesRelativePath: "entities/parentThings"
      }
    };
  })((typeof process === "undefined" || !process.versions ? window.controllerRedirectConf = window.controllerRedirectConf || {} : exports));

}).call(this);
