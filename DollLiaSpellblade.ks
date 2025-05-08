'use strict';

//////////////////////////////////////////////////////
// DLSB - Doll.Lia's Spellblade Class               //
//  Version 0.1a                                    //
// Use DLSB_ as the prefix for any new content.     //
//////////////////////////////////////////////////////

// NOTE - If you are reading my code, I recommend an IDE such as VSCode that supports the #region tag.
// > This will help you navigate this file easier by using the preview bar on the right.

// NOTE TO SELF:
// Please remember to increment this when you update your own mod!
// -Doll.Lia
let DLSB_VER = 0.1

/**************************************************************
 * DLSB - Mod Configuration Menu
 * 
 * Access these properties with KDModSettings["DLSBMCM"]["NAME"]
 *  > Return can be a boolean, range, etc. depending upon the type.
 * 
 * Names are handled in CSV with the prefix KDModButton
 **************************************************************/                

//region MCM
if (KDEventMapGeneric['afterModSettingsLoad'] != undefined) {
    KDEventMapGeneric['afterModSettingsLoad']["DLSBMCM"] = (e, data) => {
        // Sanity check to make sure KDModSettings is NOT null. 
        if (KDModSettings == null) { 
            KDModSettings = {} 
            console.log("KDModSettings was null!")
        };
        if (KDModConfigs != undefined) {
            KDModConfigs["DLSBMCM"] = [
                {refvar: "DLSBMCM_Header_Meow", type: "text"},
                {refvar: "DLSBMCM_Meow",       type: "boolean", default: true, block: undefined},
            ]
        }
        let settingsobject = (KDModSettings.hasOwnProperty("DLSBMCM") == false) ? {} : Object.assign({}, KDModSettings["DLSBMCM"]);
        KDModConfigs["DLSBMCM"].forEach((option) => {
            if (settingsobject[option.refvar] == undefined) {
                settingsobject[option.refvar] = option.default
            }
        })
        KDModSettings["DLSBMCM"] = settingsobject;

        DLSB_MCM_Config()
    }
}

//  Trigger helper functions after the MCM is exited.
if (KDEventMapGeneric['afterModConfig'] != undefined) {
    KDEventMapGeneric['afterModConfig']["DLSBMCM"] = (e,  data) => {
        DLSB_MCM_Config()
    }
}

// Run all helper functions on game load OR post-MCM config.
////////////////////////////////////////////////////////////
function DLSB_MCM_Config(){

    // TBD

    KDLoadPerks();              // Refresh the perks list so that things show up.
    KDRefreshSpellCache = true;
}

//#region Initialize Save Data
/****************************************************************
 * Need to keep track of certain things.
 ****************************************************************/
KDAddEvent(KDEventMapGeneric, "afterNewGame", "DLSB_SaveData", (e, data) => {
    console.log("NEW GAME")
    // Initialize data in the save file if necessary.
    DLSB_Init_SpellbladeSave();
});

KDAddEvent(KDEventMapGeneric, "afterLoadGame", "DLSB_SaveData", (e, data) => {
    console.log("LOAD GAME")
    // Initialize data in the save file.
    DLSB_Init_SpellbladeSave();
});

function DLSB_Init_SpellbladeSave(){
    // Initialize the GameData portion for DollLia's mods.
    if(!KDGameData?.DollLia){
        console.log("Created DollLia base gamedata.")
        KDGameData.DollLia = {}
    }
    // Initialize the GameData portion for DollLia's mods.
    if(!KDGameData.DollLia?.Spellblade){
        console.log("Created DollLia Spellweaver gamedata.")
        KDGameData.DollLia.Spellblade = {
            modVer:             DLSB_VER,           // Important to track in case of potentially save-breaking changes. Can write code to fix.
            spellweaver:        [],                 // Queue for Spellweaver buffs.
            boundWeapon:        null,               // Store the player's bound weapon here.
            spellsWoven:        0,                  // Running total ID just to make sure buff IDs are unique.
        }
    }
    console.log(KDGameData.DollLia.Spellblade)
}



// #region Spellblade Class
/**************************************************************
 * DLSB - Spellblade Class
 * 
 * Wields Magic and Swords.
 **************************************************************/

// Spellblade class is defined in KDClassStart.
KDClassStart["DLSB_Spellblade"] = () => {
    // Spellblade should start with a Foil equipped.
    KinkyDungeonInventoryAddWeapon("Knife");
    KinkyDungeonInventoryAddWeapon("Foil");
    KDGameData.PreviousWeapon = ["Foil", "Knife", "Unarmed", "Unarmed"];
    KDSetWeapon("Foil");

    // Class-specific passive goes here
    KDPushSpell(KinkyDungeonFindSpell("DLSB_Spellweaver"));

    // Class-specific free passive.
    KDPushSpell(KinkyDungeonFindSpell("Vault"));

    // Starting spells
    KDPushSpell(KinkyDungeonFindSpell("Bondage"));
    KinkyDungeonSpellChoices.push(KinkyDungeonSpells.length - 1);
    KDPushSpell(KinkyDungeonFindSpell("CommandWord"));
    KinkyDungeonSpellChoices.push(KinkyDungeonSpells.length - 1);

    // SP+25, MP+25
    KDGameData.StatMaxBonus.SP += 2.5;
    KDGameData.StatMaxBonus.MP += 2.5;

    // Starting Supplies
    KinkyDungeonSpellPoints = 3;
    KDAddConsumable("RedKey", 1);
    KDAddConsumable("Pick", 1);
    KinkyDungeonGold = 100;

    // Potion loadout, slight bump in ManaPots.
    KinkyDungeonChangeConsumable(KinkyDungeonConsumables.PotionMana, 2);
    KinkyDungeonChangeConsumable(KinkyDungeonConsumables.PotionFrigid, 1);
    KinkyDungeonChangeConsumable(KinkyDungeonConsumables.PotionStamina, 1);
    KinkyDungeonChangeConsumable(KinkyDungeonConsumables.PotionWill, 1);

    // Starting bondage loadout, somewhat magic.
    KinkyDungeonInventoryAddLoose("StrongMagicRopeRaw", undefined, undefined, 10);
    KinkyDungeonInventoryAddLoose("TrapGag", undefined, undefined, 3);
}

// #region Multiclass Perk
// Add the "debuff" property to make it switch columns.
KinkyDungeonStatsPresets["MC_DLSB_Spellblade"] = {category: "Multiclass", id: "MC_DLSB_Spellblade", cost: 5, blockclass: ["DLSB_Spellblade"], tags: ["start", "mc"]}

KDPerkStart["MC_DLSB_Spellblade"] = () => {
    if (!KDHasSpell("DLSB_Spellweaver"))
        KDPushSpell(KinkyDungeonFindSpell("DLSB_Spellweaver"));
}



//#region Spellblade Content
/**************************************************
 * Spellblade - Class Spells
 **************************************************/

// Offhand
let DLSB_Spellblade_OffHand = {name: "DLSB_SpellbladeOffhand", tags: ["utility", "defense", "offense"], school: "Special",
    prerequisite: "DLSB_Spellweaver", classSpecific: "DLSB_Spellblade", hideWithout: "DLSB_Spellweaver",
    hideLearned: true, hideWith: "FighterOffhand",
    events: [
        {trigger: "canOffhand", type: "DLSB_SpellbladeOffhand", delayedOrder: 1},
    ],
    manacost: 0, components: [], level:1, spellPointCost: 1, type:"", passive: true, autoLearn: ["Offhand"],
    onhit:"", time:25, power: 0, range: 1.5, size: 1, damage: ""
}
// Offhand event
KDEventMapSpell.canOffhand["DLSB_SpellbladeOffhand"]  = (_e, _spell, data) => {
    if (!data.canOffhand && KDHasSpell("DLSB_SpellbladeOffhand")) {
        if (!(KDWeapon(data.item)?.heavy || KDWeapon(data.item)?.massive)
            || KDWeapon(data.item)?.tags?.includes("illum")) {
            data.canOffhand = true;
        }
    }
}

//#region Arcane Synergy
/////////////////////////////////////////////////////
// Arcane Synergy
// Mana costs reduced by 25% after consuming a Spellweaver proc.
///////////////////////////////////////////////////////////////////////////////

let DLSB_Spellblade_Sustain = {name: "DLSB_ArcaneSynergy", tags: ["mana", "utility"], school: "Special", manacost: 0, components: [], classSpecific: "DLSB_Spellblade", prerequisite: "DLSB_Spellweaver", hideUnlearnable: true, level:1, passive: true, type:"", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    events: [
        {type: "DLSB_ArcaneSynergy", trigger: "calcMultMana", mult: 0.75},

        {type: "DLSB_ArcaneSynergy", trigger: "spellTrigger"},
        {type: "DLSB_ArcaneSynergy", trigger: "playerCast"},
    ]
}

