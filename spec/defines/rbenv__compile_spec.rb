require 'spec_helper'

describe 'rbenv::compile', :type => :define do
  on_supported_os.each do |os, os_facts|
    let(:user)         { 'tester' }
    let(:ruby_version) { '1.9.3-p125' }
    let(:title)        { "rbenv::compile::#{user}::#{ruby_version}" }
    let(:dot_rbenv)    { "/home/#{user}/.rbenv" }
    let(:bundler)      { '1.3.4' }
    let(:params)       { {:user => user, :ruby => ruby_version, :global => true, :bundler => bundler} }
    let(:facts)        { os_facts }

    let(:pre_condition)  do
      <<~PP
        rbenv::install { "#{user}":
          group => '',
          home  => '/project'
        }
      PP
    end

    context "on #{os}" do
      it "installs ruby of the chosen version" do
        should contain_exec("rbenv::compile #{user} #{ruby_version}").
          with_command("rbenv install #{ruby_version} && touch #{dot_rbenv}/.rehash")
      end

      it "issues a rehash command" do
        should contain_exec("rbenv::rehash #{user} #{ruby_version}").
          with_command("rbenv rehash && rm -f #{dot_rbenv}/.rehash")
      end

      it "sets the global ruby version for the specific user" do
        should contain_file("rbenv::global #{user}").
          with_content("#{ruby_version}\n").
          with_require("Exec[rbenv::compile #{user} #{ruby_version}]")
      end

      it "installs ruby-build plugin from official repository" do
        should contain_rbenv__plugin__rubybuild("rbenv::rubybuild::#{user}")
      end

      it "installs bundler" do
        should contain_rbenv__gem("rbenv::bundler #{user} #{ruby_version}").
          with_ensure(bundler)
      end
    end
  end
end
