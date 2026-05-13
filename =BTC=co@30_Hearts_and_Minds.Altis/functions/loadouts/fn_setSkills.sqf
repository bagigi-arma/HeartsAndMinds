/*
 * Adds the selected skills to a unit
 *
 * Arguments:
 * 0: Unit to set skills for <OBJECT>
 * 1: Array of skills to set <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, ["eng", "eod"]] call TRN_fnc_setSkills
 */

params ["_unit", ["_skills", []]];

// Remove all skills
_unit setVariable ["ace_medical_medicClass", 0, true];
_unit setVariable ["ACE_IsEngineer", 0, true];
_unit setVariable ["ACE_isEOD", false, true];

// Re-Add only selected skills
{
	switch (_x) do {
		case "med": {
			_unit setVariable ["ace_medical_medicClass", 1, true];
		};
		case "doc": {
			_unit setVariable ["ace_medical_medicClass", 2, true];
		};
		case "eng": {
			_unit setVariable ["ACE_IsEngineer", 1, true];
		};
		case "eod": {
			_unit setVariable ["ACE_isEOD", true, true];
		};
	};
} forEach _skills;
