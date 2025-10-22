Rbcli::Configurate.envvars do
  ##### Environment Variable Parsing (Optional) #####
  # The envvars module can pull in all environment variables with a given
  # prefix and organize them into a hash structure based on name.
  # It will also parse the string values and convert them to the proper type (Integer, Boolean, etc)
  # Any values set here will be treated as defaults and made available when a variable is missing
  #
  # For example, these two environment variables:
  #   SILKEDIT_TERM_HEIGHT=40
  #   SILKEDIT_TERM_WIDTH=120
  # Would be declared here as:
  #   prefix 'SILKEDIT'
  #   envvar 'TERM_HEIGHT', 40
  #   envvar 'TERM_WIDTH', 120
  # And get loaded into the env hash as:
  #   { term: { height: 40, width: 120 } }
  #
  # If the prefix is unset or equal to nil, the environment variables specified here will
  # be loaded without one.
  prefix 'SILKEDIT'
  envvar 'SAVENUM', nil
  envvar 'DEVELOPMENT', false
end