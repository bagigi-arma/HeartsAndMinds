/*
 * Adds the ACE interactions to spawn patients with different treatment difficulty levels on the given pad
 *
 * Arguments:
 * 0: Interactable laptop/crate <OBJECT>
 * 1: Nearby Pad to place patient on <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [laptop_1, medical_pad_1] call TRN_fnc_addSpawnPatientActions
 */

params ["_laptop", "_pad"];

// Root action
private _action = ["medTrainingRoot", "Training Medical", "data\bagigi.paa", {}, {true}, {}, [_pad], [0, 0, 0.45]] call ace_interact_menu_fnc_createAction;
private _rootPath = [_laptop, 0, [], _action] call ace_interact_menu_fnc_addActionToObject;

// Action to clear up the pad, visible only if a patient is on it
_action = ["medTrainingClearPad", "Ripulisci pad", "", {
	(_this select 2) params ["_pad"];
	[_pad] spawn TRN_fnc_clearPad;
}, {
	(_this select 2) params ["_pad"];
	!isNull (_pad getVariable ["TRN_medTrainingPatient", objNull])
}, {}, [_pad]] call ace_interact_menu_fnc_createAction;
[_laptop, 0, _rootPath, _action] call ace_interact_menu_fnc_addActionToObject;

// Sub-Root Action to Spawn a new patient on the pad, visible only if the pad is clear
_action = ["medTrainingSpawnPatient", "Genera paziente", "", {}, {
	(_this select 2) params ["_pad"];
	isNull (_pad getVariable ["TRN_medTrainingPatient", objNull])
}, {}, [_pad]] call ace_interact_menu_fnc_createAction;
private _spawnRootPath = [_laptop, 0, _rootPath, _action] call ace_interact_menu_fnc_addActionToObject;

// Sub-Actions to spawn a patient with varying difficulty levels
{
	_x params ["_name", "_difficulty", "_message"];

	_action = [str _forEachIndex, _name, "", {
		params ["_target", "_player", "_args"];
		_args params ["_pad", "_difficulty", "_message"];
		["TRN_spawnPatient", _args] call CBA_fnc_serverEvent;
	}, {true}, {}, [_pad, _difficulty, _message]] call ace_interact_menu_fnc_createAction;
	[_laptop, 0, _spawnRootPath, _action] call ace_interact_menu_fnc_addActionToObject;
} forEach [
	["Facile (Soccorso Base)", "EASY", "Spawnato un ferito lieve, pienamente stabilizzabile da un Fante Regolare con nozioni di Soccorso."],
	["Medio (Soccorritore)", "MEDIUM", "Spawnato un ferito medio, stabilizzabile con il supporto di un Soccorritore Militare."],
	["Difficile (Medico)", "HARD", "Spawnato un ferito grave, stabilizzabile dall'intervento di un Medico."],
	["Assurdo (Medico di plotone)", "INSANE", "Spawnato un ferito gravissimo, salvabile solo con difficoltà da parte di un molteplici Medici molto ben equipaggiati."],
	["Casuale", "RANDOM", "Spawnato un ferito di categoria casuale, buona fortuna."],
	["Incolume", "NONE", "Spawnato una cavia incolume, fategli quello che volete."]
];
