# puppet-phpbrew

Puppet module for phpbrew.


## Usage

	class { 'phpdecoder':
		$php_version => '5.3',
		$type        => 'zend',
	}


## Configuration

You can additional define apache modules and php conf.d directory:

	class { 'phpdecoder':
	    $php_version => '5.3',
	    $type        => 'zend',
		$modules_dir => '/etc/apache2/modules/zgl/',
        $php_ini_dir => '/etc/php5/apache2/conf.d/'
	}


Default values:

    $php_version = '5.3'
    $type        = 'zend'
    $modules_dir = '/etc/apache2/modules/zgl/'
    $php_ini_dir = '/etc/php5/apache2/conf.d/'


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