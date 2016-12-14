define rbenv::rubygems (
  $version,
  $user,
  $home,
  $ruby,
) {

  exec { "update_rubygems_${user}_${version}":
    command     => "${home}/.rbenv/shims/gem update --system ${version}",
    unless      => "${home}/.rbenv/shims/gem -v | /bin/grep ${version}",
    user        => $user,
    cwd         => $home,
    environment => "HOME=${home}",
    require     => Exec["rbenv::compile ${user} ${ruby}"],
  }

}
