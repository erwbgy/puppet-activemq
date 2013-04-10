define activemq::service (
  $basedir,
  $config,
  $config_file,
  $cpu_affinity,
  $down,
  $filestore,
  $group,
  $logdir,
  $java_home,
  $java_opts,
  $jolokia,
  $jolokia_address,
  $jolokia_cron,
  $jolokia_port,
  $jolokia_version,
  $max_mem,
  $min_mem,
  $product,
  $ulimit_nofile,
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
  if $jolokia_cron {
   cron { 'activemq-connection-monitor':
      command => "${basedir}/${product}-${version}/bin/connection-monitor",
      user    => $user,
      require => File["${basedir}/${product}-${version}/bin/connection-monitor"],
    }
    cron { 'activemq-queue-monitor':
      command => "${basedir}/${product}-${version}/bin/queue-monitor",
      user    => $user,
      require => File["${basedir}/${product}-${version}/bin/queue-monitor"],
    }
  }
}
