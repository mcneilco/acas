(function() {
  (function(exports) {
    return exports.controllerRedirectConf = {
      PRCL: {
        entityName: "protocols",
        stub: true,
        "default": {
          deepLink: "protocol_base"
        },
        "Bio Activity": {
          deepLink: "primary_screen_protocol"
        }
      },
      EXPT: {
        entityName: "experiments",
        stub: false,
        "default": {
          deepLink: "experiment_base"
        },
        "Bio Activity": {
          deepLink: "flipr_screening_assay"
        }
      }
    };
  })((typeof process === "undefined" || !process.versions ? window.controllerRedirectConf = window.controllerRedirectConf || {} : exports));

}).call(this);
