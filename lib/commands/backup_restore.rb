Rbcli.command 'backup' do
  description 'Backs up the savefile'
  parameter :custom_name, 'Give the backup a custom name. Named backups can\'t be edited.', short: :n, type: :string
  action do |opts, params, args, config, env|
    s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
    s.direct_backup(backup_name: params[:custom_name])
  end
end

Rbcli.command 'restore' do
  description 'Restore a backup to the savefile. Providing no parameters restores the latest backup.'
  parameter :backup_seq, 'Backup number to restore (Can\'t use together with named backup)', short: :b, type: :integer
  parameter :backup_name, 'Named backup to restore', short: :n, type: :string

  action do |opts, params, args, config, env|
    if !params[:backup_seq].nil? && !params[:backup_name].nil?
      Rbcli.log.error 'Can\'t specify both a sequence and name at the same time.'
    else
      s = Silkedit::Savegame::SaveFile.new(:silksong, opts[:savenum])
      unless s.direct_restore(seq_number: params[:backup_seq], backup_name: params[:backup_name])
        Rbcli.log.error "Failed to restore backup"
      end
    end
  end
end