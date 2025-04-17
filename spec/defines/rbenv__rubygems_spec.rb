# frozen_string_literal: true

require 'spec_helper'

describe 'rbenv::rubygems', type: :define do
  let(:version) { '3.3.7' }
  let(:user)    { 'tester' }
  let(:home)    { "/home/#{user}" }
  let(:ruby)    { '3.1.1' }

  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }
    let(:pre_condition) do
      <<~PP
        exec { "rbenv::compile #{user} #{ruby}":
          command => true,
        }
      PP
    end

    let(:title)   { "rbenv::rubygems #{user} #{ruby}" }
    let(:params)  { { version: version, user: user, home: home, ruby: ruby } }

    context "on #{os}" do
      it 'updates rubygems to 3.3.7' do
        should contain_exec('update_rubygems_tester_3.3.7').with(
          command: "/home/#{user}/.rbenv/shims/gem update --system #{version}",
          unless: "/home/#{user}/.rbenv/shims/gem -v | /bin/grep #{version}",
          user: user,
          cwd: home,
          environment: "HOME=#{home}"
        )
      end
    end
  end
end
