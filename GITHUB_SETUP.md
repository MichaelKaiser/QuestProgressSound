# QuestProgressSound - GitHub Setup

## Bereits erledigt
- ✅ .gitignore erstellt
- ✅ README.md erstellt  
- ✅ LICENSE erstellt (MIT)

## Nächste Schritte

### 1. Git installieren (falls noch nicht vorhanden)
Download: https://git-scm.com/download/win

### 2. Git Repository initialisieren
```powershell
cd "d:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\QuestProgressSound"
git init
git add .
git commit -m "Initial commit: QuestProgressSound addon with profile management and i18n"
```

### 3. Repository auf GitHub erstellen
1. Gehe zu https://github.com/new
2. Repository Name: `QuestProgressSound` (oder ein anderer Name deiner Wahl)
3. Beschreibung: "WoW addon for quest progress sound notifications"
4. **Wichtig**: Wähle "Public" (oder "Private" wenn du möchtest)
5. **Nicht** "Initialize with README" ankreuzen (wir haben bereits eins)
6. Klicke "Create repository"

### 4. Lokales Repository mit GitHub verbinden
Ersetze `DEIN-USERNAME` mit deinem GitHub-Benutzernamen:

```powershell
git remote add origin https://github.com/DEIN-USERNAME/QuestProgressSound.git
git branch -M main
git push -u origin main
```

### 5. Optional: Release erstellen
Nach dem ersten Push kannst du auf GitHub:
1. Gehe zu "Releases" → "Create a new release"
2. Tag: `v1.0.0`
3. Title: `QuestProgressSound v1.0.0`
4. Beschreibung der Features hinzufügen
5. "Publish release" klicken

## Dateistruktur
```
QuestProgressSound/
├── .gitignore
├── README.md
├── LICENSE
├── QuestProgressSound.toc
├── Core.lua
├── Config.lua
├── Events.lua
├── Comm.lua
├── Chat.lua
├── Locales/
│   ├── enUS.lua
│   └── deDE.lua
├── libs/
│   ├── AceDB-3.0/
│   ├── AceDBOptions-3.0/
│   ├── AceLocale-3.0/
│   └── LibSharedMedia-3.0/
└── media/
    ├── schaffe.ogg
    └── feierabend.ogg
```
