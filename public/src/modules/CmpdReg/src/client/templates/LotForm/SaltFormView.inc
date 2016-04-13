<script type="text/template" id="LotForm_SaltFormView_template">

    <div class="EnterIsoHeader"><h2>
        <span class="showSaltFormMarvinControl">
            <input type="checkbox" class="showSaltFormMarvin"/>
            Enter 
        </span>
        Isotope/salt Structure:
    </h2></div>
	<div class="structureWrapper">
		<iframe src="/src/modules/CmpdReg/src/marvinjs/editorws.html" id="saltFormMarvinSketch" class="sketcher-frame"></iframe>
		<div class="saltFormImage"></div>
	</div>
	<div class="radioWrapper">
		<input type="radio" name="regPick" class="regPick" ><label>New lot of <span class="corpName"></span></label>
	</div>
        

	<div class="rightPane">
		<div class="casNumberDiv">
			<label class="FormLabel">CAS number:</label>
			<input type="textfield" class="casNumber"></input>
		</div>
        <div class="addIsosaltButtons">
            <a class="button addSaltButton" href="#" onclick="this.blur(); return false;"></a>
            <a class="button addIsotopeButton" href="#" onclick="this.blur(); return false;"></a>
        </div>
	</div>
	
	<div class="isosaltEquivListView"></div>
	
    <div class="floatingPanel newSaltView"></div>
    <div class="floatingPanel newIsotopeView"></div>

</script>
