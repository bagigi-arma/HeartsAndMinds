/*
 * Spawns a medical training subject on the given pad, depending on the set difficulty, different injury scenarios can be simulated
 *
 * Arguments:
 * 0: Pad of the medical training area <OBJECT>
 * 1: Difficulty level <STRING>
 * 2: Notification text displayed to nearby players <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [pad1, "EASY"] spawn TRN_fnc_spawnPatient
 */

params ["_pad", ["_difficulty", "NONE"], ["_message", ""]];

private _padPos = getPosATL _pad;

// Spawn patient
private _group = createGroup blufor;
_group deleteGroupWhenEmpty true;
private _patient = _group createUnit ["rhsusf_army_ocp_rifleman_m16", _padPos, [], 0, "CAN_COLLIDE"];
_patient setDir (getDir _pad);
removeVest _patient; // Remove vest
removeAllWeapons _patient; // Remove all weapons and magazines
_pad setVariable ["TRN_medTrainingPatient", _patient, true]; // Mark pad as used
["ace_captives_setHandcuffed", [_patient, true], _patient] call CBA_fnc_targetEvent; // Handcuff patient
_patient setVariable ["kat_misc_PreventInstantAIDeath", true, true]; // Disable lethal damage
_patient setVariable ["kat_vitals_simpleMedical", false, true]; // Prevent simplification of vitals

// Random (weighted) blood type
private _bloodType = selectRandomWeighted ["A", 0.3, "A_N", 0.08, "B", 0.09, "B_N", 0.02, "AB", 0.02, "AB_N", 0.01, "O", 0.35, "O_N", 0.13];
_patient setVariable ["kat_circulation_bloodtype", _bloodType, true];

// Notify proximity players of the spawned patient
if (_message != "") then {
	private _nearPlayers = (_padPos nearEntities ["CAManBase", 8]) select {isPlayer _x};
	["TRN_Notify", _message, _nearPlayers] call CBA_fnc_targetEvent;
};

// Exit early if set for no injuries, allowing instructors to deal damage themselves
if (_difficulty == "NONE") exitWith {};

