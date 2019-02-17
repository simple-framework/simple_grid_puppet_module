Puppet::Functions.create_function(:'simple_grid::check_presence_host_certificates') do
    dispatch :check_presence_host_certificates do
        param 'String', :host_certificates_dir
        param 'String', :fqdn 
    end
    def check_presence_host_certificates(host_certificates_dir, fqdn)
        directory = "#{host_certificates_dir}/#{fqdn}"
        File.directory?(directory)
    end
end
