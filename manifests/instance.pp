define activemq::instance (
  $basedir          = $::activemq::basedir,
  $config           = $::activemq::config,
  $config_file      = $::activemq::config_file,
  $cpu_affinity     = $::activemq::cpu_affinity,
  $down             = $::activemq::down,
  $files            = $::activemq::files,
  $group            = $::activemq::group,
  $java_home        = $::activemq::java_home,
  $java_opts        = $::activemq::java_opts,
  $logdir           = $::activemq::logdir,
  $max_mem          = $::activemq::max_mem,
  $min_mem          = $::activemq::min_mem,
  $mode             = $::activemq::mode,
  $templates        = $::activemq::templates,
  $version          = $::activemq::version,
  $workspace        = $::activemq::workspace,
) {
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
    version     => $version,
    user        => $user,
    group       => $group,
    basedir     => $basedir,
    workspace   => $workspace,
  }

  create_resources( 'activemq::file', $files,
    {
      group       => $group,
      mode        => $mode,
      product_dir => $product_dir,
      user        => $user,
    }
  )

  create_resources( 'activemq::template', $templates,
    {
      basedir      => $basedir,
      config       => $config,
      config_file  => $config_file,
      cpu_affinity => $cpu_affinity,
      down         => $down,
      group        => $group,
      java_home    => $java_home,
      java_opts    => $java_opts,
      logdir       => $logdir,
      max_mem      => $max_mem,
      min_mem      => $min_mem,
      mode         => $mode,
      product_dir  => $product_dir,
      user         => $user,
      version      => $version,
      workspace    => $workspace,
    }
  )

  activemq::service { "${user}-${product}":
    basedir      => $basedir,
    logdir       => $logdir,
    product      => $product,
    user         => $user,
    group        => $group,
    version      => $version,
    java_home    => $java_home,
    java_opts    => $java_opts,
    config       => $config,
    config_file  => $config_file,
    cpu_affinity => $cpu_affinity,
    min_mem      => $min_mem,
    max_mem      => $max_mem,
    down         => $down,
  }

}
