define rbenv::rubygems (
  $version,
  $user,
  $ruby
) {

  exec { "update_rubygems_${user}_${version}":
    command => "/home/${user}/.rbenv/shims/gem update --system ${version}",
    unless  => "/home/${user}/.rbenv/shims/gem -v | /bin/grep ${version}",
    require => Exec["rbenv::compile ${user} ${ruby}"],
  }

}
