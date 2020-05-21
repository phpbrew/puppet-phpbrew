# Class: phpbrew
#
# This module manages the installing of phpbrew.
#
# Parameters:
#
# Actions:
#
# Requires:
#   puppetlabs/stdlib
# Sample Usage:
#  class { 'phpbrew': }
#
class phpbrew (
  String $php_install_dir = '/opt/phpbrew',
  Boolean $system_wide = false,
  Array $additional_dependencies = []
) {
  case $::operatingsystem {
    centos: {
      if $::operatingsystemmajrelease == '7' {
        $dependencies = [
          'curl',
          'libxslt-devel',
          're2c',
          'libxml2-devel',
          'php-cli',
          'libmcrypt-devel',
          'php-devel',
          'openssl-devel',
          'bzip2-devel',
          'libicu-devel',
          'readline-devel'
        ] + $additional_dependencies

        exec { 'Installing Development Tools package group':
          command => '/usr/bin/yum -y groupinstall Development Tools'
        }

        each($dependencies) |$dependency| {
          if ! defined(Package[$dependency]) {
            package { $dependency:
              ensure => 'installed',
              before => Exec['download phpbrew'],
            }
          }
        }
      } else {
        fail("CentOS support only tested on major version 7, you are running version '${::operatingsystemmajrelease}'")
      }
    }
    debian, ubuntu: {
      exec { '/usr/bin/apt-get -y update': }

      $dependencies = [
        'autoconf',
        'automake',
        'curl',
        'build-essential',
        'libxslt1-dev',
        're2c',
        'libxml2-dev',
        'php5-cli',
        'libmcrypt-dev',
        'php5-dev'
      ]

      each($dependencies) |$dependency| {
        if ! defined(Package[$dependency]) {
          package { $dependency:
            ensure  => 'installed',
            require => Exec['/usr/bin/apt-get -y update'],
            before  => Exec['download phpbrew'],
          }
        }
      }

      exec { '/usr/bin/apt-get -y build-dep php5':
        require => Exec['/usr/bin/apt-get -y update'],
        before  => Exec['download phpbrew'],
      }
    }
    redhat: {
      fail('RedHat is not supported yet')
    }
    default: {
      fail('Unrecognized operating system for phpbrew')
    }
  }

  exec { 'download phpbrew':
    command => '/usr/bin/wget -P /tmp https://raw.github.com/c9s/phpbrew/master/phpbrew',
    creates => '/tmp/phpbrew',
  }

  file { '/usr/bin/phpbrew':
    source  => '/tmp/phpbrew',
    mode    => 'a+x',
    require => Exec['download phpbrew'],
  }

  exec { 'init phpbrew':
    command     => '/usr/bin/sudo /usr/bin/phpbrew init',
    creates     => '/root/.phpbrew/bashrc',
    subscribe   => File['/usr/bin/phpbrew'],
    refreshonly => true,
  }
  
  file { $php_install_dir:
    ensure  => 'directory',
    require => Exec['init phpbrew'],
  }

  file { '/usr/lib/cgi-bin':
    ensure  => 'directory',
    require => Exec['init phpbrew'],
  }

  # Specify where versions of PHP will be installed.
  file { '/root/.phpbrew/init':
    content => "export PHPBREW_ROOT=${php_install_dir}",
    require => Exec['init phpbrew']
  }
  
  # Load phpbrew configuration by default.
  if $system_wide {
    ###################################################################
    # Init as vagrant user to use when need to switch php 
    # and use it from vagrant console for example for composer command
    ###################################################################
    exec { 'init phpbrew as vagrant':
      command     => '/usr/bin/phpbrew init',
      creates     => '/home/vagrant/.phpbrew/bashrc',
      subscribe   => File['/usr/bin/phpbrew'],
      refreshonly => true,
      user        => "vagrant",
      environment => ["HOME=/home/vagrant"],
    }
    
    file { '/opt/phpbrew/bashrc':
      ensure  => present,
      content => template('phpbrew/bashrc.erb'),
      require => Exec['init phpbrew']
    }
    
    file { "/etc/profile.d/phpbrew.sh":
      ensure  => present,
      content => template('phpbrew/phpbrew.sh.erb'),
      require => Exec['init phpbrew']
    }
  } else {
    file_line { 'add phpbrew to bashrc':
      path    => '/root/.bashrc',
      line    => 'source /root/.phpbrew/bashrc',
      require => Exec['init phpbrew'],
    }
  }

  exec { 'update basbrc':
    command => '/bin/bash'
  }

  file { '/root/.phpbrew/install_extension.sh':
    ensure  => present,
    mode    => 'a+x',
    source  => 'puppet:///modules/phpbrew/install_extension.sh',
    require => Exec['init phpbrew']
  }
}
