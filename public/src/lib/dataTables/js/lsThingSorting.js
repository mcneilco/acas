jQuery.extend( jQuery.fn.dataTableExt.oSort, {

// Custom sorting for Simple SAR
// lsThing1
// All values prefaced with a "<" sign are sorted as smallest
// All values prefaced with a ">" sign are sorted as largest
// NA always sorts to the bottom
// e.g. [1, "<2", 0.5]  ----> ["<2", 0.5, 1]
// Also handles scientific notation

    "includeOperators-pre": function ( a ) {
        var operator = a[0];

        while (operator == "*"){
            a = a.slice(1);
            operator = a[0];
        }
        if (operator == ">" || operator == "<") {
            return operator + parseFloat(a.slice(1) );
        }
        //console.log(parseFloat( a ) || a.toLowerCase());
        console.log(a);
        //console.log(parseFloat( a ));
        //console.log(a.toLowerCase());
        if(isNaN(parseFloat(a))) {
            console.log("return lowercase - nan")
            return a.toLowerCase();
        }
        else {
            console.log("return parseFloat");
            return (parseFloat( a ));
        }
        //return (parseFloat( a ) || a.toLowerCase());
    },

    "includeOperators-asc": function ( a, b ) {
        if (a == "na"){
            return 1;
        }
        if (b == "na"){
            return -1;
        }
        if (typeof(a) === "string" && typeof(b) == "string"){
            if (typeof(parseFloat(a.slice(1))||"") == "string" && typeof(parseFloat(b.slice(1))||"") == "string"){
                return ((a < b) ? -1 : ((a > b) ? 1 : 0));
            }
        }
        if (typeof(a) === "string"){
            if (typeof(parseFloat(a.slice(1))||"") == "string"){
                return 1;
            }
        }
        if (typeof(b) === "string"){
            if (typeof(parseFloat(b.slice(1))||"") == "string"){
                return -1;
            }
        }
        if (a[0] == "<"){
            if (b[0] == "<"){
                return ((parseFloat(a.slice(1)) > parseFloat(b.slice(1))) ? -1 : ((parseFloat(a.slice(1)) < parseFloat(b.slice(1))) ? 1 : 0));
            }else{return -1;}
        }if (a[0] == ">"){
            if (b[0] == ">"){
                return ((parseFloat(a.slice(1)) < parseFloat(b.slice(1))) ? -1 : ((parseFloat(a.slice(1)) > parseFloat(b.slice(1))) ? 1 : 0));
            }else{return 1;}
        }else {
            if (b[0] == "<") {
                return 1;
            }
            if (b[0] == ">") {
                return -1;
            }
        }
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "includeOperators-desc": function ( a, b ) {
        if (a == "na"){
            return 1;
        }
        if (b == "na"){
            return -1;
        }
        if (typeof(a) === "string" && typeof(b) == "string"){
            if (typeof(parseFloat(a.slice(1))||"") == "string" && typeof(parseFloat(b.slice(1))||"") == "string"){
                return ((a < b) ? 1 : ((a > b) ? -1 : 0));
            }
        }
        if (typeof(a) === "string"){
            if (typeof(parseFloat(a.slice(1))||"") == "string"){
                return 1;
            }
        }
        if (typeof(b) === "string"){
            if (typeof(parseFloat(b.slice(1))||"") == "string"){
                return -1;
            }
        }
        if (a[0] == "<"){
            if (b[0] == "<"){
                return ((parseFloat(a.slice(1)) > parseFloat(b.slice(1))) ? 1 : ((parseFloat(a.slice(1)) < parseFloat(b.slice(1))) ? -1 : 0));
            }else{return 1;}
        }if (a[0] == ">"){
            if (b[0] == ">"){
                return ((parseFloat(a.slice(1)) < parseFloat(b.slice(1))) ? 1 : ((parseFloat(a.slice(1)) > parseFloat(b.slice(1))) ? -1 : 0));
            }else{return -1;}
        }else {
            if (b[0] == "<") {
                return -1;
            }
            if (b[0] == ">") {
                return 1;
            }
        }
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    },

    //lsThing2 -- ignores < and > and sorts them as though they were simply the value
    // e.g. [1, "<2", 0.5] ----> [0.5, 1, <2]

    "ignoreOperators-pre": function ( a ) {
        var operator = a[0];

        while (operator == "*"){
            a = a.slice(1);
            operator = a[0];
        }
        if (operator == ">" || operator == "<") {
            return parseFloat(a.slice(1));
        }
        return (parseFloat( a ) || a.toLowerCase());

    },

    "ignoreOperators-asc": function ( a, b ) {
        if (a == "na"){
            return 1;
        }
        if (b == "na"){
            return -1;
        }
        if (typeof(a) == "string" && typeof(b) == "string"){
            return ((a < b) ? -1 : ((a > b) ? 1 : 0));
        }
        if (typeof(a) === "string"){
            return 1;
        }
        if (typeof(b) === "string"){
            return -1;
        }
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "ignoreOperators-desc": function ( a, b ) {
        if (a == "na"){
            return 1;
        }
        if (b == "na"){
            return -1;
        }
        if (typeof(a) == "string" && typeof(b) == "string"){
            return ((a < b) ? 1 : ((a > b) ? -1 : 0));
        }
        if (typeof(a) === "string"){
            return 1;
        }
        if (typeof(b) === "string"){
            return -1;
        }
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }

} );