// Define injury shortcut functions
private _fnc_setWounds = {
	// Applies an amount of ACE Medical wounds on the patient, depending on the specified severity
	// Valid selections: ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"]
	// Valid projectile types: ["bullet", "shell", "explosive"]
	params ["_patient", "_type"];
	switch (_type) do {
		case "LIGHT": { // Small-caliber hits to head or light fragmentation damage
			if (random 1 < 0.7) then { // Shots
				[_patient, random [0, 0.8, 1], selectRandom ["Head", "Body"], "bullet"] call ace_medical_fnc_addDamageToUnit;
			} else { // Frag
				{
					[_patient, random [1, 2, 4], _x, "explosive"] call ace_medical_fnc_addDamageToUnit;
				} forEach ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"];
			};
		};
		case "MEDIUM": { // Few high-caliber hits to head, torso and limbs
			[_patient, random [3, 5, 7], "Head", "bullet"] call ace_medical_fnc_addDamageToUnit;
			[_patient, random [3, 5, 7], "Body", "bullet"] call ace_medical_fnc_addDamageToUnit;
			[_patient, random [3, 5, 7], selectRandom ["LeftArm", "RightArm", "LeftLeg", "RightLeg"], "bullet"] call ace_medical_fnc_addDamageToUnit;
			[_patient, random [3, 5, 7], selectRandom ["LeftArm", "RightArm", "LeftLeg", "RightLeg"], "bullet"] call ace_medical_fnc_addDamageToUnit;
		};
		case "SEVERE": { // Multiple high-caliber hits
			[_patient, random [4, 7, 10], "Head", "bullet"] call ace_medical_fnc_addDamageToUnit;
			[_patient, random [4, 7, 10], "Body", "bullet"] call ace_medical_fnc_addDamageToUnit;
			[_patient, random [4, 7, 10], selectRandom ["LeftArm", "RightArm", "LeftLeg", "RightLeg"], "bullet"] call ace_medical_fnc_addDamageToUnit;
			[_patient, random [4, 7, 10], selectRandom ["LeftArm", "RightArm", "LeftLeg", "RightLeg"], "bullet"] call ace_medical_fnc_addDamageToUnit;
		};
		case "INSANE": { // Proximity IED detonation, entire body dark orange or red
			[_patient, random [6, 14, 20], "Head", "explosive"] call ace_medical_fnc_addDamageToUnit;
			[_patient, random [4, 8, 18], "Body", "explosive"] call ace_medical_fnc_addDamageToUnit;
			[_patient, random [4, 8, 18], "Body", "explosive"] call ace_medical_fnc_addDamageToUnit;
			{
				[_patient, random [6, 10, 14], _x, "explosive"] call ace_medical_fnc_addDamageToUnit;
			} forEach ["LeftArm", "RightArm", "LeftLeg", "RightLeg"];
		};
	};
};
private _fnc_addFractures = {
	params ["_patient", ["_number", 1]];
	// Adds fractures to limbs which are injured
	//private _limbNames = ["LeftArm", "RightArm", "LeftLeg", "RightLeg"];
	private _limbDamages = _patient getVariable ["ace_medical_bodyPartDamage", [0, 0, 0, 0, 0, 0]];
	private _fractures = _patient getVariable ["ace_medical_fractures", [0, 0, 0, 0, 0, 0]];
	private _i = 0;
	while {_number > 0 && {_i <= 4}} do {
		private _limbIndex = floor (random 4) + 2;
		if (_limbDamages select _limbIndex > 0.5) then {
			_fractures set [_limbIndex, 1];
			_number = _number - 1;
		};
		_i = _i + 1;
	};
	_patient setVariable ["ace_medical_fractures", _fractures, true];
};
private _fnc_setCardiacState = {
	// Applies the specified KAM Rythm and arrest timeout to the patient
	params ["_patient", "_rythm", "_seconds"];
	private _rythmType = if (_rythm isEqualType 0) then {_rythm} else {
		switch (_rythm) do {
			case "STABLE": {0};
			case "VTAC": {4};
			case "VFIB": {3};
			case "PEA": {2};
			case "ASYST": {1};
			default {0};
		};
	};
	_patient setVariable ["kat_circulation_cardiacArrestType", _rythmType, true];
	if (_rythmType > 0) then {
		_patient setVariable ["ace_medical_statemachine_cardiacArrestTimeLeft", (ace_medical_statemachine_cardiacArrestTime - _seconds), true];
		["ace_medical_FatalVitals", [_patient], _patient] call CBA_fnc_targetEvent;
	} else {
		["ace_medical_CPRSucceeded", [_patient], _patient] call CBA_fnc_targetEvent;
	};
};
private _fnc_setBloodVolume = {
	// Applies the blood volume to the patient as if having bled for given time, based on previously applied wounds and cardiac state
	params ["_patient", "_seconds"];
	private _volumeReduction = ([_patient] call ace_medical_status_fnc_getBloodLoss) * 1000 * _seconds;
	if (_volumeReduction < 950) then {
		// if volume reduction is low, increase it just enough to make "lost a lot of blood" more likely
		_volumeReduction = _volumeReduction * 1.5;
	};
	private _bodyFluid = _patient getVariable ["kat_circulation_bodyFluid", [2700, 3300, 500, 10000, 6000]];
	_bodyFluid set [0, (_bodyFluid select 0) - (_volumeReduction / 2)];
	_bodyFluid set [1, (_bodyFluid select 1) - (_volumeReduction / 2)];
	_bodyFluid set [4, (_bodyFluid select 4) - _volumeReduction];
	_patient setVariable ["kat_circulation_bodyFluid", _bodyFluid, true];
};
private _fnc_setAirwayState = {
	// Applies the given airway states
	params ["_patient", "_obstruction", "_occlusion"];
	_patient setVariable ["kat_airway_obstruction", _obstruction, true];
	_patient setVariable ["kat_airway_occluded", _occlusion, true];
};
private _fnc_setLungState = {
	// Applies the given lung state, aka pneumothorax conditions
	params ["_patient", "_pneumoType"];
	if ( // Avoid adding a Pneumo without chest damage being present
		_pneumoType != "NONE" && 
		{(_patient getVariable ["ace_medical_bodyPartDamage", [0, 0, 0, 0, 0, 0]]) select 1 < 0.5}
	) then {
		[_patient, random [0, 0.8, 1], "Body", "bullet"] call ace_medical_fnc_addDamageToUnit;
	};
	switch (_pneumoType) do {
		case "NONE": {
			_patient setVariable ["kat_breathing_pneumothorax", 0, true];
			_patient setVariable ["kat_breathing_tensionpneumothorax", false, true];
			_patient setVariable ["kat_breathing_hemopneumothorax", false, true];
		};
		case "PNEUMO": {
			_patient setVariable ["kat_breathing_pneumothorax", 1, true];
			[_patient, 0.125] call ace_medical_status_fnc_adjustPainLevel;
			[_patient, -12, -12, "ptx_tension", true] call kat_circulation_fnc_updateBloodPressureChange;
		};
		case "TENSION": {
			_patient setVariable ["kat_breathing_pneumothorax", 4, true];
			_patient setVariable ["kat_breathing_tensionpneumothorax", true, true];
			[_patient, 0.5] call ace_medical_status_fnc_adjustPainLevel;
			[_patient, -48, -48, "ptx_tension", true] call kat_circulation_fnc_updateBloodPressureChange;
		};
		case "HEMO": {
			_patient setVariable ["kat_breathing_pneumothorax", 4, true];
			_patient setVariable ["kat_breathing_hemopneumothorax", true, true];
			[_patient, 0.5] call ace_medical_status_fnc_adjustPainLevel;
			[_patient, -48, -48, "ptx_tension", true] call kat_circulation_fnc_updateBloodPressureChange;
			[_patient] call kat_circulation_fnc_updateInternalBleeding;
		};
	};
};
private _fnc_setOxygenation = {
	// Applies the given SpO2 level
	params ["_patient", "_spO2"];
	private _bloodGas = _patient getVariable ["kat_circulation_bloodGas", [40, 90, 0.96, 24, 7.4, 37]];
	private _paO2 = (25 * (_spO2 / (100 - _spO2)) ^ (1 / 2.7)) min 100; // Simplified and reversed paO2>spO2 function
	_bloodGas set [1, _paO2];
	_patient setVariable ["kat_circulation_bloodGas", _bloodGas, true];
};

