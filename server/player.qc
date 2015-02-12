//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

void() PlayerPreThink =
{
	if(self.button0)
	{
		if(time > self.attacking)
			fire();
	}
	else
		self.semi = TRUE;
};

void() PlayerPostThink =
{

};

void() ClientKill =
{

};

//called when a client connects to the server
void() ClientConnect =
{
	bprint(PRINT_HIGH, self.netname); //print player name
	bprint(PRINT_HIGH, " connected.\n");
};

void() PlayerSpawn =
{
	local entity spawnpoint;
	spawnpoint = find(world, classname, "info_player_start");
	
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/player_lower.iqm");
	self.movetype = MOVETYPE_WALK;
	self.health = 100;
	self.origin = spawnpoint.origin + [0,0,1];
	self.fixangle = TRUE;
	self.attacking = FALSE;
	setsize(self, [-16, -16, 0], [16, 16, 64]);
	self.view_ofs = '0 0 22';
	stuffcmd(self, "cd loop 1\n");
};

//called when a client loads a map
void() PutClientInServer =
{
	self.score = 0;
	PlayerSpawn();
};

//called when client disconnects from the server
void() ClientDisconnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has left the game.\n");
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FLY;
	setmodel(self, "");
};


void() SetNewParms =
{
};

void() SetChangeParms =
{
};

void() info_player_start =
{
	
};

void() SV_RunClientCommand =
{
	//bprint(PRINT_HIGH,vtos(input_angles));
	//bprint(PRINT_HIGH,"\n");
	self.aimyaw = input_angles_z;
	input_angles_z = 0;
	runstandardplayerphysics(self);
	if(vlen(input_movevalues) >= 200)
	{
		self.angles = input_angles;
		self.fixangle = TRUE;
	}
}