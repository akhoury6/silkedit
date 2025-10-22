Rbcli.command 'edit' do
  description 'Edit the savefile directly'
  action do |opts, params, args, config, env|
    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    s.load_from_dat
    s.save_to_json
    Process.wait(Process.spawn(config[:editor_command].sub('%FILE%', s.filenames[:json])))
    if Silkedit::Sys.yes_no?('Apply changes?')
      s.load_from_json
      s.direct_backup
      s.save_to_dat
      Rbcli.log.info 'Updated savefile'
    else
      Rbcli.log.info 'Aborted'
    end
  end
end

Rbcli.command 'diff' do
  description 'Diffs the current savegame against the latest backup, a specified backup, or a different save'
  parameter :backup_seq, 'Backup number to diff against', short: :b, type: :integer
  parameter :othersave, 'Other save number to diff against', short: :o, type: :integer
  parameter :yaml_output, 'Output in YAML instead of a Ruby object', short: :y, type: :boolean


  action do |opts, params, args, config, env|
    new = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    new.load_from_dat
    if params[:othersave]
      old = Silkedit::Savegame::SaveFile.new(:silksong, params[:othersave])
      old.load_from_dat
    else
      old = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
      old.load_from_backup(seq_number: params[:backup_seq])
    end

    diff = Silkedit::Savegame::Diff.mkdiff(old.data, new.data)
    Rbcli.log.info Silkedit::Savegame::Diff.parse_diff(diff, yaml_output: params[:yaml_output])

    # s.save_as_json
    # FileUtils.mv(s.json_filename, "#{s.json_filename}.old")
    # s.load_from_dat
    # s.save_as_json
    # FileUtils.mv(s.json_filename, "#{s.json_filename}.new")
    # Process.wait(Process.spawn(config[:diff_command].sub('%OLD%', "#{s.json_filename}.old").sub('%NEW%', "#{s.json_filename}.new")))
  end
end