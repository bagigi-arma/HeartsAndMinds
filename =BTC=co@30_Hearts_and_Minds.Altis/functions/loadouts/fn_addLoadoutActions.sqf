/*
 * Adds all loadout actions to a box or to players (for use by instructors)
 *
 * Arguments:
 * 0: The box <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [arsenal_1] call TRN_fnc_addLoadoutActions
 */

params ["_object"];

private _name = "Loadout";
private _condition = {true};
if (_object isKindOf "CAManBase") then {
	_name = "Assegna Loadout";
	_condition = {call BIS_fnc_admin == 2};
};

private _action = ["loadoutRoot", _name, "data\bagigi.paa", {}, _condition] call ace_interact_menu_fnc_createAction;
private _rootAction = [_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

{ // Add loadout categories
	_x params ["_category", "_loadouts"];

	_action = [_forEachIndex, _category, "", {}, {true}] call ace_interact_menu_fnc_createAction;
	private _categoryAction = [_object, 0, _rootAction, _action] call ace_interact_menu_fnc_addActionToObject;

	{ // Fill each category with loadouts
		_x params ["_name", "_loadout", "_skills"];

		_action = [_forEachIndex, _name, "", {
			params ["_target", "_player", "_args"];
			_args params ["_loadout", "_skills"];

			// Apply loadout to targeted player or oneself, depending on whether the target of the interaction is a player or a box
			private _unit = if (_target isKindOf "CAManBase") then {_target} else {_player};

			// Set loadout and skills
			_unit setUnitLoadout _loadout;
			[_unit, _skills] call TRN_fnc_setSkills;

			// Update 3DEN Enhanced Saved Loadout for Respawn
			_unit setVariable ["ENH_SavedLoadout", _loadout, true];
		}, {true}, {}, [_loadout, _skills]] call ace_interact_menu_fnc_createAction;
		[_object, 0, _categoryAction, _action] call ace_interact_menu_fnc_addActionToObject;
	} forEach _loadouts;
} forEach TRN_loadouts;
