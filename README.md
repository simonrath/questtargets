# Quest Targets

Quest-targeting addon for **WoW Classic Era 1.15.9 (Interface 11509)**, **Burning Crusade Classic 2.5.6 (20506)**, **Mists of Pandaria Classic 5.5.4 (50504)**, **WoW Forever 1.60.1 (16001)**, and **Retail 12.1.5 (120105)**.

**[Download the latest release](https://github.com/simonrath/questtargets/releases/latest)**

## Installation

Download `QuestTargets-<version>.zip` for any supported client: Retail, Classic,
TBC, Mists, or Forever. The same ZIP works on all five and contains only `QuestTargets/`. Close WoW and replace
`Interface/AddOns/QuestTargets` with the folder from the ZIP.

For Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, and Forever,
install and enable **QuestieDB** separately from
[CurseForge](https://www.curseforge.com/wow/addons/questiedb) or the
[official QuestieDB releases](https://github.com/Questie/QuestieDB/releases/).
Choose the version for your client. QuestieDB is no longer included in Quest Targets.
If QuestieDB is already installed, keep it and update it separately.
QuestieDB supplies data only; keep the full Questie addon enabled to use its tracker.

Retail needs no QuestieDB and reads objectives from the Retail quest log. Mob names
come from readable quest text and visible nameplates. Item sources and turn-in NPCs
without names in the quest text are not inferred on Retail.

## Features

Release maintainers: [Set up automatic CurseForge publishing](docs/curseforge-publishing.md).

Quest Targets also appears under **Options → Keybindings → Quest Targets**.
Both target actions support the native primary and secondary binding slots.
Native changes, including clearing a focused-quest binding, are kept across
refreshes and reloads. In the addon's own Hotkeys section, assigning an occupied
keyboard/controller key requires confirmation before replacing its old action.

- One target button per quest and a master button for active objectives.
- Prioritizes quest mobs, then NPCs for quests ready to turn in.
- Name targeting and nearby nameplate detection.
- Configurable target markers, hotkeys, and tooltips.
- Compact native addon settings in every supported client, with inline master-button text editing, a minimap button, and classic or modern master-button appearance.
- Quest-specific target buttons appear automatically beside quest rows in Questie's tracker when Questie is installed and enabled.
- Right-click a quest icon in either quest list to focus that quest. The always-visible focus highlight is shared between both lists; a separate configurable hotkey targets only the focused quest while the master button keeps its normal behavior.
- Optional RestedXP guide targeting for the master button, with a matching button on RestedXP's target frame. Active-step mobs and explicitly named targets are eligible even outside the quest log, including gathering mobs, quest NPCs, and flight masters. If the guide has no target, the native quest search takes over immediately; failed guide searches try a native quest target in the same macro when space allows, then fall back to the full native search on the next click. Repeated clicks keep a valid current target unless another matching target is visible. Secure targets refresh after combat.
- Optional transparency mode immediately leaves only the quest list visible. Its toggle icon hides two seconds after the cursor leaves the window and reappears when the cursor moves anywhere over it. A 90% transparent draggable strip is shown only while the cursor is over the window.
- The compact quest window has adjacent Settings and Feedback buttons; quest data also refreshes automatically or with `/qt refresh`.
- At 100%, both master-button styles are the size previously shown at 150%; saved scales are migrated to preserve their visible size.
- English, German, Spanish, French, Turkish, and Simplified Chinese.
- In-game feedback button linking to [the public feedback form](https://feedback.jacknine.org); no GitHub account needed.

Use `/qt` to open the quest window and `/qt settings` to open settings.
Under **Hotkeys**, Master and Focus each have two binding buttons side by side,
like WoW's native keybinding rows. Click either slot and press a keyboard key or
an Xbox/controller button. Changing or clearing one slot keeps the other binding;
when the first slot is cleared, the remaining binding moves into it. The controller must already be recognized by WoW
and native gamepad input must be enabled (`/console GamePadEnable 1` on clients
that support it). Escape cancels assignment; Delete or Backspace clears the selected slot.
Clients without the gamepad frame API retain keyboard binding support.
To position the master button, open **Settings → Master button → Move master button**.
Outside combat, drag the handle with the left mouse button; the native move cursor
shows where you can drag. Choose **Done** to save, **Cancel** or Escape to restore
the previous position, or **Reset position** to preview the default position.
Holding the right mouse button and dragging the master button still works directly.
If combat starts during editing, editing ends and the last released position is
saved after combat. The positioning controls are available even with tooltips off.
Targeting is subject to the client's protected-action and combat restrictions.
Under **Target markers**, **Mute dead-target clearing sound** optionally suppresses
the deselection sound for 100 ms when a Quest Targets button or hotkey replaces
a dead NPC. It is off by default and adds no macro bytes. Selection sounds and
living-target changes stay audible; another playback of the same deselection
sound during the short window is also muted. Standalone action-bar macros are
not covered. In-game timing still needs validation on each supported client.
See [the detailed documentation](QuestTargets/README.md) for behavior and limitations.

## Development

Install Python dependencies with `python -m pip install -r tests/requirements.txt`.
Run `python -m unittest discover -s tests -p "test_quest_targets*.py"`.
Database integration tests use the pinned QuestieDB v1.0.9 Vanilla archive in
the system temporary directory at
`quest-targets-questiedb-v1.0.9/QuestieDB-Vanilla.zip`. Package tests verify that every flavor contains Quest Targets only;
building packages requires no QuestieDB download or provider cache.

Build the universal release package with PowerShell:

```powershell
./tools/package_quest_targets.ps1
```

The result is `dist/QuestTargets-<version>.zip`, shared by all five clients.
It contains runtime Lua, XML, TOC, and texture files only. Tests, documentation,
and QuestieDB are excluded. Legacy `-Flavor`, `-AddonOnly`, and `-CurseForge`
arguments remain accepted and produce the same universal archive.

## License

[GNU GENERAL PUBLIC LICENSE](LICENSE) for Quest Targets only.

### QuestieDB attribution

Quest Targets accesses the separately installed QuestieDB addon through its public
API. QuestieDB code and data belong to the [QuestieDB team and its contributors](https://github.com/Questie/QuestieDB).
Quest Targets 1.4.2 and later do not redistribute QuestieDB. See the
[QuestieDB notice](QuestTargets/QUESTIEDB-NOTICE.md) for earlier package provenance.
