WRATH MENTOR v2.2.4  -  in-game tactics for every WotLK raid (WoW 3.3.5a)
by Saranwrap
==========================================================================

INSTALL
  Delete any old WrathMentor folder, then copy this "WrathMentor" folder into:
      <WoW folder>\Interface\AddOns\
  Restart the game (or /reload). Your saved settings are kept.

WHAT'S IN THE WINDOW (/wm)
  Left: raid + boss list (bosses with a personal note are tinted blue).
  The window can be resized: drag the small grip in the bottom-right corner, or set an
  overall size with the "Tactics window size" slider in Settings.
  Top row:  All / Tank / Healer / DPS  |  10 / 25  |  Notes  |  Copy
    - Role buttons filter the tips.
    - 10 / 25 switches the text to the 10-man or 25-man version
      (add counts, tank counts, number of marked players, etc.).
    - Notes opens a side box for your own notes on that boss. Press Save to keep them.
      (Unsaved text is also saved automatically if you change boss, close the box or the window.)
    - Copy shows the whole boss text as plain, selectable text: drag with the mouse to select
      part of it, or press Select all, then Ctrl+C. Press Back to return.
  Each boss shows: TL;DR, How to start the fight, Strategy (by phase), Tank/Healer/DPS tips,
  Boss abilities and the Hard mode / Heroic explanation.

BOSS POPUP
  When you target a boss inside a raid, a small popup shows the boss's TL;DR.
  Inside a fight it appears at most ONCE per boss: if you close it, targeting an add and then the
  boss again will not bring it back. It can appear again in the next fight.

SEND TO CHAT
  "Send to chat" (and the Send button on the popup) posts ONLY the Strategy section of the boss,
  in the selected 10/25-man version, one line at a time.

ABILITY LINKS
  Abilities are shown with their spell icon next to a [Spell Name] link. Hover for the real game
  tooltip, click to open it, shift-click to put the link in chat.
  A link (and its icon) is only shown when this client confirms the spell ID has the expected name,
  so a wrong ID can never show a wrong spell or icon. Abilities without a confirmed ID show a plain
  question-mark icon and appear as plain white text instead of a link.
  /wm checklinks tells you how many abilities linked on your client.

COMMANDS
  /wm                          open / close
  /wm <boss name>              open a boss (partial names work: /wm lich, /wm sapph, /wm yogg)
  /wm role all|tank|heal|dps   role filter
  /wm size 10|25               choose 10-man or 25-man text
  /wm notes                    open / close the notes box
  /wm quick                    toggle the TL;DR popup when you target a boss (once per fight)
  /wm config                   settings panel (window size slider, popup options)
  /wm minimap                  show / hide the minimap button
  /wm send [raid|party|say]    send the selected boss's Strategy section to chat
  /wm checklinks               report resolved ability links
  /wm reset                    reset window positions

EDITING THE DATA
  Open Data_*.lua in a text editor. Boss fields:
    name, aliases, tldr, start, general, tank, heal, dps, abilities, hard
  Line tags:   "[10] text" = only in 10-man,  "[25] text" = only in 25-man,
               "#{a/b}" = a in 10-man / b in 25-man,  "## Title" = sub-heading inside a list.
  Ability:     { ids = { 10-man id, 25-man id }, name = "Exact Spell Name", desc = "..." }
  Boss names must match the in-game NPC name (English client) for the popup to trigger.
  Personal notes are stored in your saved variables, keyed by raid and boss name.

ICON
  icon.png (150x150) is a preview/listing image for this addon. WoW 3.3.5a loads textures as
  .blp or .tga, not .png, so it is not loaded in-game - it's for CurseForge/WoWInterface-style
  listings or your addon manager.
