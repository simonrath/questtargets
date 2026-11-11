# Issue #27: mouse bindings

The binding capture enabled keyboard and gamepad events but never registered
extra mouse clicks or converted their names into WoW binding tokens. This
prevented assigning them through both native and fallback Quest Targets settings.
The stored action itself already uses SetBindingClick and supports mouse keys.

During capture, settings controls now register AnyUp, convert MiddleButton and
Button4–Button31 to BUTTON3–BUTTON31, and process mouse-wheel movement through
the same modifier, conflict confirmation, saving and rollback path as keyboard
input. Left/right click cancels, following Blizzard's primary-button convention.
The original click/wheel handlers and wheel-enabled state are restored on
completion, cancellation, hide, tab changes, row recycling and combat entry.
The change affects all slots for master, focus and ItemTree bindings. No macro
bytes, targeting logic, or Issue #30 sound behavior are changed.

References: XERJ lookup for `GetConvertedKeyOrButton beginBindingCapture` was
unavailable because XERJ is not installed. Fallback inspection used local rg and
Blizzard's [CustomBindingButtonMixin](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_SharedXML/CustomBindingButtonMixin.lua)
and [BindingUtil](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_SharedXML/BindingUtil.lua).
The implementation uses the existing Quest Targets capture lifecycle and does
not copy either mixin.

Tests cover middle/extra buttons in both slots of all three actions, modifiers,
wheel input, primary-button cancellation, occupied bindings, callback restoration,
combat/tab cancellation, and native settings on the five supported flavors.
An in-game mouse-device and controller regression check remains necessary.

The same report also requests a first-found-mob notification. That is a separate
feature and remains open: a local sound requires defining when a mob counts as
found, how identity is tracked, and when notifications reset. A real game ping
also needs client support and permission checks. This commit fixes mouse capture
without silently enabling or deciding the notification behavior.
