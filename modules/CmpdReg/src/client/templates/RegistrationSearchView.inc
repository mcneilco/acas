<script type="text/template" id="RegistrationSearch_template">

	<h2 class="form_title">Registration Step 1: Draw Structure</h2>
    
		<div class="marvinWrapper"> <!--dependent? change name...-->
			<iframe src="/src/modules/CmpdReg/src/marvinjs/editorws.html" id="registrationSearchMarvinSketch" class="sketcher-frame"></iframe>
		<div class="corpNameInput">
			<label>Or enter compound ID </label>
			<input type=text class="corpName" />
			</div>
		</div>
		
	<div class="buttons">
		<a class="nextButton" href="#" onclick="this.blur(); return false;"><span></span></a>
		<a class="cancelButton" href="#" onclick="this.blur(); return false;"><span></span></a>
	</div>
	
    <div class="registrationSearchMarvinSize"></div>

</script>