KDEventMapSpell.calcMultMana["DLSB_ArcaneSynergy"] = (e, _spell, data) => {
    // If we have the buff, compute the costs.
    if(KDEntityHasBuff(KinkyDungeonPlayerEntity,"DLSB_ArcaneSynergy")){
        // Do not reduce costs if the spell is a damage rider.
        if(data.spell.type == "passive" && data.spell.components.length == 0){
            return;
        }
        data.cost = Math.max(data.cost * e.mult);
    }
}

// Remove buff if you cast a spell
KDEventMapSpell.playerCast["DLSB_ArcaneSynergy"] = (_e, _spell, data) => {
    // Do not reduce costs if the spell is a damage rider.
    if(!KDEntityHasBuff(KinkyDungeonPlayerEntity,"DLSB_ArcaneSynergy") || (data.spell.type == "passive" && data.spell.components.length == 0)){
        return;
    }
    if(data.spell && data.manacost > 0){
        // Tick down stacks
        KinkyDungeonPlayerBuffs.DLSB_ArcaneSynergy.DLSB_AS_Stacks -= 1;
        KinkyDungeonPlayerBuffs.DLSB_ArcaneSynergy.text = null;

        // Expire buff if we ran out of stacks
        if(KinkyDungeonPlayerBuffs.DLSB_ArcaneSynergy.DLSB_AS_Stacks < 1){
            KinkyDungeonExpireBuff(KinkyDungeonPlayerEntity, "DLSB_ArcaneSynergy");
        }
    }
}

// Remove buff if you trigger a spell.
KDEventMapSpell.spellTrigger["DLSB_ArcaneSynergy"] = (_e, _spell, data) => {
    // Do not reduce costs if the spell is a damage rider.
    if(!KDEntityHasBuff(KinkyDungeonPlayerEntity,"DLSB_ArcaneSynergy") || (data.spell.type == "passive" && data.spell.components.length == 0)){
        return;
    }
    if(data.spell && data.manacost > 0){
        // Tick down stacks
        KinkyDungeonPlayerBuffs.DLSB_ArcaneSynergy.DLSB_AS_Stacks -= 1;
        KinkyDungeonPlayerBuffs.DLSB_ArcaneSynergy.text = null;

        // Expire buff if we ran out of stacks
        if(KinkyDungeonPlayerBuffs.DLSB_ArcaneSynergy.DLSB_AS_Stacks < 1){
            KinkyDungeonExpireBuff(KinkyDungeonPlayerEntity, "DLSB_ArcaneSynergy");
        }
    }
}

//#region Fancy Footwork
// Does nothing but set a flag that other parts of the class will check.
let DLSB_Spellblade_FF = {
    name: "DLSB_FancyFootwork", tags: ["utility", "offense"], school: "Special", manacost: 0, components: [],
    classSpecific: "DLSB_Spellblade", prerequisite: "DLSB_Displacement", hideWithout: "DLSB_Spellweaver",
    level:1, passive: true, type:"", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    events: [],
    learnFlags: ["DLSB_FancyFootwork"],     // Set a flag when you learn this spell, probably more performant than checking if you have the spell.
}



//#region Hexed Blade
/************************************************************************
 * Upgrade - Hexed Blade                                                *
 *                                                                      *
 * Adds a bunch of new and exciting effects to your Spellweaver.        *
 ************************************************************************/
let DLSB_Spellblade_HexedBlade = {
    name: "DLSB_HexedBlade", tags: ["utility", "offense"], school: "Special", manacost: 0, components: [],
    classSpecific: "DLSB_Spellblade", prerequisite: "DLSB_Spellweaver", hideWithout: "DLSB_Spellweaver",
    level:1, passive: true, type:"", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    events: [
        {type: "DLSB_HexedBlade", trigger: "duringCrit"},
    ],
    learnFlags: ["DLSB_HexedBlade"],        // Set a flag when you learn this spell, probably more performant than checking if you have the spell.
    spellPointCost: 2,                      // Make it cost 2
}

KDAddEvent(KDEventMapSpell, "duringCrit", "DLSB_HexedBlade", (e, spell, data) => {
    // console.log("Knowledge - During Crit:")
    // console.log(data)
    if (data.faction == "Player"
        // Buff that we are consuming has the correct tag
        && KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_SpellTag == "knowledge"
        // Is a weapon attack made with Spellweaver
        && (data.weapon || data.spell?.name == "DLSB_Spellweaver")
        && !data.customCrit
    ){
        // Make it super crit.
        data.crit *= 1.5;
        data.bindcrit *= 1.5;
        KinkyDungeonSetEnemyFlag(data.enemy, "RogueTarget", -1);
        KDDamageQueue.push({ floater: TextGet("KDRogueCritical"), Entity: data.enemy, Color: "#ff5555", Delay: data.Delay });
        data.customCrit = true;
    }
});
    

// Clone of Familiar, but doesn't count towards summons.
// Has a cool hat though!
KinkyDungeonEnemies.push({
    name: "DLSB_HexedAlly", tags: KDMapInit(["ghost", "flying", "silenceimmune", "blindimmune", "player", "melee"]), keepLevel: true, allied: true, armor: 0, followRange: 1, AI: "hunt", evasion: 0.33, accuracy: 1.5,
    visionRadius: 20, playerBlindSight: 100, maxhp: 8, minLevel:0, weight:-1000, movePoints: 1, attackPoints: 1, attack: "MeleeWill", attackRange: 1, attackWidth: 3, power: 1.5, dmgType: "pierce", CountLimit: false,
    stamina: 4,
    maxblock: 0,
    maxdodge: 2,
    nonDirectional: true,
    terrainTags: {}, floors:KDMapInit([])
});

//#region Spellweaver Queue
let DLSB_Spellblade_SpellweaverQueue = {
    name: "DLSB_SpellweaverQueue", tags: ["utility", "offense"], school: "Special", manacost: 0, components: [],
    classSpecific: "DLSB_Spellblade", prerequisite: "DLSB_ArcaneSynergy", hideWithout: "DLSB_Spellweaver",
    level:1, passive: true, type:"", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    events: [],
    learnFlags: ["DLSB_SpellweaverQueue"],        // Set a flag when you learn this spell, probably more performant than checking if you have the spell.
}

//#region Bound Weapon
/////////////////////////////////////////////////
// Bound Weapon
//
// Reduces SP costs based upon your max MP.
// Enables bound combat with Spellweaver charges.
/////////////////////////////////////////////////
let DLSB_Spellblade_Mageblade = {
    name: "DLSB_Mageblade", tags: ["utility", "defense", "offense"], quick: true, school: "Special", prerequisite: "DLSB_Spellweaver", classSpecific: "DLSB_Spellblade", hideWithout: "DLSB_Spellweaver",
    manacost: 0, components: [], level:1, spellPointCost: 1, type:"passive", defaultOff: true,
    mixedPassive: true,
    autoLearn: ["DLSB_Mageblade_Invis"],
    events: [
        //{type: "DLSB_Mageblade", trigger: "attackCost", power: 0.3, mult: 0.01},
        // Bound Combat
        {type: "DLSB_Mageblade", trigger: "calcDamage", always: true, delayedOrder: 2},
        {type: "DLSB_Mageblade", trigger: "getWeapon", always: true, delayedOrder: 2},
        // Binding
        {type: "DLSB_Mageblade", trigger: "toggleSpell", },
    ],
    onhit:"", time:25, power: 0, range: 1.5, size: 1, damage: "",
}

// Invisible passive that handles tracking attackCost event
let DLSB_Spellblade_Mageblade_Invis = {
    name: "DLSB_Mageblade_Invis", manacost: 0, components: [], level:1, passive: true, type:"", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    hideLearned: true, hideWithout: "DLSB_Mageblade",
    events: [
        {type: "DLSB_Mageblade_Invis", trigger: "attackCost", power: 0.3, mult: 0.01},
    ]
}

// Reduce attack cost if we are using our bound weapon.
KDAddEvent(KDEventMapSpell, "attackCost", "DLSB_Mageblade_Invis", (e, spell, data) => {
    //if(data.flags?.weapon?.name == KDWeapon({ name: KDGameData.DollLia.Spellblade.boundWeapon })?.name){
    if(KinkyDungeonPlayerWeapon == KDWeapon({ name: KDGameData.DollLia.Spellblade.boundWeapon })?.name){
        let amount = Math.min(e.power, e.mult * KinkyDungeonStatManaMax);
        data.mult *= 1 - amount;
    }
});

// Binding
KDAddEvent(KDEventMapSpell, "toggleSpell", "DLSB_Mageblade", (_e, spell, data) => {
    if (data.spell?.name == spell?.name) {
        KinkyDungeonSpellChoicesToggle[data.index] = false;

        KDGameData.InventoryAction = "DLSB_BindWeapon";
        KDShowInventory(null);
        KinkyDungeonCurrentFilter = Weapon;
        KinkyDungeonPlaySound(KinkyDungeonRootDirectory + "Audio/Rope1.ogg");
    }
});

