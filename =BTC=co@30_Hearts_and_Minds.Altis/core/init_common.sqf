// Event handler to remove Holographic Sights from M2 HMGs assembled via Ace CSW interactions by BLUFOR
addMissionEventHandler ["EntityCreated", {
	params ["_entity"];

	if (typeOf _entity != "B_HMG_02_F") exitWith {};

	[_entity, false, ["Hide_Rail", 1, "Hide_Shield", 1]] call BIS_fnc_initVehicle;
}];
