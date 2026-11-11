# Issue #30: dead-target deselection sound

Implemented on the shared `issue-fixes-1.6.1` branch; no release/version bump.

The opt-in setting `muteDeadTargetSound` is off by default. It is exposed in the
native settings layout and the fallback Target markers tab. Hardware-click
preparation mutes only FileDataID 567520 (`Sound/Interface/iDeselectTarget.ogg`)
when the current target is a readable, dead NPC and the prepared macro includes
target selection. The macro bytes and targeting behavior are unchanged.

Covered input paths: master, focused quest, quest rows, Questie target buttons,
RestedXP, and the ItemTree target button/hotkey. Combat preparation reads the
already configured macro and does not write protected attributes. Standalone
action-bar macros do not pass through these handlers and are excluded.

Each qualifying input renews a 100 ms window. Only one mute is acquired across
overlapping clicks; stale cleanup timers cannot release a newer window. Timer
scheduling failure and PLAYER_LOGOUT (including normal UI reload) release the
addon's mute. Missing APIs or unreadable unit data leave audio untouched.

This is a file-level mute, so another playback of the same file in that window
is also suppressed. The duration is a conservative starting value, not a
measured guarantee about native event delivery. A real-client check is required
for each flavor: dead NPC to live NPC, dead NPC to no match, living target
changes, repeated clicks, combat, option off, and reload during suppression.
No in-game verification is claimed.

References consulted:

- Local XERJ lookup for `MuteSoundFile Core.ClickMacro` could not run: XERJ is
  not installed. Native UI sources and local `rg` were used instead.
- Blizzard TargetFrameMixin, `PLAYER_TARGET_CHANGED` and
  `OnHide_TargetFrame`/Classic `OnHide`: the lost-target sound is distinct from
  the selection sounds. See [Blizzard UI source](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_UnitFrame/Mainline/TargetFrame.lua).
- The extracted sound listings identify iDeselectTarget as file 567520 for
  [Retail](https://www.wowhead.com/sound=206823/ideselecttarget) and
  [Classic](https://www.wowhead.com/classic/sound=900/interfacesound-losttargetunit).
  SoundKit IDs differ from this FileDataID and must not be passed as file IDs.

Automated coverage checks the real Lua click preparation, unchanged 255-byte
macro text, dead/living/player/absent/secret targets, disabled/missing APIs,
overlapping cleanup, timer failure, logout, combat attribute preservation, and
native/fallback settings. Mocks establish lifecycle behavior, not audio output.
