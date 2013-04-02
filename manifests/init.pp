class activemq (
  $version          = undef,
  $basedir          = '/opt/activemq',
  $config           = {},
  $config_file      = 'xbean:conf/activemq.xml',
  $cpu_affinity     = undef,
  $down             = false,
  $files            = {},
  $group            = 'activemq',
  $logdir           = '/var/log/activemq',
  $java_home        = '/usr/java/latest',
  $java_opts        = '',
  $jolokia          = false,
  $jolokia_address  = 'localhost',
  $jolokia_port     = '8778',
  $jolokia_version  = '1.1.1',
  $max_mem          = '2048m',
  $min_mem          = '1024m',
  $mode             = undef,
  $remove_docs      = true,
  $remove_examples  = true,
  $templates        = {},
  $workspace        = '/root/activemq',
) {
  $activemq = hiera_hash('activemq::instances', undef)
  if $activemq {
    create_resources('activemq::instance', $activemq)
  }
}