KDAddEvent(KDEventMapSpell, "getWeapon", "DLSB_Mageblade", (_e, _spell, data) => {
    if (!data.IsSpell && !data.flags.HandsFree
        // Have a valid Spellweaver passive
        && (KDGameData.DollLia.Spellblade.spellweaver[0])
        && KDGameData.DollLia.Spellblade.boundWeapon
        && data.flags?.weapon?.name == KDWeapon({ name: KDGameData.DollLia.Spellblade.boundWeapon })?.name
        && (!KinkyDungeonIsArmsBound(false, true) || (KinkyDungeonCanStand() && KinkyDungeonSlowLevel < 2))
    ) {
        data.flags.HandsFree = true;
    }
});

KDAddEvent(KDEventMapSpell, "calcDamage", "DLSB_Mageblade", (_e, _spell, data) => {
    if (!data.IsSpell && !data.forceUse) {
        if (!KinkyDungeonCanUseWeapon(true, undefined, data.weapon)
            && KDGameData.DollLia.Spellblade.boundWeapon && data.weapon?.name == KDWeapon({ name: KDGameData.DollLia.Spellblade.boundWeapon })?.name
            && (data.flags.KDDamageHands || data.flags.KDDamageArms)
            && (KDGameData.DollLia.Spellblade.spellweaver[0])
            //&& (!KinkyDungeonIsArmsBound(false, true) || (KinkyDungeonCanStand() && KinkyDungeonSlowLevel < 2))
            && (!KDWeapon({ name: data.weapon?.name })?.noHands)
            && !KDWeapon({ name: data.weapon?.name })?.unarmed) {
            data.canUse = true;
            data.flags.KDDamageHands = false;
            data.flags.KDDamageArms = false;
            // TODO - Different penalty?
            data.accuracyMult = 0.6;
        }
    }
});

// Inventory Action
KDInventoryAction["DLSB_BindWeapon"] = {
    icon: (_player, _item) => {
        return "InventoryAction/DLSB_BindWeapon";
    },
    valid: (player, item) => {
        if (!(item?.type == Weapon && !KDWeapon(item)?.noHands && !KDWeapon(item)?.unarmed)) return false;
        if (KDInventoryActionContainer(player)) return false;
        return item.name != KDGameData.DollLia.Spellblade.boundWeapon;//KDGameData.AttachedWep;
    },
    label:  (_player, _item) => {
        if (KDGameData.DollLia.Spellblade.boundWeapon && KinkyDungeonInventoryGet(KDGameData.DollLia.Spellblade.boundWeapon))
            return KDGetItemNameString(KDGameData.DollLia.Spellblade.boundWeapon);
        return "";
    },
    itemlabel:  (_player, item) => {
        if (KDGameData.DollLia.Spellblade.boundWeapon == item.name)
            return TextGet("KDBindWeapon");
        return "";
    },
    /** Happens when you click the button */
    click: (_player, item) => {
        KDGameData.DollLia.Spellblade.boundWeapon = item.name;
        KinkyDungeonAdvanceTime(1, true, true);
        KDStunTurns(4, true);
        KinkyDungeonDrawState = "Game";
        KDResetAlternateInventoryRender();
        KDRefreshCharacter.set(KinkyDungeonPlayer, true);
        KinkyDungeonDressPlayer();
        KinkyDungeonPlaySound(KinkyDungeonRootDirectory + "Audio/Rope4.ogg");
    },
    /** Return true to cancel it */
    cancel: (_player, delta) => {
        if (delta > 0) {
            if (KinkyDungeonLastTurnAction != "Wait") {
                return true;
            }
        }
        return false;
    },
}

// Spellweaver
//#region Spellweaver
//////////////////////////////////////////////////
//          Core Passive - Spellweaver          //
//////////////////////////////////////////////////
let DLSB_Spellblade_CorePassive = {name: "DLSB_Spellweaver", tags: ["utility"], school: "Special", manacost: 0, components: [], classSpecific: "DLSB_Spellblade", prerequisite: "Null", hideUnlearnable: true, level:1, passive: true, type:"", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    events: [
        //{type: "RogueTargets", trigger: "duringCrit", mult: 1.5},
        // Events to handle granting a buff to the player on spellcast:
        {type: "DLSB_Spellweaver", trigger: "spellTrigger"},
        {type: "DLSB_Spellweaver", trigger: "playerCast"},

        // Events to handle consuming the buff on attack:
        {type: "DLSB_Spellweaver", power: 3, trigger: "playerAttack", },//prereq: "wepDamageType", kind: "melee",},
    ]
}

KDEventMapSpell.spellTrigger["DLSB_Spellweaver"] = (_e, _spell, data) => {
    if (!data.spell) return;
    if (!data.castID) data.castID = KinkyDungeonGetSpellID();
    if(data.spell.type == "passive" && data.spell.components.length == 0){
        return;
    }
    //if (!data.manacost) data.manacost = KinkyDungeonGetManaCost(data.spell, data.Passive, data.Toggle);
    if (!KinkyDungeonFlags.get("DLSB_Spellweaver")
        //&& data.manacost > 0
    ) {
        // Use a helper function to determine the buff type.
        DLSB_Spellweaver_BuffType(data);

        // Set a flag to prevent duplicating this event
        KinkyDungeonSetFlag("DLSB_Spellweaver", 1);
    }
}

KDEventMapSpell.playerCast["DLSB_Spellweaver"] = (_e, _spell, data) => {
    if(data.spell.type == "passive" && data.spell.components.length == 0){
        return;
    }
    if (data.spell 
        //&& data.manacost > 0 
        && !KinkyDungeonFlags.get("DLSB_Spellweaver")
    ) {
        // NOTE - This is a clone of the body of the above "spellTrigger" event.
        // Use a helper function to determine the buff type.
        DLSB_Spellweaver_BuffType(data);

        // Set a flag to prevent duplicating this event
        KinkyDungeonSetFlag("DLSB_Spellweaver", 1);
    }
}

// If the buff times out, need to clear Current Buff.
KDAddEvent(KDEventMapBuff, "expireBuff", "DLSB_Spellweaver", (_e, buff, entity, data) => {
});

// Expire Buff was a turn late.
KDAddEvent(KDEventMapBuff, "tick", "DLSB_Spellweaver", (_e, buff, entity, data) => {
    //console.log(buff)
    if (buff.id == KDGameData.DollLia.Spellblade.spellweaver[0] && buff.duration == 1 && entity.player) {
        //console.log("END BUFF NOW");
        buff.duration = 0;
        KDGameData.DollLia.Spellblade.spellweaver.shift()//[0] = null;
    }
});

// Constants for quick balancing.
let DLSB_SPELLWEAVER_BUFFDUR                = 10
let DLSB_SPELLWEAVER_POWER                  = 3     
let DLSB_SPELLWEAVER_POWER_UTIL             = 2     // Utility schools hit weaker than Elemental, etc.
let DLSB_SPELLWEAVER_POWER_BIND             = 1.5   // Bondage schools
let DLSB_SPELLWEAVER_POWER_BINDAMT          = 2     // Bondage schools
// Hexed Blade
let DLSB_SPELLWEAVER_HEXED_POWER            = 4
let DLSB_SPELLWEAVER_HEXED_POWER_UTIL       = 3
let DLSB_SPELLWEAVER_HEXED_POWER_BIND       = 2
let DLSB_SPELLWEAVER_HEXED_POWER_BINDAMT    = 2.5   // Bondage schools
let DLSB_Checked_Tags = ["fire", "ice", "earth", "electric", "air", "water", "latex", "summon", "physics", "metal", "leather", "rope", "knowledge", "stealth", "light", "shadow"]//, "telekinesis"]

// TODO - Expand this.
let DLSB_All_Possible_Tags = DLSB_Checked_Tags.concat([])


