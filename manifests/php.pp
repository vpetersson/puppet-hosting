# == Class: hosting::php
# Install PHP-FPM with the most common modules.

class hosting::php {

  $required_packages=[
    'php5-fpm',
    'php5-mysql',
    'php-apc',
    'php5-gd',
    'php5-curl',
  ]

  package { $required_packages:
    ensure => present,
  }

  service { 'php5-fpm':
    ensure => running,
  }

  file { "www.conf":
    ensure => file,
    path => '/etc/php5/fpm/pool.d/www.conf',
    source  => 'puppet:///modules/hosting/www.conf',
    owner => root,
    group => root,
    notify  => Service["php5-fpm"]
  }

}
