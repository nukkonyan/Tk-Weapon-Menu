#include	<tk>
#include	<multicolors>
#include	<clientprefs>

#pragma		semicolon	1
#pragma		newdecls	required

bool	DEBUG = false;

public	Plugin	myinfo	=	{
	name		=	"[CSS/CSGO] Tk's Weapon Menu",
	author		=	"Tk /id/Teamkiller324",
	description	=	"Weapon Menu",
	version		=	"1.0.0",
	url			=	"https://steamcommunity.com/id/Teamkiller324"
}

char	path		[MAX_TARGET_LENGTH];
int		enabled		[MAXPLAYERS+1] = 1;
int		GrenadeAmmo	[MAXPLAYERS+1];

ConVar	allow_cookies;

Cookie	weapon_primary,
		weapon_secondary,
		weapon_melee,
		weapon_grenades,
		weapon_other,
		weapon_grenades_unlimited,
		spawn_with_selected_weapons;

//Check if the keyvalues is found
bool	KvPrimary	=	false,
		KvSecondary	=	false,
		KvGrenades	=	false,
		KvMelee		=	false,
		KvOther		=	false;

bool	Invalid[MAXPLAYERS+1],
		Ignore[MAXPLAYERS+1];

//	Weapons
int		weaponid_primary	[MAXPLAYERS+1],
		weaponid_secondary	[MAXPLAYERS+1],
		weaponid_grenades	[MAXPLAYERS+1],
		weaponid_melee		[MAXPLAYERS+1],
		weaponid_other		[MAXPLAYERS+1];
		
//Clip 1
int		clip1_ak47,
		clip1_m4a4,
		clip1_m4a1s,
		clip1_sg556,
		clip1_sg552,
		clip1_aug,
		clip1_awp,
		clip1_ssg08,
		clip1_scout,
		clip1_famas,
		clip1_galilar,
		clip1_galil,
		clip1_mac10,
		clip1_mp5sd,
		clip1_mp5navy,
		clip1_mp7,
		clip1_mp9,
		clip1_p90,
		clip1_ump45,
		clip1_mag7,
		clip1_sawedoff,
		clip1_xm1014,
		clip1_nova,
		clip1_m3,
		clip1_scar20,
		clip1_sg550,
		clip1_g3sg1,
		clip1_bizon,
		clip1_glock,
		clip1_usps,
		clip1_usp,
		clip1_hkp2000,
		clip1_p250,
		clip1_p228,
		clip1_tec9,
		clip1_cz75a,
		clip1_revolver,
		clip1_fiveseven,
		clip1_deagle,
		clip1_negev,
		clip1_m249;
		
//Clip 2
int		clip2_ak47,
		clip2_m4a4,
		clip2_m4a1s,
		clip2_sg556,
		clip2_sg552,
		clip2_aug,
		clip2_awp,
		clip2_ssg08,
		clip2_scout,
		clip2_famas,
		clip2_galilar,
		clip2_galil,
		clip2_mac10,
		clip2_mp5sd,
		clip2_mp5navy,
		clip2_mp7,
		clip2_mp9,
		clip2_p90,
		clip2_ump45,
		clip2_mag7,
		clip2_sawedoff,
		clip2_xm1014,
		clip2_nova,
		clip2_m3,
		clip2_scar20,
		clip2_sg550,
		clip2_g3sg1,
		clip2_bizon,
		clip2_glock,
		clip2_usps,
		clip2_usp,
		clip2_hkp2000,
		clip2_p250,
		clip2_p228,
		clip2_tec9,
		clip2_cz75a,
		clip2_revolver,
		clip2_fiveseven,
		clip2_deagle,
		clip2_negev,
		clip2_m249;
		
KeyValues	config;

public void OnPluginStart()	{
	if(GetEngineVersion() != Engine_CSS && GetEngineVersion() != Engine_CSGO)
		SetFailState("This plugin is designed to function only in Counter-Strike: Source & Counter-Strike: Global Offensive");
	
	for(int i = 1; i <= MaxClients; i++)	{
		if(IsClientInGame(i))
			OnClientPutInServer(i);
	}
	
	weapon_primary	=	new Cookie("sm_weaponmenu_cookie_primary",	"Weapon Menu Cookie Primary",	CookieAccess_Private);
	weapon_secondary=	new Cookie("sm_weaponmenu_cookie_secondary","Weapon Menu Cookie Secondary",	CookieAccess_Private);
	weapon_melee	=	new Cookie("sm_weaponmenu_cookie_melee",	"Weapon Menu Cookie Melee",		CookieAccess_Private);
	weapon_grenades	=	new Cookie("sm_weaponmenu_cookie_grenades",	"Weapon Menu Cookie Grenades",	CookieAccess_Private);
	weapon_other	=	new Cookie("sm_weaponmenu_cookie_other",	"Weapon Menu Cookie Other",		CookieAccess_Private);
	
	weapon_grenades_unlimited	=	new Cookie("sm_weaponmenu_cookie_grenades",	"Weapon Menu Cookie Grenades Unlimited",	CookieAccess_Private);
	spawn_with_selected_weapons	=	new Cookie("sm_weaponmenu_cookie_spawn_with_selected_weapons",	"Weapon Menu Cookie Spawn With Selected Weawpons",	CookieAccess_Private);
	
	allow_cookies	=	CreateConVar("sm_weaponmenu_allow_cookies",	"1",	"Allow or disable cookie support",	FCVAR_NOTIFY,	true,	0.0,	true,	1.0);
	
	RegConsoleCmd("sm_guns",		WeaponMenu);
	RegConsoleCmd("sm_gun",			WeaponMenu);
	RegConsoleCmd("sm_weapon",		WeaponMenu);
	RegConsoleCmd("sm_weapons",		WeaponMenu);
	RegConsoleCmd("guns",			WeaponMenu);
	RegConsoleCmd("gun",			WeaponMenu);
	RegConsoleCmd("weapon",			WeaponMenu);
	RegConsoleCmd("weapons",		WeaponMenu);
	RegConsoleCmd("sm_weps",		WeaponMenu);
	
	RegConsoleCmd("sm_reloadguns",	WeaponMenu_ReloadConfig,	"Reload Weapon Menu KeyValues Configuration File.");
	
	ParseKV_Config();
	ParseKV_Primary();
	ParseKV_Secondary();
	ParseKV_Grenades();
	if(GetEngineVersion() == Engine_CSGO)	{
		ParseKV_Melee();
		ParseKV_Other();
		HookEvent("grenade_thrown",			WeaponMenu_Grenades,		EventHookMode_Pre);
	}
	
	if(GetEngineVersion() == Engine_CSS)	{
		HookEvent("smokegrenade_detonate",	WeaponMenu_Grenades_CSS,	EventHookMode_Pre);
		HookEvent("hegrenade_detonate",		WeaponMenu_Grenades_CSS,	EventHookMode_Pre);
		HookEvent("flashbang_detonate",		WeaponMenu_Grenades_CSS,	EventHookMode_Pre);
	}
	
	HookEvent("player_spawn",	WeaponMenu_Spawn);
	
	AutoExecConfig(true,	"plugin.tk_weaponmenu");
}

public	void	OnClientPutInServer(int client)	{
	SDKHook(client,	SDKHook_WeaponCanUse,	UseWeapon);
	
	if(IsClientInGame(client))
		LoadWeaponMenuCookies(client);
}

public	void	OnClientCookiesCached(int client)	{
	if(IsClientInGame(client))
		LoadWeaponMenuCookies(client);
}

public	void	OnClientDisconnect(int client)	{
	LoadWeaponMenuCookies(client);
}

