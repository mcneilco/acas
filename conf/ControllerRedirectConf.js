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
      PROT: {
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
      }
    };
  })((typeof process === "undefined" || !process.versions ? window.controllerRedirectConf = window.controllerRedirectConf || {} : exports));

}).call(this);
