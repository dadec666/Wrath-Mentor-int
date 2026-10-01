-- The Obsidian Sanctum and The Eye of Eternity
local WM = WrathMentor

WM:AddRaid("os", "The Obsidian Sanctum", { "The Obsidian Sanctum" }, {
    {
        name = "Sartharion",
        aliases = { "Tenebron", "Shadron", "Vesperon" },
        tldr = "Kill him while dodging the lava walls (Flame Tsunami), void zones and Fire Cyclone adds. Leaving 1, 2 or 3 of his drakes alive (1D/2D/3D) makes it harder but gives more loot.",
        start = {
            "Decide how many drakes (Tenebron, Shadron, Vesperon) the raid will leave alive BEFORE you pull - each one you leave is a hard mode. Kill the drakes you don't want first; they are in the side caves of the instance.",
            "Main tank takes Sartharion and turns him away from the raid. An off-tank is ready for Lava Blazes and, if drakes are alive, for the drake that arrives.",
            "Melee stand behind him only if you are sure of the lava-wave positions; nobody stands in front (Flame Breath) or right behind him (Tail Lash).",
        },
        general = {
            "## Sartharion himself (no drakes alive)",
            "Kill him fast. His main dangers: Flame Breath (in front), Tail Lash (behind), Cleave, and Fire Cyclone which spawns adds.",
            "Flame Tsunami: giant walls of lava sweep across the room. Move out of the wall; keep positioned close to your healers so you don't get cut off. Adds must not touch the Tsunami or they hit much harder.",
            "Void Blast leaves a big purple void zone: run out of it.",
            "Lava Blazes appear all fight: the off-tank picks them up and DPS kills them quickly. At 10% health he spawns a large pack - either AoE them on top of the boss or ignore them and burn him down.",
            "Enrage: a Hunter's Tranquilizing Shot or a Rogue's Anesthetic Poison removes it (stay out of the Tsunami while doing so).",
            "## 1 drake alive (1D) - Tenebron",
            "About 30 seconds in, Tenebron joins. Switch to her and kill her first, with healers in range of both tanks. She hatches Twilight Whelps from eggs - kill them quickly.",
            "## 2 drakes alive (2D) - plus Shadron",
            "Shadron joins after Tenebron (roughly 75 seconds in). Kill Tenebron before swapping to Shadron; the off-tank moves to Shadron's landing spot and holds both facing the lava.",
            "Shadron opens a Twilight Portal and an Acolyte of Shadron spawns: while Shadron or his Acolyte is alive, Sartharion is immune and deals 50% more fire damage (Gift of Twilight). You can ignore the portal and burn Shadron; if healing can't keep up, DPS step into the portal and kill the Acolyte quickly.",
            "## 3 drakes alive (3D) - plus Vesperon",
            "Vesperon joins about 125 seconds in (Shadron should be dead by now). Pick him up at once and face him away from the raid.",
            "His Twilight Portal Acolyte and Vesperon apply Twilight Torment: you take 75% more Shadow and Fire damage and hurt yourself for every attack you make. This portal CANNOT be ignored - kill the Acolyte quickly. Sartharion's breaths can now one-shot a tank without cooldowns.",
        },
        tank = {
            "Main tank: face Sartharion away from the raid; use cooldowns against Flame Breath when drakes are alive.",
            "Off-tank: pick up Lava Blazes; with drakes alive pick up each drake as it lands, face them toward the lava, and use tank cooldowns when Vesperon's Torment starts.",
        },
        heal = {
            "Stay close to both tanks and the raid so a Flame Tsunami doesn't cut you off. Pool your cooldowns for the moment Vesperon (3D) arrives.",
        },
        dps = {
            "With drakes alive, keep cooldowns for the drakes and kill in the order they arrive.",
            "Never let Fire Cyclone adds touch a lava wall. Stay out of Void Blast.",
        },
        abilities = {
            { ids = { 56909 }, name = "Cleave", desc = "Hits players in front of him. Only the tank stands there." },
            { ids = { 56908, 58956 }, name = "Flame Breath", desc = "Massive fire damage in a cone in front of him." },
            { ids = { 56910, 58957 }, name = "Tail Lash", desc = "Damages and knocks back players behind him. Don't stand there." },
            { id = 57491, name = "Flame Tsunami", desc = "A wall of lava that runs across the room. Get out of its path." },
            { id = 57581, name = "Void Blast", desc = "A void zone under a player. Run out of it." },
            { kind = "buff", id = 61254, name = "Will of Sartharion", desc = "With drakes alive, Sartharion and the drakes have increased health." },
            { ids = { 57570, 59126 }, name = "Shadow Breath", desc = "The drakes' shadow breath. Tanks face them away from the raid." },
            { kind = "buff", ids = { 57835, 58766 }, name = "Gift of Twilight", desc = "Shadron's Acolyte makes Sartharion immune and deal 50% more fire damage." },
            { kind = "debuff", ids = { 57935, 58853 }, name = "Twilight Torment", desc = "Vesperon's Acolyte: everyone takes 75% more Shadow and Fire damage and hurts themselves when attacking." },
            { kind = "debuff", id = 60708, name = "Fade Armor", desc = "Twilight Whelps reduce a tank's armor. Kill them fast." },
        },
        hard = {
            "The hard mode is chosen by which drakes are alive when you pull: 0 (normal), 1D, 2D, or 3D. Each drake is its own mini-boss that joins mid-fight.",
            "Every drake left alive makes Sartharion and the drakes tougher (Will of Sartharion adds health) and adds one extra mechanic: Tenebron = Twilight Whelps, Shadron = Gift of Twilight (Sartharion immune + 50% fire damage while his Acolyte/Shadron lives), Vesperon = Twilight Torment.",
            "Arrival times: Tenebron about 30 seconds, Shadron roughly 75 seconds, Vesperon about 125 seconds. Kill each drake before the next one arrives.",
            "Reward: each drake left alive adds extra loot, and all 3 drakes gives the bonus items and the Twilight/Black Drake mount (10-man Reins of the Black Drake, 25-man Reins of the Twilight Drake).",
            "3D is the danger point: Vesperon plus Torment can one-shot the tank. Save all raid and tank cooldowns for that moment and kill the Acolyte immediately.",
        },
    },
}, "Warcraft Tavern (Obsidian Sanctum 10/25 + Sartharion guide), Icy Veins, Wowpedia; Syndicate Guild page not checked for this raid")

