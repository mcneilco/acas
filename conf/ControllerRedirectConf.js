(function() {
  (function(exports) {
    return exports.controllerRedirectConf = {
      CB: {
        entityName: "cationicBlockParents",
        stub: false,
        "cationic block": {
          deepLink: "cationic_block"
        }
      },
      LSM: {
        entityName: "linkerSmallMoleculeParents",
        stub: false,
        "linker small molecule": {
          deepLink: "linker_small_molecule"
        }
      },
      PRTN: {
        entityName: "proteinParents",
        stub: false,
        "protein": {
          deepLink: "protein"
        }
      },
      SP: {
        entityName: "spacerParents",
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