void	LoadWeaponMenuCookies(int client)	{	
	if(IsValidClient(client) && allow_cookies.BoolValue)	{
		char	cookie_primary[64],
				cookie_secondary[64],
				cookie_melee[64],
				cookie_grenades[64],
				cookie_other[64],
				cookie_grenades_unlimited[16],
				cookie_spawn_with_selected_weapons[16];
		
		weapon_primary.Get(client,		cookie_primary,		sizeof(cookie_primary));
		weapon_secondary.Get(client,	cookie_secondary,	sizeof(cookie_secondary));
		weapon_melee.Get(client,		cookie_melee,		sizeof(cookie_melee));
		weapon_grenades.Get(client,		cookie_grenades,	sizeof(cookie_grenades));
		weapon_other.Get(client,		cookie_other,		sizeof(cookie_other));
		weapon_grenades_unlimited.Get(client,	cookie_grenades_unlimited,	sizeof(cookie_grenades_unlimited));
		spawn_with_selected_weapons.Get(client,	cookie_spawn_with_selected_weapons,	sizeof(cookie_spawn_with_selected_weapons));
		
		if(StrEqual(cookie_primary,	""))
			return;
		if(StrEqual(cookie_secondary,	""))
			return;
		if(StrEqual(cookie_melee,	"")||GetEngineVersion() != Engine_CSGO) //Avoid these if the game isn't csgo.
			return;
		if(StrEqual(cookie_grenades,	""))
			return;
		if(StrEqual(cookie_other,	"")||GetEngineVersion() != Engine_CSGO)
			return;
		if(StrEqual(cookie_grenades_unlimited,	""))
			return;
		if(StrEqual(cookie_spawn_with_selected_weapons,	""))
			return;
		
		weaponid_primary[client]	=	StringToInt(cookie_primary);
		weaponid_secondary[client]	=	StringToInt(cookie_secondary);
		weaponid_melee[client]		=	StringToInt(cookie_melee);
		weaponid_grenades[client]	=	StringToInt(cookie_grenades);
		weaponid_other[client]		=	StringToInt(cookie_other);
		GrenadeAmmo[client]			=	StringToInt(cookie_grenades_unlimited);
		enabled[client]				=	StringToInt(cookie_spawn_with_selected_weapons);
	}
}

Action	UseWeapon(int client,	int weapon)	{
	char classname[64]; 
	GetEntityClassname(weapon,	classname,	sizeof classname); 
     
	if(StrEqual(classname, "weapon_melee") || StrEqual(classname, "weapon_knife")) 
		EquipPlayerWeapon(client,	weapon); 
}

Action	WeaponMenu_ReloadConfig(int client,	int args)	{
	if(CheckCommandAccess(client,	"weaponmenu_reloadconfig",	ADMFLAG_SLAY,	false))	{
		CPrintToChat(client,	"{orange}[Weapon Menu] {default}Reloaded the Weapon Menu KeyValues Configuration File.");
		ParseKV_Config();
	}
	else
		CPrintToChat(client,	"{orange}[Weapon Menu] {red}you have no access it seems.. aborting the plan. {yellow}:(");
	return Plugin_Handled;
}

void	ParseKV_Config()	{
	BuildPath(Path_SM, path, sizeof(path), "configs/weaponmenu.cfg");
	
	if(!FileExists(path))
		ThrowError("[Weapon Menu] Config file %s not found", path);
		
	KeyValues kv = new KeyValues("Weapon Menu");
	
	if(!kv.ImportFromFile(path))	{
		ThrowError("[Weapon Menu] Config file %s was unable to be parsed (Is it properly installed?)", path);
		SetFailState("Fatal Error occured, shutting down. Check your error logs");
	}
	
	if(!kv.GotoFirstSubKey())	{
		ThrowError("[Weapon Menu] Config file %s was unable to find the first subkey section in file %s", path);
		SetFailState("Error occured, shutting down. Check your error logs.");
	}
	
	delete kv;
	delete config;
}

void	ParseKV_Primary()	{
	KeyValues kv = new KeyValues("Weapon Menu");	
	kv.ImportFromFile(path);
	if(!kv.JumpToKey("Primary"))	{
		PrintToServer("[Weapon Menu] Unable to find \"Primary\", check your config file in %s. Ignoring..", path);
		KvPrimary = false;
	}
	else KvPrimary = true;	
	kv.GotoFirstSubKey();
	
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH],
				ammo		[MAX_TARGET_LENGTH],
				reserve		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",		weapon,		sizeof(weapon));
		kv.GetString("team",		team,		sizeof(team));
		kv.GetString("ammo",		ammo,		sizeof(ammo));
		kv.GetString("reserve",		reserve,	sizeof(reserve));
		
		if(StrEqual(team, "") && KvPrimary == true)	{
			ThrowError("[Weapon Menu] WARNING: The team specified for the primary weapon \"%s\" cannot be empty", weapon);
			SetFailState("Error occured, shutting down");
		}
		
		if(DEBUG)	{
			if(StrEqual(ammo, ""))	{
				if(StrEqual(weapon, "weapon_hegrenade"))	return;
				if(StrEqual(weapon,	"weapon_flashbang"))	return;
				if(StrEqual(weapon,	"weapon_tagrenade"))	return;
				if(StrEqual(weapon,	"weapon_decoy"))		return;
				if(StrEqual(weapon,	"weapon_molotov"))		return;
				if(StrEqual(weapon,	"weapon_incgrenade"))	return;
				PrintToServer("[Weapon Menu] Ammo specified for the primary weapon \"%s\" is empty, ignoring..", weapon);
			}
			
			if(StrEqual(reserve, ""))	{
				if(StrEqual(weapon, "weapon_hegrenade"))	return;
				if(StrEqual(weapon,	"weapon_flashbang"))	return;
				if(StrEqual(weapon,	"weapon_tagrenade"))	return;
				if(StrEqual(weapon,	"weapon_decoy"))		return;
				if(StrEqual(weapon,	"weapon_molotov"))		return;
				if(StrEqual(weapon,	"weapon_incgrenade"))	return;
				PrintToServer("[Weapon Menu] Reserve Ammo specified for the primary weapon \"%s\" is empty, ignoring..", weapon);
			}
		}
			
		CheckWeaponClip1(weapon,	StringToInt(ammo));
		CheckWeaponClip2(weapon,	StringToInt(reserve));
	}
	while (kv.GotoNextKey());
	delete kv;
}

void	ParseKV_Secondary()	{
	KeyValues kv = new KeyValues("Weapon Menu");
	kv.ImportFromFile(path);
	if(!kv.JumpToKey("Secondary"))	{
		PrintToServer("[Weapon Menu] Unable to find \"Secondary\", check your config file in %s. Ignoring..", path);
		KvSecondary = false;
	}
	else KvSecondary = true;
	
	kv.GotoFirstSubKey();
	
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH],
				ammo		[MAX_TARGET_LENGTH],
				reserve		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",		weapon,		sizeof(weapon));
		kv.GetString("team",		team,		sizeof(team));
		kv.GetString("ammo",		ammo,		sizeof(ammo));
		kv.GetString("reserve",		reserve,	sizeof(reserve));
		
		if(StrEqual(team, "") && KvSecondary == true)	{
			ThrowError("[Weapon Menu] WARNING: The team specified for the the secondary weapon \"%s\" cannot be empty", weapon);
			SetFailState("Error occured, shutting down");
		}
			
		if(DEBUG)	{
			if(StrEqual(ammo, ""))	{
				if(StrEqual(weapon, "weapon_hegrenade"))	return;
				if(StrEqual(weapon,	"weapon_flashbang"))	return;
				if(StrEqual(weapon,	"weapon_tagrenade"))	return;
				if(StrEqual(weapon,	"weapon_decoy"))		return;
				if(StrEqual(weapon,	"weapon_molotov"))		return;
				if(StrEqual(weapon,	"weapon_incgrenade"))	return;
				PrintToServer("[Weapon Menu] Ammo specified for secondary the weapon \"%s\" is empty, ignoring..", weapon);
			}
			
			if(StrEqual(reserve, ""))	{
				if(StrEqual(weapon, "weapon_hegrenade"))	return;
				if(StrEqual(weapon,	"weapon_flashbang"))	return;
				if(StrEqual(weapon,	"weapon_tagrenade"))	return;
				if(StrEqual(weapon,	"weapon_decoy"))		return;
				if(StrEqual(weapon,	"weapon_molotov"))		return;
				if(StrEqual(weapon,	"weapon_incgrenade"))	return;
				PrintToServer("[Weapon Menu] Reserve Ammo specified for the secondary weapon \"%s\" is empty, ignoring..", weapon);
			}
		}
			
		CheckWeaponClip1(weapon,	StringToInt(ammo));
		CheckWeaponClip2(weapon,	StringToInt(reserve));
	}
	while (kv.GotoNextKey());
	delete kv;
}

