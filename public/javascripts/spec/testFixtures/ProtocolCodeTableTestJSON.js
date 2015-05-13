(function() {
  (function(exports) {
    return exports.codetableValues = [
      {
        type: "protocol",
        kind: "status",
        codes: [
          {
            code: "created",
            name: "Created",
            ignored: false
          }, {
            code: "started",
            name: "Started",
            ignored: false
          }, {
            code: "complete",
            name: "Complete",
            ignored: false
          }, {
            code: "finalized",
            name: "Finalized",
            ignored: false
          }, {
            code: "rejected",
            name: "Rejected",
            ignored: false
          }, {
            code: "approved",
            name: "Approved",
            ignored: false
          }
        ]
      }, {
        type: "assay",
        kind: "stage",
        codes: [
          {
            code: "assay development",
            name: "Assay Development",
            ignored: false
          }
        ]
      }, {
        type: "protocol metadata",
        kind: "file type",
        codes: [
          {
            code: "reference file",
            name: "Reference File",
            ignored: false
          }, {
            code: "protocol file",
            name: "Protocol File",
            ignored: false
          }
        ]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.protocolCodeTableTestJSON = window.protocolCodeTableTestJSON || {} : exports));

}).call(this);