// Randomize difficulty if set
if (_difficulty == "RANDOM") then {
	_difficulty = ["EASY", "MEDIUM", "HARD", "INSANE"] select ((floor random [0, 2, 4]) min 4);
};

// Set injuries according to difficulty
switch (_difficulty) do {
	case "EASY": {
		private _secondsDowned = random [30, 80, 120];
		[_patient, "LIGHT"] call _fnc_setWounds;
		[_patient, 1] call _fnc_addFractures;
		[_patient, round (random [1, 3.5, 4]), _secondsDowned] call _fnc_setCardiacState;
		[_patient, _secondsDowned] call _fnc_setBloodVolume;
		[_patient, selectRandom [false, true], true] call _fnc_setAirwayState;
		[_patient, selectRandom ["NONE", "PNEUMO"]] call _fnc_setLungState;
		[_patient, 92] call _fnc_setOxygenation;
	};
	case "MEDIUM": {
		private _secondsDowned = random [40, 90, 120];
		[_patient, selectRandom ["LIGHT", "MEDIUM"]] call _fnc_setWounds;
		[_patient, 2] call _fnc_addFractures;
		[_patient, round (random [1, 3, 4]), _secondsDowned] call _fnc_setCardiacState;
		[_patient, _secondsDowned] call _fnc_setBloodVolume;
		[_patient, selectRandom [false, true], true] call _fnc_setAirwayState;
		[_patient, selectRandom ["PNEUMO", "TENSION", "HEMO"]] call _fnc_setLungState;
		[_patient, 94] call _fnc_setOxygenation;
	};
	case "HARD": {
		private _secondsDowned = random [20, 40, 60];
		[_patient, selectRandom ["LIGHT", "MEDIUM"]] call _fnc_setWounds;
		[_patient, 2] call _fnc_addFractures;
		[_patient, round (random [1, 2, 4]), _secondsDowned] call _fnc_setCardiacState;
		[_patient, _secondsDowned] call _fnc_setBloodVolume;
		[_patient, true, true] call _fnc_setAirwayState;
		[_patient, selectRandom ["PNEUMO", "TENSION", "HEMO"]] call _fnc_setLungState;
		[_patient, 94] call _fnc_setOxygenation;
	};
	case "INSANE": {
		private _secondsDowned = random [10, 20, 40];
		[_patient, "INSANE"] call _fnc_setWounds;
		[_patient, 3] call _fnc_addFractures;
		[_patient, round (random [1, 2, 4]), _secondsDowned] call _fnc_setCardiacState;
		[_patient, _secondsDowned] call _fnc_setBloodVolume;
		[_patient, true, true] call _fnc_setAirwayState;
		[_patient, selectRandom ["PNEUMO", "TENSION", "HEMO"]] call _fnc_setLungState;
		[_patient, 95] call _fnc_setOxygenation;
	};
};
