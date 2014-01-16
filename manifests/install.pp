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
  $default_path = '/opt/phpbrew'
) {
  require phpbrew

  if $version == '' {
    $php_version = $title
  } else {
    $php_version = $version
  }

  if versioncmp($php_version, '5.3') < 0 {
    $extra_params  = ''
  } else {
    $extra_params  = ''
  }

  exec { "install php-${php_version}":
    command     => "sudo PHPBREW_ROOT=${$default_path} /usr/bin/phpbrew install --old php-${php_version} +default +intl +cgi ${extra_params}",
    creates     => "${default_path}/php/php-${php_version}/bin/php",
    timeout     => 0,
  }

  file { "/usr/lib/cgi-bin/fcgiwrapper-${php_version}.sh":
    ensure => present,
    content => template("phpbrew/fcgiwrapper.sh.erb"),
    mode    => 'a+x',
    require => Exec["install php-${php_version}"]
  }
}