function DLSB_Spellweaver_BuffType(data, forceTag = null, forceDur = null){
    // Use Spell Tags to determine what buff to grant to the player.
    /****************************************
     * Relevant Spell Tags
     * 
     * "fire", "ice", "earth", "electric", "air", "water"
     * "latex", "summon", "physics", "metal", "leather", "rope"
     * "stealth", "light", "shadow", "knowledge"
     * 
     * Command spells only have "binding" and "command" so we may need to make special cases.
     * 
     * Find the buff to apply, if any.
     */
    
    // Find a valid spell tag that we are listening for.
    // > This returns the first thing found, so putting "hybrid" tags first might be a play.
    // > If a "frostfire" spell has ["frostfire", "fire", "ice"] it SHOULD find "frostfire" first.
    let spellTag = null;
    if(forceTag){
        spellTag = forceTag;
    }
    else if(data){
        // Force certain overrides.
        if(data.spell.name == "TrueSteel"){spellTag = "knowledge"}
        else{
            spellTag = data.spell.tags.find((spelltag) => DLSB_Checked_Tags.includes(spelltag))
        }

    }
    if(!spellTag){
        //console.log("Invalid spell for spellblade")
        return
    }

    // Randomly assign a spell tag if we are given "random"
    // This can include spell tags not normally accessible to the player. (Blade Twirl)
    //console.log(DLSB_All_Possible_Tags)
    if(spellTag == "random"){
        spellTag = DLSB_All_Possible_Tags[Math.floor(KDRandom() * DLSB_All_Possible_Tags.length)];
    }

    // Buff ID is entirely arbitrary. I'm just using an integer to make it unique.
    let newBuff = "DLSB_Spellweaver_" + String(KDGameData.DollLia.Spellblade.spellsWoven)//spellTag;
    KDGameData.DollLia.Spellblade.spellsWoven += 1;

    // If we have too many spellweaver charges, expire the oldest buff (first in queue).
    // TODO - Flag ternary condition instead of 1
    if(KDGameData.DollLia.Spellblade.spellweaver.length >= (KinkyDungeonFlags.get("DLSB_SpellweaverQueue") ? 2 : 1)){
        KinkyDungeonExpireBuff(KinkyDungeonPlayerEntity, KDGameData.DollLia.Spellblade.spellweaver[0])
        KDGameData.DollLia.Spellblade.spellweaver.shift();
    }
    // Push the buff.
    KDGameData.DollLia.Spellblade.spellweaver.push(newBuff)


    // Determine specific stats of the buff based upon tag.
    let spellweaverBuff_Power = DLSB_SPELLWEAVER_POWER;     // Default damage
    let spellweaver_type = null;                            // Damage type
    // Declare various properties that the buff may or may not have.
    let spellweaver_bind = null, spellweaver_distract = null, spellweaver_bindType = null, spellweaver_addBind = null, spellweaver_bindEff = null, 
        spellweaver_color = KDBaseWhite, spellweaver_crit = KDDefaultCrit
    let spellweaver_tileKind = null, spellweaver_tileAoE = 1.1, spellweaver_tileDur = null
    let spellweaver_buffSprite = null, spellweaver_buffText = null
    let spellweaver_buffTime = null

    // Switch statement to configure buff properties.
    // It's really messy, and I am sorry.
    switch(spellTag){
        // Elemental
        case "fire":
            spellweaver_type            = "fire";
            spellweaver_color           = KDBaseRed;
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER : spellweaverBuff_Power
            spellweaver_buffSprite      = "DLSB_Spellweaver_fire";
            spellweaver_buffText        = "DLSB_Spellweaver_fire"
            break;
        case "ice":
            spellweaver_type            = "frost";
            spellweaver_color           = KDBaseCyan;
            spellweaver_buffSprite      = "DLSB_Spellweaver_ice";
            spellweaver_buffText        = "DLSB_Spellweaver_ice";
            spellweaver_buffTime        = KinkyDungeonFlags.get("DLSB_HexedBlade") ? 6 : null
            break;
        case "earth":
            spellweaver_type            = "crush";
            spellweaver_color           = KDBaseOrange;
            spellweaver_buffSprite      = "DLSB_Spellweaver_earth";
            spellweaver_buffText        = "DLSB_Spellweaver_earth";
            break; 
        case "electric":
            spellweaver_type            = "electric";
            spellweaver_color           = KDBaseElectricBlue;
            spellweaverBuff_Power       = spellweaverBuff_Power;
            spellweaver_buffSprite      = "DLSB_Spellweaver_electric";
            spellweaver_buffText        = "DLSB_Spellweaver_electric";
            spellweaver_buffTime        = KinkyDungeonFlags.get("DLSB_HexedBlade") ? 2 : null
            break; 
        case "air":
            spellweaver_type            = "stun";
            spellweaver_color           = KDBaseWhite;
            spellweaver_buffSprite      = "DLSB_Spellweaver_air";
            spellweaver_buffText        = "DLSB_Spellweaver_air";
            break;
        case "water":
            spellweaver_type            = "soap";
            spellweaver_color           = KDBaseBlue;
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER : spellweaverBuff_Power
            spellweaver_buffSprite      = "DLSB_Spellweaver_water";
            spellweaver_buffText        = "DLSB_Spellweaver_water";
            break;
        // Conjuration - Bondage
        case "latex":
            spellweaver_type            = "glue";
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BIND : DLSB_SPELLWEAVER_POWER_BIND;
            spellweaver_addBind         = true;
            spellweaver_bindType        = "Slime";
            spellweaver_bind            = DLSB_SPELLWEAVER_POWER_BINDAMT;

            spellweaver_tileKind        = "Slime";
            spellweaver_tileAoE         = 1.1;
            spellweaver_tileDur         = 7;

            spellweaver_color           = "cc2f7b";       // Slime Pink
            spellweaver_buffSprite      = "DLSB_Spellweaver_latex";
            spellweaver_buffText        = "DLSB_Spellweaver_latex";
            break;
        case "metal":
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BIND : DLSB_SPELLWEAVER_POWER_BIND;
            spellweaver_addBind         = true;
            spellweaver_bindType        = "Metal";
            spellweaver_bind            = DLSB_SPELLWEAVER_POWER_BINDAMT;

            spellweaver_tileKind        = "Chains";
            spellweaver_tileAoE         = 1.1;
            spellweaver_tileDur         = 16;

            spellweaver_color           = KDBaseLightGrey;
            spellweaver_buffSprite      = "DLSB_Spellweaver_metal";
            spellweaver_buffText        = "DLSB_Spellweaver_metal";
            break;
        case "leather":
            spellweaver_type            = "pain";       // Leather is specifically pain
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BIND : DLSB_SPELLWEAVER_POWER_BIND;
            spellweaver_addBind         = true;
            spellweaver_bindType        = "Leather";
            spellweaver_bind            = DLSB_SPELLWEAVER_POWER_BINDAMT;

            spellweaver_tileKind        = "Belts";
            spellweaver_tileAoE         = 1.1;
            spellweaver_tileDur         = 12;

            spellweaver_color           = KDBaseLightGrey;
            spellweaver_buffSprite      = "DLSB_Spellweaver_leather";
            spellweaver_buffText        = "DLSB_Spellweaver_leather";
            break;
        case "rope":
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BIND : DLSB_SPELLWEAVER_POWER_BIND;
            spellweaver_addBind         = true;
            spellweaver_bindType        = "Rope";
            spellweaver_bind            = DLSB_SPELLWEAVER_POWER_BINDAMT;

            spellweaver_tileKind        = "Ropes";
            spellweaver_tileAoE         = 1.1;
            spellweaver_tileDur         = 12;

            spellweaver_color           = "ED872D"
            spellweaver_buffSprite      = "DLSB_Spellweaver_rope";
            spellweaver_buffText        = "DLSB_Spellweaver_rope";
            break;
        // Conjuration - Other
        case "summon":
            spellweaver_type            = "stun";
            spellweaver_color           = KDBaseLime;
            spellweaverBuff_Power       = DLSB_SPELLWEAVER_POWER_UTIL;
            spellweaver_buffSprite      = "DLSB_Spellweaver_summon";
            spellweaver_buffText        = "DLSB_Spellweaver_summon";
            break;
        case "physics":
            spellweaver_type            = "stun";
            spellweaver_color           = KDBaseYellowGreen;
            spellweaverBuff_Power       = DLSB_SPELLWEAVER_POWER_UTIL;
            spellweaver_buffSprite      = "DLSB_Spellweaver_physics";
            spellweaver_buffText        = "DLSB_Spellweaver_physics";
            break;
        case "telekinesis":
            spellweaver_type            = "stun";
            spellweaver_color           = KDBaseYellowGreen;
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_UTIL : DLSB_SPELLWEAVER_POWER_UTIL
            spellweaver_buffSprite      = "DLSB_Spellweaver_telekinesis";
            spellweaver_buffText        = "DLSB_Spellweaver_telekinesis";
            break;
        // Illusion
        case "light":
            spellweaver_type            = "holy";
            spellweaver_color           = KDBaseYellow;
            spellweaver_buffSprite      = "DLSB_Spellweaver_light";
            spellweaver_buffText        = "DLSB_Spellweaver_light";
            break;
        case "shadow":
            spellweaver_type            = "cold";
            spellweaver_color           = KDBasePurple;
            spellweaver_buffSprite      = "DLSB_Spellweaver_shadow";
            spellweaver_buffText        = "DLSB_Spellweaver_shadow";
            break;
        case "stealth":
            spellweaver_type            = "stun";
            spellweaver_color           = KDBaseLightGrey;
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_UTIL : DLSB_SPELLWEAVER_POWER_UTIL
            spellweaver_buffSprite      = "DLSB_Spellweaver_stealth";
            spellweaver_buffText        = "DLSB_Spellweaver_stealth";
            break;
        case "knowledge":
            spellweaver_type            = "stun";
            spellweaver_color           = KDBaseLightGrey;
            spellweaverBuff_Power       = DLSB_SPELLWEAVER_POWER_UTIL;
            spellweaver_buffSprite      = "DLSB_Spellweaver_knowledge";
            spellweaver_buffText        = "DLSB_Spellweaver_knowledge";
            break;
        /// We should never hit this, but just in case, default to blast damage.
        default:
            spellweaver_type            = "stun";
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER : spellweaverBuff_Power
            spellweaver_buffSprite      = "DLSB_Spellweaver_DEFAULT";
            spellweaver_buffText        = "DLSB_Spellweaver_DEFAULT";
            break;
    }

    // Change displayed string if we have hexed blade.
    if(KinkyDungeonFlags.get("DLSB_HexedBlade")){
        spellweaver_buffText += "hex";
    }


    // Stuff all the necessary information into the buff directly.
    KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, {
        id:                         newBuff, 
        type:                       "DLSB_Spellweaver",
        power:                      spellweaverBuff_Power,
        duration:                   forceDur ? forceDur : DLSB_SPELLWEAVER_BUFFDUR, 
        aura:                       spellweaver_color, 
        buffSprite:                 true,
        buffSpriteSpecific:         spellweaver_buffSprite,
        desc:                       spellweaver_buffText,
        // Custom buff additions to store properties of the attack. These persist through save/load.
        DLSB_Spellweaver_SpellTag:  spellTag,
        DLSB_Spellweaver_Type:      spellweaver_type,
        DLSB_Spellweaver_Crit:      spellweaver_crit,
        DLSB_Spellweaver_Bind:      spellweaver_bind,
        DLSB_Spellweaver_Distract:  spellweaver_distract,
        DLSB_Spellweaver_BindType:  spellweaver_bindType,
        DLSB_Spellweaver_AddBind:   spellweaver_addBind,
        DLSB_Spellweaver_BindEff:   spellweaver_bindEff,

        // Handle spawning effect tiles.
        DLSB_Spellweaver_Tile_Kind:     spellweaver_tileKind,
        DLSB_Spellweaver_Tile_AoE:      spellweaver_tileAoE,
        DLSB_Spellweaver_Tile_Dur:      spellweaver_tileDur,

        DLSB_Spellweaver_Time:      spellweaver_buffTime,

        events: [
            {type: "DLSB_Spellweaver", trigger: "tick"},
            {type: "DLSB_Spellweaver", trigger: "expireBuff"},
            // TODO - Could I put buffs here?  Didn't seem to work.
        ]
    });

    // If the player has the spell, reequip their old weapon.
    if (KDHasSpell("DLSB_Mageblade") && KinkyDungeonPlayerWeapon != KDGameData.PlayerWeaponLastEquipped && KinkyDungeonInventoryGet(KDGameData.PlayerWeaponLastEquipped)) {
        KDSetWeapon(KDGameData.PlayerWeaponLastEquipped);
    }
    // Maybe reequip offhand if able?
}