void	ParseKV_Grenades()	{
	KeyValues kv = new KeyValues("Weapon Menu");
	kv.ImportFromFile(path);	
	if(!kv.JumpToKey("Grenades"))	{
		PrintToServer("[Weapon Menu] Unable to find \"Grenades\", check your config file in %s. Ignoring..", path);
		KvGrenades = false;
	}
	else KvGrenades = true;
	
	kv.GotoFirstSubKey();
	
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH],
				ammo		[MAX_TARGET_LENGTH],
				reserve		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",		weapon,		sizeof(weapon));
		kv.GetString("team",		team,		sizeof(team));
		kv.GetString("ammo",		ammo,		sizeof(ammo));
		kv.GetString("reserve",		reserve,	sizeof(reserve));
		
		if(GetEngineVersion() == Engine_CSS)	{	//These weapons do not exist in Counter-Strike: Source, so we'll ignore them.
			if(StrEqual(weapon,	"weapon_tagrenade"))	return;
			if(StrEqual(weapon,	"weapon_decoy"))		return;
		}
		
		if(StrEqual(team, "") && KvGrenades == true)	{
			ThrowError("[Weapon Menu] WARNING: The team specified for the the grenade weapon \"%s\" cannot be empty", weapon);
			SetFailState("Error occured, shutting down");
		}
			
		CheckWeaponClip1(weapon,	StringToInt(ammo));
		CheckWeaponClip2(weapon,	StringToInt(reserve));
	}
	while(kv.GotoNextKey());
	delete kv;
}

void	ParseKV_Melee()	{
	KeyValues kv = new KeyValues("Weapon Menu");
	kv.ImportFromFile(path);
	if(!kv.JumpToKey("Melee"))	{
		PrintToServer("[Weapon Menu] Unable to find \"Melee\", check your config file in %s. Ignoring..", path);
		KvMelee = false;
	}
	else KvMelee = true;
	
	kv.GotoFirstSubKey();
	
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",		weapon,		sizeof(weapon));
		kv.GetString("team",		team,		sizeof(team));
		
		if(StrEqual(team, "") && KvMelee == true)	{
			ThrowError("[Weapon Menu] WARNING: The team specified for the melee weapon \"%s\" cannot be empty", weapon);
			SetFailState("Error occured, shutting down");
		}
	}
	while(kv.GotoNextKey());
	delete kv;
}

void	ParseKV_Other()	{
	KeyValues kv = new KeyValues("Weapon Menu");
	kv.ImportFromFile(path);
	if(!kv.JumpToKey("Other"))	{
		PrintToServer("[Weapon Menu] Unable to find \"Other\", check your config file in %s. Ignoring..", path);
		KvOther = false;
	}
	else KvOther = true;
	
	kv.GotoFirstSubKey();
	
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",		weapon,		sizeof(weapon));
		kv.GetString("team",		team,		sizeof(team));
		
		if(StrEqual(team, "") && KvOther == true)	{
			ThrowError("[Weapon Menu] WARNING: The team specified for the weapon \"%s\" cannot be empty", weapon);
			SetFailState("Error occured, shutting down");
		}
	}
	while (kv.GotoNextKey());
	delete kv;
}

Action	WeaponMenu(int client,	int args)	{
	Menu menu = new Menu(WeaponMenuHandler);
	menu.SetTitle("Weapon Menu");
	menu.AddItem("1",	"Primary Weapon",		KvPrimary	?	ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	menu.AddItem("2",	"Secondary Weapon",		KvSecondary	?	ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	menu.AddItem("3",	"Grenade Weapon",		KvGrenades	?	ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	if(GetEngineVersion() == Engine_CSGO)	{
		menu.AddItem("4",	"Melee Weapon",			KvMelee		?	ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
		menu.AddItem("5",	"Other",				KvOther		?	ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	}
	char menuinfo[64];
	FormatEx(menuinfo,	sizeof(menuinfo),	"Spawn with weapon: %s",	enabled[client] ? "On":"Off");
	menu.AddItem("69",	menuinfo);
	FormatEx(menuinfo,	sizeof(menuinfo),	"Unlimited Grenades: %s",	GrenadeAmmo[client] ? "On":"Off");
	menu.AddItem("420",	menuinfo);
	menu.AddItem("X",	"----- DEBUGGING -----",	ITEMDRAW_DISABLED);
	FormatEx(menuinfo,	sizeof(menuinfo),	"Primary Weapon id: %d",	weaponid_primary[client]);
	menu.AddItem("X",	menuinfo,	ITEMDRAW_DISABLED);
	FormatEx(menuinfo,	sizeof(menuinfo),	"Secondary Weapon id: %d",	weaponid_secondary[client]);
	menu.AddItem("X",	menuinfo,	ITEMDRAW_DISABLED);
	FormatEx(menuinfo,	sizeof(menuinfo),	"Grenades Weapon id: %d",	weaponid_grenades[client]);
	menu.AddItem("X",	menuinfo,	ITEMDRAW_DISABLED);
	if(GetEngineVersion() == Engine_CSGO)	{
		FormatEx(menuinfo,	sizeof(menuinfo),	"Melee Weapon id: %d",		weaponid_melee[client]);
		menu.AddItem("X",	menuinfo, KvOther ? ITEMDRAW_DISABLED:ITEMDRAW_IGNORE);
		FormatEx(menuinfo,	sizeof(menuinfo),	"Other Weapon id: %d",		weaponid_other[client]);
	}
	menu.Display(client, MENU_TIME_FOREVER);
}

int		WeaponMenuHandler(Menu menu,	MenuAction action,	int client,	int selection)	{
	switch (action)	{
		case MenuAction_Select:	{
			char info[16];
			menu.GetItem(selection, info, sizeof(info));
			switch(StringToInt(info))	{
				case	1:	Primary(client);
				case	2:	Secondary(client);
				case	3:	Grenades(client);
				case	4:	Melee(client);
				case	5:	Other(client);
				case	69:	{
					if(enabled[client] == 1)
						enabled[client] = 0;
					else
						enabled[client] = 1;
					WeaponMenu(client, -1);
				}
				case	420:	{
					if(GrenadeAmmo[client] == 1)
						GrenadeAmmo[client] = 0;
					else
						GrenadeAmmo[client] = 1;
					WeaponMenu(client, -1);
				}
			}
		}
		case MenuAction_End:
			delete menu;	//Deletes the menu, otherwise causes a memory leak and potential server crash
	}
}

Action	Primary(int client)	{
	Menu menu = new Menu(PrimaryHandler);
	menu.SetTitle("Weapon Menu: Primary");
	menu.AddItem("default_primary",	"Default");
	KeyValues kv = new KeyValues("Weapon Menu");
	kv.ImportFromFile(path);
	kv.JumpToKey("Primary");
	kv.GotoFirstSubKey();
	
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH],
				flags		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",	weapon,	sizeof(weapon));
		kv.GetString("team",	team,	sizeof(team));
		kv.GetString("flags",	flags,	sizeof(flags));
		
		char	flagstringfix[24];
		FormatEx(flagstringfix,	sizeof(flagstringfix),	"weaponmenu_flag_%s", flags);
		int	FlagCheck	=	ReadFlagString(flags);
		
		//If you're not a Counter-Terrorist
		if(StrEqual(team, "CT"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_CT)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}
		//If you're not a Terrorist
		if(StrEqual(team, "T"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_T)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}
		//For everyone
		else if(StrEqual(team, "Any"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else
				Invalid[client] = false;
		}
		switch(GetEngineVersion())	{
			case	Engine_CSS:	{
				if(StrEqual(weapon, "weapon_ak47"))				Ignore[client]	=	false;
				if(StrEqual(weapon, "weapon_m4a1"))	{
					Ignore[client]	=	false;
					section	=	"M4A1";
				}
				if(StrEqual(weapon, "weapon_m4a1_silencer"))	Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_sg556"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_aug"))				Ignore[client]	=	false;
				if(StrEqual(weapon, "weapon_awp"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_ssg08"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_scout"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_famas"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_galilar"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_galil"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_mac10"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_mp5sd"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_mp5navy"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_mp7"))				Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_mp9"))				Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_p90"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_ump45"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_bizon"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_mag7"))				Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_sawedoff"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_xm1014"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_nova"))				Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_m3"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_scar20"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_sg550"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_g3sg1"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_negev"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_m249"))				Ignore[client]	=	false;
			}
			case	Engine_CSGO:	{
				if(StrEqual(weapon, "weapon_ak47"))				Ignore[client]	=	false;
				if(StrEqual(weapon, "weapon_m4a1"))	{
					Ignore[client]	=	false;
					section	=	"M4A4";
				}
				if(StrEqual(weapon, "weapon_m4a1_silencer"))	Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_sg556"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_aug"))				Ignore[client]	=	false;
				if(StrEqual(weapon, "weapon_awp"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_ssg08"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_scout"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_famas"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_galilar"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_galil"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_mac10"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_mp5sd"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_mp5navy"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_mp7"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_mp9"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_p90"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_ump45"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_bizon"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_mag7"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_sawedoff"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_xm1014"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_nova"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_m3"))				Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_scar20"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_sg550"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_g3sg1"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_negev"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_m249"))				Ignore[client]	=	false;
			}
		}
		if(Ignore[client] == false)		{
			menu.AddItem(weapon, section, Invalid[client] ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		}
	}
	while (kv.GotoNextKey());
	menu.Display(client, MENU_TIME_FOREVER);
	delete kv;
	return Plugin_Handled;
}

