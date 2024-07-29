// Function to determine whether a unit can contact the carrier for Simplex Support System requests
params ["_player", "_items", "_accessItems", "_supportEntity"];

private _nextUpdateTime = _player getVariable ["nextCarrierConnCheck", CBA_missionTime];
// Return cached value if the last update was less than 3s ago
private _cachedReturn = _player getVariable ["cachedCarrierConnCheck", false];
if (CBA_missionTime < _nextUpdateTime) exitWith {_cachedReturn};

// Go through player radios and check if one can reach the carrier
private _carrierConnEstablished = false;
private _playerRadios = ([] call acre_sys_data_fnc_getPlayerRadioList) select {
	(toLower ([_x] call acre_sys_radio_fnc_getRadioBaseClassname)) in ["acre_prc148", "acre_prc152", "acre_prc117f"]
};
private _waitForExt = false;

{
	private _radioId = _x;
	private _txAntenna = ([_radioId] call acre_sys_components_fnc_findAntenna) select 0;

	if ((_txAntenna#0) == "ACRE_RF3080_UHF_TNC") then {
		// Check for SATCOM connection
		_carrierConnEstablished = [_txAntenna#1] call acre_sys_signal_fnc_checkClearSkyLOS;
	} else {
		if (
			(_player distance2D carrierAntennaObj) < 2000 || 
			{!(terrainIntersectASL [_txAntenna#2, getPosASL carrierAntennaObj])}
		) then {
			// When LOS to the carrier's antenna is clear, just return true
			_carrierConnEstablished = true;
		} else {
			// Check multipath signal model via extension
			_waitForExt = true;
			private _carrierRadio = "ATLAS";
			private _carrierAntenna = "ACRE_270CM_VEH_BNC";
			private _txData = [_radioId, "getCurrentChannelData"] call acre_sys_data_fnc_dataEvent;
			private _txFreq = _txData getVariable "frequencyTX";
			private _txPower = _txData getVariable "power";
			[
				"process_signal",
				[
					acre_sys_signal_signalModel,
					format ["%1_%2_%3_%4", _radioId, (_txAntenna select 0), _carrierRadio, _carrierAntenna],
					(_txAntenna select 2),
					(_txAntenna select 3),
					(_txAntenna select 0),
					((getPosASL carrierAntennaObj) vectorAdd [0, 0, 2.5]),
					(vectorDir carrierAntennaObj),
					(_carrierAntenna),
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
					//systemChat format ["%1 signal to carrier %2", _id, _signal];
					_unit setVariable ["nextCarrierConnCheck", CBA_missionTime + 3];
					if (_signal > -70) then {
						_unit setVariable ["cachedCarrierConnCheck", true];
					} else {
						_unit setVariable ["cachedCarrierConnCheck", false];
					};
				},
				[_player]
			] call acre_sys_core_fnc_callExt;
		};
	};

	// Only requires one functional radio connection
	if (_carrierConnEstablished) then {
		break;
	};
} forEach _playerRadios;

if (!_carrierConnEstablished && _waitForExt) then {
	_cachedReturn
} else {
	_player setVariable ["nextCarrierConnCheck", CBA_missionTime + 3];
	_player setVariable ["cachedCarrierConnCheck", _carrierConnEstablished];
	_carrierConnEstablished
};
