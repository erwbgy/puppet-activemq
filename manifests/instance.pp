define activemq::instance (
  $basedir          = $::activemq::basedir,
  $config           = $::activemq::config,
  $config_file      = $::activemq::config_file,
  $cpu_affinity     = $::activemq::cpu_affinity,
  $down             = $::activemq::down,
  $files            = $::activemq::files,
  $filestore        = $::activemq::filestore,
  $group            = $::activemq::group,
  $java_home        = $::activemq::java_home,
  $java_opts        = $::activemq::java_opts,
  $jolokia          = $::activemq::jolokia,
  $jolokia_address  = $::activemq::jolokia_address,
  $jolokia_cron     = $::activemq::jolokia_cron,
  $jolokia_port     = $::activemq::jolokia_port,
  $jolokia_version  = $::activemq::jolokia_version,
  $logdir           = $::activemq::logdir,
  $max_mem          = $::activemq::max_mem,
  $min_mem          = $::activemq::min_mem,
  $mode             = $::activemq::mode,
  $templates        = $::activemq::templates,
  $version          = $::activemq::version,
  $workspace        = $::activemq::workspace,
) {
  if ! $version {
    fail('activemq version MUST be set')
  }
  $user        = $title
  $product     = 'apache-activemq'
  $product_dir = "${basedir}/${product}-${version}"

  if ! defined(File[$workspace]) {
    file { $workspace:
      ensure => directory,
    }
  }

  include runit
  if ! defined(Runit::User[$user]) {
    runit::user { $user:
      basedir => $basedir,
      group   => $group,
    }
  }

  activemq::install { "${user}-${product}":
    basedir         => $basedir,
    filestore       => $filestore,
    group           => $group,
    jolokia         => $jolokia,
    jolokia_address => $jolokia_address,
    jolokia_cron    => $jolokia_cron,
    jolokia_port    => $jolokia_port,
    jolokia_version => $jolokia_version,
    user            => $user,
    version         => $version,
    workspace       => $workspace,
  }

  create_resources( 'activemq::file', $files,
    {
      filestore   => $filestore,
      group       => $group,
      mode        => $mode,
      product_dir => $product_dir,
      user        => $user,
    }
  )

  create_resources( 'activemq::template', $templates,
    {
      basedir         => $basedir,
      config          => $config,
      config_file     => $config_file,
      cpu_affinity    => $cpu_affinity,
      down            => $down,
      filestore       => $filestore,
      group           => $group,
      java_home       => $java_home,
      java_opts       => $java_opts,
      jolokia         => $jolokia,
      jolokia_address => $jolokia_address,
      jolokia_cron    => $jolokia_cron,
      jolokia_port    => $jolokia_port,
      jolokia_version => $jolokia_version,
      logdir          => $logdir,
      max_mem         => $max_mem,
      min_mem         => $min_mem,
      mode            => $mode,
      product_dir     => $product_dir,
      user            => $user,
      version         => $version,
      workspace       => $workspace,
    }
  )

  activemq::service { "${user}-${product}":
    basedir         => $basedir,
    config          => $config,
    config_file     => $config_file,
    cpu_affinity    => $cpu_affinity,
    down            => $down,
    filestore       => $filestore,
    group           => $group,
    java_home       => $java_home,
    java_opts       => $java_opts,
    jolokia         => $jolokia,
    jolokia_address => $jolokia_address,
    jolokia_cron    => $jolokia_cron,
    jolokia_port    => $jolokia_port,
    jolokia_version => $jolokia_version,
    logdir          => $logdir,
    max_mem         => $max_mem,
    min_mem         => $min_mem,
    product         => $product,
    user            => $user,
    version         => $version,
  }

}
