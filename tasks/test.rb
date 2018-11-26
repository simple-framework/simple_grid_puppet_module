#!/opt/puppetlabs/puppet/bin/ruby
 
#lines = File.readlines('/tmp/188.184.29.186.txt')
lines = IO.readlines("/tmp/188.184.29.186.txt")[2]
 puts lines
