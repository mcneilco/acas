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
        }
      ]
    };
  })((typeof process === "undefined" || !process.versions ? window.genericDataParserConfJSON = window.genericDataParserConfJSON || {} : exports));

}).call(this);
