module Silkedit::Cheat
  def self.merge_cheat(data, cheat, should_merge_arrays: true, force_soft_reqs: false, enforce_min_act: false)
    # 1. Check act requirement
    game_act = self.get_game_act(data)
    Rbcli.log.debug "Game act is #{game_act}, required act is #{cheat['min_act']}", 'CHEATS'
    return :failed_act_check if enforce_min_act && cheat.key?('min_act') && game_act < cheat['min_act']

    # 2. Check hard reqs and abort if not met
    if cheat.key?('hard_reqs') && !cheat['hard_reqs'].nil? && !cheat['hard_reqs'].empty?
      return :failed_hard_reqs unless verify_hash(data, cheat['hard_reqs'])
    end

    # 3. Check soft reqs, and either queue them to be applied or abort
    queue_soft_reqs = false
    if cheat.key?('soft_reqs') && !cheat['soft_reqs'].nil? && !cheat['soft_reqs'].empty?
      unless verify_hash(data, cheat['soft_reqs'])
        return :failed_soft_reqs unless force_soft_reqs
        queue_soft_reqs = true
      end
    end

    # 4. Apply cheat
    self.merge_hash(data, cheat['soft_reqs'], should_merge_arrays: true) if queue_soft_reqs
    self.merge_hash(data, cheat['data'], should_merge_arrays: should_merge_arrays)
    :success
  end

  def self.merge_hash(data, cheat, should_merge_arrays: true)
    cheat.each_key do |k|
      if cheat[k].is_a?(Hash) && data[k].is_a?(Hash)
        merge_hash(data[k], cheat[k])
      elsif should_merge_arrays && cheat[k].is_a?(Array) && data[k].is_a?(Array)
        if cheat[k][0].is_a?(Hash)
          data[k] = merge_arrays_by_hash_keys(data[k], cheat[k])
        else
          data[k].merge!(cheat[k])
          data[k].uniq!
        end
      else
        data[k] = cheat[k]
      end
    end
    true
  end

  def self.merge_arrays_by_hash_keys(data, cheat)
    return data unless data.is_a?(Array) && cheat.is_a?(Array) && cheat.first.is_a?(Hash)
    if data.empty?
      data = cheat
      return data
    end
    # First determine the primary key(s) for the object
    pkeys = []
    [%w[Name], %w[SceneName ID]].each do |pkey_arr|
      pkeys = pkey_arr if pkey_arr.all? { |k| data.first.key?(k) || cheat.first.key?(k) }
    end
    cheat.each do |c|
      idx = data.find_index { |d| d.is_a?(Hash) && pkeys.all? { |k| d.key?(k) && d[k] == c[k] } }
      if idx
        self.merge_hash(data[idx], c, should_merge_arrays: true)
      else
        data << c
      end
    end
    data
  end

  def self.verify_hash(data, reqs)
    reqs.each_key do |k|
      if reqs[k].is_a?(Hash) && data[k].is_a?(Hash)
        return false unless verify_hash(data[k], reqs[k])
      elsif reqs[k].is_a?(Array) && data[k].is_a?(Array)
        if reqs[k].first.is_a?(Hash)
          return false unless verify_array_of_hashes(data[k], reqs[k])
        else
          return false unless reqs[k].all? { |r| data[k].include?(r) }
        end
      else
        return false unless data[k] == reqs[k]
      end
    end
    true
  end

  def self.verify_array_of_hashes(data, reqs)
    # First determine the primary key(s) for the object
    pkeys = []
    [%w[Name], %w[SceneName ID]].each do |pkey_arr|
      pkeys = pkey_arr if pkey_arr.all? { |k| data.first.key?(k) || reqs.first.key?(k) }
    end
    reqs.each do |r|
      idx = data.find_index { |d| d.is_a?(Hash) && pkeys.all? { |k| d.key?(k) && d[k] == r[k] } }
      return false unless idx && self.verify_hash(data[idx], r)
    end
    true
  end

  def self.get_game_act(data)
    if %w[act3MapUpdated act3_wokeup].any? { |c| data['playerData'][c] }
      3
    elsif %w[act2started visitedCitadel defeatedLastJudge].any? { |c| data['playerData'][c] }
      2
    else
      1
    end
  end
end
