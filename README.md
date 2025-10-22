# Silkedit

Silkedit is a tool that allows quick and easy editing of savefiles for Hollow Knight and Silksong.

It has built-in cheats, can zone the player to nearly any bench or spawn point in the game (such as spawning where you obtain a skill), can edit the enemy journal to quickly update all required kills, and can save and restore the state of savefiles to provide you with a much larger save capacity.

What's useful to note is that the game has a few seconds in between when you exit a game and when the main menu gets loaded during which you can apply cheats to your savefile. This means that you don't have to exit out of the game to reload your cheats - just quit to the main menu and run silkedit before it loads.

Basic usage:

```bash
# Either supply the savegame number directly...
silkedit -s 1 cheat max_health max_silk quill_purple

# ...or keep it in an environment variable
export SILKEDIT_SAVENUM=1
silkedit cheat max_health max_silk quill_purple

# Un-kill your character, even in Silk Soul Mode
silkedit cheat unkill

# List all cheats and zones
silkedit cheat -l
silkedit zone -l

# Spawn at a different point when reloading the game
silkedit zone terminus

# Analyze or edit your enemy kill records
# If you have a terminal emulator compatible with `imgcat`
# (such as iterm2), images of the enemies will also be displayed.
silkedit journal listall
silkedit journal listmissing
silkedit journal killsonly
silkedit journal complete

# Or load up a pre-defined savefile to any slot
silkedit permaload -n act3complete
```

All available commands:
```
$ silkedit -h
  backup         Backs up the savefile
  restore        Restore a backup to the savefile. Providing no parameters restores the latest backup.
  cheat          Applies one or more cheats to the selected savefile
  edit           Edit the savefile directly
  diff           Diffs the current savegame against the latest backup, a specified backup, or a different save
  journal        Manages the journal of enemy kills
  permasave      Saves a local copy of a game into the config to restore later.
  permaload      Restores a permasave into the slot
  unpack         Unpacks a save file or backup to JSON/YAML for manual editing
  repack         Packs the JSON/YAML to the savefile
  zone           Zones the character to a different respawn point
  mkzone         Adds a new spawn point to the library
```

Available cheats:

```
$ silkedit cheat -l
all_abilities
all_crest_unlocks
all_crests
all_eva_upgrades
all_fasttravel
all_fleas
all_maps
all_spells
all_tools
complete_mushroom_quest
easy_dice_game_win
easy_flea_games_win
give_consumables
give_farsight
max_everything
max_health
max_liquids
max_rosaries
max_shards
max_silk
max_tool_upgrades
max_weapon
quill_none
quill_purple
quill_red
quill_white
refresh
toggle_cloakless
toggle_flea_reveal
toggle_map_reveal
toggle_permadeath_mode
unkill
unlock_terminus_door
```

Available Spawn Points

Note: The act shown is the expected act in the game when you'd normally get there. In most cases, however, you can ignore it and spawn anywhere during any act. Notable exceptions are the flea games during Act 1/2, or fleatopia during act 3. These will cause glitches.

