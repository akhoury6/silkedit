require 'open-uri'
require 'nokogiri'

module Silkedit::Cheat
  module SilksongJournaler
    @enemylist = YAML.safe_load_file(File.join(Silkedit::LIBDIR, 'config', 'silksong', 'enemylist.yaml'), symbolize_names: false)

    def update_journal(should_update_kills_only: true)
      enemylist = Silkedit::Cheat::SilksongJournaler.module_eval { @enemylist }
      Rbcli.log.info 'Applying ', 'JOURNAL'
      enemylist['playerData']['EnemyJournalKillData']['list'].sort_by { |known_enemy| known_enemy['Position']}.each do |known_enemy|
        sleep 0.01
        player_enemy = @data['playerData']['EnemyJournalKillData']['list'].find { |i| i['Name'] == known_enemy['Name'] }
        self.display_enemy(known_enemy, player_enemy, show_images: false)
        if player_enemy.nil?
          if should_update_kills_only
            Rbcli.log.info "    Not Seen. Skipping.".colorize(:grey)
          else
            new_entry = {
              'Name' => known_enemy['Name'],
              'Record' => {
                'Kills' => known_enemy['Record']['Kills'],
                'HasBeenSeen' => false
              } }
            @data['playerData']['EnemyJournalKillData']['list'].append(new_entry)
            Rbcli.log.info "    Added to journal.".colorize(:magenta)
          end
        elsif player_enemy['Record']['Kills'] < known_enemy['Record']['Kills']
          next if (known_enemy['Record']['Kills'] < 10) && !Silkedit::Sys.yes_no?("    Set #{known_enemy['GameName'].colorize(:blue)} kills from #{player_enemy['Record']['Kills'].to_s.colorize(:red)} to #{known_enemy['Record']['Kills'].to_s.colorize(:green)}?")
          player_enemy['Record']['Kills'] = known_enemy['Record']['Kills']
          player_enemy['Record']['HasBeenSeen'] = true
          Rbcli.log.info "    Updated kills.".colorize(:cyan)
        else
          Rbcli.log.info "    Already Completed.".colorize(:green)
        end
      end
    end

    def enemy_list(only_missing: false, show_images: false)
      enemylist = Silkedit::Cheat::SilksongJournaler.module_eval { @enemylist }
      enemylist['playerData']['EnemyJournalKillData']['list'].sort_by { |known_enemy| known_enemy['Position']}.each do |known_enemy|
        player_enemy = @data['playerData']['EnemyJournalKillData']['list'].find { |i| i['Name'] == known_enemy['Name'] }
        left = player_enemy.nil? ? known_enemy['Record']['Kills'] : known_enemy['Record']['Kills'] - player_enemy['Record']['Kills']
        left = 0 if left < 0
        next if only_missing && left <= 0
        self.display_enemy(known_enemy, player_enemy, show_images: show_images)
      end
    end

    private

    def display_enemy(known_enemy, player_enemy, show_images: false)
      self.show_enemy_image(known_enemy['GameName']) if show_images
      left = player_enemy.nil? ? known_enemy['Record']['Kills'] : known_enemy['Record']['Kills'] - player_enemy['Record']['Kills']
      left = 0 if left < 0
      e_complete = left <= 0 ? '*'.colorize(:cyan) : ' '
      e_number = known_enemy['Position'].to_s.rjust(3)
      e_name = known_enemy['GameName'].ljust(27).colorize(:blue).bold
      e_seen = player_enemy.nil? ? 'N'.colorize(:red) : 'Y'.colorize(:green)
      e_kills = (player_enemy.nil? ? 0 : player_enemy['Record']['Kills']).to_s.rjust(4).colorize(:green)
      e_req = known_enemy['Record']['Kills'].to_s.rjust(4).colorize(:blue)
      e_need = left.to_s.rjust(4).colorize(left <= 0 ? :cyan : :red)
      Rbcli.log.info "#{e_number}. #{e_complete} #{e_name} Seen? #{e_seen} Kills: #{e_kills} Needed: #{e_req} Left: #{e_need}"
    end

    def show_enemy_image(name)
      `which imgcat > /dev/null 2>&1`
      return false unless $?.success?
      enemy_name = name.gsub(' ', '_')
      # enemy_image_directory = File.expand_path(Rbcli::Warehouse.get(:config, :parsedopts)[:images_directory])
      enemy_image_directory = File.join(Silkedit::LIBDIR, 'images', 'silksong')
      cached_image_option_1 = File.join(enemy_image_directory, "#{enemy_name}.png")
      cached_image_option_2 = File.join(enemy_image_directory, "#{enemy_name}_(Silksong).png")

      command = "imgcat '%s'"

      if File.exist?(cached_image_option_1)
        system(format(command, cached_image_option_1))
      elsif File.exist?(cached_image_option_2)
        system(format(command, cached_image_option_2))
      else
        got_image = self.get_large_enemy_image(enemy_name, cached_image_option_1)
        got_image = self.get_large_enemy_image("#{enemy_name}_(Silksong)", cached_image_option_2) unless got_image
        show_enemy_image(name) if got_image
      end
    end

    def get_large_enemy_image(enemy_name, desired_filename)
      begin
        page_url = "https://hollowknight.wiki/w/#{enemy_name}"
        html = URI.open(page_url, 'User-Agent' => 'Ruby/Nokogiri').read
        doc = Nokogiri::HTML(html)
        img = doc.at_css('img.pi-image-thumbnail')
        return false unless img

        raw = img['src'] || img['data-src'] || img['srcset']
        return false unless raw && !raw.strip.empty?

        raw = raw.split(',').first.split(/\s+/).first
        image_url = if raw.start_with?('//')
                      "https:#{raw}"
                    elsif raw =~ %r{\Ahttps?://}
                      raw
                    else
                      URI.join(page_url, raw).to_s
                    end
        URI.open(image_url, 'rb', 'User-Agent' => 'Ruby/Nokogiri') do |image_io|
          FileUtils.mkdir_p(File.dirname(desired_filename)) unless File.directory?(File.dirname(desired_filename))
          File.open(desired_filename, 'wb') do |file|
            IO.copy_stream(image_io, file)
          end
        end
        return true
      rescue StandardError => _e
        return false
      end
    end

  end
end