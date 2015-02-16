(function() {
  (function(exports) {
    return exports.controllerRedirectConf = {
      CB: {
        entityName: "things/parent/cationic block",
        stub: false,
        "cationic block": {
          deepLink: "cationic_block"
        }
      },
      LSM: {
        entityName: "things/parent/linker small molecule",
        stub: false,
        "linker small molecule": {
          deepLink: "linker_small_molecule"
        }
      },
      PRTN: {
        entityName: "things/parent/protein",
        stub: false,
        "protein": {
          deepLink: "protein"
        }
      },
      SP: {
        entityName: "things/parent/spacer",
        stub: false,
        "spacer": {
          deepLink: "spacer"
        }
      },
      PROT: {
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
          deepLink: "primary_screen_experiment"
        }
      }
    };
  })((typeof process === "undefined" || !process.versions ? window.controllerRedirectConf = window.controllerRedirectConf || {} : exports));

}).call(this);
