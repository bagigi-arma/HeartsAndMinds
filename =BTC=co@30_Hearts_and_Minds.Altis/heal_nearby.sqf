// Heal all units in proximity
params ["_target", "_caller", "_actionId", "_arguments"];

{
	["ace_medical_treatment_fullHealLocal", _x, _x] call CBA_fnc_targetEvent;
} forEach (_target nearEntities ["Man", 50]);
