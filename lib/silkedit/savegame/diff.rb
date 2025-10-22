require 'pp'

module Silkedit::Savegame
  module Diff
    def self.mkdiff (old, new)
      return { old: old, new: new } if old.class != new.class

      diff = nil

      if old.is_a?(Hash)
        diff = {}
        (old.keys + new.keys).uniq.each do |k|
          itemdiff = mkdiff(old[k], new[k])
          diff[k] = itemdiff unless itemdiff.nil? || itemdiff.empty?
        end
      elsif old.is_a?(Array)
        diff = []
        if old.first.is_a?(Hash)
          if old.first.key?('Name')
            keycomps = %w[Name]
          elsif old.first.key?('SceneName') && old.first.key?('ID')
            keycomps = %w[SceneName ID]
          elsif old.first.key?('SceneName') && old.first.key?('EventType')
            keycomps = %w[SceneName EventType]
          else
            keycomps = nil
          end
          if keycomps.nil?
            diff = { old: old.reject { |e| new.include?(e) }, new: new.reject { |e| old.include?(e) } }
          else
            old.each do |o|
              n = new.find { |e| keycomps.map { |k| e[k] == o[k] }.reduce { |a, b| a && b } }
              itemdiff = mkdiff(
                o.reject { |k, _v| keycomps.include?(k) },
                n.nil? ? nil : n.reject { |k, _v| keycomps.include?(k) }
              )
              next if itemdiff.empty?
              newobj = {}
              keycomps.each { |k| newobj[k] = o[k] }
              diff.append(newobj.merge(itemdiff))
            end
            new.each do |n|
              o = old.find { |e| keycomps.map { |k| e[k] == n[k] }.reduce { |a, b| a && b } }
              next unless o.nil?
              itemdiff = mkdiff(
                nil,
                n.reject { |k, _v| keycomps.include?(k) }
              )
              newobj = {}
              keycomps.each { |k| newobj[k] = n[k] }
              diff.append(newobj.merge(itemdiff))
            end
          end
        end
      elsif old != new
        diff = { old: old, new: new }
      end
      return diff
    end

    def self.parse_diff(obj, yaml_output: false)
      if yaml_output
        sio = StringIO.new
        YAML.dump(obj, sio)
        colored_string = ''

        sio.string.each_line do |line|
          i = 0
          while i < line.length
            blank_leadup = line[0..i-1].chars.map { |c| c == ' ' }.all?
            if line[i] == '-' && blank_leadup
              colored_string += line[i].colorize(:yellow)
              i += 1
            elsif line[i] == ':' && blank_leadup
              j = i + line[i+1..-1].index(':')
              colored_string += line[i..j].colorize(:magenta)
              i += j - i + 1
            elsif line[i].match(%r{[\"\w]}) && line[i+1..-1].include?(':')
              j = i + line[i+1..-1].index(':')
              colored_string += line[i..j].colorize(:red)
              i += j - i + 1
            elsif line[i].match(%r{\d}) && line[i..-2].chars.map { |c| c.match(%r{\d}) }.all?
              colored_string += line[i..-2].colorize(:blue)
              i = line.length - 1
            elsif line[i..i + 2] == 'nil'
              colored_string += line[i..i + 2].colorize(:yellow)
              i += 3
            elsif line[i..i + 3] == 'true'
              colored_string += line[i..i + 3].colorize(:yellow)
              i += 4
            elsif line[i..i + 4] == 'false'
              colored_string += line[i..i + 4].colorize(:yellow)
              i += 5
            elsif line[i].match(%r{[\"\w]})
              colored_string += line[i..-2].colorize(:green)
              i = line.length - 1
            elsif line[i] == ':'
              colored_string += line[i].colorize(:yellow)
              i += 1
            else
              colored_string += line[i]
              i += 1
            end
          end
        end

        return colored_string
      end

      sio = StringIO.new
      PP.pp(obj, sio)

      colored_string = ''
      i = 0
      while i < sio.string.length
        if ['{', '}', '[', ']', ','].include?(sio.string[i])
          colored_string += sio.string[i]
          i += 1
        elsif sio.string[i] == '"'
          capture = '"'
          cnt = 1
          while sio.string[i + cnt] != '"'
            capture += sio.string[i + cnt]
            cnt += 1
          end
          capture += '"'
          color = sio.string[i + cnt + 2] == '=' ? :red : :green
          colored_string += capture.colorize(color)
          i += cnt + 1
        elsif sio.string[i..i + 1] == '=>'
          colored_string += sio.string[i..i + 1].colorize(:yellow)
          i += 2
        elsif sio.string[i].to_i.to_s == sio.string[i]
          colored_string += sio.string[i].colorize(:light_blue)
          i += 1
        elsif sio.string[i..i + 2] == 'nil'
          colored_string += sio.string[i..i + 2].colorize(:yellow)
          i += 3
        elsif sio.string[i..i + 3] == 'true'
          colored_string += sio.string[i..i + 3].colorize(:yellow)
          i += 4
        elsif sio.string[i..i + 4] == 'false'
          colored_string += sio.string[i..i + 4].colorize(:yellow)
          i += 5
        elsif ['new:', 'old:'].include?(sio.string[i..i + 3])
          colored_string += sio.string[i..i + 2].colorize(:magenta)
          colored_string += sio.string[i + 3].colorize(:yellow)
          i += 4
        else
          colored_string += sio.string[i]
          i += 1
        end
      end
      return colored_string
    end

  end
end