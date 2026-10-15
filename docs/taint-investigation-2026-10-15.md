# ActionBar taint investigation — 2026-10-15

## Evidence

The installed Forever addon is version 1.2.6. Its UI.lua matches the working
repository byte for byte. Secure integration buttons are already parented and
anchored to UIParent, independently of Questie and RestedXP frames.

The existing local `Logs/taint.log` is from October 7, before these changes.
It confirms blocked `UseAction()` calls through
`SECURE_ACTIONS.action -> PerformAction -> SecureActionButton_OnClick ->
MultiBarBottomLeftButton10:TriggerSecureClick`. It does not establish where
the current build first becomes tainted.

The native action handler calls `flyout:Hide()` before `UseAction()`. Thus both
reported function names can be downstream symptoms of a contaminated ActionBar
execution path. They do not establish that Quest Targets directly hides the
flyout; the addon contains no such call or ActionBar hook.

The old log also records slash-command registration being read by Blizzard's
macro parser. Other addons appear in the same import sequence. These entries
alone do not demonstrate that normal slash-command registration caused the
later blocked action.

## New trigger and captured failure

The user now reproduces the failure by toggling the RestedXP option and then
clicking an ActionBar spell. The installed diagnostic package captured five
`ADDON_ACTION_FORBIDDEN` events through `UseAction()` in the normal native
ActionBar click path. Both enabled and disabled RestedXP states occur. The
captured ActionBar/flyout field lists are empty; these snapshots alone neither
identify the source nor prove the whole Settings system is untainted.

## Registration path found in the Forever UI source

Quest Targets passed `function() return L(key) end` as the name to
`Settings.RegisterProxySetting`. The Forever 1.60.1.70124 UI source supplied
by the WoW MCP shows this sequence:

1. `Blizzard_SettingsInbound.lua:213-217` creates a proxy setting in the
   attribute delegate, then registers it with SettingsPanel.
2. `ProxySettingMixin:Init` in `Blizzard_Setting.lua:337-341` validates the
   arguments before initializing the setting.
3. `ErrorIfInvalidSettingArguments -> GetNameType -> GetOrCallName` invokes a
   function-valued name directly (`Blizzard_Setting.lua:12-20,31-35`). There
   is no `securecallfunction` around this validation callback.
4. `GenerateClosure` does not isolate the callback: its wrapper simply calls
   the supplied function. This allows addon execution taint into the remainder
   of construction and registration, unlike the isolated proxy value accessors.
5. `SettingsPanel:RegisterSetting` stores the object in `self.settings` at
   `Blizzard_SettingsPanel.lua:760`.
6. Every native ActionBar click calls `Settings.GetValue("lockActionBars")`
   (`ActionButton.lua:1409`). `SettingsPanel:GetSetting` traverses the shared
   setting map (`Blizzard_SettingsPanel.lua:778-785`) before the native click
   eventually reaches `UseAction()`.

This is a concrete source-level taint path consistent with the captured clean
ActionBar fields and intermittent native click failure. The MCP source build
is older than the installed 1.60.1.70374 client, so the actual client result
still requires an in-game regression check.

## Targeted correction and verification

Proxy registration now receives the resolved label string. Live translation is
handled by our display initializer's `GetName`, outside setting construction;
the registered setting and native ActionBar methods remain unchanged. RestedXP
target selection, secure macros, and enable/disable behavior are unchanged.

The native Settings regression checks all five flavors, rejects callback-valued
registration names, verifies live language labels, and repeatedly enables and
disables guide targeting without a reload. The check failed on the old
registration and passes with the change. The full suite passes 158 tests.
These tests run under Lua 5.1 without
the game's taint engine and must not be presented as in-game confirmation.

## Evidence capture added

`Diagnostics.lua` observes `ADDON_ACTION_BLOCKED` and `ADDON_ACTION_FORBIDDEN`
for Quest Targets. It records the function, bounded stack, integration state,
and insecure field owners for the native ActionBar/flyout path. A read-only
two-second sampler preserves the first observed contaminated fields in the
current session. The last five failure reports persist in the existing
per-character SavedVariables under `taintDiagnostics`.

Captures now also record probe availability/failures, Settings methods, bounded
shared registry slots and relevant `lockActionBars` fields. They never invoke
setting getters or callbacks, and tolerate unavailable introspection APIs.

The capture does not hook or modify Blizzard functions or frames, change CVars,
suppress error popups, or trigger a reload. Missing/restricted introspection
APIs are tolerated. `/qt debug` prints the last captured function and a short
field summary. Normal logout or game exit writes the report to disk.

The next in-game toggle/cast test must start with the updated addon loaded, so
previous session taint is absent. That one installation reload is distinct from
requiring a reload whenever a setting changes. No reload workaround is added.

## Release confirmation

The user subsequently confirmed the identified error and requested publication.
Version 1.2.7 includes the registration correction and bounded diagnostics.
