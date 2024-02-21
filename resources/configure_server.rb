actions :glassfish_configure_network, :glassfish_configure_monitoring, :glassfish_configure, :glassfish_configure_realm, :glassfish_configure_http_logging, :glassfish_create_resource_ref

attribute :domain_name, :kind_of => String, :default => nil
attribute :domains_dir, :kind_of => String, :default => nil
attribute :password_file, :kind_of => String, :default => nil
attribute :username, :kind_of => String, :default => nil
attribute :admin_port, :kind_of => Integer, :default => 4848
attribute :target, :kind_of => String, :default => "server"
attribute :asadmin, :kind_of => String, :default => nil
attribute :internal_port, :kind_of => Integer, :default => 8182

attribute :securityenabled, :kind_of => [TrueClass, FalseClass], :default => true
attribute :network_name, :kind_of => String, :default => nil
attribute :network_listener_name, :kind_of => String, :default => nil

attribute :nodedir, :kind_of => String, :default => nil
attribute :node_name, :kind_of => String, :default => nil
attribute :override_props, :kind_of => Hash, :default => {}
attribute :recreate, :kind_of => [TrueClass, FalseClass], :default => false
attribute :ignore_failure, :kind_of => [TrueClass, FalseClass], :default => false
attribute :realmname, :kind_of => String, :default =>  "hopsworksrealm"