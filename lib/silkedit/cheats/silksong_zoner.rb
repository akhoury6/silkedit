module Silkedit::Cheat
  module SilksongZoner
    @zonedata = YAML.safe_load_file(File.join(Silkedit::LIBDIR, 'config', 'silksong', 'zones.yaml'), symbolize_names: false)
    @shortcuts = @zonedata['_shortcuts']
    @zonelist = @zonedata.reject { |k, _v| k.start_with?('_') }.to_a.map do |region, r_values|
      r_values.map do |spawnpoint, data|
        {
          "slug" => "#{region}.#{spawnpoint}",
          "shortcut" => @shortcuts.values.include?("#{region}.#{spawnpoint}") ? @shortcuts.key("#{region}.#{spawnpoint}") : nil
        }.merge(data)
      end
    end.flatten

    def list_zones
      zonelist = Silkedit::Cheat::SilksongZoner.module_eval { @zonelist }
      zonelist.map { |z| z.select { |k, _v| %w[slug shortcut min_act].include?(k) }.transform_keys(&:to_sym) }
    end

    def list_shortcuts
      Silkedit::Cheat::SilksongZoner.module_eval { @shortcuts }
    end

    def zone_to(zone, force_soft_reqs: false, enforce_min_act: true)
      zonedata = Silkedit::Cheat::SilksongZoner.module_eval { @zonedata }
      zonelist = Silkedit::Cheat::SilksongZoner.module_eval { @zonelist }
      shortcuts = Silkedit::Cheat::SilksongZoner.module_eval { @shortcuts }
      Rbcli.log.info "Zoning to #{zone}", 'ZONER'
      return self.zone_to(shortcuts[zone]) if shortcuts.key?(zone)
      return :no_zone unless zonelist.find { |z| z['slug'] == zone }
      region, target = zone.split('.')
      Silkedit::Cheat.merge_cheat(
        @data,
        zonedata[region][target],
        should_merge_arrays: true,
        force_soft_reqs: force_soft_reqs,
        enforce_min_act: enforce_min_act
      )
    end

    def save_current_zone(name, shortcut = nil, act_override = nil, overwrite: false)
      region, target = name.downcase.split('.')
      return :badname unless region && target
      return :badact if !act_override.nil? && (act_override < 1 || act_override > 3)
      return :badshortcut if !shortcut.nil? && shortcut.include?('.')

      zone = {
        'data' => {
          'playerData' => {
            'atBench' => @data['playerData']['atBench'],
            'respawnScene' => @data['playerData']['respawnScene'],
            'mapZone' => @data['playerData']['mapZone'],
            'extraRestZone' => @data['playerData']['extraRestZone'],
            'respawnMarkerName' => @data['playerData']['respawnMarkerName'],
            'respawnType' => @data['playerData']['respawnType'],
            'hazardRespawnFacing' => @data['playerData']['hazardRespawnFacing'],
          }
        },
        'soft_reqs' => {},
        'hard_reqs' => {},
        'min_act' => act_override || Silkedit::Cheat.get_game_act(@data)
      }

      rosarylock = @data['sceneData']['persistentBools']['serializedList'].find { |i| i['SceneName'] == @data['playerData']['respawnScene'] && i['ID'] == 'bell_toll_machine' }
      zone['soft_reqs'].merge!({'sceneData' => {'persistentBools' => {'serializedList' => [rosarylock]}}}) unless rosarylock.nil?
      leverlock = @data['sceneData']['persistentInts']['serializedList'].find { |i| i['SceneName'] == @data['playerData']['respawnScene'] && i['ID'].include?('Bellshrine Sequence') }
      zone['soft_reqs'].merge!({'sceneData' => {'persistentInts' => {'serializedList' => [leverlock]}}}) unless leverlock.nil?

      zonedata = Silkedit::Cheat::SilksongZoner.module_eval { @zonedata }
      zonelist = Silkedit::Cheat::SilksongZoner.module_eval { @zonelist }
      known_zone_idx = zonelist.find_index do |known_zone|
        known_zone['data']['playerData']['respawnScene'] == zone['data']['playerData']['respawnScene'] &&
        known_zone['data']['playerData']['respawnMarkerName'] == zone['data']['playerData']['respawnMarkerName']
      end

      if known_zone_idx
        if overwrite
          old_region, old_target = zonelist[known_zone_idx]['slug'].split('.')
          zonedata[old_region].delete(old_target)
          zonedata.delete(old_region) if zonedata[old_region].empty?
        else
          return zonelist[known_zone_idx]['slug']
        end
      end

      zonedata[region] ||= {}
      zonedata[region][target] = zone
      zonedata[region] = zonedata[region].sort_by { |k, _v| k }.to_h
      zonedata = zonedata.sort_by { |k, _v| k }.to_h

      if shortcut
        zonedata['_shortcuts'][shortcut] = "#{region}.#{target}"
      end

      File.write(File.join(Silkedit::LIBDIR, 'config', 'silksong', 'zones.yaml'), YAML.safe_dump(zonedata))
      :success
    end
  end
end