'use strict';

//////////////////////////////////////////////////////
// DLSB - Doll.Lia's Spellblade Class               //
// Use DLSB_ as the prefix for any new content.     //
//////////////////////////////////////////////////////

// NOTE - If you are reading my code, I recommend an IDE such as VSCode that supports the #region tag.
// > This will help you navigate this file easier by using the preview bar on the right.

// NOTE TO SELF:
// Please remember to increment this when you update your own mod!
// -Doll.Lia
let DLSB_VER = 0.55

/**************************************************************
 * DLSB - Mod Configuration Menu
 * 
 * Access these properties with KDModSettings["DLSBMCM"]["NAME"]
 *  > Return can be a boolean, range, etc. depending upon the type.
 * 
 * Names are handled in CSV with the prefix KDModButton
 **************************************************************/           

// By concatenating TextKeys, we can create TextKeys with line breaks in them.
// Necessary to format the MCM like I want to.

//region MCM
if (KDEventMapGeneric['afterModSettingsLoad'] != undefined) {
    KDEventMapGeneric['afterModSettingsLoad']["DLSBMCM"] = (e, data) => {

        addTextKey("KDModButtonDLSBMCM_Prep_ChaosChanceDesc", TextGet("KDModButtonDLSBMCM_Prep_ChaosChanceDescRow1") + "\n" + TextGet("KDModButtonDLSBMCM_Prep_ChaosChanceDescRow2"))
        addTextKey("KDModButtonDLSBMCM_Prep_ChaosChance", TextGet("KDModButtonDLSBMCM_Prep_ChaosChanceRow1") + "\n" + TextGet("KDModButtonDLSBMCM_Prep_ChaosChanceRow2"))
        addTextKey("KDModButtonDLSBMCM_ModCompatHeader", TextGet("KDModButtonDLSBMCM_ModCompatHeaderRow1"))
        addTextKey("KDModButtonDLSBMCM_TestSpellHitsDesc", TextGet("KDModButtonDLSBMCM_TestSpellHitsDescRow1") + "\n" + TextGet("KDModButtonDLSBMCM_TestSpellHitsDescRow2")  + "\n" + TextGet("KDModButtonDLSBMCM_TestSpellHitsDescRow3"))
        addTextKey("KDModButtonDLSBMCM_TestSpellHits", TextGet("KDModButtonDLSBMCM_TestSpellHitsRow1") + "\n" + TextGet("KDModButtonDLSBMCM_TestSpellHitsRow2"));

        
        // Sanity check to make sure KDModSettings is NOT null. 
        if (KDModSettings == null) { 
            KDModSettings = {} 
            console.log("KDModSettings was null!")
        };
        if (KDModConfigs != undefined) {
            KDModConfigs["DLSBMCM"] = [
                // Page 1 Col 1

                // How chaotic will Preparation be?
                // Access value with:  KDModSettings["DLSBMCM"]["DLSBMCM_Prep_ChaosChance"]
                {refvar: "DLSBMCM_Header_Spellblade", type: "text"},
                {
                    refvar: "DLSBMCM_Prep_ChaosChance",
                    type: "range",
                    rangelow: 0,
                    rangehigh: 100,
                    stepcount: 5,
                    default: 35,
                    block: undefined
                },
                {refvar: "DLSBMCM_Spacer", type: "text"},
                {refvar: "DLSBMCM_ModCompatHeader", type: "text"},
                {refvar: "DLSBMCM_TestSpellHits",  type: "boolean", default: true, block: undefined},
                {refvar: "DLSBMCM_Spacer", type: "text"},
                {refvar: "DLSBMCM_Spacer", type: "text"},
                {refvar: "DLSBMCM_Spacer", type: "text"},

                // Page 1, Column 2
                {refvar: "DLSBMCM_Spacer", type: "text"},
                {refvar: "DLSBMCM_Prep_ChaosChanceDesc", type: "text"},
                {refvar: "DLSBMCM_Spacer", type: "text"},
                {refvar: "DLSBMCM_Spacer", type: "text"},
                {refvar: "DLSBMCM_TestSpellHitsDesc", type: "text"},
                {refvar: "DLSBMCM_Spacer", type: "text"},
                {refvar: "DLSBMCM_Spacer", type: "text"},
                {refvar: "DLSBMCM_Header_Meow", type: "text"},
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
let DLSB_KDTestSpellHits_Overridden = false;
let DLSB_KDTestSpellHits_Backup = null;
function DLSB_MCM_Config(){

    // Overwrite KDTestSpellHits
    if(KDModSettings["DLSBMCM"]["DLSBMCM_TestSpellHits"]){
        console.log("Blade Twirl++")
        // Back up the function if necessary.
        // Might be able to catch another mod's changes with this.
        if(!DLSB_KDTestSpellHits_Backup){
            DLSB_KDTestSpellHits_Backup = KDTestSpellHits;
        }
        // Overwrite Text Key
        //addTextKey("KinkyDungeonSpellDescriptionDLSB_BladeTwirl", TextGet("KinkyDungeonSpellDescriptionDLSB_BladeTwirl_Ideal"));
        if(!DLSB_KDTestSpellHits_Overridden){
            KDTestSpellHits = DLSB_BladeTwirl_KDTestSpellHits;      // Overwrite the function
            DLSB_KDTestSpellHits_Overridden = true;                 // Note that we did so.
        }
    }
    // Revert if overwritten.
    else if(!KDModSettings["DLSBMCM"]["DLSBMCM_TestSpellHits"]){
        console.log("Blade Twirl--")
        // Always update the Text Key
        //addTextKey("KinkyDungeonSpellDescriptionDLSB_BladeTwirl", TextGet("KinkyDungeonSpellDescriptionDLSB_BladeTwirl_Legacy"));
        // Update TestSpellHits
        if(DLSB_KDTestSpellHits_Overridden){
            KDTestSpellHits = DLSB_KDTestSpellHits_Backup;          // Restore the function.
            DLSB_KDTestSpellHits_Overridden = false;                // Note that we did so.
        }
    }

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
    }else{
        // Verify Mod Version
        if(KDGameData.DollLia.Spellblade.modVer < DLSB_VER){
            console.log("Updating Mod Version from " + String(KDGameData.DollLia.Spellblade.modVer) + " to " + String(DLSB_VER))

            ////////////////////////////////////////////////////////////
            // If updating to 0.54, refund the SP spent on Fleche, then remove Vault from the player.
            ////////////////////////////////////////////////////////////
            if(KDGameData.DollLia.Spellblade.modVer < 0.54){
                if(KDGameData.Class == "DLSB_Spellblade"){                     // If the player is a Spellblade
                    if(KDHasSpell("DLSB_Fleche")){
                        KinkyDungeonSpellPoints += 1;                           // Refund the spell point spent on Fleche.
                        KinkyDungeonSendTextMessage(10, "Refunded +1 SP spent on Flèche!", KDBaseCyan, 10);
                    // Give the player Fleche if they didn't have it.
                    }else{
                        KDPushSpell(KinkyDungeonFindSpell("DLSB_Fleche"));
                        KinkyDungeonSendTextMessage(10, "Learned Flèche!", KDBaseCyan, 10);
                    }
                    if(!KDHasSpell("Evasive1") && KDHasSpell("Vault")){         // If the player got Vault from Spellblade
                        KinkyDungeonSpellRemove("Vault")
                        KinkyDungeonSendTextMessage(10, "Removed Vault!", KDBaseCyan, 10);
                        KDRefreshSpellCache = true;
                    }
                }
            }

            // Hopefully not too many of these

            // Update the number.
            KinkyDungeonSendTextMessage(10, "Updated Spellblade from v" + String(KDGameData.DollLia.Spellblade.modVer) + " to v" + String(DLSB_VER) + "!", KDBaseCyan, 10);
            KDGameData.DollLia.Spellblade.modVer = DLSB_VER;
        // This should NEVER happen.
        }else if(KDGameData.DollLia.Spellblade.modVer > DLSB_VER){
            console.log("ERROR: Game save is from a later version of DollLiaSpellblade, please update!");
            KinkyDungeonSendTextMessage(10, "ERROR: Game save is from a later version of Spellblade, please update the mod!", KDBaseRed, 10);
        }

        // Verify spellweaver queue is clean.  Blank it if we find a buff that the player does not have.
        for(let itr = 0; itr < KDGameData.DollLia.Spellblade.spellweaver.length; itr++){
            if(!KDEntityGetBuff(KinkyDungeonPlayerEntity, KDGameData.DollLia.Spellblade.spellweaver[itr])){
                KDGameData.DollLia.Spellblade.spellweaver = [];
                console.log("Missing Queue Buff Detected - Reset Spellweaver Queue!")
                break;
            }
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
    KDPushSpell(KinkyDungeonFindSpell("DLSB_Fleche"));
    KinkyDungeonSpellChoices.push(KinkyDungeonSpells.length - 1);

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


//#region Blademistress
// Does nothing but set a flag that other parts of the class will check.
let DLSB_Spellblade_Blademistress = {
    name: "DLSB_Blademistress", tags: ["utility", "offense"], school: "Special", manacost: 0, components: [],
    classSpecific: "DLSB_Spellblade", prerequisite: "DLSB_Displacement", hideWithout: "DLSB_Spellweaver",
    level:1, passive: true, type:"", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
    events: [],
    learnFlags: ["DLSB_Blademistress"],     // Set a flag when you learn this spell, probably more performant than checking if you have the spell.
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
    
KinkyDungeonEnemies.push({
    name: "DLSB_SpellweaverAlly", tags: KDMapInit(["ghost", "flying", "silenceimmune", "blindimmune", "player", "melee"]), keepLevel: true, allied: true, armor: 0, followRange: 1, AI: "hunt", evasion: 0.33, accuracy: 1.5,
    visionRadius: 20, playerBlindSight: 100, maxhp: 8, minLevel:0, weight:-1000, movePoints: 1, attackPoints: 1, attack: "MeleeWill", attackRange: 1, attackWidth: 3, power: 1, dmgType: "pierce", CountLimit: false,
    stamina: 4,
    maxblock: 0,
    maxdodge: 2,
    nonDirectional: true,
    terrainTags: {}, floors:KDMapInit([])
});

// Clone of Familiar, but doesn't count towards summons.
// Has a cool hat though!
KinkyDungeonEnemies.push({
    name: "DLSB_HexedAlly", tags: KDMapInit(["ghost", "flying", "silenceimmune", "blindimmune", "player", "melee"]), keepLevel: true, allied: true, armor: 0, followRange: 1, AI: "hunt", evasion: 0.33, accuracy: 1.5,
    visionRadius: 20, playerBlindSight: 100, maxhp: 12, minLevel:0, weight:-1000, movePoints: 1, attackPoints: 1, attack: "MeleeWill", attackRange: 1, attackWidth: 3, power: 1.5, dmgType: "pierce", CountLimit: false,
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


        // Event to handle Fleche. It can go here, it's FINE:tm:
        {type: "DLSB_Spellweaver", trigger: "beforePlayerAttack"},
    ]
}


// Event to make Thrusting Swords work with Fleche/Displacement.
KDAddEvent(KDEventMapSpell, "beforePlayerAttack", "DLSB_Spellweaver", (e, _weapon, data) => {
    //console.log(data)
    if(KinkyDungeonFlags.get("DLSB_PerformingFlecheDisplacement")){
        if (data.enemy && !data.miss && !data.disarm && !KDHelpless(data.enemy) && data.Damage && data.Damage.damage > 0) {
            if (data.enemy && (!e.requiredTag || data.enemy.Enemy.tags[e.requiredTag]) && (!e.chance || KDRandom() < e.chance) && data.enemy.hp > 0) {
                // Don't do anything if the enemy is already vulnerable.
                if (!data.enemy.vulnerable) {
                    // Take the event data from the ChangeDamageVulnerable event.
                    if(data.weapon.events){
                        let event = data.weapon.events.find((someEvent) => someEvent.type == "ChangeDamageVulnerable");
                        if(event){
                            data.Damage.damage = event.power;
                            data.Damage.type = event.damage;
                            data.Damage.time = event.time;
                            data.Damage.bind = event.bind;
                        }
                    }
                }
            }
        }
    }
});


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
        DLSB_Spellweaver_BuffType(data, null);

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
        DLSB_Spellweaver_BuffType(data, null);

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
    }else if(buff.id != KDGameData.DollLia.Spellblade.spellweaver[0] && entity.player){
        buff.duration += 1;
    }
});

// Constants for quick balancing.
let DLSB_SPELLWEAVER_BUFFDUR                = 10
let DLSB_SPELLWEAVER_POWER                  = 3     
let DLSB_SPELLWEAVER_POWER_UTIL             = 2     // Utility schools hit weaker than Elemental, etc.
let DLSB_SPELLWEAVER_POWER_BIND             = 1.5   // Bondage schools
let DLSB_SPELLWEAVER_POWER_BINDAMT          = 2.5   // Bondage schools
// Hexed Blade
let DLSB_SPELLWEAVER_HEXED_POWER            = 4
let DLSB_SPELLWEAVER_HEXED_POWER_UTIL       = 3
let DLSB_SPELLWEAVER_HEXED_POWER_BIND       = 2
let DLSB_SPELLWEAVER_HEXED_POWER_BINDAMT    = 3     // Bondage schools
// Chaos Elements - Basically all enemy spells apply binding.
let DLSB_CHAOSWEAVER_POWER_BIND             = 2
let DLSB_CHAOSWEAVER_POWER_BINDAMT          = 3
let DLSB_CHAOSWEAVER_HEXED_POWER_BIND       = 2.5
let DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT    = 4

let DLSB_Checked_Tags = ["fire", "ice", "earth", "electric", "air", "water", "latex", "latex_solid", "summon", "physics", "metal", "leather", "rope", "knowledge", "stealth", "light", "shadow"]//, "telekinesis"]
let DLSB_Chaos_Tags = ["e_asylum","e_magicbelt","e_zombieorb", "e_ropemithril", "e_ropecelestial", "e_rope_vine", "e_rope_magic", "e_wrapblessed", "e_rubberbullet", "e_shadow", "e_crystal", "e_cables", "e_hairpin"]
let DLSB_All_Possible_Tags = DLSB_Checked_Tags.concat(DLSB_Chaos_Tags)


//#region Generate Spellweaver
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
            // If a spell has no tags, this breaks. Notably occurs whenever you use a weapon's special.
            if(data.spell?.tags){
                spellTag = data.spell.tags.find((spelltag) => DLSB_Checked_Tags.includes(spelltag))
            }
        }
        if(spellTag == "latex" && data.spell.prerequisite == "SlimeToLatex"){
            spellTag = "latex_solid"
        }
    }
    if(!spellTag){
        //console.log("Invalid spell for spellblade")
        return
    }

    // Randomly assign a spell tag if we are given "random" or "chaos"
    // This can include spell tags not normally accessible to the player. (Blade Twirl)
    //console.log(DLSB_All_Possible_Tags)
    if(spellTag == "random"){
        spellTag = DLSB_Checked_Tags[Math.floor(KDRandom() * DLSB_Checked_Tags.length)];
    }
    else if(spellTag == "chaos"){
        spellTag = DLSB_Chaos_Tags[Math.floor(KDRandom() * DLSB_Chaos_Tags.length)];
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
    let spellweaver_tileKind = null, spellweaver_tileAoE = 1.1, spellweaver_tileDur = null, spellweaver_tileDurMod = null,spellweaver_tileDensity = null
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
        // Slime Bondage
        case "latex":
            spellweaver_type            = "glue";
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BIND : DLSB_SPELLWEAVER_POWER_BIND;
            spellweaver_addBind         = true;
            spellweaver_bindType        = "Slime";
            spellweaver_bind            = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BINDAMT : DLSB_SPELLWEAVER_POWER_BINDAMT;

            spellweaver_tileKind        = "Slime";
            spellweaver_tileAoE         = 1.1;
            spellweaver_tileDur         = 7;

            spellweaver_color           = "#cc2f7b";       // Slime Pink
            spellweaver_buffSprite      = "DLSB_Spellweaver_latex";
            spellweaver_buffText        = "DLSB_Spellweaver_latex";
            break;
        // Latex Bondage
        case "latex_solid":
            spellweaver_type            = "glue";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BIND : DLSB_SPELLWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "Latex";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BINDAMT : DLSB_SPELLWEAVER_POWER_BINDAMT);

            // TODO - Might be a bit sketchy.
            spellweaver_tileKind        = "LatexThinBlue";
            spellweaver_tileAoE         = 0.5;
            spellweaver_tileDur         = 20;
            spellweaver_tileDurMod      = 10;
            spellweaver_tileDensity     = 0.5;

            spellweaver_color           = KDBaseWhite;
            spellweaver_buffSprite      = "DLSB_Spellweaver_latex_solid";
            spellweaver_buffText        = "DLSB_Spellweaver_latex_solid";
            break;
        case "metal":
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BIND : DLSB_SPELLWEAVER_POWER_BIND;
            spellweaver_addBind         = true;
            spellweaver_bindType        = "Metal";
            spellweaver_bind            = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BINDAMT : DLSB_SPELLWEAVER_POWER_BINDAMT;

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
            spellweaver_bind            = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BINDAMT : DLSB_SPELLWEAVER_POWER_BINDAMT;

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
            spellweaver_bind            = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_BINDAMT : DLSB_SPELLWEAVER_POWER_BINDAMT;

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
        // Enemy-Specific
        // Intentionally stronger than normal Spellweaver charges, as you cannot normally gain them.
        case "e_asylum":            // Apply Asylum Restraints
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "DLSB_Asylum";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            spellweaver_tileKind        = "Belts";
            spellweaver_tileAoE         = 1.1;
            spellweaver_tileDur         = 12;

            spellweaver_color           = KDBaseWhite;
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_asylum";
            spellweaver_buffText        = "DLSB_Spellweaver_e_asylum";
            break;
        case "e_magicbelt":         // Magic Belts from Witch Apprentices and Bondage Tomes
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "DLSB_MagicBelt";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            spellweaver_tileKind        = "Belts";
            spellweaver_tileAoE         = 1.1;
            spellweaver_tileDur         = 12;

            spellweaver_color           = KDBasePink;
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_magicbelt";
            spellweaver_buffText        = "DLSB_Spellweaver_e_magicbelt";
            break;
        case "e_zombieorb":         // Charm orbs from Zombies & Fuuka Windsong
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "Magic";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            spellweaver_color           = KDBaseRibbon;
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_wrapcharm";
            spellweaver_buffText        = "DLSB_Spellweaver_e_wrapcharm";
            break;
        case "e_wrapblessed":       // Blessed Wrappings (Mummy, etc.)
            spellweaver_type            = "soul";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "DLSB_BlessedWrappings";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            spellweaver_color           = KDBaseMint;
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_wrapblessed";
            spellweaver_buffText        = "DLSB_Spellweaver_e_wrapblessed";
            break;
        case "e_rope_magic":        // Mithril Rope (Elf Ranger)     
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "MagicRope";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            spellweaver_tileKind        = "Ropes";
            spellweaver_tileAoE         = 1.1;
            spellweaver_tileDur         = 12;

            spellweaver_color           = KDBaseLightGrey
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_magic";
            spellweaver_buffText        = "DLSB_Spellweaver_e_magic";
            break;
        case "e_rope_vine":         // Vine Bolt - Dryad
            spellweaver_type            = "grope";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "Vine";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            spellweaver_tileKind        = "Vines";
            spellweaver_tileAoE         = 1.1;
            spellweaver_tileDur         = 12;

            spellweaver_color           = KDBaseLightGrey
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_vine";
            spellweaver_buffText        = "DLSB_Spellweaver_e_vine";
            break;
        case "e_rope_mithril":      // Mithril Rope (Elf Ranger)     
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "DLSB_RopeMithril";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            // spellweaver_tileKind        = "Ropes";
            // spellweaver_tileAoE         = 1.1;
            // spellweaver_tileDur         = 12;

            spellweaver_color           = KDBaseLightGrey
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_mithril";
            spellweaver_buffText        = "DLSB_Spellweaver_e_mithril";
            break;
        case "e_rope_celestial":    // Angels, etc.
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "DLSB_RopeCelestial";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            // spellweaver_tileKind        = "Ropes";
            // spellweaver_tileAoE         = 1.1;
            // spellweaver_tileDur         = 12;

            spellweaver_color           = KDBaseYellow
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_celestial";
            spellweaver_buffText        = "DLSB_Spellweaver_e_celestial";
            break;
        case "e_rubberbullet":      // Rubber Bullets (MaidforceMafia, MaidKnightLight)
            spellweaver_type            = "glue";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "DLSB_CaptureFoam";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            spellweaver_color           = "#e7cf1a";       // Yellow
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_rubberbullet";
            spellweaver_buffText        = "DLSB_Spellweaver_e_rubberbullet";
            break;
        case "e_cables":            // Hi-Tech Cables
            spellweaver_type            = "chain";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "DLSB_Cables";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            // spellweaver_tileKind        = "Ropes";
            // spellweaver_tileAoE         = 1.1;
            // spellweaver_tileDur         = 12;

            spellweaver_color           = KDBaseLightGrey
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_cables";
            spellweaver_buffText        = "DLSB_Spellweaver_e_cables";
            break;
        case "e_crystal":           // Crystal Bindings (Ancient Worshippers, Crystal Dragons)
            spellweaver_type            = "soul";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "DLSB_Crystal";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            spellweaver_color           = KDBaseRed;
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_crystal";
            spellweaver_buffText        = "DLSB_Spellweaver_e_crystal";
            break;
        case "e_shadow":            // Shadow Hands (Corrupted Adventurer, etc.)
            spellweaver_type            = "cold";
            spellweaverBuff_Power       = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BIND : DLSB_CHAOSWEAVER_POWER_BIND);
            spellweaver_addBind         = true;
            spellweaver_bindType        = "DLSB_ShadowHands";
            spellweaver_bind            = (KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_CHAOSWEAVER_HEXED_POWER_BINDAMT : DLSB_CHAOSWEAVER_POWER_BINDAMT);

            spellweaver_color           = "#3c115c";
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_shadow";
            spellweaver_buffText        = "DLSB_Spellweaver_e_shadow";
            break;
        case "e_hairpin":            // Hairpin (M.F. Parasol)
            spellweaver_type            = "pain";
            spellweaverBuff_Power       = KinkyDungeonFlags.get("DLSB_HexedBlade") ? DLSB_SPELLWEAVER_HEXED_POWER_UTIL : DLSB_SPELLWEAVER_POWER_UTIL

            spellweaver_color           = KDBaseLightGrey
            spellweaver_buffSprite      = "DLSB_Spellweaver_e_hairpin";
            spellweaver_buffText        = "DLSB_Spellweaver_e_hairpin";
            break;
        default:                    // Default to Blast damage, and buffText saying to file a bug report.
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
        DLSB_Spellweaver_Tile_DurMod:   spellweaver_tileDurMod,
        DLSB_Spellweaver_Tile_Density:  spellweaver_tileDensity,

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

//#region Consume Spellweaver
/*****************************************************
 * playerAttack Spellweaver Event 
 * 
 * Consume the buff IF it triggers on playerAttack.
 * > Typically a damage rider-type effect.
 * > Some future buffs (Crit) might trigger on beforeCrit or duringCrit.
 *********************************************************/
KDEventMapSpell.playerAttack["DLSB_Spellweaver"] = (e, spell, data) => {
    console.log("PLAYER ATTACK")
    console.log(e)
    console.log(spell)
    console.log(data)
    if ((!data.bullet || e.bullet
        || (data?.bullet && data.bullet.bullet?.name == "SagittaBolt"))
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
                                    lifetime: 20,
                                    maxlifetime: 20,
                                });
                            }
                        // Summon a basic friend, no cool hat. :c
                        }else{
                            let point = KinkyDungeonGetNearbyPoint(data.enemy.x, data.enemy.y, true, undefined, true);
                            if (point) {
                                let Enemy = KinkyDungeonGetEnemyByName("DLSB_SpellweaverAlly");
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
                    case "e_hairpin":           // Blinds the target.
                        KDBlindEnemy(data.enemy, 5);
                        break;
                }

                let spellweaverDmg  = KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.power;
                let spellweaverCrit = KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_Crit;
                if(KinkyDungeonFlags.get("DLSB_Blademistress")){
                    console.log(KinkyDungeonPlayerDamage)

                    // Change crit modifier if weapon is light.
                    if(KinkyDungeonPlayerDamage?.light && KinkyDungeonPlayerDamage?.crit){
                        if(KinkyDungeonPlayerDamage.crit > spellweaverCrit){
                            spellweaverCrit = KinkyDungeonPlayerDamage.crit;
                        }
                    }
                    let heavyTags = 0;
                    if(KinkyDungeonPlayerDamage?.clumsy){heavyTags++}
                    if(KinkyDungeonPlayerDamage?.massive){heavyTags++}
                    if(KinkyDungeonPlayerDamage?.heavy){heavyTags++}
                    if(heavyTags){spellweaverDmg += heavyTags * 0.5}
                }

                // Obtain all important stats from the buff itself.
                KinkyDungeonDamageEnemy(data.enemy, {
                    type:       KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]].DLSB_Spellweaver_Type,     //spellweaverType,
                    damage:     spellweaverDmg,
                    time:       KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_Time,
                    chance:     1,
                    crit:       spellweaverCrit,
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
                    },
                    KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_Tile_DurMod,
                    KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]].DLSB_Spellweaver_Tile_AoE,
                    null,
                    KinkyDungeonPlayerBuffs[KDGameData.DollLia.Spellblade.spellweaver[0]]?.DLSB_Spellweaver_Tile_Density);
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

