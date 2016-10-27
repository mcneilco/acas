(function() {
  (function(exports) {
    exports.project = {
      "codeName": "PROJ-00000001",
      "deleted": false,
      "firstLsThings": [],
      "id": 1,
      "ignored": false,
      "lsKind": "project",
      "lsLabels": [
        {
          "deleted": false,
          "id": 1,
          "ignored": false,
          "labelText": "Test Project 1",
          "lsKind": "project name",
          "lsTransaction": 1,
          "lsType": "name",
          "lsTypeAndKind": "name_project name",
          "physicallyLabled": false,
          "preferred": true,
          "recordedBy": "bob",
          "recordedDate": 1462553966814,
          "version": 0
        }, {
          "deleted": false,
          "id": 2,
          "ignored": false,
          "labelText": "Project 1",
          "lsKind": "project alias",
          "lsTransaction": 1,
          "lsType": "name",
          "lsTypeAndKind": "name_project alias",
          "physicallyLabled": false,
          "preferred": false,
          "recordedBy": "bob",
          "recordedDate": 1462553966815,
          "version": 0
        }
      ],
      "lsStates": [
        {
          "deleted": false,
          "id": 1,
          "ignored": false,
          "lsKind": "project metadata",
          "lsTransaction": 1,
          "lsType": "metadata",
          "lsTypeAndKind": "metadata_project metadata",
          "lsValues": [
            {
              "codeTypeAndKind": "null_null",
              "codeValue": "bob",
              "deleted": false,
              "id": 1,
              "ignored": false,
              "lsKind": "project leader",
              "lsTransaction": 1,
              "lsType": "codeValue",
              "lsTypeAndKind": "codeValue_project leader",
              "operatorTypeAndKind": "null_null",
              "publicData": false,
              "recordedBy": "bob",
              "recordedDate": 1462553966826,
              "unitTypeAndKind": "null_null",
              "version": 0
            }, {
              "codeTypeAndKind": "null_null",
              "deleted": false,
              "id": 5,
              "ignored": false,
              "lsKind": "short description",
              "lsTransaction": 1,
              "lsType": "stringValue",
              "lsTypeAndKind": "stringValue_short description",
              "operatorTypeAndKind": "null_null",
              "publicData": false,
              "recordedBy": "bob",
              "recordedDate": 1462553966821,
              "stringValue": "Example short description",
              "unitTypeAndKind": "null_null",
              "version": 0
            }, {
              "clobValue": "Example project details",
              "codeTypeAndKind": "null_null",
              "deleted": false,
              "id": 3,
              "ignored": false,
              "lsKind": "project details",
              "lsTransaction": 1,
              "lsType": "clobValue",
              "lsTypeAndKind": "clobValue_project details",
              "operatorTypeAndKind": "null_null",
              "publicData": false,
              "recordedBy": "bob",
              "recordedDate": 1462553966823,
              "unitTypeAndKind": "null_null",
              "version": 0
            }, {
              "codeTypeAndKind": "null_null",
              "dateValue": 1462518000000,
              "deleted": false,
              "id": 6,
              "ignored": false,
              "lsKind": "start date",
              "lsTransaction": 1,
              "lsType": "dateValue",
              "lsTypeAndKind": "dateValue_start date",
              "operatorTypeAndKind": "null_null",
              "publicData": false,
              "recordedBy": "bob",
              "recordedDate": 1462553966818,
              "unitTypeAndKind": "null_null",
              "version": 0
            }, {
              "codeKind": "restricted",
              "codeOrigin": "ACAS DDICT",
              "codeType": "project",
              "codeTypeAndKind": "project_restricted",
              "codeValue": "true",
              "deleted": false,
              "id": 2,
              "ignored": false,
              "lsKind": "is restricted",
              "lsTransaction": 1,
              "lsType": "codeValue",
              "lsTypeAndKind": "codeValue_is restricted",
              "operatorTypeAndKind": "null_null",
              "publicData": false,
              "recordedBy": "bob",
              "recordedDate": 1462553966824,
              "unitTypeAndKind": "null_null",
              "version": 0
            }, {
              "codeKind": "status",
              "codeOrigin": "ACAS DDICT",
              "codeType": "project",
              "codeTypeAndKind": "project_status",
              "codeValue": "active",
              "deleted": false,
              "id": 4,
              "ignored": false,
              "lsKind": "project status",
              "lsTransaction": 1,
              "lsType": "codeValue",
              "lsTypeAndKind": "codeValue_project status",
              "operatorTypeAndKind": "null_null",
              "publicData": false,
              "recordedBy": "bob",
              "recordedDate": 1462553966819,
              "unitTypeAndKind": "null_null",
              "version": 0
            }
          ],
          "recordedBy": "bob",
          "recordedDate": 1462553966816,
          "version": 0
        }
      ],
      "lsTags": [],
      "lsTransaction": 1,
      "lsType": "project",
      "lsTypeAndKind": "project_project",
      "recordedBy": "bob",
      "recordedDate": 1462553966814,
      "secondLsThings": [],
      "version": 0
    };
    exports.projectUsers = [
      {
        code: "bob",
        name: "Bob Roberts"
      }, {
        code: "jane",
        name: "Jane Doe"
      }
    ];
    return exports.projectAdmins = [
      {
        code: "bob",
        name: "Bob Roberts"
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.projectTestJSON = window.projectTestJSON || {} : exports));

}).call(this);
