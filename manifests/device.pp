# == Define: observium::device
#
define observium::device() {

  $hostname    = $name
  $check_query = "SELECT device_id FROM devices WHERE hostname = \'${hostname}\'"
  $mysql_cmd   = "mysql -h ${observium::mysql_host} -u ${observium::mysql_user} -p${observium::mysql_password} -s -e \"${check_query}\" ${observium::mysql_db}"

  exec { "device-${hostname}":
    path    => '/bin:/usr/bin:/usr/local/bin',
    command => "php add_device.php ${hostname}",
    cwd     => $observium::base_path,
    onlyif  => "test -z `${mysql_cmd}`",
    require => Package['observium_packages'],
  }
}
