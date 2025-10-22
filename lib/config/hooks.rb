Rbcli::Configurate.hooks do
  ##### Hooks (Optional) #####
  # These hooks are scheduled on the Rbcli execution engine to run
  # Pre- and Post- the command specified. They are executed after
  # everything else has been initialized, so the runtime configuration
  # values are all made available, as they will appear to the command.
  #
  # These are good for parsing and/or doing transformations on the provided
  # configuration before passing them to the command, and for cleaning
  # up your environment afterwards.
  pre_execute do |opts, params, args, config, env|
    opts[:savenum] = env[:savenum] if opts[:savenum].nil? && !env[:savenum].nil?

    if !opts[:savenum].is_a?(Integer) || opts[:savenum] < 1 || opts[:savenum] > 4
      Rbcli.log.fatal 'A savegame index between 1-4 must be specified either via the command line (-s #) or environment variable (SILKEDIT_SAVENUM=#). See help (-h) for details.', exit_status: 24
    end
  end

  # post_execute do |opts, params, args, config, env|
  #   Rbcli.log.info "I'm done running the command!"
  # end
end