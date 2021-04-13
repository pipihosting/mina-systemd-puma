# frozen_string_literal: true

require "test_helper"

class PumaTest < Minitest::Test
  def setup
    @old_cwd = Dir.pwd
    @env_root = TEST_ROOT.join("fake")
    Dir.chdir(@env_root)
    FileUtils.rm_rf("deploy")
  end

  def teardown
    Dir.chdir(@old_cwd)
  end

  def test_that_it_has_a_version_number
    refute_nil Mina::Systemd::Puma::VERSION
  end

  def test_it_should_install_units
    res = system("sudo systemctl list-units | grep puma")
    assert_equal res, false

    #mina "puma:install"
    #mina 'deploy'

    #res = system("sudo systemctl list-units | grep puma")
    #assert_equal res, true

  end

  private
  def mina(task)
    cmd = "bundle exec mina --verbose #{task}"
    puts "$ #{cmd}"
    system cmd
  end
end
