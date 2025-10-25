module Silkedit::Savegame
  class SaveFile
    def initialize(game, savegame_index)
      # Rbcli::Warehouse.get(:config, :parsedopts)
      Rbcli.log.fatal('Running on unknown OS. Exiting.', exit_status: 25) if Silkedit::Sys.os.nil?

      config = YAML.safe_load_file(File.join(Silkedit::LIBDIR, 'config', 'savegame.yaml'), symbolize_names: true)

      @max_backups = config[:max_backups]
      @use_yaml = config[:use_yaml]
      @game = game
      @data = nil

      basename = "user#{savegame_index}"
      @dirs = {
        saves: File.expand_path(config[:savegame_directory][@game][Silkedit::Sys.os]),
        work: File.join(Silkedit::Sys.tmpdir, @game.to_s),
        backups: File.join(Silkedit::Sys.tmpdir, @game.to_s)
      }
      if @dirs[:saves].include?('%STEAMID%')
        @dirs[:saves] = Dir.glob(File.join(File.dirname(@dirs[:saves]), '*')).select { |f| File.basename(f).match(%r{\d+}) }.first
      end
      @dirs.each_value { |dir| FileUtils.mkdir_p(dir) unless File.directory?(dir) }
      @filenames = {
        dat: File.join(@dirs[:saves], "#{basename}.dat"),
        json: File.join(@dirs[:work], "#{basename}.#{@use_yaml ? 'yaml' : 'json'}"),
        backup: File.join(@dirs[:backups], "#{basename}.bak")
      }
      @filenames[:backups] = self.get_backup_file_list
      Rbcli.log.debug "Savegame directory: #{@dirs[:saves]}", 'SAVEGAME'
      Rbcli.log.debug "Working directory:  #{@dirs[:work]}", 'SAVEGAME'
    end

    attr_accessor :data
    attr_reader :dirs, :filenames, :game

    def loaded?
      !@data.nil?
    end

    def load_from_dat
      load_from_disk(@filenames[:dat])
      self
    end

    def save_to_dat
      save_to_disk(@filenames[:dat], pack: true)
      self
    end

    def load_from_json
      load_from_disk(@filenames[:json])
      self
    end

    def save_to_json
      save_to_disk(@filenames[:json], pack: false)
      self
    end

    def del_json
      FileUtils.rm(@filenames[:json])
      self
    end

    def load_from_backup(seq_number: nil)
      all_backup_files = self.get_backup_file_list
      return false if all_backup_files.empty?
      selected_file = seq_number.nil? ? all_backup_files.last : "#{@filenames[:backup]}#{seq_number}"
      return false unless File.exist?(selected_file)
      load_from_disk(selected_file)
      self
    end

    def save_to_backup(backup_name: nil)
      if backup_name.nil?
        return false if @max_backups <= 0
        self.remove_old_backups
        backup_filename = "#{@filenames[:backup]}#{self.next_backup_seq_number}"
      else
        backup_filename = "#{@filenames[:backup]}.#{backup_name}"
      end
      save_to_disk(backup_filename, pack: true)
      backup_filename
    end

    def direct_backup(backup_name: nil)
      if backup_name.nil?
        return false if @max_backups <= 0
        self.remove_old_backups
        backup_filename = "#{@filenames[:backup]}#{self.next_backup_seq_number}"
      else
        backup_filename = "#{@filenames[:backup]}.#{backup_name}"
      end
      FileUtils.cp(@filenames[:dat], backup_filename)
      @filenames[:backups] = self.get_backup_file_list
      Rbcli.log.info "Backed up savefile to #{backup_filename}", 'SAVEGAME'
      backup_filename
    end

    def direct_restore(seq_number: nil, backup_name: nil)
      if seq_number.nil? && backup_name.nil?
        all_backup_files = self.get_backup_file_list
        return false if all_backup_files.empty?
        selected_file = all_backup_files.last
      elsif !seq_number.nil?
        all_seq_numbers = self.get_backup_file_list.map { |f| File.extname(f).scan(/\d+$/).first }.reject(&:nil?).map { |n| n.to_i }
        return false unless all_seq_numbers.include?(seq_number)
        selected_file = "#{@filenames[:backup]}#{seq_number}"
      elsif !backup_name.nil?
        return false unless File.exist?("#{@filenames[:backup]}.#{backup_name}")
        selected_file = "#{@filenames[:backup]}.#{backup_name}"
      end
      FileUtils.cp(selected_file, @filenames[:dat])
      Rbcli.log.info "Restored savefile from #{selected_file}", 'SAVEGAME'
      selected_file
    end

    private

    def load_from_disk(filename)
      begin
        data = File.read(filename)
      rescue Errno::ENOENT
        Rbcli.log.fatal("File not found: #{filename}.", exit_status: 25)
      end
      data = Packer.unpack(data) if Packer.can_unpack?(data)
      Rbcli.log.info "Loaded from #{File.basename(filename)}", 'SAVEGAME'
      @data = YAML.safe_load(data)
      # @data = JSON.parse(data)
    end

    def save_to_disk(filename, pack: false)
      data = (@use_yaml && !pack) ? YAML.safe_dump(@data) : JSON.pretty_generate(@data)
      data = Packer.pack(data) if pack
      File.write(filename, data)
      Rbcli.log.info "Saved to #{File.basename(filename)}", 'SAVEGAME'
    end

    def get_backup_file_list
      Dir.glob("#{@filenames[:backup]}*").select { |f| f.match?(/#{File.basename(@filenames[:backup])}\d+$/) }.sort_by { |f| File.extname(f).scan(/\d+$/).first.to_i }
    end

    def remove_old_backups
      all_backup_files = self.get_backup_file_list
      while !all_backup_files.empty? && all_backup_files.length >= @max_backups
        FileUtils.rm(all_backup_files.shift)
      end
    end

    def next_backup_seq_number
      all_backup_files = self.get_backup_file_list
      return 0 if all_backup_files.empty?
      all_backup_files.map { |f| File.extname(f).scan(/\d+$/).first }.reject(&:nil?).map { |n| n.to_i }.max + 1
    end
  end
end