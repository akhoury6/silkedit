# frozen_string_literal: true

require_relative "lib/silkedit/version"

Gem::Specification.new do |spec|
  spec.name = "silkedit"
  spec.version = Silkedit::VERSION
  spec.authors = ["Andrew Khoury"]
  spec.email = ["akhoury@live.com"]

  spec.summary = "A tool to quickly and easily edit savefiles for Hollow Knight / SilkSong."
  # spec.description = ""
  spec.homepage = "https://github.com/akhoury6/silkedit"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/akhoury6/silkedit"
  spec.metadata["changelog_uri"] = "https://github.com/akhoury6/silkedit/blob/main/CHANGELOG.md"
  spec.licenses = ['GPL-3.0-only']

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.7"
  spec.add_development_dependency "rake", ">= 13.3"
  spec.add_development_dependency "rspec", ">= 3.0"

  spec.add_dependency 'rbcli', '~> 0.4'
  spec.add_dependency 'base64', '>= 0.3.0'
  spec.add_dependency 'openssl', '>= 3.3.1'
  spec.add_dependency 'json', '>= 2.15.1'
  spec.add_dependency 'yaml', '>= 0.4.0'
  spec.add_dependency 'fileutils', '>= 1.7.3'
  spec.add_dependency 'zlib', '>= 3.2.1'
  spec.add_dependency 'colorize', '>= 1.1.0'
  spec.add_dependency 'nokogiri', '>= 1.18.10'
  spec.add_dependency 'http', '>= 5.3.1'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
