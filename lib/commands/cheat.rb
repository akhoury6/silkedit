Rbcli.command 'cheat' do
  description 'Applies one or more cheats to the selected savefile'
  usage '<cheat1> <cheat2> <cheat3>...'
  parameter :list, 'List all cheats', type: :bool, default: false
  action do |opts, params, args, config, env|
    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    s.load_from_dat
    c = Silkedit::Cheat::Engine.new(s.data)
    selected_cheats = args.map { |arg| arg.downcase }.select { |cht| c.cheat_exists?(cht) }
    if params[:list] || selected_cheats.empty?
      Rbcli.log.info "Cheats: \n" + c.list_cheats.map(&:to_s).join("\n")
    else
      selected_cheats.each { |cht| c.apply_cheat(cht) }
      s.direct_backup
      # s.save_to_dat
      Rbcli.log.info "applied cheats: #{selected_cheats.join(', ')}"
    end
  end
end