/*****************************************************
 * playerAttack Spellweaver Event 
 * 
 * Consume the buff IF it triggers on playerAttack.
 * > Typically a damage rider-type effect.
 * > Some future buffs (Crit) might trigger on beforeCrit or duringCrit.
 *********************************************************/
KDEventMapSpell.playerAttack["DLSB_Spellweaver"] = (e, spell, data) => {
    if ((!data.bullet || e.bullet)
        //&& KinkyDungeonHasMana(e.cost != undefined ? e.cost : KinkyDungeonGetManaCost(spell, false, true))
        && !data.miss && !data.disarm && data.targetX && data.targetY && data.enemy && KDHostile(data.enemy)
        // Require the use of a weapon, OR Brawler perk.
        && ((KinkyDungeonPlayerDamage.name && KinkyDungeonPlayerDamage.name != "Unarmed") || KinkyDungeonStatsChoice.get("Brawler"))
    ){
        // Check that we are using a melee weapon
        if (KDCheckPrereq(null, e.prereq, e, data)) {
            // Do we have a buff?
            if(KDGameData.DollLia.Spellblade.spellweaver[0]){
                // Handle special case events before attack.
                switch(KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]].DLSB_Spellweaver_SpellTag){
                    case "ice":
                        // Hexed Blade - Ice:  Freeze the target if slowed/drenched/bound.
                        // TODO - Should this apply on bound? Uncertain.
                        if(KinkyDungeonFlags.get("DLSB_HexedBlade") && data.enemy
                            && (KinkyDungeonIsSlowed(data.enemy) || data.enemy.bind > 0 || (data.enemy.buffs && data.enemy.buffs.Drenched))
                        ){
                            // Damage the enemy as if using an ElementalEffect event.
                            KinkyDungeonDamageEnemy(data.enemy, {
                                type: "ice",
                                damage: 0,
                                time: 6,
                                // bind: 0,
                                // distract: null,
                                // addBind: false,
                                // bindType: null,
                            }, false, e.power < 0.5, undefined, undefined, KinkyDungeonPlayerEntity);
                        }
                        break; 
                    case "earth":
                        // If we have Stoneskin, extend it. Else, grant short-lived.
                        if(KinkyDungeonFlags.get("DLSB_HexedBlade")){
                            // Extend if active
                            if(KinkyDungeonPlayerBuffs?.StoneSkin){
                                KinkyDungeonPlayerBuffs.StoneSkin.duration += 4;
                            }
                            // Grant if not.
                            else{
                                KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity,{id: "StoneSkin", aura: "#FF6A00", type: "Armor", duration: 4, power: 2.0, player: true, enemies: true, tags: ["defense", "armor"]});
                            }
                        }
                        break;
                    case "air":
                        if(KinkyDungeonFlags.get("DLSB_HexedBlade")){
                            let air_e = {power: 0.8, dist: 1.0}
                            // Just call the Knockback function. Kinda weird solution, but it works!
                            KDEventMapWeapon.playerAttack["Knockback"](air_e, null, data)
                        }
                        break;
                    case "light":
                        if(KinkyDungeonFlags.get("DLSB_HexedBlade")){
                            // Stun the enemy if already blind
                            if(data.enemy.blind){
                                // Damage the enemy as if using an ElementalEffect event.
                                KinkyDungeonDamageEnemy(data.enemy, {
                                    type: "stun",
                                    damage: 0,
                                    time: 2,
                                    // bind: 0,
                                    // distract: null,
                                    // addBind: false,
                                    // bindType: null,
                                }, false, e.power < 0.5, undefined, undefined, KinkyDungeonPlayerEntity);
                            }
                            KDBlindEnemy(data.enemy, 5);
                        }
                        break;
                    case "shadow":
                        // Multiply damage in darkness.
                        if(KinkyDungeonFlags.get("DLSB_HexedBlade") && (KinkyDungeonBrightnessGet(KinkyDungeonPlayerEntity.x, KinkyDungeonPlayerEntity.y) <= 1.5 || KinkyDungeonBrightnessGet(data.enemy.x, data.enemy.y) <= 1.5)){
                            KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]].power *= 1.5;
                            KinkyDungeonPlaySound(KinkyDungeonRootDirectory + "Audio/" + "Fwoosh" + ".ogg", undefined, undefined);
                        }
                        break;
                    case "knowledge":
                        break;
                    case "stealth":
                        // Just ripping this from Illusion Shrine because I'm drawing a blank.
                        if(KinkyDungeonFlags.get("DLSB_HexedBlade")){
                            KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, {
                                id: "ShadowStep",
                                type: "SlowDetection",
                                duration: 6 * 2,
                                power: 0.667,
                                player: true,
                                enemies: true,
                                endSleep: true,
                                currentCount: -1,
                                maxCount: 1,
                                tags: ["SlowDetection", "hit", "cast"],
                            });
                            KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, {
                                id: "ShadowStep2",
                                type: "Sneak",
                                duration: 6,
                                power: Math.min(20, 6 * 2),
                                player: true,
                                enemies: true,
                                endSleep: true,
                                currentCount: -1,
                                maxCount: 1,
                                tags: ["Sneak", "hit", "cast"],
                            });
                        }
                        break;
                    case "physics":
                        // Give a stack of quickness.
                        if(KinkyDungeonFlags.get("DLSB_HexedBlade")){
                            KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, {
                                id: "DLSB_HexedBlade_Quickness",
                                type: "Quickness",
                                duration: 1,
                                power: 1,
                                endSleep: true,
                                currentCount: -1,
                                maxCount: 3,
                                tags: ["quickness", "move", "attack", "cast"],
                            });
                        }
                        break;
                    case "summon":
                        // Summon a temporary friend with a cool hat.
                        if(KinkyDungeonFlags.get("DLSB_HexedBlade")){
                            let point = KinkyDungeonGetNearbyPoint(data.enemy.x, data.enemy.y, true, undefined, true);
                            if (point) {
                                let Enemy = KinkyDungeonGetEnemyByName("DLSB_HexedAlly");
                                KDAddEntity({
                                    summoned: true,
                                    rage: Enemy.summonRage ? 9999 : undefined,
                                    Enemy: Enemy,
                                    id: KinkyDungeonGetEnemyID(),
                                    x: point.x,
                                    y: point.y,
                                    hp: (Enemy.startinghp) ? Enemy.startinghp : Enemy.maxhp,
                                    movePoints: 0,
                                    attackPoints: 0,
                                    lifetime: 15,
                                    maxlifetime: 15,
                                });
                            }
                        }
                        break;
                }

                //console.log(data.enemy)

                // Obtain all important stats from the buff itself.
                KinkyDungeonDamageEnemy(data.enemy, {
                    type:       KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]].DLSB_Spellweaver_Type,     //spellweaverType,
                    damage:     KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.power,//spellweaverPower,
                    time:       KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_Time,
                    chance:     1,
                    crit:       KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_Crit,
                    bind:       KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_Bind,
                    distract:   KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_Distract,
                    bindType:   KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_BindType,
                    addBind:    KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_AddBind,
                    bindEff:    KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_BindEff,
                }, false, e.power < 0.5, {name:"DLSB_Spellweaver"}, undefined, KinkyDungeonPlayerEntity);

                // Spawn Effect Tiles if there is a tile to spawn.
                if(KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_Tile_Kind){
                    KDCreateAoEEffectTiles(data.targetX, data.targetY, {
                        name:       KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]].DLSB_Spellweaver_Tile_Kind,
                        duration:   KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]].DLSB_Spellweaver_Tile_Dur,
                    }, e.variance, KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]].DLSB_Spellweaver_Tile_AoE);
                }

                // Consume the buff.
                KinkyDungeonExpireBuff(KinkyDungeonPlayerEntity, KDGameData.DollLia.Spellblade.spellweaver[0])
                KDGameData.DollLia.Spellblade.spellweaver.shift();

                // Arcane Synergy
                if(KDHasSpell("DLSB_ArcaneSynergy")){
                    // If we have the buff, tick it up by 1.
                    if(KDEntityHasBuff(KinkyDungeonPlayerEntity,"DLSB_ArcaneSynergy") && KinkyDungeonFlags.get("DLSB_SpellweaverQueue")){
                        KinkyDungeonPlayerBuffs.DLSB_ArcaneSynergy.DLSB_AS_Stacks = 2;
                        KinkyDungeonPlayerBuffs.DLSB_ArcaneSynergy.text = "x2";
                    // If we don't have the buff, grant it.
                    }else if (!KDEntityHasBuff(KinkyDungeonPlayerEntity,"DLSB_ArcaneSynergy")){
                        KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, {
                            id:                         "DLSB_ArcaneSynergy", 
                            type:                       "DLSB_ArcaneSynergy",
                            power:                      0.75,
                            duration:                   9999,
                            infinite:                   true, 
                            aura:                       KDBaseLightBlue, 
                            buffSprite:                 true,
                            // Only add stacks if we need them.
                            DLSB_AS_Stacks:             1,
                        });
                    }
                }
            }
        }
    }
}

