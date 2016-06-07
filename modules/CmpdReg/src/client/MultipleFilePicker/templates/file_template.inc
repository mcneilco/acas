<script type="text/template" id="file-template">
    <span class="name"><%= name %></span>
    <span class="size"><%= size %> bytes</span>
    <input type="button" class="delete" value="remove">
    <span class="<%= uploaded ? '' : 'not' %>uploaded"><%= uploaded ? '' : 'not ' %>uploaded</span>
</script>