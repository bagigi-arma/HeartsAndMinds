// Function to determine whether a unit can contact the base for Simplex Support System requests
params ["_player", "_items", "_accessItems", "_supportEntity"];

private _nextUpdateTime = _player getVariable ["nextBaseConnCheck", CBA_missionTime];
// Return cached value if the last update was less than 3s ago
private _cachedReturn = _player getVariable ["cachedBaseConnCheck", false];
if (CBA_missionTime < _nextUpdateTime) exitWith {_cachedReturn};

// Go through player radios and check if one can reach the base
private _baseConnEstablished = false;
private _playerRadios = ([] call acre_sys_data_fnc_getPlayerRadioList) select {
	(toLower ([_x] call acre_sys_radio_fnc_getRadioBaseClassname)) in ["acre_prc77"]
};
private _waitForExt = false;

{
	private _radioId = _x;
	private _txAntenna = ([_radioId] call acre_sys_components_fnc_findAntenna) select 0;

	if (
		(_player distance2D baseAntennaObj) < 2000 || 
		{!(terrainIntersectASL [_txAntenna#2, getPosASL baseAntennaObj])}
	) then {
		// When LOS to the base's antenna is clear, just return true
		_baseConnEstablished = true;
	} else {
		// Check multipath signal model via extension
		_waitForExt = true;
		private _baseRadio = "BASE";
		private _baseAntenna = "ACRE_270CM_VEH_BNC";
		private _txData = [_radioId, "getCurrentChannelData"] call acre_sys_data_fnc_dataEvent;
		private _txFreq = _txData getVariable "frequencyTX";
		private _txPower = _txData getVariable "power";
		[
			"process_signal",
			[
				acre_sys_signal_signalModel,
				format ["%1_%2_%3_%4", _radioId, (_txAntenna select 0), _baseRadio, _baseAntenna],
				(_txAntenna select 2),
				(_txAntenna select 3),
				(_txAntenna select 0),
				((getPosASL baseAntennaObj) vectorAdd [0, 0, 2.5]),
				(vectorDir baseAntennaObj),
				(_baseAntenna),
				_txFreq,
				_txPower,
				acre_sys_signal_terrainScaling,
				diag_tickTime,
				ACRE_SIGNAL_DEBUGGING,
				acre_sys_signal_omnidirectionalRadios
			],
			2,
			{
				params ["_args", "_result"];
				_args params ["_unit"];
				_result params ["_id", "_signal"];
				//systemChat format ["%1 signal to base %2", _id, _signal];
				_unit setVariable ["nextBaseConnCheck", CBA_missionTime + 3];
				if (_signal > -70) then {
					_unit setVariable ["cachedBaseConnCheck", true];
				} else {
					_unit setVariable ["cachedBaseConnCheck", false];
				};
			},
			[_player]
		] call acre_sys_core_fnc_callExt;
	};

	// Only requires one functional radio connection
	if (_baseConnEstablished) then {
		break;
	};
} forEach _playerRadios;

if (!_baseConnEstablished && _waitForExt) then {
	_cachedReturn
} else {
	_player setVariable ["nextBaseConnCheck", CBA_missionTime + 3];
	_player setVariable ["cachedBaseConnCheck", _baseConnEstablished];
	_baseConnEstablished
};