//#region Fleche & Displacement
//////////////////////////////////////////////
//      Spellblade - Movement Spells        // 
//////////////////////////////////////////////

let DLSB_Spellblade_Fleche = {name: "DLSB_Fleche", tags: ["stamina", "utility", "offense"], school: "Special", prerequisite: "DLSB_Spellweaver", classSpecific: "DLSB_Spellblade", hideWithout: "DLSB_Spellweaver", manacost: 0, customCost: "SprintPlusAttack", components: [], level:1,
    type:"special", special: "DLSB_Fleche", noMiscast: true,
    onhit:"", time:25, power: 0, 
    //minRange: 1.99, 
    castCondition: "DLSB_Fleche",
    range: 3.99, size: 1, damage: ""
}

let DLSB_Spellblade_Displacement = {name: "DLSB_Displacement", tags: ["stamina", "utility", "offense"], school: "Special", prerequisite: "DLSB_Fleche", classSpecific: "DLSB_Spellblade", hideWithout: "DLSB_Spellweaver", manacost: 0, customCost: "DLSB_DoubleSprintPlusAttack", components: [], level:1,
    type:"special", special: "DLSB_Displacement", noMiscast: true,
    onhit:"", time:25, power: 0, range: 1.5, size: 1, damage: ""
}

KDCustomCost["DLSB_DoubleSprintPlusAttack"] = (data) => {
    data.cost = Math.round(10 * -(KDAttackCost().attackCost + 2*KDSprintCost())) + "SP";
    data.color = KDBaseMint;
}

// CastCond
KDPlayerCastConditions["DLSB_Fleche"] = (player, x, y) => {
    return (
        // If you have FF, return 1
        //(KDHasSpell("DLSB_FancyFootwork"))
        // Or distance > 1
        KinkyDungeonFlags.get("DLSB_FancyFootwork") || (KDistChebyshev(x - player.x, y - player.y) > 1.5)
    )
}

// SpellSpecial for Fleche
KinkyDungeonSpellSpecials["DLSB_Fleche"] = (spell, _data, targetX, targetY, _tX, _tY, entity, _enemy, _moveDirection, _bullet, _miscast, _faction, _cast, _selfCast) => {
    if(KinkyDungeonPlayerDamage?.name && (KinkyDungeonPlayerDamage.name == "Unarmed")){
        KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoWeapon"), KDBaseRed, 1, true);
        return "Fail";
    }
    let cost = KDAttackCost().attackCost + KDSprintCost();
    let en = KinkyDungeonEntityAt(targetX, targetY);
    let space = false;
    let dash_x = targetX;
    let dash_y = targetY;
    //console.log(en)
    if (en?.Enemy) {
        if (KinkyDungeonHasStamina(-cost)) {
            let dist = KDistChebyshev(en.x - entity.x, en.y - entity.y);
            // If we are adjacent, we Fleche through.
            if (dist < 1.5) {
                // Find our relation to the target.  This is the reverse of Displacement.
                let delta_x = en.x - entity.x
                let delta_y = en.y - entity.y

                // Check full backflip dist AND clear line to it.
                if(KinkyDungeonNoEnemy(entity.x + 2 * delta_x, entity.y + 2 * delta_y) && KDIsMovable(entity.x + 2 * delta_x, entity.y + 2 * delta_y)){
                    dash_x = entity.x + 2 * delta_x;
                    dash_y = entity.y + 2 * delta_y;
                    // Check clear line
                    if (KinkyDungeonCheckPath(entity.x, entity.y, dash_x, dash_y, false, false)) {
                        space = true;
                    }
                }
            // Not adjacent, we dash to.
            } else {
                // Average out the distance between self and enemy. Dash to it.
                dash_x = Math.round((en.x + entity.x) / 2);
                dash_y = Math.round((en.y + entity.y) / 2);
                //console.log("Dash Coords" + " " + dash_x + " " + dash_y)

                // If we are still not adjacent, average out the distance again.
                if(KDistChebyshev(en.x - dash_x, en.y - dash_y) > 1.5){
                    //console.log("Too far!")
                    dash_x = Math.round((en.x + dash_x) / 2);
                    dash_y = Math.round((en.y + dash_y) / 2);
                    //console.log("Dash Coords" + " " + dash_x + " " + dash_y)
                }

                // If the space is open, check if we can move to it.
                if (KinkyDungeonNoEnemy(dash_x, dash_y) && KDIsMovable(dash_x, dash_y)) {
                    space = true;
                }
            }
            if (space) {
                if (_miscast) return "Miscast";
                let result = KinkyDungeonLaunchAttack(en, 1);
                if (result == "confirm" || result == "dialogue") return "Fail";
                if (result == "hit" || result == "capture") {
                    KinkyDungeonTrapMoved = true;  // Suffer
                    if (KinkyDungeonNoEnemy(dash_x, dash_y) && KDIsMovable(dash_x, dash_y)) {
                        KDMovePlayer(dash_x, dash_y, true, true);
                    }
                    KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheSuccess"), "#e7cf1a", 1, false);
                    KDChangeStamina(spell.name, "spell", "cast", KDSprintCost());
                } else if (result == "miss") {
                    KinkyDungeonTrapMoved = true;  // Suffer
                    if (KinkyDungeonNoEnemy(dash_x, dash_y) && KDIsMovable(dash_x, dash_y)) {
                        KDMovePlayer(dash_x, dash_y, true, true);
                    }
                    KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_AttackMiss"), KDBaseRed, 1, true);
                }
                KinkyDungeonPlaySound(KinkyDungeonRootDirectory + "Audio/Miss.ogg");
                return "Cast";
            } else {
                KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoSpace"), KDBaseRed, 1, true);
            }
        } else {
            KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoStamina"), KDBaseRed, 1, true);
        }
    } else {
        KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoTarget"), KDBaseRed, 1, true);
    }
    return "Fail";
}

