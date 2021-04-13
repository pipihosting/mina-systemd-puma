# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "mina/systemd/puma"

require "minitest/autorun"
