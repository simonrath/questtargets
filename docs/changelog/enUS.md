# Quest Targets – Patch Notes

Player-facing changes, newest version first. Historical installation notes apply to the version listed.

## 1.7.4 – Preview

### Polestar
- **Polestar guide targets:** On WoW Forever, with Polestar installed, enable the normally disabled **Buttons → Targeting bar → Follow Polestar guide targets** option. The main compass searches named open goals in the displayed guide step; without targets it falls back to quest search. Changes apply after combat. If RestedXP is also enabled and available, it takes precedence.

## 1.7.3 – Nov 20, 2026

### Options
- Fixed an error in Blizzard's **Social settings**.

## 1.7.2 – Nov 19, 2026

### RareScanner
- **Nearest rares first:** The purple button orders marked rares and the zone list by distance to the nearest known RareScanner spawn point, so nearby rares are checked sooner.

### Targeting bar
- **Current position on every click:** Out of combat, targeting buttons read your position for distance-based searches only when you click or press a hotkey. If you've moved, the search starts at the top of the updated list. If you stay in place, further clicks check the next names.

## 1.7.1 – Nov 19, 2026

### RareScanner
- **Keep your target:** A living rare on the search list stays selected when you click the purple button again or press its hotkey.

### Targeting bar
- **Separate target searches:** The red master button looks for quest targets and adds targets from the active RestedXP guide step when enabled. The blue RestedXP, yellow ItemTree and purple RareScanner buttons each search their own list.

## 1.7.0 – Nov 19, 2026

### RareScanner
- **WoW Forever:** Targeting requires the RareScanner addon. It works out of combat and within WoW’s targeting range.
- **World map:** Left-click rare NPCs to mark them. Click the purple **RareScanner Button** on the targeting bar to search for all marked rares. The tooltip lists the targets.
- **RareScanner macro:** Depending on name length, the macro usually fits **2–4 rare mobs per click**. If the list has more rares, click again to check the next ones.
- **Show RareScanner Button:** You can hide the compass under **Buttons → Targeting bar**. It is shown by default and grayed out when it has no targets to search for. It stays visible in combat, with targeting disabled.
- **Target RareScanner rares:** Under **Hotkeys**, you can assign two keys to the purple button. Each key press searches like a left-click.
- **Search all rares in the zone:** Enable this under **Buttons → Targeting bar** to search for every rare NPC RareScanner lists in your current zone, including unmarked ones. The list updates as you change zones and includes rares in your current dungeon when RareScanner has data for it. Off by default.
- **Minimap:** Left-click a rare's RareScanner icon to look for that NPC. A **radar pulse** confirms the click. If the minimap handles the first click, click again to attempt targeting.

### Targeting bar
- **Targeting bar:** Under **Buttons → Targeting bar**, set **Button layout** to horizontal or vertical and **Button spacing** to 0–32 px. Turn on **Show bronze border** for one chamfered bronze frame around the entire bar inspired by FlareUI's unit frames. Defaults are horizontal, 4 px spacing and border off.
- **Show dividers:** Toggle the gold-to-silver dividers with star tips independently of the bronze border. The dividers rotate when the bar is vertical.
- **Modern quest compass:** The classic text button and its width, height and text options have been removed. If you used the classic button, the update switches it to the compass at your saved position. Adjust its size under **Buttons → Targeting bar → Button size**.

### Patch Notes window
- **Patch Notes:** On your first login with a new version, the history opens once per account and stays open until you close it. Find it under **Options → AddOns → Quest Targets → Patch Notes**. The notes follow your chosen addon language.

## 1.6.1 – Nov 15, 2026

### New
- **EllesmereUI:** Quest Targets adds buttons to the Custom Quest Tracker on Forever. Left-click to search for a target or right-click to focus the quest.
- **Feedback:** The dialog provides a QR code for the feedback form.

### Improved
- Assign mouse buttons, the mouse wheel, and key combinations as targeting shortcuts anywhere in the game window.
- Questie and EllesmereUI have separate spacing controls under **Buttons**.
- You can mute the sound that plays when a target is cleared.

## 1.6.0 – Nov 10, 2026

### New
- **ItemTree integration:** Install and enable ItemTree separately. Open an ingredient’s **Sources** view, expand **Show more** if needed, and click **Import mobs**. Quest Targets imports the mobs that drop that ingredient.
- **ItemTree targeting:** Enable the yellow compass under **Buttons → Show ItemTree button** or assign a key under **Hotkeys → Target ItemTree mobs**. If a click finds nothing, click again to check more names.
- **Action bar macro:** When possible, importing creates the character macro **ItemTree Mobs**. Drag it from the macro window to your action bar. The targeting button and its hotkey work without a free macro slot.
- The **targeting bar** holds the red Master button, the blue RestedXP button, and the yellow ItemTree button.

### Improved
- Move and resize the three buttons together, and choose which ones to show.
- ItemTree searches prioritize targets in your zone and use known spawn points when available.

## 1.5.1 – Nov 3, 2026

### New
- Drag the **bottom-right corner** to resize the quest window. Its size and position are saved.
- Turn off Questie’s target buttons or adjust their spacing.

### Improved
- The **minimap button** works better with addons that collect minimap buttons.
- The options show the installed version. New settings use the compass as the Master button.

## 1.5.0 – Nov 3, 2026

