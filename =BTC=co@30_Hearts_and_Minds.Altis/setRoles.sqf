// Function to set ACE Roles and H&M Translator role
params [["_role", ""]];

// Remove all roles
player setVariable ["ace_medical_medicClass", 0, true];
player setVariable ["ACE_IsEngineer", 0, true];
player setVariable ["ACE_isEOD", false, true];

player setVariable ["interpreter", false, true];

// Add only selected roles
switch (_role) do {
	case "med": {
		player setVariable ["ace_medical_medicClass", 1, true];
	};
	case "doc": {
		player setVariable ["ace_medical_medicClass", 2, true];
	};
	case "eng": {
		player setVariable ["ACE_IsEngineer", 1, true];
		player setVariable ["ACE_isEOD", true, true];
	};
	case "tran": {
		player setVariable ["interpreter", true, true];
	};
};
