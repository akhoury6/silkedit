Rbcli.command 'unpack' do
  description 'Unpacks a save file or backup to JSON/YAML for manual editing'
  parameter :backup_seq, 'Sequence number for the backup to unpack', short: :b, type: :integer
  action do |opts, params, args, config, env|
    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    if params[:backup_seq].nil?
      s.load_from_dat
      s.save_to_json
      Rbcli.log.info 'Unpacked savefile to json/yaml'
    else
      s.load_from_backup(seq_number: params[:backup_seq])
      s.save_to_json
      Rbcli.log.info "Unpacked backup ##{params[:backup_seq]}"
    end
  end
end

Rbcli.command 'repack' do
  description 'Packs the JSON/YAML to the savefile'
  action do |opts, params, args, config, env|
    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    s.load_from_json
    s.direct_backup
    s.save_to_dat
    Rbcli.log.info 'Repacked savefile from json/yaml'
  end
end