Puppet::Functions.create_function(:'simple_grid::docker_run') do
    dispatch :docker_run do
        param 'Hash', :augmented_site_level_config
        param 'Hash', :current_lightweight_component
        param 'Hash', :meta_info
        param 'String', :config_dir
    end
    def docker_run(augmented_site_level_config, current_lightweight_component, meta_info, config_dir)
        docker_run_parameters = meta_info['docker_run_parameters']
        
        #name
        ############### 
        # Volume Mounts
        ###############
        
        # Config Dir
        docker_run = "docker run" << " "
        docker_run << "-v #{config_dir}:/config" << " "
        
        #CVMFS
        if meta_info.key?("host_requirements") and meta_info['host_requirements'].key?("cvmfs") and meta_info['host_requirements']['cvmfs'] == true
            docker_run << "--mount type=bind,source=/cvmfs,target=/cvmfs,bind-propogation=shared" << " "
        end

        ##############
        # Network
        ##############
        
        docker_run
        
    end
end