define activemq::template(
  $basedir,
  $config,
  $config_file,
  $cpu_affinity,
  $down,
  $group,
  $java_home,
  $java_opts,
  $jolokia,
  $jolokia_address,
  $jolokia_port,
  $jolokia_version,
  $logdir,
  $max_mem,
  $min_mem,
  $mode,
  $product_dir,
  $template,
  $user,
  $version,
  $workspace,
) {
  $filename = $title
  if $filename =~ /^(.*?)\/([^\/]+)$/ {
    $dir = $1
    exec { "create-parent-dir-${product_dir}/${filename}":
      path    => [ '/bin', '/usr/bin' ],
      command => "mkdir -p ${product_dir}/${dir}",
      creates => "${product_dir}/${dir}",
      user    => $user,
      group   => $group,
    }
  }
  file { "${product_dir}/${filename}":
    owner    => $user,
    group    => $group,
    mode     => $mode,
    content  => template($template),
    require  => Exec[
      "activemq-unpack-${user}",
      "create-parent-dir-${product_dir}/${filename}"
    ],
  }
}
