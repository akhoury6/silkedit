Rbcli.command 'cheat' do
  description 'Applies one or more cheats to the selected savefile'
  usage '<cheat1> <cheat2> <cheat3>...'
  parameter :list, 'List all cheats', type: :bool, default: false
  # parameter :force, "Force application of a cheat even when requirements aren't met. Additional changes may be made to your savegave.", type: :bool, default: false
  action do |opts, params, args, config, env|
    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    s.load_from_dat
    c = Silkedit::Cheat::Engine.new(s.data)

    display_simple_list = lambda do |list, cols|
      max_length = list.map(&:length).max
      display_set = []
      rows = (list.length / cols.to_f).ceil
      row_idx = 0
      max_rows = rows - 1
      list.length.times do |i|
        display_set[row_idx] ||= []
        display_set[row_idx] << list[i]
        row_idx += 1
        row_idx = 0 if row_idx > max_rows
      end
      display_set.map { |row| row.map { |z| z.ljust(max_length) }.join('   ') }.join("\n")
    end

    if args.empty? || params[:list]
      Rbcli.log.info 'Cheats:'
      Rbcli.log.info display_simple_list.call(c.list_cheats, 5)
      Rbcli.exit(0)
    end

    changes = args.map do |cht|
      cht = cht.downcase
      status = c.apply_cheat(cht)
      case status
      when :no_cheat
        Rbcli.log.warn "Could not apply cheat #{cht}: Cheat does not exist"
        Rbcli.log.info 'Did you mean one of these?'
        possible_cheats = c.list_cheats.select { |cheat| cheat.include?(cht) }
        Rbcli.log.info display_simple_list.call(possible_cheats, 5)
        nil
      when :failed_act_check
        Rbcli.log.warn "Could not apply cheat #{cht.colorize(:red)}: The player is in the wrong act. Use --(f)orce to override."
        nil
      when :failed_soft_reqs
        Rbcli.log.warn "Could not apply cheat #{cht.colorize(:red)}: Soft requirements not met. Use --(f)orce to apply the required changes."
        nil
      when :failed_hard_reqs
        Rbcli.log.error "Could not apply cheat #{cht.colorize(:red)}: Hard requirements not met. Applying the cheat would cause in-game errors."
        nil
      when :success
        Rbcli.log.info "    Success!".colorize(:green)
        cht
      else
        raise "Unknown status: #{status}"
      end
    end

    if changes.empty?
      Rbcli.log.info ''
      Rbcli.log.info 'No cheats applied'
      Rbcli.exit(0)
    end

    if changes.include?(nil)
      Rbcli.log.info ''
      Rbcli.log.info 'Some cheats failed to apply. Discarding changes.'
      Rbcli.exit(0)
    end

    s.direct_backup
    s.save_to_dat
  end
end