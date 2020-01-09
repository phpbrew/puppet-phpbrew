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
  $php_install_dir = '/opt/phpbrew'
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
        ]

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
    creates     => '~/.phpbrew/bashrc',
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
  file { '~/.phpbrew/init':
    content => "export PHPBREW_ROOT=${php_install_dir}",
    require => Exec['init phpbrew']
  }->
  file_line { 'Append a line to ~/.phpbrew/init':
    path => '~/.phpbrew/init',
    line => 'export PHPBREW_HOME=${php_install_dir}',
  }

  file { "/etc/profile.d/phpbrew.sh":
    ensure  => present,
    content => template('phpbrew/phpbrew.sh.erb'),
    mode    => 'a+x',
    require => Exec['init phpbrew']
  }
  
  # Load phpbrew configuration by default.
  file_line { 'add phpbrew to bashrc':
    path    => '~/.bashrc',
    line    => 'source ~/.phpbrew/bashrc',
    require => Exec['init phpbrew'],
  }

  
  exec { 'update basbrc':
    command => '/bin/bash'
  }

  file { '~/.phpbrew/install_extension.sh':
    ensure  => present,
    mode    => 'a+x',
    source  => 'puppet:///modules/phpbrew/install_extension.sh',
    require => Exec['init phpbrew']
  }
}
