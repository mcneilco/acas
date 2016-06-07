<!DOCTYPE html>
<html>
<head>
    <title>Test Drag and Drop</title>
    
    <link rel="stylesheet" type="text/css" href="css/style.css"/>
    
    <script type="text/javascript" src="javascript/lib/json2.js"></script>
    <script type="text/javascript" src="javascript/lib/jquery-1.6.2.js"></script>
    <script type="text/javascript" src="javascript/lib/jquery.form.js"></script>
    <script type="text/javascript" src="javascript/lib/underscore-1.1.6.js"></script>
    <script type="text/javascript" src="javascript/lib/backbone.js"></script>
    <script type="text/javascript" src="javascript/lib/backbone-localstorage.js"></script>
    <script type="text/javascript" src="javascript/src/file.js"></script>
    <script type="text/javascript" src="javascript/src/file_renderer.js"></script>
    <script type="text/javascript" src="../src/PickList.js"></script>
    <script type="text/javascript">
        
        $(function() {
            window.configuration =     {serverConnection: {
                connectToServer: false
            }};
 
            var fileList = new BackboneFileList();

/*
            var fileList = new BackboneFileList([
                new BackboneFileDesc({
                    name: 'file1',
                    content: 'this is file 1',
                    size: 1,
                    type: 'text/plain',
                    description: "LCMS",
                    uploaded: true,
                    url: 'url1'
                }),
                new BackboneFileDesc({
                    name: 'file2',
                    content: 'this is file 2',
                    size: 2,
                    type: 'text/plain',
                    description: "HPLC",
                    uploaded: true,
                    url: 'url2'
                })
            ]);
*/

            
            var app = new UploadAppView({
                fileList: fileList,
                descriptions: false,
                compatibilityMode: false,
                target: 'file_upload.php',
                serverDestDir: '',
                closeOnUpload: false,
                showButtons: false  // The wrapper application may want to provide its own buttons
//                validMimeTypes: ['text/plain']
            });
            
            //var render = new FileRenderer(fileList);
            //app.hide();
            $('body .dropControllerContainer').append(app.el);
            //$('body').append(render.el);
            
            if ($.browser.msie) {
                $('body').prepend('<h1>IE fall back, no drag and drop</h1>');
            } else {
                $('body').prepend('<h1>Drag and Drop Application Demo</h1>');
            }
            
            $btn = $('<input type="button" value="Upload File"/>')
            $('body').append($btn);
            $btn.click(function () {
                app.upload();
            });
        });
    </script>
</head>
<body>
	<div>Some app header stuff</div>
	<div class="dropControllerContainer"></div>
	<div>Some other app stuff</div>
    <?php
    include 'templates/file_template.inc';
    include 'templates/file_template_desc.inc';
    include 'templates/file_template_renderer.inc';
    include 'templates/DropView.inc';
    ?>
</body>
</html>