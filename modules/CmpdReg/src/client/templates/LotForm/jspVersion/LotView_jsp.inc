<script type="text/template" id="LotForm_LotView_template">

    <div><h2>Properties:</h2></div>
	<div class="LotForm_LotViewChem">
		<div>
			<div>
				<label class="FormLabel">Chemist:</label>
				<select class="FormInput chemist" <%= saved ? 'disabled=true': '' %> ></select>
			</div>
			<div>
				<label class="FormLabel">*Notebook-Page:</label>
				<input type="textfield" class="FormInput notebookPage" <%= saved ? 'disabled=true': '' %> value="<%= notebookPage %>" />
			</div>
		</div>
		
		<div class="notForVirtual1">
			<div>
				<label class="FormLabel">Lot Mol. Wt.:</label>
				<input type="textfield" class="FormInput lotMolWeight" disabled=true value="<%= lotMolWeight %>" />
			</div>
			<div>
				<label class="FormLabel">Physical state:</label>
				<select class="FormInput physicalStateCode"></select><br />
			</div>
			<div>
				<label class="FormLabel">Supplier:</label>
				<input type="textfield" class="FormInput supplier" value="<%= supplier %>" /><br />
			</div>
			<div>
				<label class="FormLabel">Supplier compound ID:</label>
				<input type="textfield" class="FormInput supplierID" value="<%= supplierID %>" /><br />
			</div>
			<div>
				<label class="FormLabel">%e.e.:</label>
				<input type="textfield" class="FormInput percentEE" value="<%= percentEE %>" />
			</div>
			<div>
				<label class="FormLabel">Lot comments:</label>
				<input type="textarea" class="FormInput comments" value="<%= comments %>" />
			</div>
		</div>
	</div>
	<div class="LotForm_LotViewSynth">
        <div>
			<div>
				<label class="FormLabel">*Synthesis Date:</label>
				<input type="textfield" class="FormInput synthesisDate" <%= saved ? 'disabled=true': '' %> value="<%= synthesisDate %>"/>
        	</div>
		</div>
        <div class="notForVirtual2">
            <div>
                <label class="FormLabel">Color:</label>
                <input type="textfield" class="FormInput color" value="<%= color %>" />
            </div>
            <div>
                <label class="FormLabel">Amount:</label>
                <input type="textfield" class="FormInput amount" value="<%= amount %>" />
                <select class="FormInput amountUnitsCode"></select>
            </div>
            <div>
                <label class="FormLabel">Retain:</label>
                <input type="textfield" class="FormInput retain" value="<%= retain %>" />
                <select class="FormInput retainUnitsCode"></select>
            </div>
            <div>
                <label class="FormLabel">Purity measured by:</label>
                <select class="FormInput purityMeasuredByCode"></select>
            </div>
            <div>
                <label class="FormLabel">Purity (%):</label>
                <select class="FormInput purityOperatorCode"></select>
                <input type="textfield" class="FormInput purity" value="<%= purity %>" />
            </div>
        </div> 
		<div class="notForVirtual3" >
			<label class="FormLabel">Analytical Files:</label>
			<div class="analyticalFiles"></div>
			<a class="editAnalyticalFiles" href="#" onclick="this.blur(); return false;" ><span></span></a>
		</div>          
    </div>

</script>
