# puppet-phpbrew

Puppet module for phpbrew.


## Usage

	phpbrew::install{ '5.3.27':
      $version = '',
      $build_parameters = undef,
      $php_inis = undef,
      $install_dir = '/opt/phpbrew',
    )


## Configuration

You can additional define the version (if the name should be different), the build parameters, the php ini files you want to copy and the install directory:

	phpbrew::install{ 'php-5.3.27':
      $version => '5.3.27',
      $build_parameters => '+mysql',
      $php_inis => [
        '/etc/php5/mods-available/custom.ini'
      ],
      $install_dir => '/opt/custom_dir',
    )

Default values:

    $version = '',
    $build_parameters = undef
    $php_inis = undef
    $install_dir = '/opt/phpbrew'


## Install php extension

### Usage

    define phpbrew::extension{ 'xdebug':
      $php_version = '5.3.27',
    )

Note the php version is required and the php version must be installed by php brew.


### Configuration

You can additional define the extension name (if the name should be different), the version (if now version is given the latest will used), the build parameters and the install directory:

Default values:

    $extension = undef
    $version = undef
    $install_dir = '/opt/phpbrew'


## License

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


## Copyright

	Alexander Schneider - Jankowfsky AG
	www.jankowfsky.com
