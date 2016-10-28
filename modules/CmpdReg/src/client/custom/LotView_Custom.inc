<script type="text/template" id="LotForm_LotView_Labsynch_template">

    <div><h2>Lot Properties:</h2></div>
	<div class="LotForm_LotViewChem">
		<div>
			<div>
				<label class="FormLabel">*Chemist:</label>
				<select class="FormInput chemist" <%= saved ? 'disabled=true': '' %> ></select>
			</div>
			<div>
				<label class="FormLabel"><span class="notForVirtual">*</span>Notebook-Page:</label>
				<input type="textfield" class="FormInput notebookPage" <%= saved ? 'disabled=true': '' %> value="<%= notebookPage %>" />
			</div>
		</div>
		
		<div class="notForVirtual1 notForVirtual">
			<div>
				<label class="FormLabel">Lot Mol. Wt.:</label>
				<input type="textfield" class="FormInput lotMolWeight" disabled=true value="<%= lotMolWeight %>" />
			</div>
			<div>
				<label class="FormLabel">Physical state:</label>
				<select class="FormInput physicalStateCode"></select><br />
			</div>
			<div>
				<label class="FormLabel">Lot comments:</label>
				<input type="textarea" class="FormInput comments" value="<%= comments %>" />
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
				<label class="FormLabel">MP:</label>
				<input type="textfield" class="FormInput meltingPoint" value="<%= meltingPoint %>" /><br />
			</div>
            <div>
                <label class="FormLabel">Purity measured by:</label>
                <select class="FormInput purityMeasuredByCode"></select>
            </div>
            <div>
            	<label class="FormLabel">Vendor:</label>
				<select class="FormInput vendorCode"></select><br />
            </div>
            <div>
                <label class="FormLabel">Retain:</label>
                <input type="textfield" class="FormInput retain" value="<%= retain %>" />
                <select class="FormInput retainUnitsCode"></select>
            </div>
		</div>
	</div>
	<div class="LotForm_LotViewSynth">
        <div>
			<div>
				<label class="FormLabel">Lot Number:</label>
				<input type="textfield" class="FormInput lotNumber" disabled=true value="<%= lotNumber %>" />
			</div>
			<div>
				<label class="FormLabel">*Project:</label>
				<select class="FormInput project" ></select>
			</div>
			<div>
				<label class="FormLabel"><span class="notForVirtual">*</span>Synthesis Date:</label>
				<input type="textfield" class="FormInput synthesisDate" <%= saved ? 'disabled=true': '' %> value="<%= synthesisDate %>"/>
        	</div>
		</div>
        <div class="notForVirtual2 notForVirtual">
			<div>
				<label class="FormLabel">%e.e.:</label>
				<input type="textfield" class="FormInput percentEE" value="<%= percentEE %>" />
			</div>
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
				<label class="FormLabel">Supplier lot:</label>
				<input type="textfield" class="FormInput supplierLot" value="<%= supplierLot %>" /><br />
			</div>
			<div>
				<label class="FormLabel">BP:</label>
				<input type="textfield" class="FormInput boilingPoint" value="<%= boilingPoint %>" /><br />
			</div>
            <div>
                <label class="FormLabel">Purity (%):</label>
                <select class="FormInput purityOperatorCode"></select>
                <input type="textfield" class="FormInput purity" value="<%= purity %>" />
            </div>
            <div>
                <label class="FormLabel">Solution Amount:</label>
                <input type="textfield" class="FormInput solutionAmount" value="<%= solutionAmount %>" />
                <select class="FormInput solutionAmountUnitsCode"></select>
            </div>

        </div> 
		<div class="notForVirtual3 notForVirtual" >
			<label class="FormLabel">Analytical Files:</label>
			<div class="analyticalFiles"></div>
			<a class="editAnalyticalFiles" href="#" onclick="this.blur(); return false;" ><span></span></a>
		</div>          
    </div>

</script>
