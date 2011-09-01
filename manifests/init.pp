class mwf {}

class mwf::server ($site_url, $site_assets_url, $site_nonmobile_url = false) {
   
   package {"git": ensure => installed }
   package {"httpd": ensure => installed }
   package {"php": ensure => installed}
   package {"php-common": ensure => installed }
   package {"php-devel": ensure => installed }
   package {"php-cli": ensure => installed }
   package {"php-gd": ensure => installed }
   package {"php-xml": ensure => installed }

   service {"httpd":
      ensure => running,
      enable => true,
      hasrestart => true,
      hasstatus => true,
      require => Package['httpd', 'php', 'php-common', 'php-devel', 'php-cli', 'php-gd', 'php-xml']
   }

   exec {"/usr/bin/git clone https://github.com/ucla/mwf.git":
      alias => "git_clone",
      creates => "/home/mwf",
      cwd => "/home",
      notify => Exec['install'],
      require => Package['git']
   }

   exec {"bash /home/mwf/install/install.sh":
      alias => "install",
      refreshonly => true,
      require => Exec['git_clone'],
      notify => Exec['install_wurfl']
   }

   exec {"bash /home/mwf/install/install-wurfl-api.sh":
      alias => "install_wurfl",
      refreshonly => true,
      require => Exec['install']
   }

   file {"/var/www/html/mobile":
      ensure => "/home/mwf/root",
      require => Exec['git_clone']
   }

   file {"/home/mwf/config/global.php":
      ensure => present,
      content => template("mwf/global.php.erb"),
      require => Exec['install']
   }
}
