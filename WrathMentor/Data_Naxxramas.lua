-- Naxxramas (WotLK, 10/25)
-- Boss fields: name, aliases, tldr, start, general, tank, heal, dps, abilities, hard, src
-- Line tags:  "[10] text" only in 10-man, "[25] text" only in 25-man, "#{a/b}" = a in 10-man / b in 25-man.
-- Ability: { id/ids = spell ID(s) (only linked if the client confirms the name), name, desc }
local WM = WrathMentor

WM:AddRaid("naxx", "Naxxramas", { "Naxxramas" }, {
    ------------------------------------------------------------------ ARACHNID QUARTER
    {
        name = "Anub'Rekhan",
        tldr = "Kill every Crypt Guard fast, keep the raid away from him while Locust Swarm is on, and AoE the Corpse Scarabs that pop out of dead guards and dead players.",
        start = {
            "Main tank pulls Anub'Rekhan and turns him away from the raid. An off-tank picks up the Crypt Guard(s) - there are 2 at the pull in 25-man, 1 in 10-man.",
            "Ranged and healers spread out around the room BEFORE the pull so one Impale cannot hit several people.",
            "Do not start damage until both tanks have their targets.",
        },
        general = {
            "## The Locust Swarm cycle",
            "Every time he casts Locust Swarm, he becomes dangerous to be near (silence + damage) and a NEW Crypt Guard spawns.",
            "The main tank kites him along the outer edge of the room for the whole swarm (his aggro range/silence radius is 30 yards) - a speed boost helps a lot. Everyone else stays at least 30 yards away so nobody gets silenced.",
            "## Between swarms",
            "Kill Crypt Guards as they appear (they can be stunned). Every dead guard, and every dead player, leaves Corpse Scarabs - AoE them at once.",
            "Impale hits a random player: staying spread out means it only ever hits one person.",
        },
        tank = {
            "Main tank: keep him facing away from the raid. When Locust Swarm starts, keep moving along the outer wall until it ends (a Hunter's Aspect of the Pack or a speed potion makes this easy).",
            "Off-tank: hold the Crypt Guard(s) away from the raid and let DPS cleave them.",
        },
        heal = {
            "Stay spread out. The kiting tank cannot be next to you during the swarm, so use HoTs and instants on them.",
            "Top off whoever is hit by Impale.",
        },
        dps = {
            "Kill Crypt Guards first, then Anub'Rekhan.",
            "Ranged: stay away from him during Locust Swarm to avoid the silence.",
            "Hunters and Mages: Frost Trap / Frost Nova help control Corpse Scarabs.",
        },
        abilities = {
            { ids = { 28785, 54021 }, name = "Locust Swarm", desc = "He calls a swarm that silences and damages players near him. The tank kites him; everyone else stays away. A new Crypt Guard spawns each time." },
            { ids = { 28783, 56090 }, name = "Impale", desc = "A random player takes heavy damage from a spike line. Spread out so only one player is hit." },
        },
    },
    {
        name = "Grand Widow Faerlina",
        tldr = "Move out of Rain of Fire and cleanse the poison. To remove her Frenzy: in 25-man, Mind Control a Worshipper and use its Widow's Embrace; in 10-man, Worshippers can't be Mind Controlled - bring one low and finish it off next to her instead.",
        start = {
            "Main tank holds Faerlina. The off-tank picks up all 4 Worshippers and keeps them alive near the raid (in 25-man, a third tank also picks up the 2 Naxxramas Followers).",
            "[25] A Priest has to be ready to Mind Control a Worshipper shortly before Faerlina Frenzies.",
            "[10] Worshippers here are immune to Mind Control - pre-pick one, bring it to around 5% health, and hold it there until it's needed.",
        },
        general = {
            "## The Frenzy / Widow's Embrace loop",
            "Faerlina periodically gains Frenzy, which hits the tank much harder. It's removed by Widow's Embrace, cast by a Worshipper next to her.",
            "[25] A Priest Mind Controls a Worshipper, walks it to Faerlina and uses its Widow's Embrace ability.",
            "[10] Worshippers can't be Mind Controlled here - instead, DPS finish off the pre-weakened Worshipper right next to Faerlina; killing it near her triggers Widow's Embrace automatically.",
            "Timing matters: using Widow's Embrace BEFORE Frenzy delays the next Frenzy by 30 seconds; doing it AFTER she already has Frenzy locks out her nature school (and removes the buff) for a full 60 seconds - so it's best to wait until she's actually enraged.",
            "## Everything else",
            "Rain of Fire: step out of the fire on the ground.",
            "Poison Bolt Volley hits the raid with a poison: cleanse it (a Shaman's Cleansing Totem helps).",
            "[25] Naxxramas Followers silence anyone within 10 yards and occasionally charge a random player - tank them away from casters and healers.",
        },
        tank = {
            "Main tank: keep Faerlina facing away from the raid.",
            "Off-tank: pick up all 4 Worshippers and hold them near the raid. [25] A third tank keeps the 2 Followers away from casters.",
        },
        heal = {
            "Cleanse Poison Bolt Volley from the raid.",
            "Expect heavy tank damage if Frenzy is not removed on time - have cooldowns ready.",
        },
        dps = {
            "Attack Faerlina; [25] never touch the Worshippers (they're needed alive for Mind Control) - only the Followers are fair game.",
            "[10] Bring one pre-chosen Worshipper down to about 5% health and finish it off next to Faerlina once she's enraged.",
            "Stay out of Rain of Fire.",
        },
        abilities = {
            { ids = { 28796, 54098 }, name = "Poison Bolt Volley", desc = "Poison damage on several players at once. Cleanse it." },
            { ids = { 28794, 54099 }, name = "Rain of Fire", desc = "Fire on the ground under a player. Step out of it immediately." },
            { ids = { 28798, 54100 }, name = "Frenzy", desc = "Faerlina attacks much faster and hits much harder. Removed only by Widow's Embrace." },
            { ids = { 28732, 54097 }, name = "Widow's Embrace", desc = "Cast by a Worshipper next to Faerlina (Mind Controlled in 25-man, killed there in 10-man): removes Frenzy and delays the next one." },
        },
    },
    {
        name = "Maexxna",
        tldr = "Free the players stuck in Web Wraps immediately, heal and HoT before every Web Spray, tank her away from the raid, and burn her when she Frenzies at 30%.",
        start = {
            "Tank Maexxna far away from the raid (Poison Shock hits everyone in front of her).",
            "Healers put HoTs on the tank early - Web Spray arrives 40 seconds after the pull and then every 40 seconds.",
        },
        general = {
            "## Web Wrap (starts 20 seconds in, then every 40 seconds)",
            "Random players are cocooned on the wall (two at a time in 25-man). Kill the web to free them fast; a wrapped player cannot fight.",
            "## Web Spray (every 40 seconds)",
            "Big raid-wide damage plus a stun. Healers top everyone off and have HoTs rolling BEFORE it lands.",
            "## Necrotic Poison and adds",
            "Necrotic Poison sits on the tank and cuts healing: cleanse it as quickly as possible (a Shaman's Cleansing Totem is very useful during Web Spray).",
            "Spiderlings appear from Web Wrap: AoE them down.",
            "At 30% health she gains Frenzy - use offensive cooldowns and finish her.",
        },
        tank = {
            "Keep her turned away from the raid so Poison Shock only hits you.",
            "Ask for the poison to be cleansed; use a defensive during Web Spray if your health is low.",
        },
        heal = {
            "Cleanse Necrotic Poison from the tank right away.",
            "Pre-cast HoTs and big heals before each Web Spray (every 40 seconds).",
        },
        dps = {
            "Free the webbed players first when they appear, then go back to Maexxna.",
            "AoE the Spiderlings.",
            "Save Bloodlust/Heroism and cooldowns for the 30% Frenzy phase.",
        },
        abilities = {
            { id = 28622, name = "Web Wrap", desc = "Players are stuck to the wall in a web (two at a time in 25-man). Destroy the web to free them." },
            { ids = { 29484, 54125 }, name = "Web Spray", desc = "Damages and stuns the whole raid. Heal up before it." },
            { ids = { 28776, 54121 }, name = "Necrotic Poison", desc = "Reduces healing taken by the tank. Cleanse it quickly." },
            { ids = { 28741, 54122 }, name = "Poison Shock", desc = "Poison damage in front of Maexxna. Keep her facing away from the raid." },
            { ids = { 54123, 54124 }, name = "Frenzy", desc = "At 30% health she attacks faster. Burn her down." },
        },
    },
    ------------------------------------------------------------------ PLAGUE QUARTER
    {
        name = "Noth the Plaguebringer",
        tldr = "Decurse the Curse of the Plaguebringer at once (or the raid dies), kill the skeleton waves, and let the tank get threat back after every Blink.",
        start = {
            "Tank Noth anywhere convenient. Priests, Mages, Druids and Paladins/Shamans must be ready to decurse.",
            "Tank picks up Noth and the Plagued Warriors that spawn with him.",
        },
        general = {
            "## Ground phase",
            "The Curse of the Plaguebringer lands on several players (10 players in 25-man) and MUST be dispelled. If it isn't, it turns into Wrath of the Plaguebringer, which wipes the raid.",
            "Three Plagued Warriors spawn: kill them.",
            "Blink: Noth teleports, drops threat and slows/cripples people nearby. DPS pause until the tank has threat again, and cleanse the Cripple.",
            "## Balcony phase (about 70 seconds)",
            "Noth leaves to his balcony and waves of skeletons appear. Kill each wave. In the 2nd and 3rd balcony phases kill the Plagued Guardian first.",
            "Shadow Shock deals raid damage - keep healing.",
            "Then he returns and the ground phase repeats.",
        },
        tank = {
            "Grab Noth and the Plagued Warriors. After each Blink, taunt/re-establish threat before DPS resumes.",
        },
        heal = {
            "Decurse Curse of the Plaguebringer immediately - this is the wipe mechanic.",
            "Cleanse Cripple after Blink (a Priest's Mass Dispel helps).",
        },
        dps = {
            "Hold your damage after a Blink until the tank has threat.",
            "Kill the Plagued Warriors quickly, then skeletons during the balcony phase.",
        },
        abilities = {
            { ids = { 29213, 54835 }, name = "Curse of the Plaguebringer", desc = "A curse on several players. Dispel it right away or it becomes Wrath of the Plaguebringer." },
            { ids = { 29214, 54836 }, name = "Wrath of the Plaguebringer", desc = "Massive raid damage that happens when the curse is left on players." },
            { ids = { 29208, 29209, 29210, 29211 }, name = "Blink", desc = "Noth teleports, resets threat and slows nearby players." },
            { id = 29212, name = "Cripple", desc = "Slows and weakens players after Blink. Cleanse it." },
        },
    },
    {
        name = "Heigan the Unclean",
        tldr = "Learn the safe-zone dance: the floor erupts in every zone except one, so walk 1-2-3-4-3-2-1-2 with everyone. Casters and healers stand on the platform in phase 1.",
        start = {
            "The room floor is split into 4 zones in a row. Zone 1 is the FURTHEST LEFT if you face the platform.",
            "Tank and melee stand at the start of the dance (zone 1). Ranged and healers stand on the platform behind Heigan.",
            "Use Smoke Flares (or raid marks) to mark the zones if your raid wants them visible.",
        },
        general = {
            "## Phase 1 (90 seconds)",
            "Heigan casts Spell Disruption (slows casting) on anyone near him, so ranged and healers stay on the platform - it is safe for them and out of range of the eruptions.",
            "Tank and melee do the dance. The eruption comes in waves; the SAFE zone order is 1 - 2 - 3 - 4 - 3 - 2 - 1 - 2, then it repeats.",
            "Cleanse Decrepit Fever when it lands.",
            "## Phase 2 (45 seconds)",
            "Heigan teleports to the platform. Ranged and healers MUST leave the platform right away (Plague Cloud kills them) and run straight to zone 1.",
            "EVERYONE now dances, and it is faster. Order: 1 - 2 - 3 - 4 - 3 - 2 - 1 - 2 - 3 - 4 - 3 - 2.",
            "After phase 2 he returns to the floor and phase 1 restarts.",
            "There is no enrage. The only priority is not being hit by the Eruption.",
        },
        tank = {
            "Tank Heigan at the start of the floor and dance with the melee. Face him away from the group.",
        },
        heal = {
            "Phase 1: heal from the platform and cleanse Decrepit Fever.",
            "Phase 2: leave the platform immediately and dance with everyone else.",
        },
        dps = {
            "Melee: dance every eruption and never stop moving early. Ranged: DPS from the platform in phase 1, and jump off for phase 2.",
            "Use cooldowns on the platform in phase 1 - ranged do not have to move.",
        },
        abilities = {
            { ids = { 29371 }, name = "Eruption", desc = "Fire erupts across the floor zones (all but one). Stand in the safe zone." },
            { id = 29310, name = "Spell Disruption", desc = "Slows casting for those near Heigan. The reason casters use the platform." },
            { ids = { 29998, 55011 }, name = "Decrepit Fever", desc = "A disease that lowers max health. Cleanse it." },
            { id = 29350, name = "Plague Cloud", desc = "Deadly poison cloud on the platform in phase 2. Everyone must leave the platform." },
        },
    },
    {
        name = "Loatheb",
        tldr = "Healers may only heal in short windows after Necrotic Aura ends. Kill a Spore near the raid every 30 seconds for Fungal Creep, and pop tank/raid cooldowns for Inevitable Doom.",
        start = {
            "Tank Loatheb in the middle. Everyone should be split into Spore groups so a Spore is killed by the assigned group within 10 yards.",
            "Healers plan the heal rotation - everyone can cast heals only during the 3-second window between auras.",
        },
        general = {
            "## Necrotic Aura (every 20 seconds)",
            "While the aura is up, healing on players does almost nothing. Healers get roughly a 3-second window after it ends - start pre-casting a heal just before the aura drops so it lands in the window.",
            "Absorbs work during the aura: Power Word: Shield, Sacred Shield, and well-timed HoTs (Druids pop Lifebloom as the aura ends).",
            "## Spores (every 30 seconds)",
            "A Spore spawns. When the assigned group is within 10 yards of it, kill it. Everyone near it gets Fungal Creep (extra crit).",
            "## Deathbloom (every 30 seconds)",
            "Loatheb casts Deathbloom on the raid every 30 seconds - keep everyone topped off so it can't kill someone.",
            "## Inevitable Doom (starts after 2 minutes, every 30 seconds)",
            "Huge damage to one target. Paladins/Rogues/Mages can survive it with Divine Shield, Cloak of Shadows, or Ice Block.",
        },
        tank = {
            "Hold Loatheb steady and pop a defensive cooldown before the second Inevitable Doom.",
        },
        heal = {
            "Follow the assigned healing rotation exactly. Pre-cast so your heal lands the moment Necrotic Aura ends.",
            "Use shields/absorbs and HoT timing during Necrotic Aura.",
        },
        dps = {
            "Kill the Spore when your assigned group is next to it (within 10 yards) to get Fungal Creep.",
            "Personal immunities (Divine Shield, Cloak of Shadows, Ice Block) can remove Inevitable Doom from you.",
        },
        abilities = {
            { id = 55593, name = "Necrotic Aura", desc = "Healing done to the group is reduced almost to nothing for a few seconds. Healers heal in the gaps." },
            { ids = { 29865, 55053 }, name = "Deathbloom", desc = "Cast on the raid every 30 seconds. Keep everyone topped off through it." },
            { ids = { 29204, 55052 }, name = "Inevitable Doom", desc = "Very heavy damage on one target every 30 seconds after 2 minutes. Use cooldowns or immunities." },
            { id = 29232, name = "Fungal Creep", desc = "A crit buff from killing a Spore near the raid." },
        },
    },
    ------------------------------------------------------------------ MILITARY QUARTER
    {
        name = "Instructor Razuvious",
        aliases = { "Death Knight Understudy" },
        tldr = "Take control of two Death Knight Understudies and use THEIR Bone Barrier, Taunt and Blood Strike to tank Razuvious. In 10-man you click Controlling Orbs to do this; in 25-man two Priests Mind Control instead. Never tank him with a normal tank.",
        start = {
            "[10] Click a Controlling Orb near an Understudy to take control of it - no Priest needed. Take control of two Understudies this way; the other two are tanked off to the side by regular tanks.",
            "[25] You need two Priests to Mind Control two of the four Understudies; the other two are tanked off to the side by regular tanks.",
            "Action bar while controlling an Understudy: slot 6 = Bone Barrier, slot 5 = Taunt, slot 4 = Blood Strike.",
        },
        general = {
            "## The Taunt rotation",
            "Controller 1 puts up Bone Barrier on their Understudy, Taunts Razuvious onto it, then spams Blood Strike on cooldown.",
            "Bone Barrier lasts 20 seconds on a 30-second cooldown, and Taunt is a 20-second cooldown too - swap Understudy tanks so Razuvious is always hitting whichever one currently has Bone Barrier up. Tanking him without it is fatal.",
            "[25] If your Mind Control is about to break or you need to reposition, releasing it and recasting works, but isn't required just to keep Taunt available - Taunt is already off cooldown every 20 seconds on its own.",
            "## Damage to expect",
            "Jagged Knife hits a random player for damage plus a bleed - can be avoided by staying out of Razuvious's line of sight. Disrupting Shout is unavoidable raid-wide damage every ~15-25 seconds.",
            "Heal the controlled Understudies - they are the tanks and won't survive without it.",
        },
        tank = {
            "Off-tank the two uncontrolled Understudies off to the side. You do NOT tank Razuvious himself - only a controlled Understudy with Bone Barrier can survive him.",
        },
        heal = {
            "Heal whichever Understudy is currently tanking as your top priority. Assign someone to watch Jagged Knife targets and keep everyone topped off through Disrupting Shout.",
        },
        dps = {
            "Focus Razuvious. Do not pull aggro from the Understudy tank.",
            "[25] Priests can Fade and Paladins can Hand of Sacrifice to lower the threat the controlling Priest generates.",
        },
        abilities = {
            { ids = { 29107, 55543 }, name = "Disrupting Shout", desc = "Raid-wide damage and mana loss around Razuvious." },
            { id = 55550, name = "Jagged Knife", desc = "Thrown at a random player for damage and a bleed. Avoid his line of sight to dodge it." },
            { id = 26613, name = "Unbalancing Strike", desc = "A heavy blow on his target - why a normal tank cannot tank him." },
            { id = 29061, name = "Bone Barrier", desc = "Understudy tanking ability: a large damage reduction shield. Use first, every time it's off cooldown." },
            { id = 29060, name = "Taunt", desc = "Understudy ability to hold Razuvious. 20-second cooldown." },
        },
    },
    {
        name = "Gothik the Harvester",
        tldr = "Split the raid between the living side and the undead side. Kill the adds on your side but don't let the undead side get overrun. After about 4:30 he comes down; kill remaining adds, then Gothik.",
        start = {
            "Split into two groups: MORE DPS on the undead side. The undead adds are stronger than the living ones.",
            "Healers and tanks are split between the sides as well. Keep communication open between the sides.",
        },
        general = {
            "## Phase 1 (about 4:30) - Gothik cannot be attacked",
            "Waves of adds spawn on the living side. Every add killed there causes a stronger Spectral copy to appear on the undead side.",
            "Unrelenting Trainees (non-elite, cast Death Plague - dispel it; 35 spawn in 25-man) -> Spectral Trainees appear on the undead side (Arcane Explosion).",
            "Unrelenting Deathknights (elite, Shadow Mark and Intercept; 14 in 25-man) -> Spectral Deathknights (Whirlwind).",
            "Unrelenting Riders (elite, Unholy Aura, Shadow Bolt Volley on marked players; 4 in 25-man) -> Spectral Riders (Drain Life) and Spectral Horses (Stomp).",
            "The goal: control how many mobs you kill on the living side so the undead side never gets overwhelmed.",
            "## Phase 2",
            "After about 4:30 Gothik joins. He casts Harvest Soul on the whole raid every 15 seconds and Shadow Bolt on his target.",
            "Kill all remaining adds, then attack Gothik. He switches between the living and undead sides until 30% health, then the gate opens and everyone kills him together.",
        },
        tank = {
            "Pick up the adds on your side and hold them together so DPS can AoE them.",
        },
        heal = {
            "Dispel Death Plague from Trainees. Keep the group healed - the undead side needs the most healing.",
        },
        dps = {
            "Kill adds on your side quickly but pace the living side so the undead side isn't buried.",
            "After phase 2 starts, switch to Gothik once the adds around you are dead.",
        },
        abilities = {
            { id = 28679, name = "Harvest Soul", desc = "Gothik's raid-wide damage and debuff, cast every 15 seconds in phase 2." },
            { ids = { 29317, 56405 }, name = "Shadow Bolt", desc = "Damage on Gothik's current target." },
            { id = 27825, name = "Shadow Mark", desc = "Marks a player; Riders cast Shadow Bolt Volley on marked players." },
            { ids = { 55604, 55645 }, name = "Death Plague", desc = "A disease from Trainees. Healers should dispel it." },
        },
    },
    {
        name = "The Four Horsemen",
        aliases = { "Thane Korth'azz", "Lady Blaumeux", "Baron Rivendare", "Sir Zeliek" },
        tldr = "Four bosses in four corners. Every 3 Marks, the tank/healer groups swap sides. Korth'azz and Rivendare groups stay stacked (Meteor); Zeliek and Blaumeux groups stay spread (Holy Wrath, Void Zone).",
        start = {
            "When engaged, the Horsemen run to different corners. Split the raid into FOUR groups.",
            "Zeliek + Blaumeux (ranged bosses): 1 Ranged DPS + 1-2 healers on EACH of them.",
            "Korth'azz + Rivendare (melee bosses): 1 tank, half the remaining DPS and half the remaining healers on EACH.",
            "There must always be someone within 45 yards of every Horseman: Marks only stack on people in range and stop wiping you if nobody is in range.",
        },
        general = {
            "## The Marks",
            "Every Horseman puts a Mark on every player within 45 yards. Marks stack forever and hit harder each stack: 0, 500, 1,500, 4,000, 12,500, 20,000, then +1,000.",
            "The first Mark is cast 20 seconds after the pull, then every 12 seconds after that from all four Horsemen. Each Mark lasts 75 seconds and refreshes on every hit, so a corner left unattended for too long stacks up fast.",
            "## Rotation",
            "At 3 stacks of a Horseman's Mark, the two groups swap. For Zeliek and Blaumeux the groups move to each other's boss.",
            "For Korth'azz and Rivendare the groups meet halfway; the tanks Taunt off each other and go to the OTHER side. Stay STACKED while crossing because of Meteor.",
            "## After the first two die",
            "When Korth'azz and Rivendare are dead, those two groups help with Zeliek and Blaumeux. You still swap every 3 stacks.",
            "## Boss abilities",
            "Zeliek: Holy Bolt and Holy Wrath - stay SPREAD. Blaumeux: Shadow Bolt and Void Zone - move out of the void.",
            "Korth'azz: Meteor - stay STACKED to share it. Rivendare: Unholy Shadow.",
        },
        tank = {
            "Each melee-boss tank holds Korth'azz or Rivendare. When the group swaps at 3 Mark stacks, taunt off the other tank and move to the other side.",
        },
        heal = {
            "Heal your corner. Watch Meteor on the melee side (stacked) and spread damage on the ranged side.",
        },
        dps = {
            "Ranged on Zeliek/Blaumeux: stay spread and move when your group swaps. Melee groups: stay stacked for Meteor.",
        },
        abilities = {
            { id = 28832, name = "Mark of Korth'azz", desc = "A stacking damage mark on everyone within 45 yards of Korth'azz." },
            { id = 28833, name = "Mark of Blaumeux", desc = "Same for Blaumeux." },
            { id = 28834, name = "Mark of Rivendare", desc = "Same for Rivendare." },
            { id = 28835, name = "Mark of Zeliek", desc = "Same for Zeliek." },
            { ids = { 28884, 57467 }, name = "Meteor", desc = "Heavy fire damage split among everyone near the target. Stay stacked to share it." },
            { ids = { 28883, 57466 }, name = "Holy Wrath", desc = "Holy damage that jumps between nearby players. Stay spread." },
            { ids = { 28863, 57463 }, name = "Void Zone", desc = "A pool of shadow damage on the ground. Move out of it." },
            { ids = { 28882, 57369 }, name = "Unholy Shadow", desc = "Shadow damage on Rivendare's target." },
        },
    },
    ------------------------------------------------------------------ CONSTRUCT QUARTER
    {
        name = "Patchwerk",
        tldr = "A pure DPS and healing check. He Hateful Strikes whoever in melee range has the MOST health, so bring #{2/3} tanks with the highest health. Berserk at 6 minutes, Frenzy at 5%.",
        start = {
            "#{2/3} tanks: one main tank and the rest as soak tanks. Off-tanks must stand in melee range, stay 2nd/3rd on threat, and have the highest health of the melee.",
            "Healers assign healers to the tanks. Everyone else spreads out, and DPS gets ready with cooldowns.",
        },
        general = {
            "Hateful Strike hits the player in melee range with the highest health. The off-tanks intentionally take it so the main tank doesn't.",
            "Berserk at 6 minutes wipes the raid: this is a DPS race, so use cooldowns and Bloodlust.",
            "At 5% health he Frenzies: finish him quickly.",
        },
        tank = {
            "Off-tanks: stand in melee range, stay second/third on threat and keep the highest health available (buffs, food, health cooldowns).",
        },
        heal = {
            "Focus tank healing; the Hateful Strike target takes a huge hit every few seconds.",
        },
        dps = {
            "Melee: you can dip into the slime on the floor to lower your health so Hateful Strike doesn't pick you.",
            "Use every cooldown; there is a hard 6-minute timer.",
        },
        abilities = {
            { ids = { 28308, 59192 }, name = "Hateful Strike", desc = "A massive strike on the highest-health melee player. Off-tanks soak it." },
            { id = 26662, name = "Berserk", desc = "At 6 minutes he becomes unbeatable - kill him before this." },
            { id = 28131, name = "Frenzy", desc = "At 5% health he attacks faster." },
        },
    },
    {
        name = "Grobbulus",
        tldr = "Tank him on the outer edge of the room facing away from the raid. Off-tank grabs the Fallout Slime and kills it fast. Move Grobbulus each Poison Cloud; drop Mutating Injection near the last cloud.",
        start = {
            "Main tank pulls Grobbulus to the outside edge of the room and turns him away from the group.",
            "An off-tank stands ready to pick up the Fallout Slime that the Slime Spray creates.",
        },
        general = {
            "Slime Spray hits everyone in front of him and creates Fallout Slimes on the hit players. Slimes hurt anyone within 10 yards for 1,000 damage every 2 seconds - the off-tank grabs them and DPS kills them immediately.",
            "Every time he leaves a Poison Cloud, move him a little so the room isn't filled with clouds.",
            "A player marked with Mutating Injection must move near the LAST Poison Cloud before the debuff is dispelled or expires, so the resulting cloud doesn't take up new space. Injections come faster as the fight goes on.",
        },
        tank = {
            "Keep him at the edge, facing away. Move him slowly after each Poison Cloud.",
            "Off-tank: pick up Fallout Slimes right after Slime Spray.",
        },
        heal = {
            "Heal the tank through Slime Spray and dispel/heal the Mutating Injection target.",
        },
        dps = {
            "Kill the Fallout Slimes as soon as the off-tank has them. If you have Mutating Injection, walk next to the last cloud before it ends.",
        },
        abilities = {
            { ids = { 28157, 54364 }, name = "Slime Spray", desc = "Damages players in front of him and spawns Fallout Slimes." },
            { id = 28169, name = "Mutating Injection", desc = "A debuff that creates a poison cloud when it ends. Drop it near the last cloud." },
            { ids = { 28158, 54362 }, name = "Poison Cloud", desc = "A cloud left behind as he moves. Don't stand in it." },
        },
    },
    {
        name = "Gluth",
        tldr = "Tank him near the door; two tanks swap for Mortal Wound. Kite the Zombie Chow around until Decimate drops everyone to almost nothing, then kill the Zombies before they reach Gluth.",
        start = {
            "Two tanks stand near the door on the far side of the room. Zombie Chow appear from the grates at the back of the room.",
            "Assign a kiting team: Hunters (Frost Trap), Mages (Frost Nova, Blizzard), Shamans (Earthbind Totem), Rogues (Mind-numbing Poison) etc.",
        },
        general = {
            "Mortal Wound stacks on the tank: taunt-swap when it reaches 3-4 stacks.",
            "Zombie Chow spawn from the grates and must be kited around the back of the room until Decimate.",
            "Decimate reduces every Zombie to 5% health and they run to Gluth: if one reaches him it heals him for 5% of his health. Kill them quickly.",
            "Healers must top the tanks after Decimate.",
            "Gluth enrages during the fight: a Hunter's Tranquilizing Shot (or a Rogue's Shiv with Mind-numbing Poison) removes it.",
        },
        tank = {
            "Swap tanks at 3-4 Mortal Wound stacks. Keep Gluth near the door.",
        },
        heal = {
            "After Decimate, everyone is left at low health: top the tanks first, then the raid.",
        },
        dps = {
            "Help kite Zombie Chow with slows and stuns; when Decimate hits, kill the Zombies before they reach him.",
            "Hunters: Tranquilizing Shot on the Enrage.",
        },
        abilities = {
            { id = 54378, name = "Mortal Wound", desc = "A stacking debuff that cuts healing on the tank. Swap at 3-4 stacks." },
            { ids = { 28374, 54426 }, name = "Decimate", desc = "Reduces every Zombie Chow to 5% health; they run at Gluth and heal him if they reach him." },
            { ids = { 28371, 54427 }, name = "Enrage", desc = "Gluth attacks faster. Tranquilizing Shot or a Rogue's poison removes it." },
        },
    },
    {
        name = "Thaddius",
        aliases = { "Feugen", "Stalagg" },
        tldr = "Phase 1: kill Feugen and Stalagg within 5 seconds of each other. Phase 2: jump to Thaddius' platform and, after every Polarity Shift, stand with players who have the SAME charge as you.",
        start = {
            "Split the raid in two. Feugen and Stalagg stay on their own platforms the whole fight; each is tanked on its platform.",
            "They both use Magnetic Pull to yank the opposite tank across, so tanks must be ready to swap back.",
        },
        general = {
            "## Phase 1: Feugen and Stalagg",
            "They must die within 5 seconds of each other or they resurrect at full health.",
            "Feugen has Static Field (damage aura); Stalagg casts Power Surge on his tank.",
            "## Phase 2: Thaddius",
            "When both are dead, jump to Thaddius' platform. If you're late, stay away from the raid until the next Polarity Shift. He activates after 15 seconds.",
            "Polarity Shift gives every player a + or - charge. Group with players of the SAME charge; opposite charges next to each other hurt.",
            "Someone must always be in melee range or he uses Ball Lightning on the highest-threat player. Chain Lightning causes raid damage. Berserk after 6 minutes.",
        },
        tank = {
            "Phase 1: one tank on each of Feugen and Stalagg. Swap back after Magnetic Pull.",
            "Phase 2: hold Thaddius and keep a melee player always in range.",
        },
        heal = {
            "Heal through Chain Lightning; after Polarity Shift move to your charge group.",
        },
        dps = {
            "Phase 1: kill both add bosses at the same time. Phase 2: after each Polarity Shift, stack on same-charge players.",
            "Priests can Levitate and Mages Slow Fall to help with the jump.",
        },
        abilities = {
            { id = 28089, name = "Polarity Shift", desc = "Gives every player a positive or negative charge. Stand with players of the same charge." },
            { ids = { 28167, 54531 }, name = "Chain Lightning", desc = "Lightning that jumps between players. Heal through it." },
            { id = 28299, name = "Ball Lightning", desc = "Used on the highest-threat player if nobody is in melee range." },
            { ids = { 54529, 28134 }, name = "Power Surge", desc = "Stalagg's damage spell on his tank." },
            { ids = { 28135, 54528 }, name = "Static Field", desc = "Feugen's damage aura around him." },
            { id = 54517, name = "Magnetic Pull", desc = "Pulls the opposing tank across to the other platform." },
        },
    },
    ------------------------------------------------------------------ FROSTWYRM LAIR
    {
        name = "Sapphiron",
        tldr = "Ground phase: don't stand behind or in front of him, decurse Life Drain, avoid Chill. Air phase (every 45 seconds): after Icebolt hits, everyone hides BEHIND an ice block from Frost Breath.",
        start = {
            "Tank him with his back to the wall, facing away from the raid. Ranged and healers spread out on the same side of the room.",
            "Frost resistance helps a lot: Paladin Frost Resistance Aura and Shaman Frost Resistance Totem.",
        },
        general = {
            "## Ground phase",
            "Frost Aura damages the whole raid the entire fight.",
            "Don't stand directly behind him (Tail Sweep) or directly in front (Cleave). Decurse Life Drain quickly. Avoid Chill patches on the ground.",
            "## Air phase (every 45 seconds)",
            "He flies up. Stay loosely spread to reduce Icebolt damage - he casts it on 2 players per air phase in 10-man, 3 in 25-man.",
            "After a player is hit by Icebolt they turn into an ice block. EVERYONE runs BEHIND an ice block to avoid the Frost Breath - otherwise you die.",
            "After 10% health he no longer flies: just kill him.",
        },
        tank = {
            "Try not to move him much. It's fine to be hit by Chill; healers can heal through it.",
        },
        heal = {
            "Spread out on the same side, remove Life Drain, and heal through Frost Aura. Hide behind an ice block for Frost Breath.",
        },
        dps = {
            "Don't stand behind or in front of him. In the air phase, hide behind an ice block right after Icebolt is cast.",
        },
        abilities = {
            { ids = { 28531, 55799 }, name = "Frost Aura", desc = "Constant frost damage to the whole raid." },
            { ids = { 28542, 55665 }, name = "Life Drain", desc = "A curse that drains health. Decurse it." },
            { id = 28522, name = "Icebolt", desc = "Freezes a player in an ice block during the air phase. Use it as cover from Frost Breath." },
            { ids = { 28524, 29318 }, name = "Frost Breath", desc = "Lethal frost breath after the air phase Icebolts. Hide behind an ice block." },
            { ids = { 28560, 55699 }, name = "Blizzard", desc = "Ice storm on the ground. Move out." },
            { id = 28547, name = "Chill", desc = "A frost patch that damages and slows. Avoid it." },
        },
    },
    {
        name = "Kel'Thuzad",
        aliases = { "Guardian of Icecrown" },
        tldr = "P1 (about 3:50): kill waves of adds while KT is untouchable. P2: fight KT - spread for Frost Blast/Detonate Mana, avoid Shadow Fissure (one-shot), interrupt Frostbolt, crowd control Chains. P3 at 45%: off-tanks pick up the Guardians of Icecrown.",
        start = {
            "Phase 1 is only add control: KT can't be attacked. Melee kills Abominations, ranged kills Soldiers of the Frozen Waste and Soul Weavers.",
            "Set up your raid: tanks for Abominations, ranged near the back, a CC plan for Chains of Kel'Thuzad.",
        },
        general = {
            "## Phase 1 (about 3 minutes 50 seconds)",
            "Soldiers of the Frozen Waste: slow, low health, explode on touch for raid-wide shadow damage. Ranged kill them.",
            "Unstoppable Abominations: tank them; melee focus them. Soul Weavers: slow, deal AoE and knock back when they reach a target - keep away and kill.",
            "## Phase 2",
            "Finish off remaining adds and stay away from Soul Weavers.",
            "Frostbolt (interruptible) can burst the tank; Frostbolt Volley deals raid AoE.",
            "Spread out to avoid chaining Frost Blast (can hit the tank) and Detonate Mana. Move out of Shadow Fissure instantly - it one-shots.",
            "About every 90 seconds Kel'Thuzad casts Chains of Kel'Thuzad on players (never the main tank): crowd control them until it ends.",
            "## Phase 3 (starts at 45% health)",
            "Guardians of Icecrown spawn from the room's side chambers - 2 in 10-man, 4 in 25-man, arriving within a few seconds of each other. Off-tanks pick them up. Ignore them with DPS and keep killing Kel'Thuzad. Guardians use Blood Tap, a self-buff that stacks their size and damage over time, so they hit much harder the longer the phase runs.",
        },
        tank = {
            "Main tank: never targeted by Chains. Phase 3: the off-tanks pick up the Guardians of Icecrown as they spawn (2 in 10-man, 4 in 25-man).",
        },
        heal = {
            "Watch Frostbolt on the tank and Frost Blast chaining. Stay spread for Detonate Mana.",
        },
        dps = {
            "Phase 1: split roles (ranged on Soldiers/Weavers, melee on Abominations). Phase 2/3: interrupt Frostbolt, dodge Shadow Fissure, and never attack Chained players.",
        },
        abilities = {
            { ids = { 28478, 55802 }, name = "Frostbolt", desc = "Big frost hit on the tank. Interrupt it." },
            { ids = { 28479, 55807 }, name = "Frostbolt Volley", desc = "Raid-wide frost damage." },
            { id = 27808, name = "Frost Blast", desc = "Freezes a player and damages nearby ones - chains. Stay spread." },
            { id = 27819, name = "Detonate Mana", desc = "A mana user explodes for damage to those near them. Stay spread." },
            { id = 27810, name = "Shadow Fissure", desc = "A shadow pit that one-shots anyone caught. Move out." },
            { id = 28410, name = "Chains of Kel'Thuzad", desc = "Mind Controls players. Crowd-control them until it ends." },
        },
    },
}, "Syndicate Guild (Naxxramas raid page: boss order and one-line calls) and wowtbc.gg boss guide (mechanics and numbers)")
