/*
 * Dynamically adds teleport child actions
 *
 * Arguments:
 * 0: Root action's target <OBJECT>
 * 1: Root action's player <OBJECT>
 * 2: Root action's arguments <ARRAY>
 *
 * Return Value:
 * Child Actions <ARRAY>
 */

params ["_target", "_player", "_args"];

private _childActions = [];

if (isNil "TRN_teleports") exitWith {_childActions};

{
	private _marker = _x;
	private _name = markerText _x;
	private _newPosition = getMarkerPos [_marker, true];

	// Make action green if the player is near that marker
	private _actionColor = "#FFFFFF";
	if (player distance2D _newPosition < 30) then {
		_actionColor = "#00FF00";
	} else {
		if ("(WIP)" in _name) then {
			_actionColor = "#FF0000";
		};
	};

	// Add main teleport action
	private _action = [_forEachIndex, _name, ["\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa", _actionColor], {
		params ["_target", "_player", "_args"];
		_args params ["_newPosition"];
		_player setPosASL _newPosition;
	}, {true}, {}, [_newPosition]] call ace_interact_menu_fnc_createAction;

	// If current group leader, add subaction to teleport your entire group
	private _subActions = [];
	if (leader player == player) then {
		private _subAction = [_forEachIndex, "Porta tutto il tuo gruppo", "", {
			params ["_target", "_player", "_args"];
			_args params ["_newPosition"];
			{_x setPosASL _newPosition} forEach (units _player);
		}, {true}, {}, [_newPosition]] call ace_interact_menu_fnc_createAction;
		_subActions pushBack [_subAction, [], _target];
	};

	// New action, its children, and the action's target
	_childActions pushBack [_action, _subActions, _target];
} forEach TRN_teleports;

_childActions
