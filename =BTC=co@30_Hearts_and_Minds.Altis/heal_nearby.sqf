// Heal all units in proximity
params ["_target", "_caller", "_actionId", "_arguments"];

{
	[_x] call ace_medical_treatment_fnc_fullHealLocal;
} forEach (_target nearEntities ["Man", 20]);