// SpellSpecial for Displacement
// Make a weapon attack at a target, then move up to two spaces away.
KinkyDungeonSpellSpecials["DLSB_Displacement"] = (spell, _data, targetX, targetY, _tX, _tY, entity, _enemy, _moveDirection, _bullet, _miscast, _faction, _cast, _selfCast) => {
    if(KinkyDungeonPlayerDamage?.name && (KinkyDungeonPlayerDamage.name == "Unarmed")){
        KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoWeapon"), KDBaseRed, 1, true);
        return "Fail";
    }
    let cost = KDAttackCost().attackCost + 2*KDSprintCost();
    let en = KinkyDungeonEntityAt(targetX, targetY);
    let space = false;
    if (en?.Enemy) {
        // console.log("DISPLACE:")
        // console.log(en)
        // Test for if we need to apply vulnerable
        let applyVuln = false;
        if(KinkyDungeonFlags.get("DLSB_FancyFootwork") && (en.attackPoints > 0 || en.warningTiles?.length > 0)){
            applyVuln = true;
        }
        if (KinkyDungeonHasStamina(-cost)) {

            // Find our relation to the target.  When backflipping, we basically multiply it by 3 or 2.
            let delta_x = entity.x - en.x
            let delta_y = entity.y - en.y
            let backflip_x = null
            let backflip_y = null

            // Check full backflip dist AND clear line to it.
            if(KinkyDungeonNoEnemy(entity.x + 2 * delta_x, entity.y + 2 * delta_y) && KDIsMovable(entity.x + 2 * delta_x, entity.y + 2 * delta_y)){
                backflip_x = entity.x + 2 * delta_x;
                backflip_y = entity.y + 2 * delta_y;
                // Check clear line
                if (KinkyDungeonCheckPath(entity.x, entity.y, backflip_x, backflip_y, false, false)) {
                    space = true;
                }
            }

            // Check half backflip dist if the above fails.
            if(!space && KinkyDungeonNoEnemy(entity.x + delta_x, entity.y + delta_y) && KDIsMovable(entity.x + delta_x, entity.y + delta_y)){
                backflip_x = entity.x + delta_x;
                backflip_y = entity.y + delta_y;
                space = true;
            }

            // Display error if neither is movable, and do nothing.
            if(!space){
                KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_DisplacementFail_Backflip"), KDBaseRed, 1, true);
                return "Fail";
            }

            if (space) {
                if (_miscast) return "Miscast";
                let result = KinkyDungeonLaunchAttack(en, 1);
                if (result == "confirm" || result == "dialogue") return "Fail";
                if (result == "hit" || result == "capture") {
                    // Make the target Vulnerable IF upgrade AND the enemy was attacking
                    if(applyVuln){
                        //console.log(_data)
                        en.vulnerable = Math.max(2, en.vulnerable||0);
                    }
                    KinkyDungeonTrapMoved = true;  // Backflipping into dangerous mechanics is the RDM way~
                    KDMovePlayer(backflip_x, backflip_y, true, true);
                    KinkyDungeonRemoveBuffsWithTag(en, ["displaceend"]);
                    KinkyDungeonRemoveBuffsWithTag(KDPlayer(), ["displaceend"]);
                    KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_DisplacementSuccess"), "#e7cf1a", 1, false);
                    KDChangeStamina(spell.name, "spell", "cast", 2*KDSprintCost());


                } else if (result == "miss") {
                    KinkyDungeonTrapMoved = true;  // Backflipping into dangerous mechanics is the RDM way~
                    KDMovePlayer(backflip_x, backflip_y, true, true);
                    KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_AttackMiss"), KDBaseRed, 1, true);
                }
                KinkyDungeonPlaySound(KinkyDungeonRootDirectory + "Audio/Miss.ogg");
                return "Cast";
            } else {
                KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoSpace"), KDBaseRed, 1, true);
            }
        } else {
            KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoStamina"), KDBaseRed, 1, true);
        }
    } else {
        KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoTarget"), KDBaseRed, 1, true);
    }
    return "Fail";
}

//#region Blade Twirl
let DLSB_BladeTwirl = {name: "DLSB_BladeTwirl", tags: ["stamina", "defense"], prerequisite: "DLSB_Spellweaver", classSpecific: "DLSB_Spellblade", hideWithout: "DLSB_Spellweaver", school: "Special",
    staminacost: 7.5, manacost: 1, components: [], defaultOff: true, level:1, type:"passive", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    // Learn a helper passive to handle passives.
    autoLearn: ["DLSB_BladeTwirl_Invis"],
    events: [
        {type: "DLSB_BladeTwirl", trigger: "toggleSpell", time: 1},
    ],
    // Custom cost to match Fleche/Displacement.
    customCost: "DLSB_BladeTwirl",
    castCondition: "DLSB_BladeTwirl",
}

// Invisible passive that handles tracking BladeTwirl events.
let DLSB_BladeTwirl_Invis = {
    name: "DLSB_BladeTwirl_Invis", manacost: 0, components: [], level:1, passive: true, type:"", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    hideLearned: true, hideWithout: "DLSB_Mageblade",
    events: [
        {type: "DLSB_BladeTwirl_Invis", trigger: "beforeAttackCalculation"},
        {type: "DLSB_BladeTwirl_Invis", trigger: "blockPlayerSpell"},
    ]
}

KDCustomCost["DLSB_BladeTwirl"] = (data) => {
    //console.log(data)
    data.cost = Math.round(10 * data.spell.manacost) + "MP+" + Math.round(10 * data.spell.staminacost) + "SP";
    data.color = "#d0dcff"//KDBaseWhite;//KDBaseMint;
}

// CastCond
KDPlayerCastConditions["DLSB_BladeTwirl"] = (player, x, y) => {
    return (
        // Need a weapon equipped.  Fists do NOT count, even with brawler.
        (KinkyDungeonPlayerDamage.name && KinkyDungeonPlayerDamage.name != "Unarmed")
    )
}


// Twirl Spell Action
KDAddEvent(KDEventMapSpell, "toggleSpell", "DLSB_BladeTwirl", (e, spell, data) => {
    if (data.spell?.name == spell?.name) {
        KinkyDungeonSpellChoicesToggle[data.index] = false;
        // Check that the player has a weapon equipped.
        if(KinkyDungeonPlayerDamage?.name && (KinkyDungeonPlayerDamage.name != "Unarmed")){
            if(KinkyDungeonStatMana >= KinkyDungeonGetManaCost(spell, false, false)){
                if (KinkyDungeonStatStamina >= KinkyDungeonGetStaminaCost(spell, false, false)) {
                    // Should never happen unless I give this a duration.
                    if (KinkyDungeonPlayerBuffs.DLSB_BladeTwirl) {
                        KinkyDungeonExpireBuff(KinkyDungeonPlayerEntity, "DLSB_BladeTwirl");
                    }
                    KinkyDungeonPlaySound(KinkyDungeonRootDirectory + "Audio/DLSB_Twirl.ogg", undefined, 0.3);
                    // Buff that will never be seen by the player, as it lasts no time.
                    KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, {
                        id: "DLSB_BladeTwirl",
                        type: "Block",
                        aura: "#ffaa44",
                        //buffSprite: true,
                        power: 9999,                // Arbitrarily large block.  Power is multiplied by 100.
                        duration: e.time,
                        //tags: ["attack"],
                    });
                    KDChangeMana(spell.name, "spell", "cast", -KinkyDungeonGetManaCost(spell, false, false));
                    KDChangeStamina(spell.name, "spell", "cast", -KinkyDungeonGetStaminaCost(spell, false, false));
                    KinkyDungeonSendTextMessage(5, TextGet("DLSB_BladeTwirlSuccess"), KDBaseOrange, 10);
                    KDTriggerSpell(spell, data, false, false);
                    KinkyDungeonAdvanceTime(1);
                } else {
                    KinkyDungeonSendTextMessage(5, TextGet("DLSB_BladeTwirlFail_NoStamina"), KDBaseOrange, 10);
                }
            }else{
                KinkyDungeonSendTextMessage(5, TextGet("DLSB_BladeTwirlFail_NoMana"), KDBaseOrange, 10);
            }
        }else{
            KinkyDungeonSendTextMessage(5, TextGet("DLSB_BladeTwirlFail_NoWeapon"), KDBaseOrange, 10);
        }
    }
});

/************************************************************************
 * Event to handle an oddity with events.
 * 
 * When enemy spells strike the player, they call KDTestSpellHits.
 * However, KDTestSpellHits does not have any events to call, it simply
 *  calculates if the attack hits, misses, or is blocked.
 * There is no event to, for example, let me raise block if the incoming hit
 *  is a projectile.
 * INSTEAD, Blade Twirl gives 9999 block, but this event removes ALL BLOCK 
 *  FROM THE PLAYER if they are attacked in melee whilst twirling their blade.
 ************************************************************************/
KDAddEvent(KDEventMapSpell, "beforeAttackCalculation", "DLSB_BladeTwirl_Invis", (e, spell, data) => {
    if (data.target?.player && data.attacker) {
        let player = KinkyDungeonPlayerEntity;
        let buff = KDEntityGetBuff(player, "DLSB_BladeTwirl");
        if(buff){
            // Set playerBlock to a very high number, so you can never block.
            data.playerBlock = 2;
        }
    }
});


