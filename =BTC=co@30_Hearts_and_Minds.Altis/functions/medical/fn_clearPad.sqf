/*
 * Clears a medical training pad from the spawned patient and any bloodspatters or medical litter
 *
 * Arguments:
 * 0: Pad of the medical training area <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [pad1] spawn TRN_fnc_clearPad
 */
#define PAD_LITTER_RADIUS_SQR 9

params ["_pad"];

// Delete patient
private _patient = _pad getVariable ["TRN_medTrainingPatient", objNull];
if (!isNull _patient) then {
	deleteVehicle _patient;
	_pad setVariable ["TRN_medTrainingPatient", objNull, true];
};

// Delete medical litter and blood in pad proximity
private _litter = (allSimpleObjects []) select {
	private _name = getModelInfo _x select 0;
	["ace_drop", "littergeneric"] findIf {_x in _name} != -1
};
{
	if (_x distanceSqr _pad < PAD_LITTER_RADIUS_SQR) then {
		deleteVehicle _x;
	};
} forEach _litter;