let DLSB_Spellblade_Fleche = {name: "DLSB_Fleche", tags: ["stamina", "utility", "offense"], school: "Special", prerequisite: "DLSB_Spellweaver", classSpecific: "DLSB_Spellblade", hideWithout: "DLSB_Spellweaver", manacost: 0, customCost: "DLSB_Fleche", components: [], level:1,
    type:"special", special: "DLSB_Fleche", noMiscast: true,
    onhit:"", time:25, power: 0, 
    //minRange: 1.99, 
    castCondition: "DLSB_Fleche",
    range: 3.99, size: 1, damage: ""
}

let DLSB_Spellblade_Displacement = {name: "DLSB_Displacement", tags: ["stamina", "utility", "offense"], school: "Special", prerequisite: "DLSB_Fleche", classSpecific: "DLSB_Spellblade", hideWithout: "DLSB_Spellweaver", manacost: 0, customCost: "DLSB_Displacement", components: [], level:1,
    type:"special", special: "DLSB_Displacement", noMiscast: true,
    onhit:"", time:25, power: 0, range: 1.5, size: 1, damage: ""
}


KDCustomCost["DLSB_Fleche"] = (data) => {
    if(KinkyDungeonSlowLevel < (KinkyDungeonStatsChoice.get("HeelWalker") ? 3 : 2)){
        data.cost = Math.round(10 * -(KDAttackCost().attackCost + KDSprintCost(undefined, undefined, true))) + "SP+SWVR";
        data.color = KDBaseMint;
    }else{
        data.cost = "999SP+SWVR";//"BOUND!";
        data.color = KDBaseOrange;
    }
}
KDCustomCost["DLSB_Displacement"] = (data) => {
    if(KinkyDungeonSlowLevel < (KinkyDungeonStatsChoice.get("HeelWalker") ? 3 : 2)){
        data.cost = Math.round(10 * -(KDAttackCost().attackCost + 2*KDSprintCost(undefined, undefined, true))) + "SP";
        data.color = KDBaseMint;
    }else{
        data.cost = "999SP";//"BOUND!";
        data.color = KDBaseOrange;
    }
}

