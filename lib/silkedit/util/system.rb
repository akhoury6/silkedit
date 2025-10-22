require 'io/console'

module Silkedit::Sys
  def self.os
    case RbConfig::CONFIG['host_os'].to_s
    when /mswin|msys|mingw|cygwin|bccwin|wince|windows/i
      :windows
    when /darwin|mac os|macos|osx/i
      :macos
    when /linux/i
      :linux
    else
      nil
    end
  end

  def self.tmpdir
    case Silkedit::Sys.os
    when :windows
      File.join(ENV['TEMP'] || ENV['TMP'], 'silkedit')
    when :macos
      File.join(ENV['TMPDIR'], 'silkedit')
    when :linux
      File.join(ENV['TMPDIR'], 'silkedit')
    else
      Dir.tmpdir
    end
  end

  def self.yes_no? question, &block
    print "#{question} (y/n): "
    answer = STDIN.getch.chomp.downcase until %w[y n].include?(answer)
    print "#{answer}\n"
    yield if block_given? && answer == 'y'
    return answer == 'y'
  end
end