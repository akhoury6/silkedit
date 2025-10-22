Rbcli::Configurate.updatechecker do
  ##### Update Check (Optional) #####
  # The application can warn users when a new version is released
  # Checks can be done either by rubygems or by a Github repo
  # Private servers for Github (enterprise) are supported
  #
  # Setting force_update to true will halt execution until it is updated
  #
  # For Github, an access_token is required for private repos. See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
  # gem 'silkedit', force_update: false, message: 'Please run `gem update silkedit` to upgrade to the latest version.'
  # github 'repo/name', access_token: nil, enterprise_hostname: nil, force_update: false, message: 'Please download the latest version from Github'
end