```
$ silkedit zone -l
Shortcuts:
     bonebottom        greymoor    blastedsteps             spa       fleatopia
          druid     halfwayhome       pinstress       highhalls       fleagames
         marrow         yarnaby     sinnersroad        terminus         surface
          docks        bellhart       bilewater       architect     weavenest_a
          sauna        bellhome    exhaustorgan         faypeak     weavenest_c
      farfields           widow           ducts       fleacamp1           abyss
     seamstress       shellwood         cogcore       fleacamp2
   huntersmarch       alchemist       songclave       fleacamp3

Zones:
Shortcut     Act Zone
               3 abyss.bell_fixed
               3 abyss.north
abyss          3 abyss.south
bellhome       2 bellhart.bellhome
bellhart       1 bellhart.bench
               1 bellhart.widow_bellshrine
widow          1 bellhart.widow_spawn
               2 bilewater.bilehaven
               2 bilewater.east
exhaustorgan   1 bilewater.exhaustorgan
bilewater      1 bilewater.station
pinstress      1 blastedsteps.pinstress
               1 blastedsteps.south
blastedsteps   1 blastedsteps.station
surface        3 bordercaves.bench
               2 choralchambers.center
               2 choralchambers.northwest
               2 choralchambers.southwest
spa            2 choralchambers.spa
cogcore        2 cogcore.bench
               2 cogcore.dancers_spawn
               2 cogcore.melodytowers_spawn
               3 cradle.destroyed
               2 cradle.lace_spawn
terminus       1 cradle.terminus
               3 deepdocks.bell_fixed
               1 deepdocks.bellshrine
               1 deepdocks.dash_spawn
docks          1 deepdocks.forgedaughter
               3 deepdocks.fromabyss
sauna          2 deepdocks.sauna
               1 deepdocks.upper
               3 farfields.act3area
               1 farfields.pilgrimsrest
seamstress     1 farfields.seamstress
               3 farfields.sprintmaster
farfields      1 farfields.station
               1 farfields.upperentrance
weavenest_c    1 farfields.weavenest_cindril
               2 fay.cave
               2 fay.climb
faypeak        2 fay.peak
               2 fay.shakra
               1 grandbellway.station
fleacamp3      2 grandgate.fleacamp_3
greymoor       1 greymoor.bellshrine
fleacamp2      1 greymoor.fleacamp_2
halfwayhome    1 greymoor.halfwayhome
               1 greymoor.reaper_crest_spawn
               1 greymoor.shakra
               1 greymoor.yarnaby_spawn
               2 highhalls.station
huntersmarch   1 huntersmarch.trappedbench
               2 karak.coraltower
               2 karak.east
               1 marrow.entrance
fleacamp1      1 marrow.fleacamp_1
               1 marrow.jail_pinchallenge
marrow         1 marrow.station_bellshrine
               2 memorium.default
               1 memory.needolin
bonebottom     1 mossgrove.bonebottom
               1 mossgrove.chapel
               3 mossgrove.chapel_inside
druid          1 mossgrove.druid
               1 mossgrove.gamestart_respawn
               1 mossgrove.mosshome
               3 mossgrove.shaman_crest_spawn
               1 mossgrove.silkspear_spawn
               1 mossgrove.wanderer_crest_spawn
               3 putrifiedducts.fleafestival
fleatopia      2 putrifiedducts.fleatopia
               2 putrifiedducts.huntress
ducts          2 putrifiedducts.station
               1 shellwood.center
               1 shellwood.clinggrip_respawn
               3 shellwood.nyleth_spawn
               2 shellwood.south
shellwood      1 shellwood.station_bellshrine
               1 shellwood.west
               2 shellwood.witch_crest_spawn
               1 sinnersroad.east
               1 sinnersroad.east_permadeathmode
sinnersroad    1 sinnersroad.west
               1 slab.east
               2 slab.firstsinner_spawn
               1 slab.nw_inside
               1 slab.nw_outside
               1 slab.station
               2 songclave.bellshrine
songclave      2 songclave.bench
architect      2 underworks.architect
               2 underworks.harpoon_spawn
               2 underworks.north_a
               2 underworks.north_b
               2 underworks.north_c
               2 underworks.west
               3 verdania.bench
               1 weavenest.atla_bench
               1 weavenest.atla_eva_spawn
               2 whisperingvaults.keeper
               2 whisperingvaults.south
               2 whiteward.default
               2 wispthicket.default
alchemist      1 wormways.alchemist
               2 wormways.sharpdart_spawn
```

Provided Permasaves:

```
$ silkedit permaload -l
standard_mode_complete
silksoul_mode_complete
act3complete
act2complete
act1complete
act1speedrun
act2_pre_lace_and_witch
cursed_mother_kill
act3start
```

Example journal update (without images):

It asks for confirmation for any mob which has less than 10 required kills, as many of those have only a fixed number in game and not everyone may want to update them.

```
$ silkedit journal complete
(...)
  Great Conchfly              Seen? Y Kills:    1 Needed:    2 Left:    1
    Set Great Conchfly kills from 1 to 2? (y/n): n
* Roachfeeder                 Seen? Y Kills:   20 Needed:   20 Left:    0
    Already Completed.
* Roachkeeper                 Seen? Y Kills:   10 Needed:   10 Left:    0
    Already Completed.
  Last Judge                  Seen? N Kills:    0 Needed:    1 Left:    1
    Added to journal.
  Underpoke                   Seen? N Kills:    0 Needed:   25 Left:   25
(...)
```


## Installation

Silkedit is available on **rubygems**, and *should* work cross-platform. I don't own an x86 Windows system to test it but if you have one and find that it doesn't work, feel free to submit a bug report or pull request!

```bash
gem install silkedit
```

If you don't already have ruby on your system, you will need to install it.

### Windows

[https://rubyinstaller.org/downloads/](https://rubyinstaller.org/downloads/)

### MacOS

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Install rbenv
brew install rbenv
# Install ruby
rbenv install "$(rbenv install -l | grep -v - | tail -1)"
```

### Linux

[https://github.com/rbenv/rbenv?tab=readme-ov-file#using-package-managers](https://github.com/rbenv/rbenv?tab=readme-ov-file#using-package-managers)

If you already have ruby on your system, just run:


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akhoury6/silkedit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/silkedit/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Silkedit project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/silkedit/blob/master/CODE_OF_CONDUCT.md).
