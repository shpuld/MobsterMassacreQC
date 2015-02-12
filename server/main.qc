//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//

//called when starting server/loading the map
void() main =
{
	localcmd("echo Server starting...\n");

}

void() light =
{
	remove(self);
}

//called for each frame that QC runs
void() StartFrame =
{

}

//called when map loaded
void() worldspawn =
{
	precache_model("models/player_lower.iqm");
	precache_model("models/enemy.iqm");
	precache_model("models/bullet.iqm");
	precache_model("models/click.iqm");
	precache_model("models/shotgun.iqm");
	precache_model("models/revolver.iqm");
	precache_model("models/mg.iqm");
	precache_sound("sound/gunshot1.wav");
	precache_sound("sound/gunshot2.wav");
	precache_sound("sound/gunshot3.wav");
	precache_sound("sound/gunshot4.wav");
	precache_sound("sound/impact.wav");
	precache_sound("sound/newround.wav");
	precache_sound("sound/roundcomplete.wav");
	precache_sound("sound/3.wav");
	precache_sound("sound/2.wav");
	precache_sound("sound/1.wav");
	precache_sound("sound/gameover.wav");
	precache_sound("sound/fight.wav");
	precache_sound("sound/pain1.wav");
	precache_sound("sound/pain2.wav");
	precache_sound("sound/pickup.wav");
	
	precache_sound("sound/voice1.wav");
	precache_sound("sound/voice2.wav");
	precache_sound("sound/voice3.wav");
	precache_sound("sound/voice4.wav");
	precache_sound("sound/voice5.wav");
	
	gamemanager = spawn();
	uselastseen = spawn();
	total_monsters = 0;
	spawns = 0;
	powerups = 0;
	previtem = time;
	gamemanager.nextthink = time + 3;
	gamemanager.think = roundstart;
	
	particleeffectnum("particles.sparks");
	particleeffectnum("particles.bloodhit");
}

void() SpectatorConnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has joined the spectators.\n");
}
