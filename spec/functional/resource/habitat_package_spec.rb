require 'spec_helper'

describe Chef::Resource::HabitatPackage do

  context 'when compiling the package recipe' do
    it 'installs core/redis' do
      expect(chef_run).to install_habitat_package('core/redis')
    end

    it 'installs lamont-granquist/ruby with a specific version' do
      expect(chef_run).to install_habitat_package('lamont-granquist/ruby')
        .with(version: '2.3.1')
    end

    it 'installs core/bundler with a specific release' do
      expect(chef_run).to install_habitat_package('core/bundler')
        .with(version: '1.13.3/20161011123917')
    end

    it 'installs core/hab-sup with a specific depot url' do
      expect(chef_run).to install_habitat_package('core/hab-sup')
        .with(bldr_url: 'https://bldr.habitat.sh')
    end

    it 'installs core/htop with binlink option' do
      expect(chef_run).to install_habitat_package('core/htop')
        .with(options: ['--binlink'])
    end

    it 'installs core/foo with binlink parameters' do
      expect(chef_run).to install_habitat_package('binlink')
        .with(binlink: true)
    end

    it 'installs core/foo by forcing binlink' do
      expect(chef_run).to install_habitat_package('binlink_force')
        .with(binlink: :force)
    end

    it 'removes core/nginx with remove action' do
      expect(chef_run).to remove_habitat_package('core/nginx')
    end
  end
end