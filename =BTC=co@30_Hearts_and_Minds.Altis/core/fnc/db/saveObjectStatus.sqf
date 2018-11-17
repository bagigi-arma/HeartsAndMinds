
/* ----------------------------------------------------------------------------
Function: btc_fnc_db_saveObjectStatus

Description:
    Fill me when you edit me !

Parameters:
    _object - [Object]

Returns:

Examples:
    (begin example)
        _result = [] call btc_fnc_db_saveObjectStatus;
    (end)

Author:
    Vdauphin

---------------------------------------------------------------------------- */

params [
    ["_object", objNull, [objNull]]
];

private _data = [];

if !(!alive _object || isNull _object) then {

    _data pushBack (typeOf _object);
    _data pushBack (getPosWorld _object);
    _data pushBack (getDir _object);
    _data pushBack (_object getVariable ["ace_rearm_magazineClass", ""]);
    //Cargo
    private _cargo = (_object getVariable ["ace_cargo_loaded", []]) apply {
        [typeOf _x, _x getVariable ["ace_rearm_magazineClass", ""], [getWeaponCargo _x, getMagazineCargo _x, getItemCargo _x]]
    };
    _data pushBack _cargo;
    //Inventory
    private _cont = [getWeaponCargo _object, getMagazineCargo _object, getItemCargo _object];
    _data pushBack _cont;
    _data pushBack [vectorDir _object, vectorUp _object];
};

_data
