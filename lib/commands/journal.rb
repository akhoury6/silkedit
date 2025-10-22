Rbcli.command 'journal' do
  description 'Manages the journal of enemy kills'
  usage '[list|listmissing|complete|killsonly]'
  parameter :showimages, 'Show images of the enemies', short: 'i', type: :bool, default: false
  action do |opts, params, args, config, env|
    command = args.first
    if command.nil? || command.empty? || !%w[list listmissing complete killsonly].include?(command)
      Rbcli.log.error "Must specify an action as one of: listall, listmissing, complete, killsonly"
      next
    end

    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    s.load_from_dat
    c = Silkedit::Cheat::Engine.new(s.data)

    case command
    when 'listall'
      c.enemy_list(only_missing: false, show_images: params[:showimages])
    when 'listmissing'
      c.enemy_list(only_missing: true, show_images: params[:showimages])
    when 'complete'
      c.update_journal(should_update_kills_only: false)
      s.direct_backup
      s.save_to_dat
    when 'killsonly'
      c.update_journal(should_update_kills_only: true)
      s.direct_backup
      s.save_to_dat
    else
      raise "Unknown command: #{command}"
    end

  end
end