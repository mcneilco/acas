(function() {
  (function(exports) {
    return exports.typeKindList = {
      valuetypes: [
        {
          typeName: "dateValue"
        }, {
          typeName: "codeValue"
        }, {
          typeName: "stringValue"
        }, {
          typeName: "clobValue"
        }, {
          typeName: "fileValue"
        }, {
          typeName: "urlValue"
        }, {
          typeName: "blobValue"
        }, {
          typeName: "inlineFileValue"
        }, {
          typeName: "numericValue"
        }
      ],
      valuekinds: [
        {
          kindName: "efficacy",
          typeName: "numericValue"
        }, {
          kindName: "flag file",
          typeName: "fileValue"
        }, {
          kindName: "dryrun flag file",
          typeName: "fileValue"
        }
      ]
    };
  })((typeof process === "undefined" || !process.versions ? window.genericDataParserConfJSON = window.genericDataParserConfJSON || {} : exports));

}).call(this);
