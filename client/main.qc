
void() ToggleMenu =
{
	if(serverkey("constate") != "disconnected")
	{
		if(in_menu == MENU_NONE)
		{
			localcmd("pause\n");
			in_menu = MENU_MAIN;
			time_in_menu = 0;
			local float i;
			for(i = 0; i < BUTTONS_COUNT; i++)
			{
				buttons[i].active = 1;
			}
			setcursormode(TRUE,"menu/cursor");
		}
		else
		{
			localcmd("pause\n");
			in_menu = MENU_NONE;
			mheld = FALSE;
			semi = TRUE;
			setcursormode(FALSE,"menu/cursor");
			cursor_pos_x = g_width/2;
			cursor_pos_y = g_height/2;
		}
	}
	else
	{
		in_menu = MENU_MAIN;
		time_in_menu = 0;
		setcursormode(TRUE,"menu/cursor");
	}
}

void() click_predraw =
{
	click.angles_y += frametime * 256;
	click.scale += frametime * 2;
	click.origin_z -= frametime * 4;
	click.alpha -= frametime * 3;
}

void() muzzleflash_predraw =
{
	muzzleflash.scale += frametime * 14;
	muzzleflash.alpha -= frametime * 12;
}

float(float isnew) playerlisten =
{
	float vell = vlen(self.velocity);
	self.angles_z = 0;
	if(isnew)
	{
		self.frame2 = 0;
	}
	self.frame1time += frametime;
	if(vell > 0)
	{
		self.frame = 1;
		self.lerpfrac = 1 - (vell/250);
		if(self.lerpfrac > 1)
			self.lerpfrac = 1;
		else if(self.lerpfrac < 0)
			self.lerpfrac = 0;
	}
	else
	{
		self.lerpfrac = 1;
	}
	setorigin(torso,gettaginfo(self, gettagindex(self,"stomach")));
	torso.angles = vectoangles(v_forward, -v_right);
	
	setorigin(wep,gettaginfo(torso, gettagindex(torso,"hand.r")));
	wep.angles = vectoangles(v_forward, v_up);
	
	setorigin(muzzleflash,gettaginfo(torso, gettagindex(torso,"hand.r")) - v_right * muzzleoffset);
	muzzleflash.angles = wep.angles;
	
	if(reloading > 0)
	{
		torso.frame2time += frametime;
		if(reloading > 0.2 && torso.lerpfrac < 1)
		{
			torso.lerpfrac += frametime  * 5;
			if(torso.lerpfrac > 1)
				torso.lerpfrac = 1;
		}
		else if(reloading <= 0.2 && torso.lerpfrac > 0)
		{
			if(nextmodel != "")
			{
				setmodel(wep, nextmodel);
				nextmodel = "";
			}
				
			torso.lerpfrac -= frametime * 5;
			if(torso.lerpfrac < 0)
				torso.lerpfrac = 0;
		}
		reloading -= frametime;
		if(reloading <= 0)
		{
			if(weapon == 0 && ammo == 0)
				ammo = 8;
			reloading = 0;
		}
	}
	
	return 1;
}

float(float isnew) enemylisten =
{
	local float vell;
	vell = 0;
	if(isnew)
	{
		self.oldorg = self.origin;
	}

	vell = vlen(self.oldorg - self.origin)/frametime;
	//print(ftos(vell));
	//print("\n");
	self.frame2 = 0;
	if(self.oframe1 != self.frame)
	{
		self.oframe1 = self.frame;
		self.f1start = time;
	}
	self.frame1time = time - self.f1start;
	/*if(self.oframe2 != self.frame2)
	{
		self.oframe2 = self.frame2;
		self.f2start = time;
	}*/
	//self.frame2time = time - self.f2start;
	
	if(self.frame == 1)
	{
		self.lerpfrac = 1 - (vell/250);
		if(self.lerpfrac > 1)
			self.lerpfrac = 1;
		else if(self.lerpfrac < 0)
			self.lerpfrac = 0;
	}
	else
		self.lerpfrac = 0;
	
	
	self.oldorg = self.origin;
	return 1;
}

