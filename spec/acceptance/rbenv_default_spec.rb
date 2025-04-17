# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'rbenv default' do
  let(:user) { 'rbenv-user' }
  let(:ruby_version) { '3.4.1' }

  let(:manifest) do
    <<-MANIFEST
      $ruby_version = '#{ruby_version}'
      $user         = '#{user}'
      $home         = "/home/$user"

      user { $user:
        ensure => present,
      }

      file { $home:
        ensure => directory,
        owner  => $user,
      }

      rbenv::install { $user:
        group => $user,
        home  => $home,
      }

      rbenv::compile{ "${user}-${ruby_version}":
        user   => $user,
        ruby   => $ruby_version,
        global => true,
      }

      rbenv::gem { 'geordi':
        user   => $user,
        ruby   => $ruby_version,
      }

      rbenv::rubygems { 'tester-3.4.1':
        user    => $user,
        version => '3.4.1',
        ruby    => $ruby_version,
        home    => $home,
      }
    MANIFEST
  end

  it 'applies with no changes on the second run' do
    apply_manifest(manifest, catch_failures: true)
    apply_manifest(manifest, catch_changes: true)
  end

  describe 'rbenv is installed' do
    describe file '/home/rbenv-user/.profile' do
      its(:content) { should contain 'source /home/rbenv-user/.rbenvrc' }
    end

    describe command "su - rbenv-user -s /bin/bash -c 'rbenv --version'" do
      its(:stdout) { should contain 'rbenv' }
    end
  end

  describe 'ruby is installed' do
    describe command "su - rbenv-user -s /bin/bash -c 'ruby --version'" do
      its(:stdout) { should contain '3.4.1' }
    end
  end

  describe command "su - rbenv-user -s /bin/bash -c 'gem info geordi'" do
    its(:stdout) { should contain 'Henning Koch' }
  end

  describe command "su - rbenv-user -s /bin/bash -c 'gem --version'" do
    its(:stdout) { should contain '3.4.1' }
  end
end
