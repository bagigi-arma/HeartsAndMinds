// Function to determine whether a unit can contact a mobile support asset (helo/boat) for Simplex Support System requests
params ["_simplex", "_vehicle"];
_simplex params ["_player", "_items", "_accessItems", "_supportEntity"];

if ((objectParent _player) isEqualTo _vehicle) exitWith {true};

private _nextUpdateTime = _player getVariable ["nextHeloConnCheck", CBA_missionTime];
// Return cached value if the last update was less than 3s ago
private _cachedReturn = _player getVariable ["cachedHeloConnCheck", false];
if (CBA_missionTime < _nextUpdateTime) exitWith {_cachedReturn};

// Check for radios on the player that can be used to contact the mobile support
private _connEstablished = false;
private _playerRadios = ([] call acre_sys_data_fnc_getPlayerRadioList) select {
	(toLower ([_x] call acre_sys_radio_fnc_getRadioBaseClassname)) in ["acre_prc148", "acre_prc152", "acre_prc117f"]
};

if (_playerRadios isNotEqualTo []) then {
	private _radioId = _playerRadios select 0;
	private _txAntenna = ([_radioId] call acre_sys_components_fnc_findAntenna) select 0;

	if (
		(_player distance2D _vehicle) < 1500 || 
		{!(terrainIntersectASL [_txAntenna#2, getPosASL _vehicle])}
	) then {
		_connEstablished = true;
	};
};

_player setVariable ["nextHeloConnCheck", CBA_missionTime + 3];
_player setVariable ["cachedHeloConnCheck", _connEstablished];

_connEstablished