noref void(float apiver, string enginename, float enginever) CSQC_Init =
{
	setcursormode(TRUE,"menu/cursor");
	registercommand("togglemenu");
	//print("CSQC Started\n");
	mheld = FALSE;
	semi = TRUE;
	precache_model("models/click.iqm");
	precache_model("models/player_lower.iqm");
	precache_model("models/pistol.iqm");
	precache_model("models/player_upper.iqm");
	precache_model("models/muzzleflash.iqm");
	precache_model("models/shotgun.iqm");
	precache_model("models/mg.iqm");
	precache_model("models/revolver.iqm");
	precache_sound("sound/pickup.wav");
	click = spawn();
	wep = spawn();
	setmodel(wep, "models/pistol.iqm");
	wep.renderflags += RF_NOSHADOW;
	muzzleflash = spawn();
	setmodel(muzzleflash, "models/muzzleflash.iqm");
	torso = spawn();
	setmodel(torso, "models/player_upper.iqm");
	torso.frame = 0;
	torso.frame2 = 1;
	wep.scale = 1.3;
	setmodel(click, "models/click.iqm");
	if(serverkey("constate") == "disconnected")
		ToggleMenu();
		
	local entity block;
	block = spawn();
	setsize(block, '-1024 -1024 0', '1024 1024 4');
	setorigin(block, '0 0 68');
	block.solid = SOLID_BBOX;
	countdowntime = 0;
	countdown2 = 0;
	weapon = 0;
	muzzleoffset = 2;
	ammo = 8;
	reloading = 0;
	nextmodel = "";
	
	particleeffectnum("particles.sparks");
	particleeffectnum("particles.bloodhit");
	
	round = 0;
	score = -1;
};

noref void() CSQC_WorldLoaded =
{

};

void() CSQC_Ent_Remove =
{
	remove(self);
};

