define activemq::service (
  $basedir,
  $config,
  $config_file,
  $down,
  $group,
  $logdir,
  $java_home,
  $java_opts,
  $max_mem,
  $min_mem,
  $product,
  $user,
  $version,
) {
  $product_dir = "${basedir}/${product}-${version}"
  runit::service { "${user}-${product}":
    service     => 'activemq',
    basedir     => $basedir,
    logdir      => $logdir,
    user        => $user,
    group       => $group,
    down        => $down,
    timestamp   => false,
  }
  file { "${basedir}/runit/activemq/run":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $group,
    content => template('activemq/run.erb'),
    require => Runit::Service["${user}-${product}"],
  }
  file { "${basedir}/service/activemq":
    ensure  => link,
    target  => "${basedir}/runit/activemq",
    owner   => $user,
    group   => $group,
    replace => false,
    require => Runit::Service["${user}-${product}"],
  }
}
