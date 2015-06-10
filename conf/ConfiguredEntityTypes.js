(function() {
  exports.entityTypes = [
    {
      type: "compound",
      kind: "batch name",
      codeOrigin: "ACAS CmpdReg",
      displayName: "Corporate Batch ID",
      sourceExternal: true
    }, {
      type: "parent",
      kind: "protein",
      codeOrigin: "ACAS LSThing",
      displayName: "Protein Parent",
      sourceExternal: false
    }, {
      type: "batch",
      kind: "protein",
      codeOrigin: "ACAS LSThing",
      displayName: "Protein Batch",
      sourceExternal: false
    }
  ];

}).call(this);
