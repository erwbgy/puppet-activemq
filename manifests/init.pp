class activemq (
  $version,
  $basedir          = '/opt/activemq',
  $bind_address     = $::fqdn,
  $down             = false,
  $files            = {},
  $group            = 'activemq',
  $logdir           = '/var/log/activemq',
  $java_home        = '/usr/java/latest',
  $java_opts        = '',
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
