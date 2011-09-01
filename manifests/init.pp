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
      require => Package['git']
   }

   file {"/var/www/html/mobile":
      ensure => "/home/mwf/root",
      require => Exec['git_clone']
   }

   file {"/home/mwf/config/global.php":
      ensure => present,
      content => template("mwf/global.php.erb"),
      require => Exec['git_clone']
   }

   file {"/var/mobile":
      ensure => directory
   }

   file {"/var/mobile/cache":
      ensure => directory
   }

   file {"/var/mobile/cache/img":
      ensure => directory,
      mode => 0755,
      group => "apache",
      owner => "apache"
   }

   file {"/var/mobile/cache/wurfl":
      ensure => directory,
      mode => 0755,
      group => "apache",
      owner => "apache"
   }

   file {"/var/mobile/cache/simplepie":
      ensure => directory,
      mode => 0755,
      group => "apache",
      owner => "apache"
   }

   file {"/var/mobile/wurfl":
      ensure => directory
   }
   
   file {"/var/mobile/wurfl/wurfl-config.xml":
      ensure => "/home/mwf/install/components/wurfl-config.xml"
   }

   file {"/var/mobile/wurfl/wurfl-web_browsers_patch.xml":
      ensure => "/home/mwf/install/components/wurfl-web_browsers_patch.xml"
   }

   exec { "/usr/bin/wget http://mwf.ucla.edu/wurfl-2.1.1.xml.gz":
      cwd => "/home/mwf/install/components",
      creates => "/home/mwf/install/components/wurfl-2.1.1.xml.gz",
      notify => Exec['decompress_metadata']
   }

   exec {"/usr/bin/gunzip -c /home/mwf/install/components/wurfl-2.1.1.xml.gz > /var/mobile/wurfl/wurfl.xml":
      creates => "/var/mobile/wurfl/wurfl.xml",
      alias => "decompress_metadata"
   }

   exec{ "/usr/bin/wget http://mwf.ucla.edu/wurfl-php-api-1.2.1.tgz":
      cwd => "/home/mwf/install/components",
      creates => "/home/mwf/install/components/wurfl-php-api-1.2.1.tgz",
      notify => Exec['decompress_api']
   }

   exec {"/bin/tar xvfz /home/mwf/install/components/wurfl-php-api-1.2.1.tgz":
      cwd => "/var/mobile/wurfl",
      creates => "/var/mobile/wurfl/api",
      alias => 'decompress_api'
   }

}
