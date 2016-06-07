// Define the default location of webservices

function getDefaultServicesPrefix() {
	var servername = "";
	var webapp = "/cmpdreg/api/v1/structureServices";
	return servername + webapp;
}

function getDefaultServices() {
	var base = getDefaultServicesPrefix();
	var services = {
			"clean2dws" : base + "/clean",
			"clean3dws" : base + "/clean",
			"molconvertws" : base + "/molconvert",
			"hydrogenizews" : base + "/hydrogenizer"

	};
	
	return services;
	
//			"reactionconvertws" : base + "/rest-v0/util/calculate/reactionExport",	
//			"stereoinfows" : base + "/cipStereoInfo",	
//			"automapperws" : base + "/rest-v0/util/convert/reactionConverter"	
//	"molconvertws" : "http://localhost:8080/cmpdreg/api/v1/structureServices/molconvert",

}