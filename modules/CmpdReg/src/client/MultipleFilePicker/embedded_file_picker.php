<?php
session_start();

chdir("..");
require_once('initPropel.php');
require_once('Utility.php');
?>

<!DOCTYPE html>
<html>
<head>
    <?php
    require_once('EmbeddedFormSupport.php');
    ?>
    
    <link rel='stylesheet' type='text/css' href='../../skin/mainSectionStyle.css' />
    <link rel='stylesheet' type='text/css' href='../../skin/FormsStyles.css' />
    <link rel="stylesheet" type="text/css" href="css/style.css"/>
    
    <script type="text/javascript" src="javascript/lib/json2.js"></script>
    <script type="text/javascript" src="javascript/lib/jquery-1.6.2.js"></script>
    <script type="text/javascript" src="javascript/lib/jquery.form.js"></script>
    <script type="text/javascript" src="javascript/lib/underscore-1.1.6.js"></script>
    <script type="text/javascript" src="javascript/lib/backbone.js"></script>
    <script type="text/javascript" src="javascript/lib/backbone-localstorage.js"></script>
    <script type="text/javascript" src="javascript/src/file.js"></script>
    <script type="text/javascript">
        $(function() {
            var app = new UploadAppView({
                compatibilityMode: false,
                target: 'file_upload.php'
//                showButtons: false // The wrapper Application may want to provide its own buttons
//                validMimeTypes: ['text/plain']
            });
            $('.embeddedFormWrapper').append(app.el);
            changeFormWindowSize(535, 275);
        });
    </script>
</head>
<body>
    <div class="formWindowHead" >
		<div class="formWindowTitle">Multiple File Picker</div>
		<div class="formWindowHeadTools">
			<input  type="image" onclick="closeForm()" name="cancel" value="cancel" border="0" src="../../skin/icons/window_close.gif" />
		</div>
	</div>

	<div class='embeddedFormWrapper'>
	</div>
    
    <?php
    include 'templates/file_template.inc';
    ?>
</body>
</html>