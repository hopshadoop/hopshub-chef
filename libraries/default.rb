module Hopsworks
  module Helpers
    def get_command_output(command)
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
      command_out = shell_out(command)
      return command_out.stdout.strip
    end
    def get_node_name(asadmin, host)
      worker_command = "#{asadmin} list-nodes -l | grep #{host} | awk '{print $1}'"
      return get_command_output(worker_command) 
    end
    def get_instance_name(asadmin, node_name)
      instance_command = "#{asadmin} list-instances #{node_name} | head -n 1 | awk '{print $1}'"
      return get_command_output(instance_command)
    end
    # only works if the instance is created
    def get_instance_name_by_host(asadmin, host)
      instance_command = "#{asadmin} list-instances -l | grep #{host} | head -n 1 | awk '{print $1}'"
      return get_command_output(instance_command)
    end
  end
end

Chef::Recipe.send(:include, Hopsworks::Helpers)
Chef::Resource.send(:include, Hopsworks::Helpers)
Chef::Provider.send(:include, Hopsworks::Helpers)