Action Secondary(int client)	{
	Menu menu = new Menu(SecondaryHandler);
	menu.SetTitle("Weapon Menu: Secondary");
	menu.AddItem("default_secondary",	"Default");
	KeyValues kv = new KeyValues("Weapon Menu");
	kv.ImportFromFile(path);
	kv.JumpToKey("Secondary");
	kv.GotoFirstSubKey();
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH],
				flags		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",	weapon,	sizeof(weapon));
		kv.GetString("team",	team,	sizeof(team));
		kv.GetString("flags",	flags,	sizeof(flags));
		
		char	flagstringfix[24];
		FormatEx(flagstringfix,	sizeof(flagstringfix),	"weaponmenu_flag_%s", flags);
		int	FlagCheck = ReadFlagString(flags);
		
		if(StrEqual(team, "CT"))		//Checking if you're a Counter-Terrorist
		{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_CT)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}	
		if(StrEqual(team, "T"))		//Checking if you're a Terrorist
		{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_T)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}
		else if(StrEqual(team, "Any"))		//For everyone
		{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else
				Invalid[client] = false;
		}
		switch(GetEngineVersion())	{
			case	Engine_CSS:	{
				if(StrEqual(weapon,	"weapon_glock"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_usp_silencer"))		Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_usp"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_hkp2000"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_p250"))				Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_p228"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_tec9"))				Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_cz75a"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_revolver"))			Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_fiveseven"))		Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_deagle"))			Ignore[client]	=	false;
			}
			case	Engine_CSGO:	{
				if(StrEqual(weapon,	"weapon_glock"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_usp_silencer"))		Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_usp"))				Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_hkp2000"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_p250"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_p228"))				Ignore[client]	=	true;
				if(StrEqual(weapon,	"weapon_tec9"))				Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_cz75a"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_revolver"))			Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_fiveseven"))		Ignore[client]	=	false;
				if(StrEqual(weapon,	"weapon_deagle"))			Ignore[client]	=	false;
			}
		}
		if(Ignore[client] == false)
			menu.AddItem(weapon, section, Invalid[client] ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	}
	while (kv.GotoNextKey());
	menu.Display(client, MENU_TIME_FOREVER);
	delete kv;
	return Plugin_Handled;
}

Action Grenades(int client)	{
	Menu menu = new Menu(GrenadesHandler);
	menu.SetTitle("Weapon Menu: Grenades");
	menu.AddItem("default_grenades",	"Default");
	KeyValues kv = new KeyValues("Weapon Menu");
	kv.ImportFromFile(path);
	kv.JumpToKey("Grenades");
	kv.GotoFirstSubKey();
	
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH],
				flags		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",	weapon,	sizeof(weapon));
		kv.GetString("team",	team,	sizeof(team));
		kv.GetString("flags",	flags,	sizeof(flags));
				
		char	flagstringfix[24];
		FormatEx(flagstringfix,	sizeof(flagstringfix),	"weaponmenu_flag_%s", flags);
		int	FlagCheck = ReadFlagString(flags);
		
		//Checking if you're a Counter-Terrorist
		if(StrEqual(team, "CT"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_CT)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}
		//Checking if you're a Terrorist
		if(StrEqual(team, "T"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_T)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}
		else if(StrEqual(team, "Any"))		//For everyone
		{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else
				Invalid[client] = false;
		}
		
		if(GetEngineVersion() == Engine_CSS)	{	//These weapons do not exist in Counter-Strike: Source, so we'll ignore them.
			if(StrEqual(weapon,	"weapon_hegrenade"))		Ignore[client]	=	false;
			if(StrEqual(weapon,	"weapon_flashbang"))		Ignore[client]	=	false;
			if(StrEqual(weapon,	"weapon_decoy"))			Ignore[client]	=	true;
			if(StrEqual(weapon,	"weapon_tagrenade"))		Ignore[client]	=	true;
			if(StrEqual(weapon,	"weapon_molotov"))			Ignore[client]	=	true;
			if(StrEqual(weapon,	"weapon_incgrenade"))		Ignore[client]	=	true;
			if(StrEqual(weapon,	"weapon_smokegrenade"))		Ignore[client]	=	false;
		}
		if(Ignore[client] == false)	{
			menu.AddItem(weapon, section, Invalid[client] ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		}
	}
	while (kv.GotoNextKey());
	menu.Display(client, MENU_TIME_FOREVER);
	delete kv;
}

Action Melee(int client)	{
	Menu menu = new Menu(MeleeHandler);
	menu.SetTitle("Weapon Menu: Melee");
	menu.AddItem("default_melee",	"Default");
	KeyValues kv = new KeyValues("Weapon Menu");
	kv.ImportFromFile(path);
	kv.JumpToKey("Melee");
	kv.GotoFirstSubKey();
	
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH],
				flags		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",	weapon,	sizeof(weapon));
		kv.GetString("team",	team,	sizeof(team));
		kv.GetString("flags",	flags,	sizeof(flags));
		
		char	flagstringfix[24];
		FormatEx(flagstringfix,	sizeof(flagstringfix),	"weaponmenu_flag_%s", flags);
		int	FlagCheck = ReadFlagString(flags);
		
		//Checking if you're a Counter-Terrorist
		if(StrEqual(team, "CT"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_CT)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}
		//Checking if you're a Terrorist
		if(StrEqual(team, "T"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_T)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}
		//For everyone
		else if(StrEqual(team, "Any"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else
				Invalid[client] = false;
		}
		
		menu.AddItem(weapon, section, Invalid[client] ? ITEMDRAW_IGNORE:ITEMDRAW_DEFAULT);
	}
	while (kv.GotoNextKey());
	menu.Display(client, MENU_TIME_FOREVER);
	delete kv;
	return Plugin_Handled;
}

