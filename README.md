# QuestProgressSound

A World of Warcraft addon that plays customizable sounds when you or your group members make progress on quests or complete them.

## Features

- **Own Quest Progress**: Sound notification when you make progress on your quests
- **Own Quest Completion**: Sound notification when you complete a quest
- **Group Quest Progress**: Sound notification when party/raid members make progress
- **Group Quest Completion**: Sound notification when party/raid members complete quests
- **Profile Management**: Full profile support with create, switch, copy, delete, and reset functionality
- **Customizable Sounds**: Choose from built-in sounds or any sound from LibSharedMedia-3.0
- **Internationalization**: Supports English (enUS) and German (deDE)
- **Group Communication**: Automatically shares quest progress with party/raid members

## Installation

1. Download the latest release
2. Extract the `QuestProgressSound` folder to your WoW AddOns directory:
   - `World of Warcraft\_retail_\Interface\AddOns\`
3. Restart WoW or reload UI (`/reload`)

## Configuration

Access the settings via:
- Game Menu → Options → AddOns → QuestProgressSound
- Or use `/qps` in chat

### Options

**Own Quests Section:**
- Enable/disable progress sounds
- Enable/disable completion sounds
- Customize sounds for progress and completion

**Group Quests Section:**
- Enable/disable group progress sounds
- Enable/disable group completion sounds
- Customize sounds for group events

**Profile Management:**
- Create new profiles
- Switch between profiles
- Copy settings from other profiles
- Delete unused profiles
- Reset profiles to defaults

## Commands

- `/qps` - Opens the configuration panel

## Technical Details

- **WoW Version**: Retail (12.0+)
- **API**: Interface 120000, 120001
- **Libraries**: 
  - AceDB-3.0 (profile management)
  - AceDBOptions-3.0 (profile UI)
  - AceLocale-3.0 (internationalization)
  - LibSharedMedia-3.0 (sound library)

## Localization

Currently supported languages:
- English (enUS) - Default
- German (deDE)

## License

MIT License - See LICENSE file for details

## Credits

Built with Ace3 libraries and LibSharedMedia-3.0