// Event to handle blocking a spell successfully.
KDAddEvent(KDEventMapSpell, "blockPlayerSpell", "DLSB_BladeTwirl_Invis", (e, spell, data) => {
    console.log("Spell blocked!")
    console.log(data)
    if(data?.player && data?.spell){
        // Default if we somehow cannot assign anything.
        let spellTag = "DEFAULT"

        // TODO - How many possible spells can we get hit by?  Oh no.
        switch(data.spell.damage){
            case "fire":
                spellTag = "fire";
                break;
            case "frost":
                spellTag = "ice";
                break;
            case "ice":
                spellTag = "ice";
                break;
            case "electric":
                spellTag = "electric";
                break;
            case "soap":
                spellTag = "water";
                break;
            // Unsure on this one.
            case "blast":
                spellTag = "air";
                break;
            case "pain":
                // TODO - Enemy Specific
                if(data.spell.name == "NurseSyringe"){
                    spellTag = "leather";
                }
                // TODO - Enemy Specific
                // NOTE - Not really a spell, should it count?
                else if(data.spell.name == "Hairpin"){
                    spellTag = "DEFAULT";

                }else{
                    spellTag = "leather";
                    break;
                }
                break;
            case "chain":
                //TODO - Special Cases
                switch(data.spell.name){
                    case "NurseBola":
                        spellTag = "leather";
                        break;
                    case "ZombieOrb":
                        spellTag = "rope";
                        break;
                    case "ElfArrow":
                        spellTag = "rope";
                        break;
                }
                // If any special cases hit, break
                if(spellTag != "DEFAULT"){break;}
                // Bind Type?
                if(data.spell?.bindType){
                    switch(data.spell?.bindType){
                        case "Leather":
                            //TODO - Magical Belt
                            if(data.spell.name == "MagicBelt"){
                                spellTag = "leather";
                                break;
                            }else{
                                spellTag = "leather";
                                break;
                            }
                        case "Rope":
                            spellTag = "rope";
                            break;
                        case "Metal":
                            // TODO - Cables?
                            if(data.spell.name == "RestrainingDevice"){
                                spellTag = "metal";
                                break;
                            }else{
                            spellTag = "metal";
                            break;
                            }
                        // TODO - Enemy-Specific
                        case "MagicRope":
                            spellTag = "rope";
                            break;
                        case "Tape":
                            spellTag = "rope";
                            break;
                        case "Vine":
                            spellTag = "rope";
                            break;
                        case "Energy":
                            spellTag = "metal";
                            break;
                        case "Magic":
                            spellTag = "rope";
                            break;
                    }
                }else{
                    //????????????????????????
                    console.log("WEIRD SPELL ALERT - PLEASE REPORT TO DOLL.LIA")
                    spellTag = "leather";       // assume Leather I guess.
                    break;
                }
                break;
            case "glue":
                // TODO - Capture Foam Spellweaver
                if(data.spell.name == "RubberBullets"){
                    spellTag = "latex"
                    break;
                }
                if(data.spell?.bindType){
                    switch(data.spell?.bindType){
                        case "Latex":
                            // TODO - SPECIAL SPELL TAG HERE
                            spellTag = "latex";
                            break;
                        case "Slime":
                            spellTag = "latex";
                            break;
                    }
                }else{
                    //????????????????????????
                    console.log("WEIRD SPELL ALERT - PLEASE REPORT TO DOLL.LIA")
                    spellTag = "latex";       // assume Slime I guess.
                    break;
                }
                break;
            case "holy":
                // TODO - Celestial Rope
                if(data.spell.name == "EnemyCoronaBeam"){
                    spellTag = "light";
                    break;
                }else{
                    spellTag = "light";
                    break;
                }
                break;
            // TODO - Shadow Hand Bolt
            case "cold":
                spellTag = "shadow";
                break;
            // Soul damage is EXTREMELY rare, and basically always special cases.
            // TODO - Crystal Dragon Girl
            // TODO - Mummy Bolt
            case "soul":
                spellTag = "DEFAULT";
                break;
            // If somehow NOTHING matches, uh.  Yeah.
            default:
                //????????????????????????
                console.log("WEIRD SPELL ALERT - PLEASE REPORT TO DOLL.LIA")
                console.log("Offending Spell:")
                console.log(data.spell)
                spellTag = "DEFAULT";
        }

        // Apply the buff
        DLSB_Spellweaver_BuffType(null, spellTag)

        // If the player has the spell, reequip their old weapon.
        if (KDHasSpell("DLSB_Mageblade") && KinkyDungeonPlayerWeapon != KDGameData.PlayerWeaponLastEquipped && KinkyDungeonInventoryGet(KDGameData.PlayerWeaponLastEquipped)) {
            KDSetWeapon(KDGameData.PlayerWeaponLastEquipped);
        }
    }
});



//#region Preparation
/***********************************************
 * Spell - Preparation
 * 
 * Generate two random Spellweaver charges.
 ***********************************************/
let DLSB_Preparation = {name: "DLSB_Preparation", tags: ["utility", "defense"], prerequisite: "DLSB_Spellweaver", classSpecific: "DLSB_Spellblade", hideWithout: "DLSB_Spellweaver", school: "Special",
    staminacost: 0, manacost: 1, components: [], defaultOff: true, level:1, type:"passive", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    events: [
        {type: "DLSB_Preparation", trigger: "toggleSpell", time: 100},
    ],
    // Custom cost
    customCost: "DLSB_Preparation",
}

KDCustomCost["DLSB_Preparation"] = (data) => {
    // Display cooldown.
    if (KinkyDungeonFlags.get("DLSB_Prepared")) {
        data.cost = Math.round(KinkyDungeonFlags.get("DLSB_Prepared")) + " Turns";
        data.color = KDBaseWhite;
    // Display mana cost.
    }else{
        data.cost = Math.round(10 * data.spell.manacost) + "MP";
        data.color = "#d0dcff"//KDBaseWhite;//KDBaseMint;
    }
}

// Twirl Spell Action
KDAddEvent(KDEventMapSpell, "toggleSpell", "DLSB_Preparation", (e, spell, data) => {
    if (data.spell?.name == spell?.name) {
        KinkyDungeonSpellChoicesToggle[data.index] = false;
        if (!KinkyDungeonFlags.get("DLSB_Prepared")) {
            if (KinkyDungeonStatMana > KinkyDungeonGetManaCost(spell)) {
                // Trigger cooldown
                KinkyDungeonSetFlag("DLSB_Prepared", e.time);
                // How many charges can we generate?
                let totalCharges = (KinkyDungeonFlags.get("DLSB_SpellweaverQueue") ? 2 : 1)

                // Generate that many random charges
                for(let itr = 0; itr < totalCharges; itr++){
                    DLSB_Spellweaver_BuffType(null, "random", DLSB_SPELLWEAVER_BUFFDUR + itr)
                }

                // Spend the Mana.
                KDChangeMana(spell.name, "spell", "cast", -KinkyDungeonGetManaCost(spell, false, false));

                // Display success message
                KinkyDungeonSendTextMessage(5, TextGet("DLSB_PreparedSuccess"), "#e7cf1a", 10);
            }else{
                KinkyDungeonSendTextMessage(5, TextGet("DLSB_PreparationFail_ManaCost"), KDBaseOrange, 10);
            }
        }else{
            KinkyDungeonSendTextMessage(5, TextGet("DLSB_PreparationFail_Prepared"), KDBaseOrange, 10);
        }
    }
});



//#region Spell List
// Add class spells to spell list.
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_CorePassive);
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_OffHand);
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_Fleche);
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_Displacement);
KinkyDungeonSpellList["Special"].push(DLSB_BladeTwirl);
KinkyDungeonSpellList["Special"].push(DLSB_BladeTwirl_Invis);
KinkyDungeonSpellList["Special"].push(DLSB_Preparation);
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_Sustain);
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_FF);
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_Mageblade);
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_Mageblade_Invis);
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_HexedBlade);
KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_SpellweaverQueue);

// KinkyDungeonLearnableSpells[2][0].splice((KinkyDungeonLearnableSpells[2][0].indexOf("LeashSkill")+1),0,"DLSB_Spellweaver");
// KinkyDungeonLearnableSpells[2][0].splice((KinkyDungeonLearnableSpells[2][0].indexOf("DLSB_Spellweaver")+1),0,"DLSB_SpellbladeOffhand");
// Col 0 - Core
KinkyDungeonLearnableSpells[2][0].push("DLSB_Spellweaver");
KinkyDungeonLearnableSpells[2][0].push("DLSB_SpellbladeOffhand");
// Col 1 - Active
KinkyDungeonLearnableSpells[2][1].push("DLSB_Fleche");
KinkyDungeonLearnableSpells[2][1].push("DLSB_Displacement");
KinkyDungeonLearnableSpells[2][1].push("DLSB_BladeTwirl");
KinkyDungeonLearnableSpells[2][1].push("DLSB_Preparation");
// Col 2 - Misc
KinkyDungeonLearnableSpells[2][2].push("DLSB_ArcaneSynergy");
KinkyDungeonLearnableSpells[2][2].push("DLSB_Mageblade");
// Col 3 - Upgrades
KinkyDungeonLearnableSpells[2][3].push("DLSB_FancyFootwork");
KinkyDungeonLearnableSpells[2][3].push("DLSB_HexedBlade");
KinkyDungeonLearnableSpells[2][3].push("DLSB_SpellweaverQueue");