### Improved
- One download supports Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever, and Retail.
- Quest Targets selects the quest data for your client. Install QuestieDB separately on clients that need it.

## 1.4.2 – Nov 3, 2026

### Improved
- **QuestieDB** is a separate download and can be updated on its own. Retail does not require it.

## 1.4.1 – Nov 2, 2026

### Improved
- Master and Focus now have both slots in WoW’s keybindings menu. Quest Targets asks before replacing a key that is already assigned.
- Quest Targets appears in AddOn options immediately after login. Controls for the other button style are grayed out.

### Fixed
- Changes and cleared bindings in WoW’s keybindings menu persist after reloading.
- Right-click opens the quest log only out of combat. Map and target matching is more reliable.

## 1.4.0 – Oct 30, 2026

### New
- Master and Focus each have two binding slots for keyboard keys and supported controllers.

### Improved
- Change or clear one binding while keeping the other. Press Escape to cancel assignment.

## 1.3.0 – Oct 29, 2026

### Improved
- Version 1.3.0 publishes the Master button positioning controls and QuestieDB 1.0.9 together as introduced in 1.2.9.

## 1.2.9 – Oct 28, 2026

### New
- **Move master button** adds a drag handle in Settings. Choose Done to save, press Escape to cancel, or choose Reset position to preview the default.

### Improved
- Classic and Forever packages included the matching QuestieDB 1.0.9 for each client.

## 1.2.8 – Oct 16, 2026

### Fixed
- Bundling QuestieDB 1.0.6 restored compatibility with Questie 12.1.0.

## 1.2.7 – Oct 15, 2026

### New
- Use **/qt debug** to see details about the last target search.

### Fixed
- WoW’s **action bar** stays usable after changing the addon options.

## 1.2.6 – Oct 12, 2026

### Fixed
- The Master and RestedXP buttons keep working when the list of quest targets shrinks or becomes empty during a guide step.

## 1.2.5 – Oct 9, 2026

### New
- Right-click a quest icon in Quest Targets or Questie to focus it. A separate hotkey searches only for targets for that quest.
- Compact native options let you edit the Master button text directly.

### Improved
- Questie’s target buttons appear automatically. RestedXP uses the remaining targets in the active guide step.
- The quest window, scrolling, and dragging are more reliable. Finished objectives are removed from searches.

## 1.2.4 – Oct 4, 2026

### Improved
- If RestedXP has no matching target, the search can fall back to open quests.
- Repeated clicks keep a valid target selected while no matching alternative is visible.

## 1.2.3 – Oct 3, 2026

### New
- RestedXP can look for explicitly named quest givers before you accept their quests.
- Added support for Burning Crusade Classic and Mists of Pandaria Classic.

### Improved
- Quest Targets appears under Quests in the AddOn list. Questie’s target buttons show the compass on Classic Era.

## 1.2.2 – Oct 3, 2026

### New
- The optional RestedXP integration searches the current guide step. A Quest Targets button appears beside RestedXP.

## 1.2.1 – Oct 2, 2026

### New
- An optional target button appears next to each quest in Questie’s tracker.

### Improved
- Updated support for the Forever interface, adjusted Master button sizing, and added a native border to the minimap button.
- In the transparent quest window, hovering shows the drag handle and the toggle. Settings and Feedback appear side by side.

## 1.2.0 – Sep 30, 2026

### New
- **Retail 12.1** is supported. Quest Targets reads the live quest log and visible nameplates without QuestieDB.

### Fixed
- If the quest log cannot be read, the window shows a message instead of an apparently empty list.

## 1.1.0 – Sep 28, 2026

### New
- **Transparent mode** shows only the quest list. Use the eye icon to toggle the view. The icon fades after a moment.

### Improved
- The close button and scrollbar fit the new layout.

## 1.0.22 – Sep 28, 2026

### Improved
- Updated QuestieDB integration. The public addon download still used the appropriate separately installed provider.

## 1.0.16 – Sep 27, 2026

### New
- The **Feedback button** opens a copyable link for bug reports and suggestions. No GitHub account is needed.

## 1.0.15 – Sep 27, 2026

### Improved
- **Mouse wheel scrolling and a scrollbar** replace the page arrows. Resize the quest window with a slider in Settings.
- Tooltips are simpler, hotkeys have their own section, and text is updated in all six languages.

## 1.0.13 – Sep 25, 2026

### Improved
- If QuestieDB is missing, the message points to the right package for Classic Era or Forever. Select the link in the dialog to copy it.

## 1.0.12 – Sep 25, 2026

### New
- Added **WoW Classic Era** 1.15.9 support alongside the Forever beta.

### Fixed
- Classic quest reading, tracking, completion, and right-click access to the quest log work correctly. Classic spawn coordinates are preserved.

## 1.0.11 – Sep 25, 2026

### New
- First documented Forever beta version. A button per quest and a **Master button** search for active quest mobs or NPCs ready for turn-in.
- QuestieDB adds kill quest targets, shared kill targets, and enemies that drop required items. Readable nameplates can provide more matching targets.
- The quest list shows progress, filters tracked quests, and opens the quest log with a right-click. /qt toggles the window.
- Configure target marking, hotkeys, tooltips, and six languages in the WoW options.
- The quest compass appears on the minimap and can serve as a movable Master button. The classic button supports custom text.
