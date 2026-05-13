/*
 * Adds ACE Interactions on the given box to heal Players an/or AI within the specified range
 *
 * Arguments:
 * 0: The box to add actions to <OBJECT>
 * 1: The max healing radius <NUMBER>
 * 2: The position around which to heal <ARRAY> (Optional, box position if unset)
 * 3: Action path <ARRAY> (Optional)
 * 4: Action position relative to model center <ARRAY> (Optional)
 *
 * Return Value:
 * None
 *
 * Example:
 * [ammobox, 20] call TRN_fnc_addHealActions
 */
#define MEDICAL_CROSS_ICON "\z\ace\addons\medical_gui\ui\cross.paa"

params ["_object", "_radius", ["_healPos", []], ["_actionPath", ["ACE_MainActions"]], ["_actionPos", [0, 0, 0]]];

if (_healPos isEqualTo []) then {
	_healPos = getPosATL _object;
};

// Root Action to heal everyone
private _action = ["healAllRoot", format ["Cura Tutti entro %1m", _radius], MEDICAL_CROSS_ICON, {
	params ["_target", "_player", "_args"];
	_args params ["_healPos", "_radius"];
	[_healPos, _radius, 0] call TRN_fnc_healAllNearby;
}, {true}, {}, [_healPos, _radius], _actionPos] call ace_interact_menu_fnc_createAction;
private _rootAction = [_object, 0, _actionPath, _action] call ace_interact_menu_fnc_addActionToObject;

// Sub-Action to heal only Players
_action = ["healPlayers", format ["Cura Player entro %1m", _radius], MEDICAL_CROSS_ICON, {
	params ["_target", "_player", "_args"];
	_args params ["_healPos", "_radius"];
	[_healPos, _radius, 2] call TRN_fnc_healAllNearby;
}, {true}, {}, [_healPos, _radius]] call ace_interact_menu_fnc_createAction;
[_object, 0, _rootAction, _action] call ace_interact_menu_fnc_addActionToObject;

// Sub-Action to heal only AI
_action = ["healAI", format ["Cura AI entro %1m", _radius], MEDICAL_CROSS_ICON, {
	params ["_target", "_player", "_args"];
	_args params ["_healPos", "_radius"];
	[_healPos, _radius, 1] call TRN_fnc_healAllNearby;
}, {true}, {}, [_healPos, _radius]] call ace_interact_menu_fnc_createAction;
[_object, 0, _rootAction, _action] call ace_interact_menu_fnc_addActionToObject;
