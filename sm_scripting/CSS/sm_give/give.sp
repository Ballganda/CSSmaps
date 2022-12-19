#include <sourcemod>
#include <sdktools>

#pragma semicolon 1

#pragma newdecls required

#define MAX_ENTITY 69

public Plugin myinfo = {
	name = "Admin Give entities to players | Weapons & Items",
	author = "Kiske, Kento, BallGanda",
	description = "Give a weapon or item to a player from a command",
	version = "1.1.b4",
	url = "http://www.sourcemod.net/"
};

char g_entity[MAX_ENTITY][] = {
	"item_cutters", //csgo
	"item_defuser",
	"item_exosuit", //csgo
	"item_assaultsuit",
	"item_heavyassaultsuit", //csgo
	"item_kevlar",
	"item_nvgs",
	"weapon_ak47",
	"weapon_aug",
	"weapon_awp",
	"weapon_axe", //csgo
	"weapon_c4",
	"weapon_bizon", //csgo
	"weapon_breachcharge", //csgo
	"weapon_bumpmine", //csgo
	"weapon_cz75a", //csgo
	"weapon_deagle",
	"weapon_decoy", //csgo
	"weapon_elite",
	"weapon_famas",
	"weapon_fists", //csgo
	"weapon_fiveseven",
	"weapon_flashbang",
	"weapon_g3sg1",
	"weapon_galil",
	"weapon_galilar", //csgo
	"weapon_glock",
	"weapon_hammer",//csgo
	"weapon_healthshot", //csgo
	"weapon_hegrenade",
	"weapon_hkp2000", //csgo
	"weapon_incgrenade", //csgo
	"weapon_knife",
	"weapon_knifegg", //csgo
	"weapon_m249",
	"weapon_m3",
	"weapon_m4a1",
	"weapon_m4a1_silencer", //csgo
	"weapon_mac10",
	"weapon_mag7", //csgo
	"weapon_molotov", //csgo
	"weapon_mp5navy",
	"weapon_mp5sd", //csgo
	"weapon_mp7", //csgo
	"weapon_mp9", //csgo
	"weapon_negev", //csgo
	"weapon_nova", //csgo
	"weapon_p228",
	"weapon_p250", //csgo
	"weapon_p90",
	"weapon_revolver", //csgo
	"weapon_sawedoff", //csgo
	"weapon_scar20", //csgo
	"weapon_scout",
	"weapon_sg550",
	"weapon_sg552",
	"weapon_sg556", //csgo
	"weapon_shield", //csgo
	"weapon_smokegrenade",
	"weapon_spanner", //csgo
	"weapon_ssg08", //csgo
	"weapon_tagrenade", //csgo
	"weapon_taser", //csgo
	"weapon_tec9", //csgo
	"weapon_tmp",
	"weapon_ump45",
	"weapon_usp",
	"weapon_usp_silencer", //csgo
	"weapon_xm1014"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_give", smGive, ADMFLAG_BAN, "- <target> <entityname>");
}

public Action smGive(int client, int args) {
	if(args < 2) {
		char temp[16];
		GetCmdArg(1, temp, sizeof(temp));
		if(StrEqual(temp, "list", false)) {
			smGiveList(client);
		} else {
			ReplyToCommand(client, "[SM] Usage: sm_give <name | #userid> <entityname>");
			ReplyToCommand(client, "[SM] Usage: sm_give list | for entity list");
		}
		return Plugin_Handled;
	}
	
	char sArg[256];
	char sTempArg[32];
	char sEntityName[32], sEntityToGive[32];
	int iL;
	int iNL;
	
	GetCmdArgString(sArg, sizeof(sArg));
	iL = BreakString(sArg, sTempArg, sizeof(sTempArg));
	
	if((iNL = BreakString(sArg[iL], sEntityName, sizeof(sEntityName))) != -1)
		iL += iNL;
	
	int iValid = 0;
	
	for(int i = 0; i < MAX_ENTITY; ++i)
	{
		if(StrContains(g_entity[i], sEntityName) != -1)
		{
			iValid = 1;
			strcopy(sEntityToGive, sizeof(sEntityToGive), g_entity[i]);
			break;
		}
	}
	if(!iValid)
	{
		ReplyToCommand(client, "[SM] The entity name (%s) isn't valid", sEntityName);
		ReplyToCommand(client, "[SM] sm_give list | for entity list");
		return Plugin_Handled;
	}
	
	char sTargetName[MAX_TARGET_LENGTH];
	int sTargetList[MAXPLAYERS], iTargetCount;
	bool bTN_IsML;
	
	if((iTargetCount = ProcessTargetString(sTempArg, client, sTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE, sTargetName, sizeof(sTargetName), bTN_IsML)) <= 0)
	{
		ReplyToTargetError(client, iTargetCount);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < iTargetCount; i++)
		GivePlayerItem(sTargetList[i], sEntityToGive);
	
	return Plugin_Handled;
}

void smGiveList(int client) {
	ReplyToCommand(client, "");
	for(int i = 0; i < MAX_ENTITY; ++i) {
		ReplyToCommand(client, "%s", g_entity[i]);
	}
	ReplyToCommand(client, "*No need to put weapon_/item_ in the <entityname>*");
	ReplyToCommand(client, "*Partials work if not overlapping other entity name*");
}
