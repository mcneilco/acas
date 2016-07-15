<script type="text/template" id="file-template-desc">
        <td class="name"><%= name %></td>
        <td class="size"><%= size %> bytes</td>
        <td><select class="description" ></select></td>
        <td class="<%= uploaded ? '' : 'not' %>uploaded"><%= uploaded ? '' : 'not ' %>uploaded</td>
        <td><input type="button" class="delete" value="remove"></td>
</script>