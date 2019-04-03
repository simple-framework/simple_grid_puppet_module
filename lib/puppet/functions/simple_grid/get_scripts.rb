Puppet::Functions.create_function(:'simple_grid::get_scripts') do
    dispatch :get_scripts do
        param 'Hash', :scripts_directory_structure
        param 'Integer', :execution_id
        param 'String', :hook
    end
    def get_scripts(scripts_directory_structure,execution_id,hook)
        scripts = Hash.new
        if scripts_directory_structure.key?(execution_id) and scripts_directory_structure[execution_id].key?(hook)
            scripts = scripts_directory_structure[execution_id][hook]
        end
        return scripts
    end
end