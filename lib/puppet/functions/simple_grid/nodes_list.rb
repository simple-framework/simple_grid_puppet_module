 Puppet::Functions.create_function(:'simple_grid::nodes_list') do
         dispatch :nodes_list do
         end
         def nodes_list()
                nodes_list_as_string = open("/etc/simple_grid/nodes.list").read
                nodes_array = nodes_list_as_string.split("\n")
         end
end
