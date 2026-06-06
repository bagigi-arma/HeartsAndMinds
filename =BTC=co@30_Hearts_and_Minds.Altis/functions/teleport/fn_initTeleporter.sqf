/*
 * Initializes the teleportation system by defining the locations one can teleport to
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 */

if (!isServer) exitWith {};

// Manual allocation of teleportable locations, using varnames of map markers
TRN_teleports = [
	"flag_atlas",
	"flag_fort_kleemann"
];
publicVariable "TRN_teleports";
