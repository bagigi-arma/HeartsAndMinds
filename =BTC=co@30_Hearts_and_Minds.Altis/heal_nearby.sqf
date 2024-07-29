// Heal all units in proximity
params ["_target", "_caller", "_actionId", "_arguments"];

{
	[_x] call ace_medical_treatment_fnc_fullHealLocal;
	_x setVariable ["kjw_imposters_core_susPoints", 0, true];
} forEach (_target nearEntities ["Man", 20]);
