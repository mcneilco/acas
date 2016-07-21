<script type="text/template" id="AddAliasPanel_template">

    <div class="floatingPanel bv_addAlias ">
        <h2 class="form_title">Add Alias</h2>
        <hr />
        <div class="bv_aliasTableContainer"></div>
        <div class="cancelAddNewAliasOn bv_cancelAddNewAlias"></div>
    </div>


</script>
<script type="text/template" id="AddAliasTable_template">
    <table class="addAliasTable">
        <thead>
            <tr class="header">
                <th>Alias Type</th>
                <th>Alias</th>
                <th>Remove</th>
            </tr>
        </thead>
        <tbody class="bv_aliasTableBody"></tbody>
    </table>
    <div class="addNewAliasOn bv_addNewAlias"></div>
</script>

<script type="text/template" id="AddAliasRow_template">
    <td>
        <select class="bv_aliasTypeContainer"></select>
    </td>
    <td class="addAliasNameTd">
        <input type="text" class="bv_aliasKind addAliasNameInput" value="<%= aliasName %>"/>
    </td>
    <td class="addAliasRemoveTd"><div class="bv_aliasRemove addAliasRemoveLink cancel">remove</div></td>

</script>
<script type="text/template" id="AliasListReadView">
    <div class="bv_aliasListContainer"></div>
</script>

<script type="text/template" id="AliasItemView">
    <span class="bv_aliasName"><%= aliasName %>;</span>
</script>

<script type="text/template" id="Aliases_template">
    <label class="FormLabel2">Aliases:</label>
    <span class="bv_aliasReadViewContainer"></span>
    <span class="bv_editAliases ">
        <img src="/CmpdReg/client/images/edit.png" class="editAliasesButton"/>
    </span>
    <div class="bv_addAliasContainer"></div>

</script>
