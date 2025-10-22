require 'yaml'

module Silkedit::Cheat
  module SilksongCheats
    @cheatdata = YAML.safe_load_file(File.join(Silkedit::LIBDIR, 'config', 'silksong', 'cheatdata.yaml'), symbolize_names: false)
    @cheatdata['cheats'].each do |cheat, cht_data|
      next if self.instance_methods.include?(cheat.to_sym)
      self.define_method(cheat.to_sym) do
        Rbcli.log.info "Applying cheat #{cheat}", 'CHEATS'
        Silkedit::Cheat.merge_cheat(@data, cht_data, should_merge_arrays: true)
      end
    end

    def unkill
      Rbcli.log.info 'Reviving from death', 'CHEATS'
      if @data['playerData']['permadeathMode'] == 2
        @data['playerData']['permadeathMode'] = 1
      end
      @data['playerData']['geo'] += @data['playerData']['HeroCorpseMoneyPool']
      @data['playerData']['HeroDeathScenePos'] = { 'x' => 0.0, 'y' => 0.0 }
      @data['playerData']['HeroDeathSceneSize'] = { 'x' => 0.0, 'y' => 0.0 }
      @data['playerData']['HeroCorpseType'] = 0
      @data['playerData']['HeroCorpseMoneyPool'] = 0
      @data['playerData']['hazardRespawnFacing'] = 0
      @data['playerData']['IsSilkSpoolBroken'] = false
      @data['playerData'].delete('HeroCorpseMarkerGuid')
      @data['playerData'].delete('HeroCorpseScene')
    end

    def refresh
      self.max_shards
      self.max_liquids
    end

    def max_everything
      %w[
        max_health
        max_silk
        max_weapon
        max_tool_upgrades
        max_liquids
        all_abilities
        all_crests
        all_crest_unlocks
        all_eva_upgrades
        all_spells
        all_tools
        give_consumables
        max_rosaries
        max_shards
      ].each { |cht| self.send(cht.to_sym) }
    end

    def max_shards
      Rbcli.log.info 'Applying cheat max_shards', 'CHEATS'
      @data['playerData']['ShellShards'] = 400 + (@data['playerData']['ToolPouchUpgrades'] || 0) * 100
    end

    def all_crest_unlocks
      Rbcli.log.info 'Applying cheat all_crest_unlocks', 'CHEATS'
      cheatdata = Silkedit::Cheat::SilksongCheats.module_eval { @cheatdata }
      @data['playerData']['ToolEquips']['savedData'].each do |crest|
        if crest['Data']['Slots'].nil? || crest['Data']['Slots'].empty?
          newcrest = cheatdata['reference']['full_crests']['playerData']['ToolEquips']['savedData'].find { |c| c['Name'] == crest['Name'] }
          next if newcrest.nil?
          crest['Data'] = {} if crest['Data'].nil?
          crest['Data']['Slots'] = newcrest['Data']['Slots'] if newcrest.key?('Data') && newcrest['Data'].key?('Slots')
        end
        crest['Data']['Slots'].each { |slot| slot['IsUnlocked'] = true }
      end
    end

    def toggle_map_reveal
      @data['playerData']['mapAllRooms'] = !@data['playerData']['mapAllRooms']
      Rbcli.log.info "Full map reveal is #{@data['playerData']['mapAllRooms'] ? 'enabled' : 'disabled'}", 'CHEATS'
    end

    def toggle_flea_reveal
      flea_keys = @data['playerData'].keys.select { |k| k.start_with?('hasPinFlea') }
      is_enabled = flea_keys.all? { |k| @data['playerData'][k] }
      flea_keys.each { |k| @data[k] = !is_enabled }
      Rbcli.log.info "Flea locations are #{is_enabled ? 'hidden' : 'revealed'} on map", 'CHEATS'
    end

    def toggle_cloakless
      if @data['playerData']['CurrentCrestID'] != 'Cloakless'
        Rbcli.log.info 'Going cloakless', 'CHEATS'
        @data['playerData']['TempGeoStore'] = @data['playerData']['geo']
        @data['playerData']['geo'] = 0
        @data['playerData']['TempShellShardStore'] = @data['playerData']['ShellShards']
        @data['playerData']['ShellShards'] = 0
        @data['playerData']['PreviousCrestID'] = @data['playerData']['CurrentCrestID']
        @data['playerData']['CurrentCrestID'] = 'Cloakless'
        @data['playerData']['slab_cloak_battle_encountered'] = false
        @data['playerData']['slab_cloak_battle_completed'] = false
        @data['playerData']['IsSilkSpoolBroken'] = true
        unless @data['playerData']['ToolEquips']['savedData'].find { |e| e['Name'] == 'Cloakless' }
          cheatdata = Silkedit::Cheat::SilksongCheats.module_eval { @cheatdata }
          @data['playerData']['ToolEquips']['savedData'].append(cheatdata['reference']['cloakless']['playerData']['ToolEquips']['savedData'].first)
        end
      else
        Rbcli.log.info 'Recovering cloak', 'CHEATS'
        @data['playerData']['geo'] = @data['playerData']['TempGeoStore']
        @data['playerData']['TempGeoStore'] = 0
        @data['playerData']['ShellShards'] = @data['playerData']['TempShellShardStore']
        @data['playerData']['TempShellShardStore'] = 0
        @data['playerData']['CurrentCrestID'] = @data['playerData']['PreviousCrestID']
        @data['playerData']['PreviousCrestID'] = 'Cloakless'
        # @data['playerData']['slab_cloak_battle_encountered'] = true
        # @data['playerData']['slab_cloak_battle_completed'] = true
        @data['playerData']['IsSilkSpoolBroken'] = false
      end
    end

    def toggle_permadeath_mode
      toggle = @data['playerData']['permadeathMode'] == 0
      Rbcli.log.info "Toggling permadeath mode #{toggle ? 'ON' : 'OFF'}", 'CHEATS'
      @data['playerData']['permadeathMode'] = toggle ? 1 : 0
    end
  end
end