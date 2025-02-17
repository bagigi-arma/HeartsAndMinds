btc_map_mapIllumination = ace_map_mapIllumination;
if !(isNil "btc_custom_loc") then {
    {
        _x params ["_pos", "_cityType", "_cityName", "_radius"];
        private _location = createLocation [_cityType, _pos, _radius, _radius];
        _location setText _cityName;
    } forEach btc_custom_loc;
};
btc_intro_done = [] spawn btc_respawn_fnc_intro;
[] call btc_int_fnc_shortcuts;
[] call btc_lift_fnc_shortcuts;

[{!isNull player}, {
    [] call compileScript ["core\doc.sqf"];

    btc_respawn_marker setMarkerPosLocal player;
    player addRating 9999;
    ["InitializePlayer", [player, true]] call BIS_fnc_dynamicGroups;

    [player] call btc_eh_fnc_player;

    private _arsenal_trait = player call btc_arsenal_fnc_trait;
    if (btc_p_arsenal_Restrict isEqualTo 3) then {
        [_arsenal_trait select 1] call btc_arsenal_fnc_weaponsFilter;
    };

    btc_fob_timeout = btc_fob_timeout + CBA_missionTime;
    [] call btc_int_fnc_add_actions;

    if (player getVariable ["interpreter", false]) then {
        player createDiarySubject ["btc_diarylog", localize "STR_BTC_HAM_CON_INFO_ASKHIDEOUT_DIARYLOG", '\A3\ui_f\data\igui\cfg\simpleTasks\types\talk_ca.paa'];
    };

    switch (btc_p_autoloadout) do {
        case 1: {
            player setUnitLoadout ([_arsenal_trait select 0] call btc_arsenal_fnc_loadout);
        };
        case 2: {
            removeAllWeapons player;
        };
        default {
        };
    };

    [] call btc_respawn_fnc_screen;

    if (btc_debug) then {
        addMissionEventHandler ["MapSingleClick", {
            params ["_units", "_pos", "_alt", "_shift"];
            if (
                alive player &&
                !_alt &&
                !_shift
            ) then {
                vehicle player setPos _pos;
            };
        }];
        player allowDamage false;

        [{!isNull (findDisplay 12)}, {
            ((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["Draw", btc_debug_fnc_marker];
        }] call CBA_fnc_waitUntilAndExecute;
    };
}] call CBA_fnc_waitUntilAndExecute;

// ------------ Custom Player Init ------------

// Respawn on carrier properly
player addMPEventHandler ["MPRespawn", {
    private _pos = getPosASL player;
    if (_pos distance2D btc_gear_object < 20) then {
        _pos set [2, 17]; // LHD Atlas main deck height
        [{player setPosASL (_this select 0);}, [_pos]] call CBA_fnc_execNextFrame;
    };
}];

// 3D Icons on important resource boxes
addMissionEventHandler ["Draw3D", {
    // Return early if far from all important objects (>30m)
    if (player distanceSqr btc_gear_object > 400) exitWith {};

    {
        _x params ["_objName", "_drawnText", "_zOffset"];

        if (player distanceSqr _objName < 100) then {
            drawIcon3D ["a3\ui_f_enoch\data\common\rschorizontalcompass\compass_hq_ca.paa", [1,1,1,1], (ASLToAGL getPosASL _objName) vectorAdd [0, 0, _zOffset], 1, 1, 0, _drawnText, 0, 0.05, "PuristaMedium", "center"];
        };
    } forEach [
        // [objName, drawnText, zOffset]
        [btc_gear_object, "Loadout Default/Predefiniti + Abilità", 2]
    ];
}];

/*[{
    private _coreSignal = _this call acre_sys_signal_fnc_getSignalCore;
    _coreSignal params ["_Px", "_maxSignal"];

    // Check for active EMPs on the map
    private _empObjects = btc_spect_emp;
    private _empRange = btc_spect_range / 2;

    // Check for transmitting and receiving radio being in range

    [_Px, _signal]
}] call acre_api_fnc_setCustomSignalFunc;*/

// Add nearby heal interaction on main Arsenal
btc_gear_object addAction ["<t color='#ff85ef'>Heal All within 50m</t>", "heal_nearby.sqf", [], 1];

// Add trait switching interactions to main Arsenal
private _action = ["traitBase", "Cambia abilità", "", {true}, {true}] call ace_interact_menu_fnc_createAction;
private _baseAction = [btc_gear_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["traitMed", "Soccorritore", "", {"med" call rusher_setRoles}, {true}] call ace_interact_menu_fnc_createAction;
[btc_gear_object, 0, _baseAction, _action] call ace_interact_menu_fnc_addActionToObject;
_action = ["traitDoc", "Medico", "", {"doc" call rusher_setRoles}, {true}] call ace_interact_menu_fnc_createAction;
[btc_gear_object, 0, _baseAction, _action] call ace_interact_menu_fnc_addActionToObject;
_action = ["traitEng", "Geniere+EOD", "", {"eng" call rusher_setRoles}, {true}] call ace_interact_menu_fnc_createAction;
[btc_gear_object, 0, _baseAction, _action] call ace_interact_menu_fnc_addActionToObject;
_action = ["traitTran", "Traduttore", "", {"tran" call rusher_setRoles}, {true}] call ace_interact_menu_fnc_createAction;
[btc_gear_object, 0, _baseAction, _action] call ace_interact_menu_fnc_addActionToObject;
