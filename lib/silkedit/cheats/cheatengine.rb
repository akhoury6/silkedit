module Silkedit::Cheat
  class Engine
    def initialize(savedata)
      @data = savedata
      game = detect_game(@data)
      @modules = %w[Cheats Zoner Journaler].map { |type| [type, Silkedit::Cheat.const_get("#{game}#{type}")]}.to_h
      @modules.each_value { |mod| self.extend(mod) }
    end

    def apply_cheat(cheat, *args)
      return :no_cheat unless cheat_exists?(cheat.to_s)
      self.send(cheat.to_sym, *args)
    end

    def apply_cheats(cheats)
      cheats.map { |cheat| apply_cheat(cheat) }
    end

    def list_cheats
      @modules['Cheats'].instance_methods.map(&:to_s).sort
    end

    def cheat_exists?(cheat)
      list_cheats.include?(cheat)
    end

    private

    def detect_game(data = nil)
      (data || @data).key?('firstGeo') ? 'HollowKnight' : 'Silksong'
    end
  end
end