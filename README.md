# QuestProgressSound

A World of Warcraft addon that plays customizable sounds and displays chat notifications when you or your group members make progress on quests or complete them.

## Features

- **Own Quest Progress**: Sound and chat notification when you make progress on your quests
- **Own Quest Completion**: Sound and chat notification when you complete a quest
- **Group Quest Progress**: Sound and chat notification when party members make progress
- **Group Quest Completion**: Sound and chat notification when party members complete quests
- **Chat Notifications**: Independently configurable chat messages for all event types
- **Group Communication Control**: Choose to share quest progress only in groups (not raids)
- **Profile Management**: Full profile support with create, switch, copy, delete, and reset functionality
- **Customizable Sounds**: Choose from built-in sounds, any sound from LibSharedMedia-3.0, or "None" to disable
- **Internationalization**: Supports English (enUS) and German (deDE)
- **Compact UI**: Streamlined configuration panel with horizontal layout

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
- **Quest Progress**: Select sound (or "None") and enable/disable chat notification
- **Quest Completion**: Select sound (or "None") and enable/disable chat notification

**Group Quests Section:**
- **Only in Group**: Enable to send/receive quest updates only in party groups (not raids)
- **Quest Progress**: Select sound (or "None") and enable/disable chat notification for group members
- **Quest Completion**: Select sound (or "None") and enable/disable chat notification for group members

**Profile Management:**
- Create new profiles
- Switch between profiles
- Copy settings from other profiles
- Delete unused profiles
- Reset profiles to defaults

### Sound Configuration

- Select sounds from the dropdown menu (includes all LibSharedMedia-3.0 sounds)
- Choose **"None"** to disable sound for any event type
- Sounds can be independently configured for each event type
- Preview sounds by selecting them from the dropdown

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
