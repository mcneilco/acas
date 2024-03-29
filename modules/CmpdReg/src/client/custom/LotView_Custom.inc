<script type="text/template" id="LotForm_LotView_Labsynch_template">

	<div><h2>Lot Properties:</h2></div>
	<div class="LotForm_LotViewChem">
		<div>
			<div>
				<label class="FormLabel">*Chemist:</label>
				<select class="FormInput chemist" ></select>
			</div>
			<div>
				<label class="FormLabel"><span class="notForVirtual">*</span>Notebook-Page:</label>
				<input type="textfield" class="FormInput notebookPage" value="<%- notebookPage %>" />
			</div>
		</div>
		
		<div class="notForVirtual1 notForVirtual">
			<div>
				<label class="FormLabel">Lot Mol. Wt.:</label>
				<input type="textfield" class="FormInput lotMolWeight" disabled=true value="<%- lotMolWeight %>" />
			</div>
			<div>
				<label class="FormLabel">Physical state:</label>
				<select class="FormInput physicalStateCode"></select><br />
			</div>
			<div>
				<label class="FormLabel">Lot comments:</label>
				<input type="textarea" class="FormInput comments" value="<%- comments %>" />
			</div>
			<div>
				<label class="FormLabel">Supplier:</label>
				<input type="textfield" class="FormInput supplier" value="<%- supplier %>" /><br />
			</div>
			<div>
				<label class="FormLabel">Supplier compound ID:</label>
				<input type="textfield" class="FormInput supplierID" value="<%- supplierID %>" /><br />
			</div>
			<div>
				<label class="FormLabel">MP:</label>
				<input type="textfield" class="FormInput meltingPoint" value="<%- meltingPoint %>" /><br />
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
			  <label class="FormLabel">Vendor ID:</label>
			  <input type="textfield" class="FormInput vendorID" value="<%- vendorID %>" /><br />
			</div>
			<div>
				<label class="FormLabel">Retain:</label>
				<input type="textfield" class="FormInput retain" value="<%- retain %>" />
				<select class="FormInput retainUnitsCode"></select>
			</div>
		</div>
	</div>
	<div class="LotForm_LotViewSynth">
		<div>
			<div>
				<label class="FormLabel">Lot Number:</label>
				<input type="textfield" class="FormInput lotNumber" <%- (saved | isVirtual | !allowManualLotNumber) ? 'disabled=true': '' %> value="<%- lotNumber %>"/>
				<img class="insertNextAutoLotNumberButton" href="#" title="Fill with next lot number" src="/CmpdReg/client/images/edit.png" <%= (saved | isVirtual | !allowManualLotNumber) ? 'style="display:none;"': 'style="width: 15px;"' %>/>
			</div>
			<div>
				<label class="FormLabel">*Project:</label>
				<select class="FormInput project" ></select>
			</div>
			<div>
				<label class="FormLabel"><span class="notForVirtual">*</span>Synthesis Date:</label>
				<input type="textfield" class="FormInput synthesisDate" value="<%- synthesisDate %>"/>
			</div>
		</div>
		<div class="notForVirtual2 notForVirtual">
			<div>
				<label class="FormLabel">%e.e.:</label>
				<input type="textfield" class="FormInput percentEE" value="<%- percentEE %>" />
			</div>
			<div>
				<label class="FormLabel">Color:</label>
				<input type="textfield" class="FormInput color" value="<%- color %>" />
			</div>
			<div class="amountWrapper">
				<label class="FormLabel">Amount:</label>
				<input type="textfield" class="FormInput amount" value="<%- amount %>" />
				<select class="FormInput amountUnitsCode"></select>
			</div>
			<div class="barcodeWrapper">
				<label class="FormLabel">Barcode:</label>
				<input type="textfield" class="FormInput barcode" value="<%- barcode %>" /><br />
			</div>
			<div>
				<label class="FormLabel">Supplier lot:</label>
				<input type="textfield" class="FormInput supplierLot" value="<%- supplierLot %>" /><br />
			</div>
			<div>
				<label class="FormLabel">BP:</label>
				<input type="textfield" class="FormInput boilingPoint" value="<%- boilingPoint %>" /><br />
			</div>
			<div>
				<label class="FormLabel">Purity (%):</label>
				<select class="FormInput purityOperatorCode"></select>
				<input type="textfield" class="FormInput purity" value="<%- purity %>" />
			</div>
			<div>
				<label class="FormLabel">Solution Amount:</label>
				<input type="textfield" class="FormInput solutionAmount" value="<%- solutionAmount %>" />
				<select class="FormInput solutionAmountUnitsCode"></select>
			</div>

			<div class="bv_tareWeightContainer" >
				<label class="FormLabel">Tare Weight:</label>
				<input type="textfield" class="FormInput tareWeight" value="<%- tareWeight %>" />
				<select class="FormInput tareWeightUnitsCode"></select>
			</div>
			<div class="bv_totalAmountStoredContainer" >
				<label class="FormLabel">Total Amount Stored:</label>
				<input type="textfield" class="FormInput totalAmountStored" value="<%- totalAmountStored %>" />
				<select class="FormInput totalAmountStoredUnitsCode"></select>
			</div>


		</div> 
		<div class="notForVirtual3 notForVirtual" >
			<label class="FormLabel">Analytical Files:</label>
			<div class="analyticalFiles"></div>
			<a class="editAnalyticalFiles" href="#" onclick="this.blur(); return false;" ><span></span></a>
		</div>		  
	</div>

</script>
