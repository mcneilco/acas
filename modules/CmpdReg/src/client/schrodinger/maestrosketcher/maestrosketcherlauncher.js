$(function() {

	window.MaestroJSUtil = {
        // See implementation of "setRepresentation" in src/components/Sketcher/index.tsx of the rc-maestro-sketcher repository as a reference
		"getSketcher": function getSketcher (el) {
            function waitForReady (resolve, reject) {
                var _a;
                maestro = $(el)[0].contentWindow.Module;
                const sketcherImportText = (_a = this.maestro) === null || _a === void 0 ? void 0 : _a.sketcher_import_text;
                // Wait until sketcher is initialized
                if (!sketcherImportText) {
                    self = this;
                    setTimeout(function() {waitForReady(resolve, reject)}, 1000);
                }
                else {
                    resolve(maestro)
                }
            }
			
			return new Promise(waitForReady);				
		}
	};
});