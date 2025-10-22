Rbcli.command 'zone' do
  description 'Zones the character to a different respawn point'
  usage '<zone> (--(f)orce)'
  parameter :force, 'Force select a spawn point even when requirements are not met. Changes may be made to your savegave.', type: :bool, default: false
  parameter :list, 'Display the full list of zones to select from', type: :bool, default: false
  action do |opts, params, args, config, env|
    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    s.load_from_dat
    c = Silkedit::Cheat::Engine.new(s.data)

    display_simple_zone_list = lambda do |list, cols|
      display_set = []
      rows = (c.list_shortcuts.length / cols.to_f).ceil
      row_idx = 0
      max_rows = rows - 1
      c.list_shortcuts.length.times do |i|
        display_set[row_idx] ||= []
        display_set[row_idx] << c.list_shortcuts.keys[i]
        row_idx += 1
        row_idx = 0 if row_idx > max_rows
      end
      display_set.map { |row| row.map { |z| z.rjust(15) }.join(' ') }.join("\n")
    end

    display_detailed_zone_list = lambda do |list|
      max_shortcut_length = list.map { |zone| (zone[:shortcut] || '').length }.max
      formatter = "%-#{max_shortcut_length}s %3s %s"
      final_string = ''
      final_string << format(formatter, 'Shortcut', 'Act', 'Zone') + "\n"
      final_string << list.map { |zone| format(formatter, zone[:shortcut], zone[:min_act], zone[:slug]) }.join("\n")
      final_string
    end

    if args.empty? || params[:list]
      Rbcli.log.info 'Shortcuts:'
      Rbcli.log.info display_simple_zone_list.call(c.list_shortcuts, 5)
    end

    if params[:list]
      Rbcli.log.info ''
      Rbcli.log.info 'Zones:'
      Rbcli.log.info display_detailed_zone_list.call(c.list_zones)
    end

    Rbcli.exit(0) if args.empty? || params[:list]

    status = c.zone_to(args.first, force_soft_reqs: params[:force], enforce_min_act: !params[:force])
    case status
    when :no_zone
      Rbcli.log.info "Could not zone to #{args.first}: Specified spawn point does not exist"
      Rbcli.log.info 'Did you mean one of these?'
      possible_zones = c.list_zones.select { |zone| zone[:slug].include?(args.first) || !zone[:shortcut].nil? && zone[:shortcut].include?(args.first) }
      Rbcli.log.info display_detailed_zone_list.call(possible_zones)
    when :failed_act_check
      Rbcli.log.warn "Could not zone to #{args.first}: The player is in the wrong act. Use --(f)orce to override."
    when :failed_soft_reqs
      Rbcli.log.warn "Could not zone to #{args.first}: Soft requirements not met. Use --(f)orce to apply the required changes."
    when :failed_hard_reqs
      Rbcli.log.error "Could not zone to #{args.first}: Hard requirements not met. Zoning here would cause errors."
    when :success
      s.direct_backup
      s.save_to_dat
      Rbcli.log.info "Zoned to #{args.first}"
    else
      raise "Unknown status: #{status}"
    end
  end
end

Rbcli.command 'mkzone' do
  description 'Adds a new spawn point to the library'
  usage '<slug>'
  parameter :slug, 'The slug of the zone to add', type: :string
  parameter :act, 'Override default act detection', type: :integer
  parameter :shortcut, 'Provide a shorter slug as a shortcut for the zone', short: 'o', type: :string
  parameter :force, 'Force overwrite of existing zone', type: :bool, default: false
  action do |opts, params, args, config, env|
    if params[:slug].nil?
      Rbcli.log.error 'Must provide a zone slug'
      next
    end

    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    s.load_from_dat
    c = Silkedit::Cheat::Engine.new(s.data)

    status = c.save_current_zone(params[:slug], params[:shortcut], params[:act], overwrite: params[:force])

    case status
    when :badname
      Rbcli.log.error 'Invalid zone name. Zones must be formatted as: region.target'
    when :badact
      Rbcli.log.error 'Invalid act number. Act must be between 1 and 3, or leave blank for autodetection.'
    when :badshortcut
      Rbcli.log.error 'Invalid shortcut. Shortcuts must not have a period (.) in them.'
    when :success
      Rbcli.log.info "Added #{params[:slug]} to zonelist."
    else
      Rbcli.log.error "Duplicate zone found: #{status}. Use --(f)orce to overwrite."
    end
  end
end