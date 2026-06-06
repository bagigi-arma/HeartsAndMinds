/*
 * Adds the root teleport action to an object
 *
 * Arguments:
 * 0: The object the actions are added to <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [flagpole_1] call TRN_fnc_addTeleportActions
 */
#define ACTION_DISTANCE 5

params ["_object"];

// Depending on the object, place the action on the root or on a specific relative position
private _actionPos = switch (typeOf _object) do {
	case "FlagPole_F": { [0.06, -0.39, -2.38] };
	case "PortableFlagPole_01_F": { [-0.07, -0.02, -1.1] };
	default { [0, 0, 0] };
};
private _rootPath = if (_actionPos isEqualTo [0, 0, 0]) then {["ACE_MainActions"]} else {[]};

// Add root teleport action, generate child actions dynamically
private _action = ["teleportRoot", "Teleport", "data\bagigi.paa", {}, {true}, {_this call TRN_fnc_teleportChildrenActions}, [], _actionPos, ACTION_DISTANCE] call ace_interact_menu_fnc_createAction;
[_object, 0, _rootPath, _action] call ace_interact_menu_fnc_addActionToObject;
