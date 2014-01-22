# Definition: phpbrew::install
#
# This class installs the given PHP version
#
# Parameters:
# - The $version to install
#
# Actions:
# - Install the given PHP version
#
# Requires:
# - The phpbrew class
#
# Sample Usage:
#  phpbrew::install { '5.3.3': }
#
define phpbrew::install(
  $version = '',
  $build_prameters = undef,
  $php_inis = undef,
  $install_dir = '/opt/phpbrew',
) {
  require phpbrew

  if $version == '' {
    $php_version = $title
  } else {
    $php_version = $version
  }

  if $build_prameters {
    $extra_params = $build_prameters
  } elsif versioncmp($php_version, '5.3') < 0 {
    $extra_params = ''
  } else {
    $extra_params = ''
  }

  exec { "install php-${php_version}":
    command     => "sudo PHPBREW_ROOT=${install_dir} /usr/bin/phpbrew install --old php-${php_version} +default +intl +cgi ${extra_params}",
    creates     => "${install_dir}/php/php-${php_version}/bin/php",
    timeout     => 0,
  }

  file { "/usr/lib/cgi-bin/fcgiwrapper-${php_version}.sh":
    ensure => present,
    content => template("phpbrew/fcgiwrapper.sh.erb"),
    mode    => 'a+x',
    require => Exec["install php-${php_version}"]
  }

  file { "${install_dir}/php/php-${php_version}/lib/php/share":
    ensure  => "directory",
    require => Exec["install php-${php_version}"]
  }

  if $php_inis != undef {
    file { [
      "${install_dir}/php/php-${php_version}/var",
      "${install_dir}/php/php-${php_version}/var/db"
    ]:
      ensure  => "directory",
      require => Exec["install php-${php_version}"]
    }

    each($php_inis) |$php_ini| {
      $short_php_ini = regsubst($php_ini, '^.*\/([^\/]*\.ini)$', '\1')

      file { "${install_dir}/php/php-${php_version}/var/db/${short_php_ini}":
        source  => $php_ini,
        require => File["${install_dir}/php/php-${php_version}/var/db"]
      }
    }
  }

}
