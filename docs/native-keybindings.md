# Native keybindings and conflict warning

The 1.4.0 release commit 692cb6c did not contain conflict confirmation.
Implementation 1e571fb existed on the separate keybinding-conflict-warning
branch. Its confirmation/rollback code and tests are incorporated here.

Reference searches used local XERJ corpus qtrefs. Broad Bindings.xml search
returned validator code, so the fallback was reading the pinned source files:
RXPGuides/Bindings.xml:3-6 at 52be76992b92 and Questie/Bindings.xml:2-7 at
62ae63250ae3. Both register entries through root Bindings.xml; RestedXP uses
empty CLICK bindings for secure buttons. No upstream implementation was copied.
WoW MCP confirmed GetBindingAction availability for Classic, TBC, Mists,
Retail, and the existing Forever source. Native Blizzard_Keybindings.lua
uses that API to find displaced actions.

Our Bindings.xml registers the existing master/focus CLICK commands without
adding insecure targeting callbacks. The packaging script includes the XML
in every flavor and the minimal package. Labels use the addon's language.

Previously every refresh restored the saved focused-quest keys, potentially
undoing edits made in Blizzard's native keybindings page. Legacy saved keys
are now migrated once; thereafter WoW's active binding set is authoritative.
UPDATE_BINDINGS mirrors the focused pair without rewriting native bindings.

Automated checks cover both slots, keyboard/controller input, confirm/cancel,
stale dialogs, combat, failed assignment rollback, native focus assignment and
clearing, reload behavior, localized labels, XML entries and packaging. The
flavor matrix runs against interface IDs 11509, 20506, 50504, 16001 and 120105.
Lua mocks do not render Blizzard's UI or replace actual client testing.
