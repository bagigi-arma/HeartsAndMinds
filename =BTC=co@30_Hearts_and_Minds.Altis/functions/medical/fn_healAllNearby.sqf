/*
 * Fully heals all units within the given area
 *
 * Arguments:
 * 0: Position AGL around which to heal entities <ARRAY>
 * 1: Radius within which to heal entities <NUMBER>
 * 2: Whether to heal Players and/or AI within radius (0: both, 1: only AI, 2: only players) <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [position player, 20] call TRN_fnc_healAllNearby
 */

params ["_pos", "_radius", ["_includeAI", 0]];

{
	if (
		_includeAI == 0 || {
			private _isPlayer = isPlayer _x;
			(_includeAI == 1 && !_isPlayer) || (_includeAI == 2 && _isPlayer)
		}
	) then {
		["ace_medical_treatment_fullHealLocal", _x, _x] call CBA_fnc_targetEvent;
	};
} forEach (_pos nearEntities ["CAManBase", _radius]);
