// Set every player as interpreter, since they speak the same language as the local population
player setVariable ["interpreter", true];

// Set random greek face
private _face = format ["GreekHead_A3_0%1", round ((random 9) + 1)];
//systemChat format ["assigned face: %1", _face];
player setFace _face;
