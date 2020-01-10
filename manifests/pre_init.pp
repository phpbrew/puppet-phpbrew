class phpbrew::pre_init
{
	case $::operatingsystem {
	    centos: {
	    	if $::operatingsystemmajrelease == '7' {
	    		
				
				package { 'libzip':
				    provider    => 'rpm',
				    ensure      => installed,
				    source		=> "http://packages.psychotic.ninja/7/plus/x86_64/RPMS//libzip-0.11.2-6.el7.psychotic.x86_64.rpm"
				}

				package { 'libzip-devel':
				    provider    => 'rpm',
				    ensure      => installed,
				    source		=> "http://packages.psychotic.ninja/7/plus/x86_64/RPMS//libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm"
				}
			} else {
        		fail("CentOS support only tested on major version 7, you are running version '${::operatingsystemmajrelease}'")
      		}
    	}
    }
}