WM:AddRaid("eoe", "The Eye of Eternity", { "The Eye of Eternity" }, {
    {
        name = "Malygos",
        aliases = { "Nexus Lord", "Scion of Eternity" },
        tldr = "P1: face him away, run from his face when you land after Vortex, kill Power Sparks. P2: tank Nexus Lords, kill Scions, hide in Arcane Overload zones. P3: everyone rides a drake - spam Flame Spike, Flame Spike, Engulf in Flames and avoid Static Field.",
        start = {
            "Tank Malygos facing away from the raid (his Arcane Breath is a cone; he has NO tail swipe).",
            "Ranged spread loosely. Everyone should have around 18k+ health or more for Vortex.",
            "Decide the Phase 3 roles now: #{2 healers / 4-5 healers} and the rest DPS on drakes.",
        },
        general = {
            "## Phase 1 (100% to 50%)",
            "About 45 seconds in, Malygos casts Vortex: everyone is lifted and spun for about 10 seconds taking damage. You can still cast instants. When you're dropped, immediately run AWAY from his face so you're not hit by Arcane Breath.",
            "Roughly every 30 seconds a Power Spark floats out of a portal toward Malygos. If it reaches him he deals 50% more damage. Kill Sparks before they arrive (they can be crowd-controlled or Death Gripped and stop moving during Vortex). Sparks leave a patch that boosts damage of players standing in it.",
            "## Phase 2 (at 50%)",
            "Malygos flies up (still hittable while he lifts off). Nexus Lords and Scions of Eternity appear; Malygos himself can't be attacked and casts Deep Breath (massive arcane damage to everyone NOT on a disc).",
            "Arcane Overload pink zones appear: standing in them reduces magic damage taken by 50%. They shrink as they absorb damage, so move to the next one.",
            "Tank the Nexus Lords. Once they die, melee take a Nexus Lord's disc to reach and kill the Scions of Eternity in the air (they cast Arcane Barrage on random players).",
            "When all adds are dead, dismount and DPS Malygos before Phase 3. Use ALL cooldowns now - you won't have them in Phase 3.",
            "## Phase 3 (the platform shatters)",
            "Alexstrasza's red drakes carry everyone. Every drake has the same abilities. There is NO tanking. Most players DPS; 1-2 (10-man) or 4-5 (25-man) drakes heal.",
            "DPS: use Flame Spike (1) twice to build combo points, then Engulf in Flames (2) to spend them; repeat 1-1-2. Keep Engulf in Flames stacking on Malygos.",
            "Healers: Revivify (3) and Life Burst (AoE heal, uses combo points). Because Life Burst is a 60-yard heal, stack up but stay at least 30 yards from Malygos so Arcane Pulse doesn't hit you.",
            "Static Field is a 30-yard sphere of heavy damage: follow the raid leader and stay together. Surge of Power is a beam on a random drake - use Flame Shield just before a big arcane hit lands.",
        },
        tank = {
            "Phase 1: face Malygos away from the raid. Phase 2: tank the Nexus Lords. Phase 3: there is no tanking - you are a drake DPS or healer.",
        },
        heal = {
            "Phase 1/2: heal the raid through Vortex and Arcane Barrage. Phase 3: choose whether you heal with Revivify/Life Burst or DPS; keep the group stacked.",
        },
        dps = {
            "Phase 1: kill Power Sparks and DPS Malygos. Phase 2: kill Scions from a Nexus Lord disc (melee) and Nexus Lords on the ground. Phase 3: 1-1-2 rotation.",
        },
        abilities = {
            { id = 56105, name = "Vortex", desc = "Lifts the whole raid into the air for about 10 seconds of damage. Run away from his face when you land." },
            { ids = { 56272, 60072 }, name = "Arcane Breath", desc = "A cone of arcane damage in front of him. Only the tank stands there." },
            { kind = "buff", id = 56152, name = "Power Spark", desc = "A spark that boosts Malygos' damage by 50% if it reaches him. Kill it first." },
            { id = 56505, name = "Deep Breath", desc = "Massive arcane damage to everyone not on a disc during phase 2." },
            { id = 56438, name = "Arcane Overload", desc = "Pink zones that reduce magic damage taken by 50%. Shrink over time." },
            { ids = { 56397, 63934 }, name = "Arcane Barrage", desc = "Scions of Eternity cast this on random players." },
            { id = 57432, name = "Arcane Pulse", desc = "Damage to anyone within 30 yards of Malygos in phase 3." },
            { id = 57430, name = "Static Field", desc = "A 30-yard sphere of heavy arcane damage in phase 3. Stack and follow your leader." },
            { ids = { 56548, 57407 }, name = "Surge of Power", desc = "A beam on a random drake. Flame Shield helps." },
            { id = 56091, name = "Flame Spike", desc = "Drake ability 1: hits Malygos and builds combo points." },
            { kind = "debuff", id = 56092, name = "Engulf in Flames", desc = "Drake ability 2: spends combo points and stacks a damage effect on Malygos." },
            { id = 57090, name = "Revivify", desc = "Drake heal (ability 3)." },
            { id = 57143, name = "Life Burst", desc = "Drake AoE heal (60 yards), uses combo points." },
            { kind = "buff", id = 57108, name = "Flame Shield", desc = "Drake defensive: use it right before a big arcane hit." },
            { kind = "buff", id = 57092, name = "Blazing Speed", desc = "Drake speed boost for moving out of Static Field." },
        },
    },
}, "Warcraft Tavern (Malygos 10/25 strategy guide), Warcraft Wiki (Malygos tactics), wowtbc.gg (Eye of Eternity), wow-pro; Syndicate Guild page not checked for this raid")
