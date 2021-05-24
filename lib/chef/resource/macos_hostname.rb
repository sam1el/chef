# Copyright:: Chef Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative "../resource"
require "chef-utils/dist" unless defined?(ChefUtils::Dist)

class Chef
  class Resource
    class MacosHostname < Chef::Resource
      unified_mode true

      provides :macos_hostname

      description "Use the **macos_hostname** resource to set the system's hostname, configure hostname and hosts config file, and re-run the Ohai hostname plugin so the hostname will be available in subsequent cookbooks."
      introduced "17.3"
      examples <<~DOC
        **Set the hostname using the IP address, as detected by Ohai**:

        ```ruby
        macos_hostname 'awesome_chef-mac01'
        ```

        **Set the localhostame to something separate from hostname**:

        ```ruby
        macos_hostname 'awesome_chef-mac01' do
          localhostname 'this_is_my-mac01'
        end
        ```

      DOC

      property :hostname, String,
      name_property: true,
      description: "An optional property to set the hostname if it differs from the resource block's name. This is the name you will see in your command line and that ssh sessions will see when connecting "

      property :computername, String,
      default: "#{new_resource.hostname}",
      description: "Allows the option to set the computer name separate from the hostname. Will default to hostname. The user-friendly name for the system."

      property :localhostname, String,
      description: "Allows you to set the local hostname. Your computer’s local hostname, or local network name, is displayed on your local network so others on the network can connect to your Mac. It also identifies your Mac to Bonjour-compatible services. (Airdrop etc)",
      default: "#{new_resource.hostname}"

      # override compile_time property to be true by default
      property :compile_time, [ TrueClass, FalseClass ],
      description: "Determines whether or not the resource should be run at compile time.",
      default: true, desired_state: false

      action :set, description: "Sets all node's hostnames." do
        execute "set HostName via scutil" do
          command "/usr/sbin/scutil --set HostName #{new_resource.hostname}"
          not_if { shell_out("/usr/sbin/scutil --get HostName").stdout.chomp == new_resource.hostname }
          notifies :reload, "ohai[reload hostname]"
        end
        execute "set ComputerName via scutil" do
          command "/usr/sbin/scutil --set ComputerName  #{new_resource.computername}"
          not_if { shell_out("/usr/sbin/scutil --get ComputerName").stdout.chomp == new_resource.hostname }
          notifies :reload, "ohai[reload hostname]"
        end
        shortname = new_resource.localhostname[/[^\.]*/]
        execute "set LocalHostName via scutil" do
          command "/usr/sbin/scutil --set LocalHostName #{shortname}"
          not_if { shell_out("/usr/sbin/scutil --get LocalHostName").stdout.chomp == shortname }
          notifies :reload, "ohai[reload hostname]"
        end
      end

      action :local, description: "Only changes node's localhost name" do
        shortname = new_resource.localhostname[/[^\.]*/]
        execute "set LocalHostName via scutil" do
          command "/usr/sbin/scutil --set LocalHostName #{shortname}"
          not_if { shell_out("/usr/sbin/scutil --get LocalHostName").stdout.chomp == shortname }
          notifies :reload, "ohai[reload hostname]"
        end
      end

      action :computer_name, description: "Only changes node's computername" do
        execute "set ComputerName via scutil" do
          command "/usr/sbin/scutil --set ComputerName  #{new_resource.computername}"
          not_if { shell_out("/usr/sbin/scutil --get ComputerName").stdout.chomp == new_resource.computername }
          notifies :reload, "ohai[reload hostname]"
        end
      end

      action :host, description: "Only set the hostname" do
        execute "set HostName via scutil" do
          command "/usr/sbin/scutil --set HostName #{new_resource.hostname}"
          not_if { shell_out("/usr/sbin/scutil --get HostName").stdout.chomp == new_resource.hostname }
          notifies :reload, "ohai[reload hostname]"
        end
      end
      default_action :set
    end
  end
end
