
$.extend( DataTable.ext.oSort, {
	/*
	 * text sorting
	 */
	"string-pre": function ( a )
	{
		if ( typeof a != 'string' ) {
			a = (a !== null && a.toString) ? a.toString() : '';
		}
		return a.toLowerCase();
	},

	"string-asc": function ( x, y )
	{
		return ((x < y) ? -1 : ((x > y) ? 1 : 0));
	},
	
	"string-desc": function ( x, y )
	{
		return ((x < y) ? 1 : ((x > y) ? -1 : 0));
	},
	
	
	/*
	 * html sorting (ignore html tags)
	 */
	"html-pre": function ( a )
	{
		return a.replace( /<.*?>/g, "" ).toLowerCase();
	},
	
	"html-asc": function ( x, y )
	{
		return ((x < y) ? -1 : ((x > y) ? 1 : 0));
	},
	
	"html-desc": function ( x, y )
	{
		return ((x < y) ? 1 : ((x > y) ? -1 : 0));
	},
	
	
	/*
	 * date sorting
	 */
	"date-pre": function ( a )
	{
		var x = Date.parse( a );
		
		if ( isNaN(x) || x==="" )
		{
			x = Date.parse( "01/01/1970 00:00:00" );
		}
		return x;
	},

	"date-asc": function ( x, y )
	{
		return x - y;
	},
	
	"date-desc": function ( x, y )
	{
		return y - x;
	},
	
	
	/*
	 * numerical sorting
	 */
	"numeric-pre": function ( a )
	{
		return (a=="-" || a==="") ? 0 : a*1;
	},

	"numeric-asc": function ( x, y )
	{
		return x - y;
	},
	
	"numeric-desc": function ( x, y )
	{
		return y - x;
	}
} );


$.extend( DataTable.ext.oSort, {

/*  Sorting for common data returned by ACAS
 *  All values prefaced with a "<" sign are sorted as smallest
 *  All values prefaced with a ">" sign are sorted as largest
 * Also handles scientific notation
 */

	"acas-pre": function ( a ) {
		var operator =a[0];
		if (operator == ">" || operator == "<") {
			return operator + parseFloat(a.slice(1) );
		}
		return (parseFloat( a ) || a);
	},

	"acas-asc": function ( a, b ) {
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

	"acas-desc": function ( a, b ) {
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
