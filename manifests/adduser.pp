define observium::adduser(
  $password,
  $level
) {
  $username = $name

  $check_query = "SELECT user_id FROM users WHERE username = \'${username}\'"

  exec { "adduser-${username}":
    path    => '/usr/bin:/bin',
    command => "php adduser.php ${username} ${password} ${level}",
    cwd     => $observium::base_path,
    onlyif  => "test -z `mysql -h ${observium::mysql_host} -u ${observium::mysql_user} -p${observium::mysql_password} -s -e \"${check_query}\" ${observium::mysql_db}`",
  }

}
