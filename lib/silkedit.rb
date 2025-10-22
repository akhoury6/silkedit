# frozen_string_literal: true

require_relative "silkedit/version"

module Silkedit
  LIBDIR = File.join(File.dirname(__FILE__), 'silkedit')
end

Dir.glob(File.join(Silkedit::LIBDIR, '**', '*.rb')).each { |file| require file }