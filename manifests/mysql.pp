# == Class: hosting::mysql
# Install MySQL and ensure it is running.

class hosting::mysql {

  package { 'mysql-server':
    ensure => present,
  }

  service { 'mysql':
    ensure  => running,
    require => Package['mysql']
  }

}
