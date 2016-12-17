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
  case $operatingsystem {
    centos, redhat: {
      fail('CentOS or RedHat are not supported yet')
    }
    debian, ubuntu: {
      exec { '/usr/bin/apt-get -y update': }

      $dependencies = [ 'autoconf', 'automake', 'curl', 'build-essential', 'libxslt1-dev', 're2c', 'libxml2-dev', 'php5-cli', 'libmcrypt-dev', 'php5-dev' ]

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

  # Specify where versions of PHP will be installed.
  file { '/root/.phpbrew/init':
    content => "export PHPBREW_ROOT=${php_install_dir}",
    require => Exec['init phpbrew']
  }

  # Load phpbrew configuration by default.
  file_line { 'add phpbrew to bashrc':
    path    => '/root/.bashrc',
    line    => 'source /root/.phpbrew/bashrc',
    require => Exec['init phpbrew'],
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
