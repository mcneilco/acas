jQuery.extend( jQuery.fn.dataTableExt.oSort, {

// Sorting for common data returned by ACAS
// All values prefaced with a "<" sign are sorted as smallest
// All values prefaced with a ">" sign are sorted as largest
// Also handles scientific notation

    "lsThing-pre": function ( a ) {
        var operator =a[0];

        while (operator == "*"){
            a = a.slice(1);
            operator = a[0];
        }
        if (operator == ">" || operator == "<") {
            return operator + parseFloat(a.slice(1) );
        }
        return (parseFloat( a ) || a.toLowerCase());
    },

    "lsThing-asc": function ( a, b ) {
        if (a[0] == "<"){
            if (b[0] == "<"){
                return ((a.split(1) < b.split(1)) ? -1 : ((a.split(1) > b.split(1)) ? 1 : 0));
            }else{return -1;}
        }if (a[0] == ">"){
            if (b[0] == ">"){
                return ((a.split(1) < b.split(1)) ? -1 : ((a.split(1) > b.split(1)) ? 1 : 0));
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

    "lsThing-desc": function ( a, b ) {
        if (a[0] == "<"){
            if (b[0] == "<"){
                return ((a.split(1) < b.split(1)) ? 1 : ((a.split(1) > b.split(1)) ? -1 : 0));
            }else{return 1;}
        }if (a[0] == ">"){
            if (b[0] == ">"){
                return ((a.split(1) < b.split(1)) ? 1 : ((a.split(1) > b.split(1)) ? -1 : 0));
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
    }
} );
