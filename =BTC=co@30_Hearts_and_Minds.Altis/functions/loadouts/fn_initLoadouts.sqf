/*
 * Executed on the server at mission start, it compiles the 3DEN-defined ACE Default Loadouts into a nested array, which will be used to generate ACE Interactions on Arsenal boxes, divided into categories containing loadouts and respective roles.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 */

if (!isServer) exitWith {};

// Maps loadouts to a Hashmap for easier reference, but WITHOUT skill info
private _loadoutsHashMap = createHashMap;

{
	_x params ["_name", "_loadout"];

	private _roles = [];

	_loadoutsHashMap set [_name, [_loadout select 0, _roles]];
} forEach ace_arsenal_defaultLoadoutsList;

// Manual allocation of loadout categories and skills, in the format: ["category", ["name", loadout, skills]]
private _loadouts = [
	[
		"Kommando Spezialkräfte Marine", [
			["(KSM) Gruppenführer", [], []],
			["(KSM) Truppenführer", [], []],
			["(KSM) Recondrohnenbediener", [], []],
			["(KSM) Scharfschütze", [], []],
			["(KSM) Leichtermaschinengewehrschütze", [], []],
			["(KSM) Obersanitätsoffizier HK33", [], ["doc"]],
			["(KSM) Obersanitätsoffizier MP5", [], ["doc"]],
			["(KSM) Pioner HK33", [], ["eod", "eng"]],
			["(KSM) Pioner MP5", [], ["eod", "eng"]],
			["(KSM) Panzerfaustschütze", [], []],
			["(KSM) Schütze", [], []]
		]
	],
	[
		"Bundeswehr", [
			["Kompanieführer", [], []],
			["Zugführer", [], []],
			["JTAC", [], []],
			["Zugsanitätsoffizier", [], ["doc"]],
			["Gruppenführer", [], []],
			["Drohnenbediener", [], []],
			["Sanitätsoffizier", [], ["doc"]],
			["Truppenführer", [], []],
			["Funker", [], []],
			["Oberschütze", [], []],
			["Panzerfaustschütze", [], []],
			["Scharfschütze", [], []],
			["Panzerabwehrspezialist", [], []],
			["Panzerabwehrspezialisthalfe", [], []],
			["Maschinengewehrschütze", [], []],
			["Maschinengewehrschützehalfe", [], []],
			["Pioner", [], ["eod", "eng"]],
			["Granatschütze", [], []],
			["Krankenträger", [], ["med"]],
			["Schütze G3", [], []],
			["Schütze G36", [], []],
			["Wehrpflichtiger", [], []]
		]
	],
	[
		"Crew - veicolo", [
			["Panzerkommandant", [], ["eng"]],
			["Besatzungsmitglied", [], ["eng"]]
		]
	],
	[
		"Crew - velivolo", [
			["Hubschrauberpilot", [], ["eng"]]
		]
	]
];

{ // iterate through all loadouts and link the respective loadout from the hashmap
	{
		private _name = _x select 0;
		private _loadout = (_loadoutsHashMap get _name) select 0;
		_x set [1, _loadout];
	} forEach (_x select 1);
} forEach _loadouts;

// Make compiled loadouts global and public
TRN_loadoutsHashMap = _loadoutsHashMap;
publicVariable "TRN_loadoutsHashMap";

TRN_loadouts = _loadouts;
publicVariable "TRN_loadouts";