noref void(float width, float height, float menushown) CSQC_UpdateView =
{
	clearscene();
	g_width = width;
	g_height = height;
	
	player_org = getentity(player_localentnum, GE_ORIGIN);
	player_forward = getentity(player_localentnum, GE_FORWARD);
	player_right = getentity(player_localentnum, GE_RIGHT);
	
	deltalisten("models/player_lower.iqm", playerlisten, 0);
	deltalisten("models/enemy.iqm", enemylisten, 0);
	
	setviewprop(VF_DRAWENGINESBAR, 0);	
	setviewprop(VF_DRAWCROSSHAIR, 0);
	setviewprop(VF_ORIGIN, [0, 0, 768]);
	setviewprop(VF_ANGLES, [90, 0, 0]);
	
	addentities(MASK_ENGINE);
	
	if(click.alpha > 0.02)
	{
		click_predraw();
		addentity(click);
	}
	
	
	setviewprop(VF_VIEWENTITY, 0);
	
	traceline(unproject([cursor_pos_x, cursor_pos_y, 0]), unproject([cursor_pos_x, cursor_pos_y, 5000]), 0, click);
	aimpos = trace_endpos - '0 0 72';
	
	/*if(mheld && (time > attackfinished) && reloading == 0)
	{
		local vector dir;
		dir = aimpos - player_org;
		dir_z = 0;
		dir = normalize(dir);

		if(weapon == 0 && semi)
		{
			ammo -= 1;
			semi = FALSE;
			muzzleflash.alpha = 1;
			muzzleflash.scale = 0.3 + random()*0.9;
			attackfinished = time + 0.1;
			sendevent("fire", "vv", wep.origin, dir);
		}
		else if(weapon == 1 && semi)
		{
			ammo -= 1;
			semi = FALSE;
			muzzleflash.alpha = 1;
			muzzleflash.scale = 0.5 + random()*0.9;
			attackfinished = time + 0.6;
			sendevent("fire", "vv", wep.origin, dir);
		}
		else if(weapon == 2)
		{
			ammo -= 1;
			muzzleflash.alpha = 1;
			muzzleflash.scale = 0.3 + random()*0.9;
			attackfinished = time + 0.075;
			sendevent("fire", "vv", wep.origin, dir);
		}
		else if(semi)
		{
			ammo -= 1;
			semi = FALSE;
			muzzleflash.alpha = 1;
			muzzleflash.scale = 0.5 + random()*0.9;
			attackfinished = time + 0.5;
			sendevent("fire", "vv", wep.origin, dir);
		}
		
		if(ammo <= 0)
		{
			if(weapon != 0)
			{
				print("Out of ammo, back to pistol\n");
				nextmodel = "models/pistol.iqm";
				weapon = 0;
				reloading = 0.5;
				muzzleoffset = 1;
			}
			else
			{
				reloading = 1;
			}
		}
	}*/

	
	local vector aimangles = vectoangles(aimpos - player_org) - vectoangles(player_forward);
	local float targetyaw = aimangles_y;
	targetyaw += 180;
	if(targetyaw < 0)
		targetyaw += 360;
	if(targetyaw > 360)
		targetyaw -= 360;
	
	targetyaw = 360 - targetyaw;
	
	torso.frame1time = targetyaw/360;
	
	addentity(torso);
	addentity(wep);
	
	if(muzzleflash.alpha > 0.05)
	{
		muzzleflash_predraw();
		addentity(muzzleflash);
		dynamiclight_add(muzzleflash.origin, 256 * muzzleflash.alpha, muzzleflash.alpha * [1, 0.6, 0.3]);
	}
	
	renderscene();
	
	if(dmgtime > 0)
	{
		drawfill([0,0,0],[g_width,g_height,0],[0.5,0.05,0.05],0.5 - (1-dmgtime),1);
		dmgtime -= frametime;
	}
	
	if(score == -1)
	{
		if(countdown2 > 0)
		{
			if(countdowntime == 0)
				drawstring([g_width*0.375, 40, 0], "FIGHT!", [16, 16, 0], [1, 1, 1], countdown2, 0);
			else
			{
				drawstring([g_width*0.325, 24, 0], "NEW ROUND IN...", [8, 8, 0], [1, 1, 1], 1, 0);
				drawstring([g_width*0.475, 40, 0], ftos(countdowntime), [16, 16, 0], [1, 1, 1], countdown2, 0);
			}
			countdown2 -= frametime;
		}
		drawstring([g_width - 72, 4, 0], "Round:", [8, 8, 0], [1, 1, 1], 1, 0);
		drawstring([g_width - 16, 4, 0], ftos(round), [16, 16, 0], [1, 1, 1], 1, 0);
		
		drawstring([g_width - 104, g_height - 18, 0], "Health:", [8, 8, 0], [1, 1, 1], 1, 0);
		drawstring([g_width - 50, g_height - 18, 0], ftos(getstatf(STAT_HEALTH)), [16, 16, 0], [1, 1, 1], 1, 0);
		
		local string tstring = "";
		
		if(weapon == 0)
			tstring = "Pistol";
		else if(weapon == 1)
			tstring = "Shotgun";
		else if(weapon == 2)
			tstring = "Machinegun";
		else
			tstring = "Revolver";
			
		drawstring([2, g_height - 26, 0], tstring, [8, 8, 0], [1, 1, 1], 1, 0);
		drawstring([2, g_height - 18, 0], "Ammo:", [8, 8, 0], [1, 1, 1], 1, 0);
		if(ammo == 0)
			drawstring([42, g_height - 18, 0], "RELOADING...", [8, 8, 0], [1, 1, 1], 1, 0);
		else
			drawstring([42, g_height - 18, 0], ftos(ammo), [16, 16, 0], [1, 1, 1], 1, 0);

			
		//drawstring([32, 32, 0], ftos(torso.frame1time), [8, 8, 0], [1, 1, 1], 1, 0);
	}
	else
	{
		if(timeingameover < 3)
			timeingameover += frametime;
		drawfill([0,0,0],[g_width,g_height,0],[0.5,0.05,0.05],timeingameover/3,0);
		drawstring([g_width*0.255, 40, 0], "GAME OVER!", [16, 16, 0], [1, 1, 1], timeingameover/3, 0);
		drawstring([g_width/2 - 56, 64, 0], "Score:", [8,8,0],[1,1,1], timeingameover/3, 0);
		drawstring([g_width/2 + 32, 64, 0], ftos(score), [8,8,0],[1,1,1], timeingameover/3, 0);
		drawstring([g_width/2 - 72, g_height - 16, 0], "Press ESC for menu", [8,8,0],[1,1,1], timeingameover/3, 0);
	}
	
	if(in_menu)
	{
		Draw_Menu();
	}
	else
	{
		drawpic([cursor_pos_x, cursor_pos_y, 0],"menu/cursor2.tga",[8,8,0],[1,1,1],1);
	}
};