Action Other(int client)	{
	Menu menu = new Menu(OtherHandler);
	menu.SetTitle("Weapon Menu: Other");
	menu.AddItem("default_other",	"Default");
	KeyValues kv = new KeyValues("Weapon Menu");
	kv.ImportFromFile(path);
	kv.JumpToKey("Other");
	kv.GotoFirstSubKey();
	
	do	{
		char	section		[MAX_TARGET_LENGTH],
				weapon		[MAX_TARGET_LENGTH],
				team		[MAX_TARGET_LENGTH],
				flags		[MAX_TARGET_LENGTH];
		kv.GetSectionName(section,	sizeof(section));
		kv.GetString("weapon",	weapon,	sizeof(weapon));
		kv.GetString("team",	team,	sizeof(team));
		kv.GetString("flags",	flags,	sizeof(flags));
		
		char	flagstringfix[24];
		FormatEx(flagstringfix,	sizeof(flagstringfix),	"weaponmenu_flag_%s", flags);
		int	FlagCheck = ReadFlagString(flags);
		
		//If you're not a Counter-Terrorist
		if(StrEqual(team, "CT"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_CT)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}
		//If you're not a Terrorist
		if(StrEqual(team, "T"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else	{
				if(GetClientTeam(client) != CS_TEAM_T)
					Invalid[client] = true;
				else
					Invalid[client] = false;
			}
		}
		//For everyone
		else if(StrEqual(team, "Any"))	{
			if(!StrEqual(flags,	""))	{
				if(!CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = true;
				else if(CheckCommandAccess(client,	flagstringfix,	FlagCheck))
					Invalid[client] = false;
			}
			else
				Invalid[client] = false;
		}
		
		menu.AddItem(weapon, section, Invalid[client] ? ITEMDRAW_IGNORE:ITEMDRAW_DEFAULT);
	}
	while (kv.GotoNextKey());
	menu.Display(client, MENU_TIME_FOREVER);
	delete kv;
	return Plugin_Handled;
}

int PrimaryHandler(Menu menu, MenuAction action, int client, int selection)	{
	switch (action)	{
		case MenuAction_Select:	{
			CS_ClientRemoveWeaponSlot(client, 1);
			char weapon[96];
			menu.GetItem(selection, weapon, sizeof(weapon));
			CheckWeapon_Primary(client, weapon);
			Primary(client);
		}
		case MenuAction_End: delete menu;
		case MenuAction_Cancel: WeaponMenu(client, -1);
	}
}

int SecondaryHandler(Menu menu, MenuAction action, int client, int selection)	{
	switch (action)	{
		case MenuAction_Select:	{
			CS_ClientRemoveWeaponSlot(client, 2);
			char	weapon[96],	defaultPistolCT[32],	defaultPistolT[32];
			switch(GetEngineVersion())	{
				case	Engine_CSGO:	{
					FindConVar("mp_ct_default_secondary").GetString(defaultPistolCT,	sizeof(defaultPistolCT));	//Gain the default via these existing ingame commands
					FindConVar("mp_t_default_secondary").GetString(defaultPistolT,		sizeof(defaultPistolT));
				}
				case	Engine_CSS:	{
					defaultPistolCT	=	"weapon_usp";
					defaultPistolT	=	"weapon_glock";
				}
			}
			menu.GetItem(selection, weapon, sizeof(weapon));
			CheckWeapon_Secondary(client, weapon);
			if(StrEqual(weapon,	"default_secondary"))	{
				switch(CS_GetClientTeam(client))	{
					case	CSTeam_CTerrorists:	GivePlayerItem(client, defaultPistolCT);
					case	CSTeam_Terrorists:	GivePlayerItem(client, defaultPistolT);
				}
			}
			Secondary(client);
		}
		case MenuAction_End: delete menu;
		case MenuAction_Cancel: WeaponMenu(client, -1);
	}
}

int	GrenadesHandler(Menu menu, MenuAction action, int client, int selection)	{
	switch (action)	{
		case MenuAction_Select:	{
			CS_ClientRemoveWeaponSlot(client, 4);
			char weapon[96];
			menu.GetItem(selection, weapon, sizeof(weapon));
			CheckWeapon_Grenades(client, weapon);
			Grenades(client);
		}
		case MenuAction_End: delete menu;
		case MenuAction_Cancel: WeaponMenu(client, -1);
	}
}

int MeleeHandler(Menu menu, MenuAction action, int client, int selection)	{
	switch(action)	{
		case MenuAction_Select:	{
			CS_ClientRemoveWeaponSlot(client, 3);
			char weapon[96];
			menu.GetItem(selection, weapon, sizeof(weapon));
			CheckWeapon_Melee(client, weapon);
			if(StrEqual(weapon,	"default_melee"))	{
				GivePlayerItem(client, "weapon_knife");
			}
			Melee(client);
		}
		case MenuAction_End: delete menu;
		case MenuAction_Cancel: WeaponMenu(client, -1);
	}
}

int OtherHandler(Menu menu, MenuAction action, int client, int selection)	{
	switch(action)	{
		case MenuAction_Select:	{
			CS_ClientRemoveWeaponSlot(client, 3);
			char weapon[96];
			menu.GetItem(selection, weapon, sizeof(weapon));
			CheckWeapon_Other(client, weapon);
			Melee(client);
		}
		case MenuAction_End: delete menu;
		case MenuAction_Cancel: WeaponMenu(client, -1);
	}
}

void CheckWeapon_Primary(int client, char[] weapon)	{
	if(StrEqual(weapon,	"default_primary"))			weaponid_primary[client]	=	0;
	if(StrEqual(weapon, "weapon_ak47"))				weaponid_primary[client]	=	1;
	if(StrEqual(weapon, "weapon_m4a1"))				weaponid_primary[client]	=	2;
	if(StrEqual(weapon, "weapon_m4a1_silencer"))	weaponid_primary[client]	=	3;
	if(StrEqual(weapon,	"weapon_sg556"))			weaponid_primary[client]	=	4;
	if(StrEqual(weapon,	"weapon_sg552"))			weaponid_primary[client]	=	4;
	if(StrEqual(weapon,	"weapon_aug"))				weaponid_primary[client]	=	5;
	if(StrEqual(weapon, "weapon_awp"))				weaponid_primary[client]	=	6;
	if(StrEqual(weapon,	"weapon_ssg08"))			weaponid_primary[client]	=	7;
	if(StrEqual(weapon,	"weapon_scout"))			weaponid_primary[client]	=	7;
	if(StrEqual(weapon,	"weapon_famas"))			weaponid_primary[client]	=	8;
	if(StrEqual(weapon,	"weapon_galilar"))			weaponid_primary[client]	=	9;
	if(StrEqual(weapon,	"weapon_galil"))			weaponid_primary[client]	=	9;
	if(StrEqual(weapon,	"weapon_mac10"))			weaponid_primary[client]	=	10;
	if(StrEqual(weapon,	"weapon_mp5sd"))			weaponid_primary[client]	=	11;
	if(StrEqual(weapon,	"weapon_mp5navy"))			weaponid_primary[client]	=	11;
	if(StrEqual(weapon,	"weapon_mp7"))				weaponid_primary[client]	=	12;
	if(StrEqual(weapon,	"weapon_mp9"))				weaponid_primary[client]	=	13;
	if(StrEqual(weapon,	"weapon_p90"))				weaponid_primary[client]	=	14;
	if(StrEqual(weapon,	"weapon_ump45"))			weaponid_primary[client]	=	15;
	if(StrEqual(weapon,	"weapon_bizon"))			weaponid_primary[client]	=	16;
	if(StrEqual(weapon,	"weapon_mag7"))				weaponid_primary[client]	=	17;
	if(StrEqual(weapon,	"weapon_sawedoff"))			weaponid_primary[client]	=	18;
	if(StrEqual(weapon,	"weapon_xm1014"))			weaponid_primary[client]	=	19;
	if(StrEqual(weapon,	"weapon_nova"))				weaponid_primary[client]	=	20;
	if(StrEqual(weapon,	"weapon_m3"))				weaponid_primary[client]	=	20;
	if(StrEqual(weapon,	"weapon_scar20"))			weaponid_primary[client]	=	21;
	if(StrEqual(weapon,	"weapon_sg550"))			weaponid_primary[client]	=	21;
	if(StrEqual(weapon,	"weapon_g3sg1"))			weaponid_primary[client]	=	22;
	if(StrEqual(weapon,	"weapon_negev"))			weaponid_primary[client]	=	23;
	if(StrEqual(weapon,	"weapon_m249"))				weaponid_primary[client]	=	24;
	
	char buffer[64];
	IntToString(weaponid_primary[client], buffer, sizeof(buffer));
	weapon_primary.Set(client,	buffer);
	
	CreateTimer(0.1, GiveWeaponTimer, client);
}

void CheckWeapon_Secondary(int client, char[] weapon)	{
	if(StrEqual(weapon,	"default_secondary"))		weaponid_secondary[client]	=	0;
	if(StrEqual(weapon,	"weapon_glock"))			weaponid_secondary[client]	=	1;
	if(StrEqual(weapon,	"weapon_usp_silencer"))		weaponid_secondary[client]	=	2;
	if(StrEqual(weapon,	"weapon_usp"))				weaponid_secondary[client]	=	2;
	if(StrEqual(weapon,	"weapon_hkp2000"))			weaponid_secondary[client]	=	3;
	if(StrEqual(weapon,	"weapon_p250"))				weaponid_secondary[client]	=	4;
	if(StrEqual(weapon,	"weapon_p228"))				weaponid_secondary[client]	=	4;
	if(StrEqual(weapon,	"weapon_tec9"))				weaponid_secondary[client]	=	5;
	if(StrEqual(weapon,	"weapon_cz75a"))			weaponid_secondary[client]	=	6;
	if(StrEqual(weapon,	"weapon_revolver"))			weaponid_secondary[client]	=	7;
	if(StrEqual(weapon,	"weapon_fiveseven"))		weaponid_secondary[client]	=	8;
	if(StrEqual(weapon,	"weapon_deagle"))			weaponid_secondary[client]	=	9;
	
	char buffer[64];
	IntToString(weaponid_secondary[client], buffer, sizeof(buffer));
	weapon_secondary.Set(client, buffer);
	
	CreateTimer(0.1, GiveWeaponTimer, client);
}

void CheckWeapon_Grenades(int client, char[] weapon)	{
	if(StrEqual(weapon,	"default_grenades"))		weaponid_grenades[client]	=	0;
	if(StrEqual(weapon,	"weapon_hegrenade"))		weaponid_grenades[client]	=	1;
	if(StrEqual(weapon,	"weapon_flashbang"))		weaponid_grenades[client]	=	2;
	if(StrEqual(weapon,	"weapon_decoy"))			weaponid_grenades[client]	=	3;
	if(StrEqual(weapon,	"weapon_tagrenade"))		weaponid_grenades[client]	=	4;
	if(StrEqual(weapon,	"weapon_molotov"))			weaponid_grenades[client]	=	5;
	if(StrEqual(weapon,	"weapon_incgrenade"))		weaponid_grenades[client]	=	6;
	if(StrEqual(weapon,	"weapon_smokegrenade"))		weaponid_grenades[client]	=	7;
	
	char	buffer[64];
	IntToString(weaponid_grenades[client], buffer, sizeof(buffer));
	weapon_grenades.Set(client,	buffer);
	
	CreateTimer(0.1, GiveWeaponTimer, client);
}

void CheckWeapon_Other(int client, char[] weapon)	{
	if(StrEqual(weapon,	"default_other"))			weaponid_other[client]		=	0;
	if(StrEqual(weapon,	"weapon_healthshot"))		weaponid_other[client]		=	1;
	if(StrEqual(weapon,	"weapon_cutters"))			weaponid_other[client]		=	2;
	
	char buffer[64];
	IntToString(weaponid_other[client], buffer, sizeof(buffer));
	weapon_other.Set(client, buffer);
	
	CreateTimer(0.1, GiveWeaponTimer, client);
}

void CheckWeapon_Melee(int client, char[] weapon)	{
	if(StrEqual(weapon,	"default_melee"))				weaponid_melee[client]		=	0;
	if(StrEqual(weapon,	"weapon_knife_karambit"))		weaponid_melee[client]		=	1;
	if(StrEqual(weapon,	"weapon_knife_m9_bayonet"))		weaponid_melee[client]		=	2;
	if(StrEqual(weapon,	"weapon_knife_bayonet"))		weaponid_melee[client]		=	3;	//Future proof
	if(StrEqual(weapon,	"weapon_bayonet"))				weaponid_melee[client]		=	3;
	if(StrEqual(weapon,	"weapon_knife_survival_bowie"))	weaponid_melee[client]		=	4;
	if(StrEqual(weapon,	"weapon_knife_butterfly"))		weaponid_melee[client]		=	5;
	if(StrEqual(weapon,	"weapon_knife_flip"))			weaponid_melee[client]		=	6;
	if(StrEqual(weapon,	"weapon_knife_push"))			weaponid_melee[client]		=	7;
	if(StrEqual(weapon,	"weapon_knife_tactical"))		weaponid_melee[client]		=	8;
	if(StrEqual(weapon,	"weapon_knife_falchion"))		weaponid_melee[client]		=	9;
	if(StrEqual(weapon,	"weapon_knife_gut"))			weaponid_melee[client]		=	10;
	if(StrEqual(weapon,	"weapon_knife_ursus"))			weaponid_melee[client]		=	11;
	if(StrEqual(weapon,	"weapon_knife_gypsy_jackknife"))weaponid_melee[client]		=	12;
	if(StrEqual(weapon,	"weapon_knife_stiletto"))		weaponid_melee[client]		=	13;
	if(StrEqual(weapon,	"weapon_knife_widowmaker"))		weaponid_melee[client]		=	14;
	if(StrEqual(weapon,	"weapon_knife_css"))			weaponid_melee[client]		=	15;
	if(StrEqual(weapon,	"weapon_knife_cord"))			weaponid_melee[client]		=	16;
	if(StrEqual(weapon,	"weapon_knife_canis"))			weaponid_melee[client]		=	17;
	if(StrEqual(weapon,	"weapon_knife_outdoor"))		weaponid_melee[client]		=	18;
	if(StrEqual(weapon,	"weapon_knife_skeleton"))		weaponid_melee[client]		=	19;
	if(StrEqual(weapon,	"weapon_fists"))				weaponid_melee[client]		=	20;
	if(StrEqual(weapon,	"weapon_axe"))					weaponid_melee[client]		=	21;
	if(StrEqual(weapon,	"weapon_hammer"))				weaponid_melee[client]		=	22;
	if(StrEqual(weapon,	"weapon_spanner"))				weaponid_melee[client]		=	23;
	
	char buffer[64];
	IntToString(weaponid_melee[client],	buffer,	sizeof(buffer));
	weapon_melee.Set(client,	buffer);
	
	CreateTimer(0.1, GiveWeaponTimer, client);
}

void CheckWeaponClip1(char[] weapon, int value)	{
	if(StrEqual(weapon,	"weapon_ak47"))				clip1_ak47		=	value;
	if(StrEqual(weapon,	"weapon_m4a1"))				clip1_m4a4		=	value;
	if(StrEqual(weapon,	"weapon_m4a1_silencer"))	clip1_m4a1s		=	value;
	if(StrEqual(weapon,	"weapon_sg556"))			clip1_sg556		=	value;
	if(StrEqual(weapon,	"weapon_sg552"))			clip1_sg552		=	value;
	if(StrEqual(weapon,	"weapon_aug"))				clip1_sg556		=	value;
	if(StrEqual(weapon,	"weapon_awp"))				clip1_awp		=	value;
	if(StrEqual(weapon,	"weapon_ssg08"))			clip1_ssg08		=	value;
	if(StrEqual(weapon,	"weapon_scout"))			clip1_scout		=	value;
	if(StrEqual(weapon,	"weapon_famas"))			clip1_famas		=	value;
	if(StrEqual(weapon,	"weapon_galilar"))			clip1_galilar	=	value;
	if(StrEqual(weapon,	"weapon_mac10"))			clip1_mac10		=	value;
	if(StrEqual(weapon,	"weapon_mp5sd"))			clip1_mp5sd		=	value;
	if(StrEqual(weapon,	"weapon_mp5navy"))			clip1_mp5navy	=	value;
	if(StrEqual(weapon,	"weapon_mp7"))				clip1_mp7		=	value;
	if(StrEqual(weapon,	"weapon_mp9"))				clip1_mp9		=	value;
	if(StrEqual(weapon,	"weapon_p90"))				clip1_p90		=	value;
	if(StrEqual(weapon,	"weapon_ump45"))			clip1_ump45		=	value;
	if(StrEqual(weapon,	"weapon_mag7"))				clip1_mag7		=	value;
	if(StrEqual(weapon,	"weapon_sawedoff"))			clip1_sawedoff	=	value;
	if(StrEqual(weapon,	"weapon_xm1014"))			clip1_xm1014	=	value;
	if(StrEqual(weapon,	"weapon_nova"))				clip1_nova		=	value;
	if(StrEqual(weapon,	"weapon_m3"))				clip1_m3		=	value;
	if(StrEqual(weapon,	"weapon_scar20"))			clip1_scar20	=	value;
	if(StrEqual(weapon,	"weapon_sg550"))			clip1_sg550		=	value;
	if(StrEqual(weapon,	"weapon_g3sg1"))			clip1_g3sg1		=	value;
	if(StrEqual(weapon,	"weapon_bizon"))			clip1_bizon		=	value;
	if(StrEqual(weapon,	"weapon_glock"))			clip1_glock		=	value;
	if(StrEqual(weapon,	"weapon_usp_silencer"))		clip1_usps		=	value;
	if(StrEqual(weapon,	"weapon_usp"))				clip1_usp		=	value;
	if(StrEqual(weapon,	"weapon_hkp2000"))			clip1_hkp2000	=	value;
	if(StrEqual(weapon,	"weapon_p250"))				clip1_p250		=	value;
	if(StrEqual(weapon,	"weapon_p228"))				clip1_p228		=	value;
	if(StrEqual(weapon,	"weapon_tec9"))				clip1_tec9		=	value;
	if(StrEqual(weapon,	"weapon_cz75a"))			clip1_cz75a		=	value;
	if(StrEqual(weapon,	"weapon_revolver"))			clip1_revolver	=	value;
	if(StrEqual(weapon,	"weapon_fiveseven"))		clip1_fiveseven	=	value;
	if(StrEqual(weapon,	"weapon_deagle"))			clip1_deagle	=	value;
	if(StrEqual(weapon,	"weapon_negev"))			clip1_negev		=	value;
	if(StrEqual(weapon,	"weapon_m249"))				clip1_m249		=	value;
}

void CheckWeaponClip2(char[] weapon, int value)	{
	if(StrEqual(weapon,	"weapon_ak47"))				clip2_ak47		=	value;
	if(StrEqual(weapon,	"weapon_m4a1"))				clip2_m4a4		=	value;
	if(StrEqual(weapon,	"weapon_m4a1_silencer"))	clip2_m4a1s		=	value;
	if(StrEqual(weapon,	"weapon_sg556"))			clip2_sg556		=	value;
	if(StrEqual(weapon,	"weapon_sg552"))			clip2_sg552		=	value;
	if(StrEqual(weapon,	"weapon_aug"))				clip2_sg556		=	value;
	if(StrEqual(weapon,	"weapon_awp"))				clip2_awp		=	value;
	if(StrEqual(weapon,	"weapon_ssg08"))			clip2_ssg08		=	value;
	if(StrEqual(weapon,	"weapon_scout"))			clip2_scout		=	value;
	if(StrEqual(weapon,	"weapon_famas"))			clip2_famas		=	value;
	if(StrEqual(weapon,	"weapon_galilar"))			clip2_galilar	=	value;
	if(StrEqual(weapon,	"weapon_galil"))			clip2_galil		=	value;
	if(StrEqual(weapon,	"weapon_mac10"))			clip2_mac10		=	value;
	if(StrEqual(weapon,	"weapon_mp5sd"))			clip2_mp5sd		=	value;
	if(StrEqual(weapon,	"weapon_mp5navy"))			clip2_mp5navy	=	value;
	if(StrEqual(weapon,	"weapon_mp7"))				clip2_mp7		=	value;
	if(StrEqual(weapon,	"weapon_mp9"))				clip2_mp9		=	value;
	if(StrEqual(weapon,	"weapon_p90"))				clip2_p90		=	value;
	if(StrEqual(weapon,	"weapon_ump45"))			clip2_ump45		=	value;
	if(StrEqual(weapon,	"weapon_mag7"))				clip2_mag7		=	value;
	if(StrEqual(weapon,	"weapon_sawedoff"))			clip2_sawedoff	=	value;
	if(StrEqual(weapon,	"weapon_xm1014"))			clip2_xm1014	=	value;
	if(StrEqual(weapon,	"weapon_nova"))				clip2_nova		=	value;
	if(StrEqual(weapon,	"weapon_m3"))				clip2_m3		=	value;
	if(StrEqual(weapon,	"weapon_scar20"))			clip2_scar20	=	value;
	if(StrEqual(weapon,	"weapon_sg550"))			clip2_sg550		=	value;
	if(StrEqual(weapon,	"weapon_g3sg1"))			clip2_g3sg1		=	value;
	if(StrEqual(weapon,	"weapon_bizon"))			clip2_bizon		=	value;
	if(StrEqual(weapon,	"weapon_glock"))			clip2_glock		=	value;
	if(StrEqual(weapon,	"weapon_usp_silencer"))		clip2_usps		=	value;
	if(StrEqual(weapon,	"weapon_usp"))				clip2_usp		=	value;
	if(StrEqual(weapon,	"weapon_hkp2000"))			clip2_hkp2000	=	value;
	if(StrEqual(weapon,	"weapon_p250"))				clip2_p250		=	value;
	if(StrEqual(weapon,	"weapon_p228"))				clip2_p228		=	value;
	if(StrEqual(weapon,	"weapon_tec9"))				clip2_tec9		=	value;
	if(StrEqual(weapon,	"weapon_cz75a"))			clip2_cz75a		=	value;
	if(StrEqual(weapon,	"weapon_revolver"))			clip2_revolver	=	value;
	if(StrEqual(weapon,	"weapon_fiveseven"))		clip2_fiveseven	=	value;
	if(StrEqual(weapon,	"weapon_deagle"))			clip2_deagle	=	value;
	if(StrEqual(weapon,	"weapon_negev"))			clip2_negev		=	value;
	if(StrEqual(weapon,	"weapon_m249"))				clip2_m249		=	value;
}

Action WeaponMenu_Spawn(Event event, char[] name, bool dontBroadcast)	{
	int	client	=	GetClientOfUserId(event.GetInt("userid"));
	if(enabled[client])
		CreateTimer(0.1, GiveWeaponTimer, client);
}

Action GiveWeaponTimer(Handle timer, any client)	{
	GiveWeapon(client);
}

void GiveWeapon(int client)	{
	switch(weaponid_primary[client])	{
		case	1:		GiveClientWeaponEx2(client,	"weapon_ak47",			1,		clip1_ak47,		clip2_ak47);
		case	2:		GiveClientWeaponEx2(client,	"weapon_m4a1",			1,		clip1_m4a4,		clip2_m4a4);
		case	3:		GiveClientWeaponEx2(client,	"weapon_m4a1_silencer",	1,		clip1_m4a1s,	clip2_m4a1s);
		case	4:
		{
			if(GetEngineVersion() == Engine_CSGO)
				GiveClientWeaponEx2(client,	"weapon_sg556",					1,		clip1_sg556,	clip2_sg556);
			else if(GetEngineVersion() == Engine_CSS)
				GiveClientWeaponEx2(client,	"weapon_sg552",					1,		clip1_sg552,	clip2_sg552);
		}
		case	5:		GiveClientWeaponEx2(client,	"weapon_aug",			1,		clip1_aug,		clip2_aug);
		case	6:		GiveClientWeaponEx2(client,	"weapon_awp",			1,		clip1_awp,		clip2_awp);
		case	7:
		{
			if(GetEngineVersion() == Engine_CSGO)
				GiveClientWeaponEx2(client,	"weapon_ssg08",					1,		clip1_ssg08,	clip2_ssg08);
			else if(GetEngineVersion() == Engine_CSS)
				GiveClientWeaponEx2(client,	"weapon_scout",					1,		clip1_scout,	clip2_scout);
		}
		case	8:		GiveClientWeaponEx2(client,	"weapon_famas",			1,		clip1_famas,	clip2_famas);
		case	9:
		{
			if(GetEngineVersion() == Engine_CSGO)
				GiveClientWeaponEx2(client,	"weapon_galilar",				1,		clip1_galilar,	clip2_galilar);
			else if(GetEngineVersion() == Engine_CSS)	
				GiveClientWeaponEx2(client,	"weapon_galil",					1,		clip1_galil,	clip2_galil);
		}
		case	10:		GiveClientWeaponEx2(client,	"weapon_mac10",			1,		clip1_mac10,	clip2_mac10);
		case	11:
		{
			if(GetEngineVersion() == Engine_CSGO)
				GiveClientWeaponEx2(client,	"weapon_mp5sd",					1,		clip1_mp5sd,	clip2_mp5sd);
			else if(GetEngineVersion() == Engine_CSS)
				GiveClientWeaponEx2(client,	"weapon_mp5navy",				1,		clip1_mp5navy,	clip2_mp5navy);
		}
		case	12:		GiveClientWeaponEx2(client,	"weapon_mp7",			1,		clip1_mp7,		clip2_mp7);
		case	13:		GiveClientWeaponEx2(client,	"weapon_mp9",			1,		clip1_mp9,		clip2_mp9);
		case	14:		GiveClientWeaponEx2(client,	"weapon_p90",			1,		clip1_p90,		clip2_p90);
		case	15:		GiveClientWeaponEx2(client,	"weapon_ump45",			1,		clip1_ump45,	clip2_ump45);
		case	16:		GiveClientWeaponEx2(client,	"weapon_bizon",			1,		clip1_bizon,	clip2_bizon);
		case	17:		GiveClientWeaponEx2(client,	"weapon_mag7",			1,		clip1_mag7,		clip2_mag7);
		case	18:		GiveClientWeaponEx2(client,	"weapon_sawedoff",		1,		clip1_sawedoff,	clip2_sawedoff);
		case	19:		GiveClientWeaponEx2(client,	"weapon_xm1014",		1,		clip1_xm1014,	clip2_xm1014);
		case	20:
		{
			if(GetEngineVersion() == Engine_CSGO)
				GiveClientWeaponEx2(client,	"weapon_nova",					1,		clip1_nova,		clip2_nova);
			else if(GetEngineVersion() == Engine_CSS)
				GiveClientWeaponEx2(client, "weapon_m3",					1,		clip1_m3,		clip2_m3);
		}
		case	21:
		{
			if(GetEngineVersion() == Engine_CSGO)
				GiveClientWeaponEx2(client,	"weapon_scar20",				1,		clip1_scar20,	clip2_scar20);
			else if(GetEngineVersion() == Engine_CSS)
				GiveClientWeaponEx2(client,	"weapon_sg550",					1,		clip1_sg550,	clip2_sg550);
		}
		case	22:		GiveClientWeaponEx2(client,	"weapon_g3sg1",			1,		clip1_g3sg1,	clip2_g3sg1);
		case	23:		GiveClientWeaponEx2(client,	"weapon_negev",			1,		clip1_negev,	clip2_negev);
		case	24:		GiveClientWeaponEx2(client,	"weapon_m249",			1,		clip1_m249,		clip2_m249);
	}
	switch (weaponid_secondary[client])	{
		case	1:		GiveClientWeaponEx2(client,	"weapon_glock",			2,		clip1_glock,	clip2_glock);
		case	2:
		{
			switch(GetEngineVersion())	{
				case	Engine_CSGO:
					GiveClientWeaponEx2(client,	"weapon_usp_silencer",			2,		clip1_usps,		clip2_usps);
				case	Engine_CSS:
					GiveClientWeaponEx2(client,	"weapon_usp",					2,		clip1_usp,		clip2_usp);
			}
		}
		case	3:		GiveClientWeaponEx2(client,	"weapon_hkp2000",		2,		clip1_hkp2000,	clip2_hkp2000);
		case	4:
		{
			switch(GetEngineVersion())	{
				case	Engine_CSGO:
					GiveClientWeaponEx2(client,	"weapon_p250",					2,		clip1_p250,		clip2_p250);
				case	Engine_CSS:
					GiveClientWeaponEx2(client,	"weapon_p228",					2,		clip1_p228,		clip2_p228);
			}
		}
		case	5:		GiveClientWeaponEx2(client,	"weapon_tec9",			2,		clip1_tec9,		clip2_tec9);
		case	6:		GiveClientWeaponEx2(client,	"weapon_cz75a",			2,		clip1_cz75a,	clip2_cz75a);
		case	7:		GiveClientWeaponEx2(client,	"weapon_revolver",		2,		clip1_revolver,	clip2_revolver);
		case	8:		GiveClientWeaponEx2(client,	"weapon_fiveseven",		2,		clip1_fiveseven,clip2_fiveseven);
		case	9:		GiveClientWeaponEx2(client,	"weapon_deagle",		2,		clip1_deagle,	clip2_deagle);
	}
	switch (weaponid_other[client])	{
		case	1:		GivePlayerItem(client,	"weapon_healthshot");
		case	2:		GivePlayerItem(client,	"weapon_cutters");
	}
	switch (weaponid_melee[client])	{
		case	1:		GiveClientWeapon(client,	"weapon_knife_karambit",		3);
		case	2:		GiveClientWeapon(client,	"weapon_knife_m9_bayonet",		3);
		case	3:		GiveClientWeapon(client,	"weapon_bayonet",				3);
		//case	3:		GiveClientWeapon(client,	"weapon_knife_bayonet",			3);	//Future proof, if bayonet ever gets its entity name changed
		case	4:		GiveClientWeapon(client,	"weapon_knife_survival_bowie",	3);
		case	5:		GiveClientWeapon(client,	"weapon_knife_butterfly",		3);
		case	6:		GiveClientWeapon(client,	"weapon_knife_flip",			3);
		case	7:		GiveClientWeapon(client,	"weapon_knife_push",			3);
		case	8:		GiveClientWeapon(client,	"weapon_knife_tactical",		3);
		case	9:		GiveClientWeapon(client,	"weapon_knife_falchion",		3);
		case	10:		GiveClientWeapon(client,	"weapon_knife_gut",				3);
		case	11:		GiveClientWeapon(client,	"weapon_knife_ursus",			3);
		case	12:		GiveClientWeapon(client,	"weapon_knife_gypsy_jackknife",	3);
		case	13:		GiveClientWeapon(client,	"weapon_knife_stiletto",		3);
		case	14:		GiveClientWeapon(client,	"weapon_knife_widowmaker",		3);
		case	15:		GiveClientWeapon(client,	"weapon_knife_css",				3);
		case	16:		GiveClientWeapon(client,	"weapon_knife_cord",			3);
		case	17:		GiveClientWeapon(client,	"weapon_knife_canis",			3);
		case	18:		GiveClientWeapon(client,	"weapon_knife_outdoor",			3);
		case	19:		GiveClientWeapon(client,	"weapon_knife_skeleton",		3);
		case	20:		GiveClientWeapon(client,	"weapon_fists",					3);
		case	21:		GiveClientWeapon(client,	"weapon_axe",					3);
		case	22:		GiveClientWeapon(client,	"weapon_hammer",				3);
		case	23:		GiveClientWeapon(client,	"weapon_spanner",				3);
	}
	switch (weaponid_grenades[client])	{
		case	1:		GiveClientWeapon(client,	"weapon_hegrenade",		4);
		case	2:		GiveClientWeapon(client,	"weapon_flashbang",		4);
		case	3:		GiveClientWeapon(client,	"weapon_decoy",			4);
		case	4:		GiveClientWeapon(client,	"weapon_tagrenade",		4);
		case	5:		GiveClientWeapon(client,	"weapon_molotov",		4);
		case	6:		GiveClientWeapon(client,	"weapon_incgrenade",	4);
		case	7:		GiveClientWeapon(client,	"weapon_smokegrenade",	4);
	}
}

Action WeaponMenu_Grenades_CSS(Event event, const char[] name, bool dontBroadcast)	{
	int	client	=	GetClientOfUserId(event.GetInt("userid"));
	if(GrenadeAmmo[client])	{
		if(StrEqual(name,	"flashbang_detonate"))
			GivePlayerItem(client, "weapon_flashbang");
		if(StrEqual(name,	"hegrenade_detonate"))
			GivePlayerItem(client,	"weapon_hegrenade");
		if(StrEqual(name,	"smokegrenade_detonate"))
			GivePlayerItem(client,	"weapon_smokegrenade");
	}
}

Action WeaponMenu_Grenades(Event event, const char[] name, bool dontBroadcast)	{
	int	client	=	GetClientOfUserId(event.GetInt("userid"));
	
	if(GrenadeAmmo[client])	{
		switch (weaponid_grenades[client])
		{
			case	1:	GivePlayerItem(client,	"weapon_hegrenade");
			case	2:	GivePlayerItem(client,	"weapon_flashbang");
			case	3:	GivePlayerItem(client,	"weapon_decoy");
			case	4:	GivePlayerItem(client,	"weapon_tagrenade");
			case	5:	GivePlayerItem(client,	"weapon_molotov");
			case	6:	GivePlayerItem(client,	"weapon_incgrenade");
			case	7:	GivePlayerItem(client,	"weapon_smokegrenade");
		}
	}
}

bool	IsValidClient(int client)	{
	if(client < 1 || client > MaxClients)
		return	false;
	if(IsFakeClient(client))
		return	false;
	if(IsClientReplay(client))
		return	false;
	if(IsClientSourceTV(client))
		return	false;
	if(IsClientObserver(client))
		return	false;
	return	true;
}