// CastCond
let DLSB_CastCondNerfedFleche = (player, x, y) => {
    let dist = KDistChebyshev(x - player.x, y - player.y);
    return (
        (dist > 1.5) &&                                                     // Do not allow casting on adjacent target.
        (KinkyDungeonFlags.get("DLSB_FancyFootwork") || (dist < 2.5))       // Do not allow casting at range 3 without Fancy Footwork.
        // Do not allow casting at range 3 if slowed.
        && ((KinkyDungeonSlowLevel < (KinkyDungeonStatsChoice.get("HeelWalker") ? 2 : 1)) || dist < 2.5)
    )
}
// Keeping this here, posthumously.
let DLSB_CastCondUnnerfedFleche = (player, x, y) => {
    let dist = KDistChebyshev(x - player.x, y - player.y);
    return (
        // Do not allow casting at range 1 without Fancy Footwork
        (KinkyDungeonFlags.get("DLSB_FancyFootwork") || (dist > 1.5))
        // Do not allow casting at range 3 with partially bound legs.
        && (
            (KinkyDungeonSlowLevel < (KinkyDungeonStatsChoice.get("HeelWalker") ? 2 : 1))//!KinkyDungeoCheckComponentsPartial({components: ["Legs"]}).includes("Legs")
            || dist < 2.5
        )
    )
}

