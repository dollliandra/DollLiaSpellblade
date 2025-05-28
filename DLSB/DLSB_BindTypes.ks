'use strict';

//////////////////////////////////////////////////////
// DLSB - Doll.Lia's Spellblade Class               //
// Use DLSB_ as the prefix for any new content.     //
//////////////////////////////////////////////////////

// This file includes new BindTypes that allow the player to apply other restraints to enemies.

//#region Spellweaver Bind Types
// Add in missing Bind Types
KDBindTypeTagLookup.DLSB_Asylum             = ["nurseRestraints"]
KDBindTypeTagLookup.DLSB_MagicBelt          = ["beltRestraintsMagic"]
KDBindTypeTagLookup.DLSB_RopeMithril        = ["mithrilRope"]          // NOTE - No trailing 's' on Rope.
KDBindTypeTagLookup.DLSB_RopeCelestial      = ["celestialRopes"]
KDBindTypeTagLookup.DLSB_BlessedWrappings   = ["mummyRestraints"]
KDBindTypeTagLookup.DLSB_CaptureFoam        = ["captureFoam"]

KDBindTypeTagLookup.DLSB_Cables             = ["hitechCables", "cableGag"]
KDBindTypeTagLookup.DLSB_ShadowHands        = ["shadowHands"]
KDBindTypeTagLookup.DLSB_Crystal            = ["crystalRestraints"] // Add crystalrestraintsheavy?

KDSpecialBondage["DLSB_Asylum"] = {
    priority: 10,               // What does this do?
    color: KDBaseWhite,
    struggleRate: 0.8,
    powerStruggleBoost: 0.5,
    healthStruggleBoost: 0.5,
    enemyBondageMult: 2.0,
}
KDSpecialBondage["DLSB_MagicBelt"] = {
    priority: 10,               // What does this do?
    color: KDBasePink,
    struggleRate: 0.9,
    powerStruggleBoost: 0.7,
    healthStruggleBoost: 1.0,
    enemyBondageMult: 1.0,
}
KDSpecialBondage["DLSB_RopeMithril"] = {
    priority: -2,
    color: KDBaseLightGrey,
    struggleRate: 2.0,
    powerStruggleBoost: 0.9,
    healthStruggleBoost: 0.9,
    enemyBondageMult: 2.0,
},
KDSpecialBondage["DLSB_RopeCelestial"] = {
    priority: 10,
    color: KDBaseYellow,
    struggleRate: 1,
    powerStruggleBoost: 0.8,
    healthStruggleBoost: 0.8,
    mageStruggleBoost: 1.2,
    enemyBondageMult: 2.0,
}
KDSpecialBondage["DLSB_BlessedWrappings"] = {
    priority: 14,
    color: KDBaseMint,
    struggleRate: 0.95,
    powerStruggleBoost: 0.3,
    healthStruggleBoost: 1.5,
    mageStruggleBoost: 2.5,
    enemyBondageMult: 1.0,
}
KDSpecialBondage["DLSB_CaptureFoam"] =  {
    priority: -10,
    color: "#404973",
    struggleRate: 1,
    powerStruggleBoost: 1.5,
    healthStruggleBoost: 0.6,
    enemyBondageMult: 1.25,
    mageStruggleBoost: 0.2,
    latex: true,
}
KDSpecialBondage["DLSB_Crystal"] = {
    priority: 10,
    color: KDBaseRed,
    struggleRate: 0.4,
    powerStruggleBoost: 0.25,
    healthStruggleBoost: 1.0,
    enemyBondageMult: 0.6,
}
KDSpecialBondage["DLSB_Cables"] = {
    priority: 10,
    color: KDBaseLightGrey,
    struggleRate: 0.6,
    powerStruggleBoost: 0.25,
    healthStruggleBoost: 1.0,
    enemyBondageMult: 0.6,
}
KDSpecialBondage["DLSB_ShadowHands"] = {
    priority: 10,
    color: "#3c115c",
    struggleRate: 1.5,
    powerStruggleBoost: 1.0,
    healthStruggleBoost: 1.0,
    mageStruggleBoost: 1.4,
    enemyBondageMult: 2.0,
}