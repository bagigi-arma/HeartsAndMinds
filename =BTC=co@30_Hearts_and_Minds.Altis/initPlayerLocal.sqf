// Set every player as interpreter, since they speak the same language as the local population
player setVariable ["interpreter", true];

// Set random Persian face
private _face = format ["PersianHead_A3_0%1", round ((random 3) + 1)];
//systemChat format ["assigned face: %1", _face];
player setFace _face;

player addEventHandler ["Respawn", {
	params ["_unit", "_corpse"];
	if (_unit isEqualTo player) then {
		private _face = format ["PersianHead_A3_0%1", round ((random 3) + 1)];
		[_unit, _face] remoteExec ["setFace", 0, true];
	};
}];

// Add nearby heal interaction on main Arsenal
btc_gear_object addAction ["<t color='#ff85ef'>Heal All within 20m</t>", "heal_nearby.sqf", [], 1];

// Add Vanilla interaction to Covert Arsenal, just like the mission does for the main Arsenal
covert_arsenal addAction ["<t color='#be00ee'>Arsenale Borghese</t>", "[covert_arsenal, player] call ace_arsenal_fnc_openBox;"];

// 3D Icons on important resource boxes
addMissionEventHandler ["Draw3D", {
	// Return early if far from all important objects (>30m)
	if (player distanceSqr btc_log_point > 900) exitWith {};

	{
		_x params ["_objName", "_drawnText", "_zOffset"];

		if (player distanceSqr _objName < 225) then {
			drawIcon3D ["a3\ui_f_enoch\data\common\rschorizontalcompass\compass_hq_ca.paa", [1,1,1,1], position _objName vectorAdd [0, 0, _zOffset], 1, 1, 0, _drawnText, 0, 0.05, "PuristaMedium", "center"];
		};
	} forEach [
		// [objName, drawnText, zOffset]
		[btc_gear_object, "Arsenale Primario", 2.3],
		[covert_arsenal, "Arsenale in-Borghese", 1.5],
		[base_water_tank, "Serbatoio d'Acqua", 2.8]
	];
}];
