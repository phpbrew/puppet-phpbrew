# Definition: phpbrew::extension
#
# This class installs the given extension for the given version
#
# Parameters:
# - The $extension
# - The $version the php version
#
# Actions:
# - Install the given extension version
#
# Sample Usage:
#  phpbrew::extension { 'xdebug':
#    version => '5.3.28'
#  }
#
define phpbrew::extension(
  $extension = undef,
  $php_version = undef,
  $version = undef
) {
  if ! $extension {
    $extension_name = $title
  } else {
    $extension_name = $extension
  }

  if ! $php_version {
    warning('No php version for extension given. Install aborted.')
  } else {
    exec { "phpbrew_extension_${extension_name}-${php_version}-${version}":
      command => "/root/.phpbrew/install_extension.sh ${php_version} ${extension_name} ${version}",
      timeout => 0,
      user    => 'root',
      creates => "/opt/phpbrew/php/php-${php_version}/var/db/${extension_name}.ini",
      notify  => Service['httpd']
    }
  }
}