KDPlayerCastConditions["DLSB_Fleche"] = DLSB_CastCondUnnerfedFleche;

// Handle partial components without attaching components to Fleche/Displacement
// I THINK this prevents you from being teased for casting these in melee.
// Unfortunate side-effect is generic spellcast fail messages, BUT this shows that you cannot "cast".
KDAddEvent(KDEventMapGeneric, "calcCompPartial", "DLSB_Flecheplacement", (e, data) => {
    if(data.spell?.name == "DLSB_Fleche" || data.spell?.name == "DLSB_Displacement"){
        if(KinkyDungeoCheckComponentsPartial( {components: ["Legs"]} ).includes("Legs")){
            data.partial = ["Legs"];
        }
    }
});
KDAddEvent(KDEventMapGeneric, "beforeCalcComp", "DLSB_Flecheplacement", (e, data) => {
    if(data.spell?.name == "DLSB_Fleche" || data.spell?.name == "DLSB_Displacement"){
        data.components = ["Legs"]
    }
});



// SpellSpecial for Fleche
KinkyDungeonSpellSpecials["DLSB_Fleche"] = (spell, _data, targetX, targetY, _tX, _tY, entity, _enemy, _moveDirection, _bullet, _miscast, _faction, _cast, _selfCast) => {
    if(KinkyDungeonPlayerDamage?.name && (KinkyDungeonPlayerDamage.name == "Unarmed")){
        KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoWeapon"), KDBaseRed, 1, true);
        return "Fail";
    }
    // Need legs to cast.
    if(KinkyDungeoCheckComponents({components: ["Legs"]}).failed.length > 0){
        KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoLegs"), KDBaseRed, 1, true);
        return "Fail";
    }
    if(!KDGameData.DollLia.Spellblade?.spellweaver[0]){
        KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoSpellweaver"), KDBaseRed, 1, true);
        return "Fail";
    }
    let cost = KDAttackCost().attackCost + KDSprintCost(undefined, undefined, true);
    let en = KinkyDungeonEntityAt(targetX, targetY);
    let dist = null;
    if(en?.Enemy){
        dist = KDistChebyshev(en.x - entity.x, en.y - entity.y);
        // Do not allow dashing through barricades/turrets.
        if(KDIsImmobile(en) && dist < 1.5){
            KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_EnemyImmobile"), KDBaseRed, 1, true);
            return "Fail";
        }
        // Consider making this unavailable if slowed.
        // if(dist < 1.5 && (KinkyDungeonSlowLevel > (KinkyDungeonStatsChoice.get("HeelWalker") ? 1 : 0))){
        //     KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoLegs_FF"), KDBaseRed, 1, true);
        //     return "Fail";
        // }
    }
    let space = false;
    let dash_x = null;
    let dash_y = null;
    //console.log(en)
    if (en?.Enemy) {
        if (KinkyDungeonHasStamina(-cost)) {
            //let dist = KDistChebyshev(en.x - entity.x, en.y - entity.y);
            // If we are adjacent, we Fleche through.
            if (dist < 1.5) {
                // Find our relation to the target.  This is the reverse of Displacement.
                let delta_x = en.x - entity.x
                let delta_y = en.y - entity.y

                // Check full dash dist AND clear line to it.
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
                KinkyDungeonSetFlag("DLSB_PerformingFlecheDisplacement", 1);         // Set a flag for changing damage of Thrusting Swords
                let result = KinkyDungeonLaunchAttack(en, 1);
                if (result == "confirm" || result == "dialogue") return "Fail";
                if (result == "hit" || result == "capture") {
                    KinkyDungeonTrapMoved = true;  // Suffer
                    if (KinkyDungeonNoEnemy(dash_x, dash_y) && KDIsMovable(dash_x, dash_y)) {
                        KDMovePlayer(dash_x, dash_y, true, true);
                        KDChangeStamina(spell.name, "spell", "cast", KDSprintCost(undefined, undefined, true));
                    }
                    
                    KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheSuccess"), "#e7cf1a", 1, false);
                } else if (result == "miss") {
                    KinkyDungeonTrapMoved = true;  // Suffer
                    if (KinkyDungeonNoEnemy(dash_x, dash_y) && KDIsMovable(dash_x, dash_y)) {
                        KDMovePlayer(dash_x, dash_y, true, true);
                        KDChangeStamina(spell.name, "spell", "cast", KDSprintCost(undefined, undefined, true));
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

//#region Displacement
// SpellSpecial for Displacement
// Make a weapon attack at a target, then move up to two spaces away.
KinkyDungeonSpellSpecials["DLSB_Displacement"] = (spell, _data, targetX, targetY, _tX, _tY, entity, _enemy, _moveDirection, _bullet, _miscast, _faction, _cast, _selfCast) => {
    if(KinkyDungeonPlayerDamage?.name && (KinkyDungeonPlayerDamage.name == "Unarmed")){
        KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_NoWeapon"), KDBaseRed, 1, true);
        return "Fail";
    }
    // Need legs to cast.
    if(KinkyDungeoCheckComponents({components: ["Legs"]}).failed.length > 0){
        KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_DisplacementFail_NoLegs"), KDBaseRed, 1, true);
        return "Fail";
    }
    let cost = KDAttackCost().attackCost + 2*KDSprintCost(undefined, undefined, true);
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
                KinkyDungeonSetFlag("DLSB_PerformingFlecheDisplacement", 1);         // Set a flag for changing damage of Thrusting Swords
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
                    KDChangeStamina(spell.name, "spell", "cast", 2*KDSprintCost(undefined, undefined, true));


                } else if (result == "miss") {
                    KinkyDungeonTrapMoved = true;  // Backflipping into dangerous mechanics is the RDM way~
                    KDMovePlayer(backflip_x, backflip_y, true, true);
                    KinkyDungeonRemoveBuffsWithTag(en, ["displaceend"]);
                    KinkyDungeonRemoveBuffsWithTag(KDPlayer(), ["displaceend"]);
                    KinkyDungeonSendTextMessage(8, TextGet("KDDLSB_FlecheFail_AttackMiss"), KDBaseRed, 1, true);
                    KDChangeStamina(spell.name, "spell", "cast", 2*KDSprintCost(undefined, undefined, true));
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
        {type: "DLSB_BladeTwirl_Invis", trigger: "DLSB_calcPlayerSpellHit"},
    ]
}

KDCustomCost["DLSB_BladeTwirl"] = (data) => {
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
        // Cannot block without any willpower - the game gives you a -100% block penalty.
        // Block it outright, so the player doesn't waste MP/SP trying anyways.
        if (!(KinkyDungeonStatWill > 0)) {
            KinkyDungeonSendTextMessage(5, TextGet("DLSB_BladeTwirlFail_NoWill"), KDBaseOrange, 10);
            return;
        }
        // Check that the player has a weapon equipped.
        if(KinkyDungeonPlayerDamage?.name && (KinkyDungeonPlayerDamage.name != "Unarmed")){

            // Freezing Point from Toy Box
            if(KinkyDungeonPlayerDamage.name == "DLSE_FreezingPoint"
               &&  KDGameData.DollLia?.ToyBox
               &&  !KDGameData.DollLia.ToyBox.freezingPointLoaded
            ){
                KinkyDungeonSendTextMessage(5, TextGet("DLSB_BladeTwirlFail_FreezingPoint"), KDBaseOrange, 10);
                return;
            }

            if(KinkyDungeonStatMana >= KinkyDungeonGetManaCost(spell, false, false)){
                if (KinkyDungeonStatStamina >= KinkyDungeonGetStaminaCost(spell, false, false)) {
                    // Should never happen unless I give this a duration.
                    if (KinkyDungeonPlayerBuffs.DLSB_BladeTwirl) {
                        KinkyDungeonExpireBuff(KinkyDungeonPlayerEntity, "DLSB_BladeTwirl");
                    }
                    KinkyDungeonPlaySound(KinkyDungeonRootDirectory + "Audio/DLSB_Twirl.ogg", undefined, 0.3);


                    ///////////////////////////////
                    // KDTestSpellHits() Version //
                    ///////////////////////////////
                    if(KDModSettings["DLSBMCM"]["DLSBMCM_TestSpellHits"]){
                        // Set flag that you are blade twirling.
                        KinkyDungeonSetFlag("DLSB_BladeTwirling", 1);
                    }
                    ///////////////////////////////
                    // Mod Compatibility Version //
                    ///////////////////////////////
                    // Legacy code from an old implementation of Blade Twirl.
                    else{
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
                    }
                    // Handle spending costs, etc.
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
    // Don't do anything if not using legacy code.
    if(!KDModSettings["DLSBMCM"]["DLSBMCM_TestSpellHits"]){
        if (data.target?.player && data.attacker) {
            let player = KinkyDungeonPlayerEntity;
            let buff = KDEntityGetBuff(player, "DLSB_BladeTwirl");
            if(buff){
                // Set playerBlock to a very high number, so you can never block.
                data.playerBlock = 2;
            }
        }
    }
});


// Event to handle blocking a spell successfully.
KDAddEvent(KDEventMapSpell, "blockPlayerSpell", "DLSB_BladeTwirl_Invis", (e, spell, data) => {
    // console.log("Spell blocked!")
    // console.log(data)
    if(data?.player && data?.spell){
        // Default if we somehow cannot assign anything.
        let spellTag = "DEFAULT"

        // Switching on the damage type first is promising.
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
            case "blast":           // No idea if anything even does this?  Maybe the air gusts from Hard/Extreme enemies?
                spellTag = "air";
                break;
            case "pain":
                if(data.spell.name == "NurseSyringe"){
                    spellTag = "e_asylum";      // TODO - Syringeweaver. Sounds DIFFICULT.
                }
                else if(data.spell.name == "Hairpin"){
                    spellTag = "e_hairpin";
                }else{
                    spellTag = "leather";
                }
                break;
            case "grope":
                if(data.spell?.bindType){
                    switch(data.spell?.bindType){
                        case "Vine":
                            spellTag = "e_rope_vine";
                            break;
                    }
                }
                break;
            case "chain":
                //TODO - Special Cases
                switch(data.spell.name){
                    case "NurseBola":
                        spellTag = "e_asylum";
                        break;
                    case "ZombieOrb":
                    case "ZombieOrbMini":
                        spellTag = "e_zombieorb";
                        break;
                    case "ElfArrow":
                        spellTag = "e_rope_mithril";
                        break;
                }
                // If any special cases hit, break
                if(spellTag != "DEFAULT"){break;}
                // Bind Type?
                if(data.spell?.bindType){
                    switch(data.spell?.bindType){
                        case "Leather":
                            if(data.spell.name == "MagicBelt"){
                                spellTag = "e_magicbelt";
                            }else{
                                spellTag = "leather";
                            }
                            break;
                        case "Rope":
                            spellTag = "rope";
                            break;
                        case "Metal":
                            if(data.spell.name == "RestrainingDevice"){
                                spellTag = "e_cables";
                            }else{
                                spellTag = "metal";
                            }
                            break;
                        // Enemy-Specific
                        case "MagicRope":
                            spellTag = "e_rope_magic";
                            break;
                        case "Tape":
                            spellTag = "rope";      // TODO - Tape (Can anything apply this though?)
                            break;
                        case "Vine":
                            spellTag = "e_rope_vine";
                            break;
                        case "Energy":              // TODO - IDFK
                            spellTag = "metal";
                            break;
                        case "Magic":
                            spellTag = "e_zombieorb";
                            break;
                    }
                }
                break;
            case "glue":
                // TODO - Capture Foam Spellweaver
                if((data.spell.name == "RubberBullets") || (data.spell.name == "RubberSniper")){
                    spellTag = "e_rubberbullet"
                    break;
                }
                if(data.spell?.bindType){
                    switch(data.spell?.bindType){
                        case "Latex":
                            spellTag = "latex_solid";
                            break;
                        case "Slime":
                            spellTag = "latex";
                            break;
                    }
                    break;
                }else{
                    //????????????????????????
                    console.log("WEIRD GLUE SPELL ALERT - PLEASE REPORT TO DOLL.LIA")
                    spellTag = "latex";       // assume Slime I guess.
                    break;
                }
                break;
            case "holy":
                if(data.spell.name == "EnemyCoronaBeam"){
                    spellTag = "e_rope_celestial";
                }else{
                    spellTag = "light";
                }
                break;
            case "cold":
                spellTag = "shadow";
                if(data.spell.playerEffect?.name == "ShadowBolt"){
                    spellTag = "e_shadow"
                }
                break;
            case "soul":        // Psychic (Soul) damage is very rare, and basically always special cases.
                switch(data.spell.name){
                    case "MummyBolt":
                        spellTag = "e_wrapblessed";
                        break;
                }
                if(data.spell.playerEffect?.name == "CrystalBind"){
                    spellTag = "e_crystal"
                }
                break;
            // If somehow NOTHING matches, uh.  Yeah.
            default:
                //????????????????????????
                spellTag = "DEFAULT";
        }

        if(spellTag == "DEFAULT"){
            console.log("WEIRD SPELL ALERT - PLEASE REPORT TO DOLL.LIA")
            console.log("Offending Spell:")
            console.log(data.spell)
        }

        // Apply the buff
        DLSB_Spellweaver_BuffType(null, spellTag)

        // If the player has the spell, reequip their old weapon.
        if (KDHasSpell("DLSB_Mageblade") && KinkyDungeonPlayerWeapon != KDGameData.PlayerWeaponLastEquipped && KinkyDungeonInventoryGet(KDGameData.PlayerWeaponLastEquipped)) {
            KDSetWeapon(KDGameData.PlayerWeaponLastEquipped);
        }
    }
});


// Actual Code
let DLSB_BladeTwirl_KDTestSpellHits = (spell, allowEvade, allowBlock) => {
    let player = KinkyDungeonPlayerEntity;
    let data = {
        player:         player,
        spell:          spell,
        allowEvade:     allowEvade,
        allowBlock:     allowBlock,
    }
    
    KinkyDungeonSendEvent("DLSB_beforeCalcPlayerSpellHit", data);       // Event to affect allowEvade/allowBlock before calculation

    data.playerEvasion = allowEvade ? KinkyDungeonPlayerEvasion() : 0;
    data.playerBlock = allowBlock ? KinkyDungeonPlayerBlock() : 0;
	data.missed = data.allowEvade && KDRandom() * AIData.accuracy < (1 - data.playerEvasion) * data.allowEvade;
	data.blockedAtk = data.allowBlock && (KDRandom() * AIData.accuracy < (1 - data.playerBlock) * data.allowBlock);

    KinkyDungeonSendEvent("DLSB_calcPlayerSpellHit", data);             // Event to affect final result

    // Added data. prefix
	if (!data.missed && !data.blockedAtk) {
		return true;
	} else {
        // Added data. prefix
		if (data.missed) {
			if (spell) {
				KinkyDungeonSendEvent("missPlayerSpell", {spell: spell, player: player});
				KinkyDungeonSendTextMessage(2, TextGet("KinkyDungeonSpellBindMiss").replace("EnemyName", TextGet("KinkyDungeonSpell" + (spell.name || ""))), KDBaseLightGreen, 1);
			}
			KDDamageQueue.push({floater: TextGet("KDMissed"), Entity: {x: player.x - 0.5, y: player.y - 0.5}, Color: KDBaseMint, Time: 2, Delay: 0});
        // Added data. prefix
        } else if (data.blockedAtk) {
			if (spell) {
				KinkyDungeonSendEvent("blockPlayerSpell", {spell: spell, player: player});
				KinkyDungeonSendTextMessage(2, TextGet("KinkyDungeonSpellBindBlock").replace("EnemyName", TextGet("KinkyDungeonSpell" + (spell.name || ""))), KDBaseLightGreen, 1);
			}
			KDDamageQueue.push({floater: TextGet("KDBlocked"), Entity: {x: player.x - 0.5, y: player.y - 0.5}, Color: KDBaseMint, Time: 2, Delay: 0});
		}
		return false;
	}
}

KDAddEvent(KDEventMapSpell, "DLSB_calcPlayerSpellHit", "DLSB_BladeTwirl_Invis", (e, spell, data) => {
    // Are we blade twirling?
    if(KinkyDungeonFlags.get("DLSB_BladeTwirling")){
        // console.log("Incoming Attack");
        // console.log(data)
        // Only block projectiles that are blockable. Do not block ground AoEs or unblockables.
        if(data.allowBlock && data.spell?.projectileTargeting){
            // If we did already blocked, no need to do anything.
            if(!data.blockedAtk){
                // If you have 50%+ to block, guarantee the block.
                if(data.allowBlock > 0.5){
                    data.missed = false;        // Block it, don't dodge it. Else, no Spellweaver.
                    data.blockedAtk = true;     // Force the attack to be blocked.
                // Roll a 50% chance to block.
                }else{
                    data.blockedAtk = (KDRandom() < 0.5);
                    if(data.blockedAtk){
                        data.missed = false;
                    }
                }
            }
        }
    }
});











//#region Preparation
/***********************************************
 * Spell - Preparation
 * 
 * Generate two random Spellweaver charges.
 * 100-turn cooldown, because it's PRETTY GOOD.
 ***********************************************/
let DLSB_Preparation = {name: "DLSB_Preparation", tags: ["utility", "defense"], prerequisite: "DLSB_Spellweaver", classSpecific: "DLSB_Spellblade", hideWithout: "DLSB_Spellweaver", school: "Special",
    staminacost: 0, manacost: 2, components: [], defaultOff: true, level:1, type:"passive", onhit:"", time: 0, delay: 0, range: 0, lifetime: 0, power: 0, damage: "inert",
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
                let chaosHit = false;
                // Generate that many random charges
                for(let itr = 0; itr < totalCharges; itr++){
                    // Roll Chaos chance. Set a boolean if any roll succeeds.
                    if(KDRandom() < (KDModSettings["DLSBMCM"]["DLSBMCM_Prep_ChaosChance"] / 100)){
                        DLSB_Spellweaver_BuffType(null, "chaos", DLSB_SPELLWEAVER_BUFFDUR - ((itr == 0) ? 1 : 0))
                        chaosHit = true;
                    }else{
                        DLSB_Spellweaver_BuffType(null, "random", DLSB_SPELLWEAVER_BUFFDUR - ((itr == 0) ? 1 : 0))
                    }
                }
                // Spend the Mana.
                KDChangeMana(spell.name, "spell", "cast", -KinkyDungeonGetManaCost(spell, false, false));

                // Display success message depending upon if a chaotic element was infused.
                if(chaosHit){KinkyDungeonSendTextMessage(5, TextGet("DLSB_PreparedSuccessChaos"), "#e7cf1a", 10);}
                else{KinkyDungeonSendTextMessage(5, TextGet("DLSB_PreparedSuccess"), "#e7cf1a", 10);}
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

KinkyDungeonSpellList["Special"].push(DLSB_Spellblade_Blademistress);

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
KinkyDungeonLearnableSpells[2][3].push("DLSB_Blademistress");         // Not sure if balanced.
KinkyDungeonLearnableSpells[2][3].push("DLSB_HexedBlade");
KinkyDungeonLearnableSpells[2][3].push("DLSB_SpellweaverQueue");











//#region Player Titles
//////////////////////////////////////////////////
let DLSB_KDPlayerTitlesLive = false;
try{
    KDPlayerTitles;                     // If player titles aren't live, this throws an exception.
    DLSB_KDPlayerTitlesLive = true;     // Otherwise, player titles are live
}catch(e){
    ;
}

if(DLSB_KDPlayerTitlesLive){
    KDPlayerTitles["DLSB_ClassSpellblade"] = {
        "unlockCondition": () => {
            return (KDGameData?.Class == "DLSB_Spellblade")
        },
        "priority": -100,
        "color": "#c708e0ff",
        "titleActive": () => {
            return false;
        },
        "titleActivate": () => {
            return false;
        },
        "titleDeactivate": () => {
            return false;
        },
        "category": "Classes",
        "icon": "None",
    };
    KDPlayerTitlesRefreshCategories();
}