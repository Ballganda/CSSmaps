#include <sourcemod>
#include <sdktools>

//insert semicolon after every statement
#pragma semicolon 1

//Enforce the new syntax in sourcemod 1.7+
#pragma newdecls required

public Plugin myinfo = {
	name = "Admin Give entities to players | Weapons & Items",
	author = "Kiske, Kento, BallGanda",
	description = "Give a weapon or item to a player from a command",
	version = "1.1.b6",
	url = "http://www.sourcemod.net/"
};

// Registers the "sm_give" admin command with the specified parameters
public void OnPluginStart()
{
	RegAdminCmd("sm_give", smGive, ADMFLAG_BAN, "<name|#userid> <entityname>");
}

// Declare a global char array named "g_entity"
// Initialize the array with a list of strings representing different entity names in the game
// want to figure out how to store entity name, offset, amount
char g_entity[][] = {
	"item_cutters", //csgo
	"item_defuser",
	"item_exosuit", //csgo
	"item_assaultsuit",
	"item_heavyassaultsuit", //csgo
	"item_kevlar",
	"item_nvgs",
	"weapon_ak47", //ammodata 2,90
	"weapon_aug", //ammodata 2,90
	"weapon_awp", //ammodata 5,30
	"weapon_axe", //csgo
	"weapon_c4",
	"weapon_bizon", //csgo
	"weapon_breachcharge", //csgo
	"weapon_bumpmine", //csgo
	"weapon_cz75a", //csgo
	"weapon_deagle", //ammodata 1,35
	"weapon_decoy", //csgo
	"weapon_elite", //ammodata 6,120
	"weapon_famas", //ammodata 3,90
	"weapon_fists", //csgo
	"weapon_fiveseven", //ammodata 10,100
	"weapon_flashbang", //ammodata 12,1
	"weapon_g3sg1", //ammodata 2,90
	"weapon_galil", //ammodata 3,90
	"weapon_galilar", //csgo
	"weapon_glock", //ammodata 6,120
	"weapon_hammer",//csgo
	"weapon_healthshot", //csgo
	"weapon_hegrenade", //ammodata 11,1
	"weapon_hkp2000", //csgo
	"weapon_incgrenade", //csgo
	"weapon_knife",
	"weapon_knifegg", //csgo
	"weapon_m249", //ammodata 4,200
	"weapon_m3", //ammodata 7,32
	"weapon_m4a1", //ammodata 3,90
	"weapon_m4a1_silencer", //csgo
	"weapon_mac10", //ammodata 8,100
	"weapon_mag7", //csgo
	"weapon_molotov", //csgo
	"weapon_mp5navy", //ammodata 6,120
	"weapon_mp5sd", //csgo
	"weapon_mp7", //csgo
	"weapon_mp9", //csgo
	"weapon_negev", //csgo
	"weapon_nova", //csgo
	"weapon_p228", //ammodata 9,52
	"weapon_p250", //csgo
	"weapon_p90", //ammodata 10,100
	"weapon_revolver", //csgo
	"weapon_sawedoff", //csgo
	"weapon_scar20", //csgo
	"weapon_scout", //ammodata 2,90
	"weapon_sg550", //ammodata 3,90
	"weapon_sg552", //ammodata 3,90
	"weapon_sg556", //csgo
	"weapon_shield", //csgo
	"weapon_smokegrenade", //ammodata 13,1
	"weapon_spanner", //csgo
	"weapon_ssg08", //csgo
	"weapon_tagrenade", //csgo
	"weapon_taser", //csgo
	"weapon_tec9", //csgo
	"weapon_tmp", //ammodata 6,120
	"weapon_ump45", //ammodata 8,100
	"weapon_usp", //ammodata 8,100
	"weapon_usp_silencer", //csgo
	"weapon_xm1014" //ammodata 7,32
};

//Get the size of the weapon/item array
int max_entity = sizeof(g_entity);

// Handles the "sm_give" admin command
public Action smGive(int client, int args) {
	// Argument check and handling
	// If there are fewer than 2 arguments, check if the first argument is "list"
	// If it is, call the smGiveList function with the client as the argument
	// If it is not, print the usage message to the client
	if(args < 2) {
		char sArg[4];
		GetCmdArg(1, sArg, sizeof(sArg));
		if(StrEqual(sArg, "list", false)) {
			smGiveList(client);
		} else {
			ReplyToCommand(client, "[SM] Usage: sm_give <name|#userid> <entityname>");
			ReplyToCommand(client, "[SM] Usage: sm_give list |for %i entity list", max_entity);
		}
		return Plugin_Handled;
	}
	
	// Declare and initialize variables for storing command arguments, the entity name, and whether the entity name is valid
	char sArg[255];
	char sTargetArg[32];
	char sEntityName[32], sEntityToGive[32];
	int iLengthArg1;
	int iLengthArg2;
	
	// Get the full string of command arguments and split it into two parts using BreakString
	GetCmdArgString(sArg, sizeof(sArg));
	iLengthArg1 = BreakString(sArg, sTargetArg, sizeof(sTargetArg));
	
	// Split the second part of the string out into sEntityName
	// Start the breaksrtring of sArg at the index of length arg 1 
	if((iLengthArg2 = BreakString(sArg[iLengthArg1], sEntityName, sizeof(sEntityName))) != -1) {
		iLengthArg1 += iLengthArg2;
	}
	
	//Create a vaiable to store whether the given entity name was found in the list of avialable entities
	//initialize with iValid(input valid) false
	bool iValid = false;
	
    //Step through g_entity array  
	for(int i = 0; i < max_entity; ++i) {
		// Check if the entity name is contained in the g_entity array
		if(StrContains(g_entity[i], sEntityName) != -1) {
			//Set valid variable to true because it was found in g_entity
			iValid = true;
			// Copy the matching entity name to sEntityToGive
			strcopy(sEntityToGive, sizeof(sEntityToGive), g_entity[i]);
			// Break out of the for loop now once entity matched
			break;
		}
	}
	
	// Error handle for when the input did not find a valid match
	if(!iValid) {
		ReplyToCommand(client, "[SM] The entity name (%s) isn't valid", sEntityName);
		ReplyToCommand(client, "[SM] sm_give list | for entity list");
		return Plugin_Handled;
	}
	
	
	// Declare a char array to store the target name and an int array to store a list of target indices.
	char sTargetName[MAX_TARGET_LENGTH];
	int sTargetList[MAXPLAYERS], iTargetCount;
	// Declare a boolean to store whether the target name is a multiple-letter abbreviation.
	bool bTN_IsML;
	
	// Process the target string and store the result in the target list and target name variables.
	// the result is the count of matching targets to the supplied target argument input
	iTargetCount = ProcessTargetString(sTargetArg, client, sTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE, sTargetName, sizeof(sTargetName), bTN_IsML);
	
	//the function returns a target count value less than or equal to 0, it indicates an error.
	if(iTargetCount <= 0) {
		ReplyToTargetError(client, iTargetCount);
		return Plugin_Handled;
	}
	
	//This is the actual giving of weapons to the members of the target list
	for (int i = 0; i < iTargetCount; i++) {
		GivePlayerItem(sTargetList[i], sEntityToGive);
	}
	
	return Plugin_Handled;
}

//Function to handle the arg that requests viewing the entity list
void smGiveList(int client) {
	ReplyToCommand(client, "");
	for(int i = 0; i < max_entity; ++i) {
		ReplyToCommand(client, "%s", g_entity[i]);
	}
	ReplyToCommand(client, "*No need to put weapon_/item_ in the <entityname>*");
	ReplyToCommand(client, "*Partials work if not overlapping other entity name*");
}
