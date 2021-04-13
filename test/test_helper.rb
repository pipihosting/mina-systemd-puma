# frozen_string_literal: true

require "mina_systemd_puma"

require "minitest/autorun"

require 'pathname'

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

TEST_ROOT = Pathname.new(File.dirname(__FILE__))
