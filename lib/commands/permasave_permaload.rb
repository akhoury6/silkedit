Rbcli.command 'permasave' do
  description 'Saves a local copy of a game into the config to restore later.'
  parameter :name, 'Name to give the savegame', short: :n, type: :string, required: true
  action do |opts, params, args, config, env|
    permasave_file = config[:permasave_file_location][Silkedit::Sys.os]
    permasave_file = permasave_file.gsub('%APPDATA%', ENV['APPDATA'] || ENV['LOCALAPPDATA']) if Silkedit::Sys.os == :windows
    permasave_file = File.expand_path(permasave_file)
    unless File.exist?(permasave_file)
      FileUtils.cp(File.join(Silkedit::LIBDIR, 'config', 'silksong', 'permasaves.yaml'), permasave_file)
    end
    permasaves = YAML.safe_load_file(permasave_file)
    Rbcli.log.fatal('Permasaves file is corrupt. Please delete or fix it and try again.', exit_status: 1) unless permasaves.is_a?(Hash)

    params[:name] = params[:name].downcase
    if permasaves.key?(params[:name])
      Rbcli.log.warn "Found existing permasave: #{params[:name]}"
      next unless Silkedit::Sys.yes_no?('Overwrite?')
    end

    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    s.load_from_dat
    permasaves[params[:name]] = YAML.safe_dump(s.data).compress
    File.write(permasave_file, YAML.safe_dump(permasaves))

    Rbcli.log.info "Permasave #{params[:name]} saved from slot #{opts[:savenum]}"
  end
end

Rbcli.command 'permaload' do
  description 'Restores a permasave into the slot'
  parameter :name, 'Name of the permasave to load', short: :n, type: :string, required: false
  parameter :list, 'List all permasaves', short: :l, type: :bool, default: false
  action do |opts, params, args, config, env|
    permasave_file = config[:permasave_file_location][Silkedit::Sys.os]
    permasave_file = permasave_file.gsub('%APPDATA%', ENV['APPDATA'] || ENV['LOCALAPPDATA']) if Silkedit::Sys.os == :windows
    permasave_file = File.expand_path(permasave_file)
    unless File.exist?(permasave_file)
      FileUtils.cp(File.join(Silkedit::LIBDIR, 'config', 'silksong', 'permasaves.yaml'), permasave_file)
    end
    permasaves = YAML.safe_load_file(permasave_file)
    Rbcli.log.fatal('Permasaves file is corrupt. Please delete or fix it and try again.', exit_status: 1) unless permasaves.is_a?(Hash)

    if !params[:name] && !params[:list]
      Rbcli.log.warn 'Must provide a permasave name to load, or use --(l)ist to list all permasaves.'
      next
    elsif params[:list]
      Rbcli.log.info permasaves.keys.join("\n")
      next
    end
    params[:name] = params[:name].downcase

    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    if permasaves.is_a?(Hash) && permasaves.key?(params[:name])
      s.data = YAML.safe_load(permasaves[params[:name]].decompress)
      s.data['profileID'] = opts[:savenum].to_i
      s.save_to_dat
      Rbcli.log.info "Permasave #{params[:name]} loaded to slot #{opts[:savenum]}."
    else
      Rbcli.log.warn "Permasave #{params[:name]} does not exist. Exiting."
    end
  end
end