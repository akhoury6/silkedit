Rbcli::Configurate.cli do
  ##### Core Configuration (Required) #####
  # appname          (Optional) - Defaults to the name of the executable
  # author           (Optional) - A name or array of names
  # email            (Optional) - An email for users to contact
  # version          (Optional) - major.minor.patch notation, required if using update checks
  # copyright_year   (Optional) - Self explanatory
  # compatibility    (Optional) - Array of Operating Systems, devices, or other targets (For example: %w[MacOS Linux Ubuntu Windows Raspberry\ Pi]
  # license          (Optional) - Convention is to use an identifier from here: https://spdx.org/licenses/
  # helptext         (Optional) - Text that gets shown with --help or -h
  appname nil
  author ['Andrew Khoury']
  email nil
  version Silkedit::VERSION
  copyright_year 2025
  compatibility %w[MacOS Linux]
  license 'GPL-3.0'
  helptext 'This is a tool to quickly and easily edit savefiles for SilkSong.'
  ##### CLI Options (Optional) #####
  # These appear to commands as `opts`.
  # Format:
  #   opt :name, "Description"[, optional arguments ]
  # Optional Arguments:
  #   long: Specify the long form (--long) version of an argument. (Default: same as the name)
  #   short: Specify the short form (-s) version of an argument. (Default: first letter of the name)
  #   type: Specify the type. Valid options are :boolean, :float, :integer, :string, :io, :date. (Default: :boolean)
  #     If the plural form of any of the above are used (i.e. ':strings') then the user can provide a comma-delimited list on the command line (--param=foo,bar)
  #   required: If set to true, requires that this option is provided by the user. (Default: false)
  #   multi: If set to true, allows the option to be provided multiple times (--param --param, or in short form, -pp). (Default: false)
  #     When using this with a :boolean type, rather than returning `true` or `false`, it will return a count of the number of times the parameter was passed.
  #   permitted: If set to an array, restricts input to the values within that array. (Default: nil (no restrictions))
  opt :verbose, "Twice or more enables very-verbose output", multi: true
  opt :savenum, "A number from 1-4, indicating which game save you'd like to address", short: 's', type: :integer
end