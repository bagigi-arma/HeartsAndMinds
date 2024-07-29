params ["_vehicle"];

if (isServer) then {
	private _allowedPositions = switch (typeOf _vehicle) do {
		case "LOP_TKA_UAZ": { ["driver", ["cargo",0,1,3,4]] };
		case "LOP_TKA_UAZ_Open": { ["driver", ["cargo",4]] };
		case "LOP_TKA_UAZ_DshKM": { ["driver"] };

		case "UK3CB_TKC_C_Hilux_Civ_Closed";
		case "UK3CB_TKA_I_Hilux_Closed": { ["driver", ["cargo",0,1,2]] };

		case "UK3CB_TKA_O_Ural_Repair";
		case "UK3CB_TKA_O_Ural_Fuel";
		case "UK3CB_TKA_O_Ural_Ammo";
		case "LOP_TKA_Ural_open";
		case "LOP_TKA_Ural": { ["driver", ["cargo",0,1]] };

		case "UK3CB_TKC_C_V3S_Closed";
		case "UK3CB_TKC_C_V3S_Open": { ["driver", ["cargo",0]] };

		default { ["inside"] };
	};

	[_vehicle, ["ACRE_VRC64", "Dash", "Dash", false, _allowedPositions, [], "ACRE_PRC77", [], [""]], true] call acre_api_fnc_addRackToVehicle;
};