noref float(string cmd) CSQC_ConsoleCommand =
{
	//self = theplayer;
	//if (!self)
	//	return FALSE;

	tokenize(cmd);
	switch(argv(0))
	{
		case "togglemenu":
			ToggleMenu();
			return TRUE;
			break;
		case "map":
			return FALSE;
			break;
		default:
			return FALSE;
	}
	return FALSE;
};

noref float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	switch(evtype)
	{
	case IE_KEYDOWN:
		if(in_menu != MENU_NONE)
		{
			if(scanx == K_MOUSE1)
			{
				//(print(strcat(ftos(cursor_pos_x), ", ", ftos(cursor_pos_y), "\n"));
				Menu_Click();
				return TRUE;
			}
		}
		else
		{
			local vector pos1, pos2;
			if(scanx == K_MOUSE1)
			{
				//print("sending mouse I think\n");
				return FALSE;
			}
			else if(scanx == K_MOUSE2)
			{
				click.alpha = 1;
				click.scale = 1;
				setorigin(click, aimpos + '0 0 48');
			}
			else if(scanx == K_SPACE)
				reloading = 1.5;
		}
		return FALSE;
	case IE_KEYUP:
		if(scanx == K_MOUSE1 && in_menu == MENU_NONE)
			return FALSE;
		return FALSE;
	case IE_MOUSEDELTA:
		if(in_menu == MENU_NONE)
		{
			cursor_pos_x += scanx;
			cursor_pos_y += chary;
			if(cursor_pos_x > g_width)
				cursor_pos_x = g_width;
			else if(cursor_pos_x < 0)
				cursor_pos_x = 0;
			if(cursor_pos_y > g_height)
				cursor_pos_y = g_height;
			else if(cursor_pos_y < 0)
				cursor_pos_y = 0;
		}
		return FALSE;
	case IE_MOUSEABS:
		//if(devid != 0 && devid != 1)
		//	return FALSE;
		cursor_pos_x = scanx;
		cursor_pos_y = chary;
		return TRUE;
	}
	return FALSE;
};

noref void() CSQC_Input_Frame =
{
	local vector target;
	target = click.origin;
	target_z = player_org_z;
	target = (player_org - target);
	input_angles = vectoangles(normalize(target), [0, 0, 1]);
	input_angles_y -= 180;
	input_angles_x = 0;
	input_angles_z = 0;
	if(vlen(target) > 32)
	{
		input_movevalues = 400 * [1,0,0];
	}
	else
	{
		input_movevalues = [0,0,0];
	}
	runstandardplayerphysics(self);
	
	//use roll field of inout angles to give aim yaw to server all the time
	local vector aimangles = vectoangles(normalize(player_org - aimpos), [0, 0, 1]);
	input_angles_z = aimangles_y -= 180;
	
}

noref void() CSQC_Parse_Event =
{
	float byte = readbyte();
	
	if(byte == 0)
	{
		countdowntime = readbyte();
		countdown2 = 1;
	}
	else if(byte == 1)
	{
		print("You picked up a shotgun\n");
		nextmodel = "models/shotgun.iqm";
		muzzleoffset = 24;
		weapon = 1;
		ammo = 6;
		reloading = 0.5;
	}
	else if(byte == 2)
	{
		print("You picked up a machinegun\n");
		nextmodel = "models/mg.iqm";
		muzzleoffset = 32;
		weapon = 2;
		ammo = 30;
		reloading = 0.5;
	}
	else if(byte == 3)
	{
		print("You picked up a revolver\n");
		nextmodel = "models/revolver.iqm";
		muzzleoffset = 4;
		weapon = 3;
		ammo = 6;
		reloading = 0.5;
	}
	else if(byte == 4)
	{
		round = readbyte();
	}
	else if(byte == 5)
	{
		score = readshort();
	}
	else if(byte == 6)
	{
		dmgtime = 1;
	}
	else if(byte == 7)
	{
		reloading = readbyte();
	}
	else if(byte == 8)
	{
		muzzleflash.alpha = 1;
		switch(weapon)
		{
			case 0:
				muzzleflash.scale = 0.2 + random() * 0.6;
				break;
			case 1:
				muzzleflash.scale = 0.7 + random();
				break;
			case 2:
				muzzleflash.scale = 0.6 + random() * 0.4;
				break;
			case 3:
				muzzleflash.scale = 0.5 + random()  * 0.5;
				break;
			default:
				muzzleflash.scale = 1;
				break;
		}
	}
}