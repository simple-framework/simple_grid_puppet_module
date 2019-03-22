Puppet::Functions.create_function(:'simple_grid::get_scripts') do
    dispatch :get_scripts do
        param 'Hash', :scripts_directory_structure
        param 'Integer', :execution_id
        param 'String', :hook
    end
    def get_scripts(scripts_directory_structure,execution_id,hook)
        return scripts_directory_structure[execution_id][hook]
    end
end