'use strict';

/******************************************************************
 * Load Assets with Nearest Enabled to fix the blurry sprite issue.
 * > Thanks to Ada for the KDTex() line of code <3
 *****************************************************************/
KDAddEvent(KDEventMapGeneric, "afterModSettingsLoad", "DLSB_SpriteNearestFix", (e, data) => {

    let DLSB_BuffsList = [
        "buffDLSB_ArcaneSynergy.png",
        "buffDLSB_Spellweaver_air.png",
        "buffDLSB_Spellweaver_earth.png",
        "buffDLSB_Spellweaver_fire.png",
        "buffDLSB_Spellweaver_water.png",
        "buffDLSB_Spellweaver_electric.png",
        "buffDLSB_Spellweaver_ice.png",

        "buffDLSB_Spellweaver_latex.png",
        "buffDLSB_Spellweaver_latex_solid.png",
        "buffDLSB_Spellweaver_leather.png",
        "buffDLSB_Spellweaver_metal.png",
        "buffDLSB_Spellweaver_rope.png",
        "buffDLSB_Spellweaver_summon.png",
        "buffDLSB_Spellweaver_physics.png",
        "buffDLSB_Spellweaver_telekinesis.png",

        "buffDLSB_Spellweaver_light.png",
        "buffDLSB_Spellweaver_shadow.png",
        "buffDLSB_Spellweaver_knowledge.png",
        "buffDLSB_Spellweaver_stealth.png",

        "buffDLSB_Spellweaver_DEFAULT.png",

        "buffDLSB_Spellweaver_e_asylum.png",
        "buffDLSB_Spellweaver_e_cables.png",
        "buffDLSB_Spellweaver_e_capturefoam.png",
        "buffDLSB_Spellweaver_e_celestial.png",
        "buffDLSB_Spellweaver_e_crystal.png",
        "buffDLSB_Spellweaver_e_hairpin.png",
        "buffDLSB_Spellweaver_e_magic.png",
        "buffDLSB_Spellweaver_e_magicbelt.png",
        "buffDLSB_Spellweaver_e_mithril.png",
        "buffDLSB_Spellweaver_e_rubberbullet.png",
        "buffDLSB_Spellweaver_e_shadow.png",
        "buffDLSB_Spellweaver_e_vine.png",
        "buffDLSB_Spellweaver_e_wrapblessed.png",
        "buffDLSB_Spellweaver_e_wrapcharm.png",
        "buffDLSB_Spellweaver_e_wrapscarf.png",
    ]
    let DLSB_EnemiesList = [
        "DLSB_HexedAlly.png",
    ]
    let DLSB_ItemsList = [
    ]
    let DLSB_SpellsList = [
        "DLSB_Displacement.png",
        "DLSB_Fleche.png",
        "DLSB_Mageblade.png",
        "DLSB_BladeTwirl.png",
        "DLSB_Preparation.png",
    ]
    let DLSB_BulletsList = [
    ]
    for (let dataFile of DLSB_BuffsList ) {
        KDTex(KDModFiles[KinkyDungeonRootDirectory + "Buffs/buff/" + dataFile], true);
    }
    for (let dataFile of DLSB_EnemiesList ) {
        KDTex(KDModFiles[KinkyDungeonRootDirectory + "Enemies/" + dataFile], true);
    }
    for (let dataFile of DLSB_ItemsList ) {
        KDTex(KDModFiles[KinkyDungeonRootDirectory + "Items/" + dataFile], true);
    }
    for (let dataFile of DLSB_SpellsList ) {
        KDTex(KDModFiles[KinkyDungeonRootDirectory + "Spells/" + dataFile], true);
    }
    for (let dataFile of DLSB_BulletsList ) {
        KDTex(KDModFiles[KinkyDungeonRootDirectory + "Bullets/" + dataFile], true);
    }
});