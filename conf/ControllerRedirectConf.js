(function() {
  (function(exports) {
    return exports.controllerRedirectConf = {
      PROT: {
        entityName: "protocols",
        stub: true,
        "default": {
          deepLink: "protocol_base"
        },
        "flipr screening assay": {
          deepLink: "primary_screen_protocol"
        }
      },
      EXPT: {
        entityName: "experiments",
        stub: false,
        "default": {
          deepLink: "experiment_base"
        },
        "flipr screening assay": {
          deepLink: "flipr_screening_assay"
        }
      }
    };
  })((typeof process === "undefined" || !process.versions ? window.controllerRedirectConf = window.controllerRedirectConf || {} : exports));

}).call(this);
