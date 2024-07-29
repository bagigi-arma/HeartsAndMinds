// Heal all units in proximity
params ["_target", "_caller", "_actionId", "_arguments"];

{
	["ace_medical_treatment_fullHealLocal", _x, _x] call CBA_fnc_targetEvent;
	_x setVariable ["kjw_imposters_core_susPoints", 0, true];
} forEach (_target nearEntities ["Man", 20]);
