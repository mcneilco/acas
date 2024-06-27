$(function() {
    window.MaestroJSUtil = {
        "getSketcher": function getSketcher(el) {
            function waitForReady(resolve, reject) {
                var maestro = $(el)?.[0]?.contentWindow?.qtLoader?.module;
                const sketcherImportText = maestro?.sketcher_import_text || maestro?.sketcherImportText;
                if (!sketcherImportText) {
                    setTimeout(() => waitForReady(resolve, reject), 1000);
                } else {
                    resolve(maestro);
                }
            }
            return new Promise(waitForReady);
        }
    };
});