(function() {
  var entity, i, len, ref;

  exports.entityTypes = [
    {
      type: "compound",
      kind: "parent name",
      codeOrigin: "ACAS CmpdReg",
      displayName: "Corporate Parent ID",
      sourceExternal: true
    }, {
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
    }, {
      type: "gene",
      kind: "entrez gene",
      codeOrigin: "ACAS LSThing",
      displayName: "Gene ID",
      sourceExternal: false
    }
  ];

  exports.entityTypesbyDisplayName = {};

  ref = exports.entityTypes;
  for (i = 0, len = ref.length; i < len; i++) {
    entity = ref[i];
    exports.entityTypesbyDisplayName[entity.displayName] = entity;
  }

}).call(this);
