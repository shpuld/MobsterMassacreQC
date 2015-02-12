
void(optional entity ignore) findnode =
{
	local entity head, success;
	local float numelements = 0;
	success = world;

	if(!ignore)
		ignore = world;

	head = find(world, classname, "info_monster_path");
	while(head != world)
	{
		traceline(self.origin + [0, 0, 32], head.origin, FALSE, self);
		if(trace_fraction >= 1)
		{
			if(head != ignore)
			{
				numelements++;
				head.chain = success;
				success = head;
			}
		}
		head = find(head, classname, "info_monster_path");
	}
	
	if(success != world)
	{
		local float i = rint(random() * numelements);
		local float asd = i;
		while(i > 1)
		{
			i--;
			success = success.chain;
		}
		//bprint(PRINT_HIGH, strcat(success.classname," ", ftos(asd), " ", ftos(numelements)," setting goalent\n"));
		self.goalentity = success;
	}
}

float() findplayer =
{
	local entity head, success;
	success = world;
	head = find(world, classname, "player");
	while(head != world)
	{
		traceline(self.origin + [0, 0, 32], head.origin + [0,0,16], FALSE, self);
		if(trace_ent.classname == "player")
		{
			success = head;
		}
		head = find(head, classname, "player");
	}
	
	if(success != world)
	{
		self.goalentity = success;
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

float() checktarget =
{
	traceline(self.origin + [0, 0, 32], self.goalentity.origin + [0,0,16], TRUE, self);
	if(trace_fraction >= 1)
	{
		return TRUE;
	}
		return FALSE;
}

void() monster_think =
{
	if(self.health >= 0 && time > self.attacking)
		self.frame = 1;
		
	if(self.health <= 0)
		return;
		
	if(!self.goalentity)
	{
		//bprint(PRINT_HIGH, "no target for me yet\n");
		//if(!findplayer())
			findnode();
	}
	else
	{
		local float temp = -1;
		if(self.goalentity.classname != "player")
		{
			if(self.goalentity == uselastseen)
			{
				temp = vlen(self.lastseen - self.origin);
				if(temp < 50)
				{
					if(!findplayer())
					{
						findnode();
					}
				}
				else if(vlen(self.velocity) < 5)
				{
					findnode();
				}
			}
			else
			{
				temp = vlen(self.goalentity.origin - self.origin);
				if(temp < 50)
				{
					//bprint(PRINT_HIGH, "new target...\n");
					findnode(self.goalentity);
				}
				else if(vlen(self.velocity) < 5)
				{
					findnode();
				}
			}
		}
		else
		{
			if(checktarget())
			{
				self.lastseen = self.goalentity.origin;
			}
			else
			{
				self.goalentity = uselastseen;
			}
		}
		findplayer();
		
		local vector target;
		if(self.goalentity == uselastseen)
			target = self.lastseen;
		else
			target = self.goalentity.origin;
		target_z = self.origin_z;
		self.angles = vectoangles(target - self.origin);
		self.velocity += normalize(target - self.origin) * 100;

		if(temp > 0)
		{
			self.velocity *= temp/50;
		}
		if(vlen(self.velocity) > 240)
		{
			self.velocity = normalize(self.velocity) * 240;
		}
		
		if(self.goalentity.classname != "player" && self.goalentity != uselastseen)
			self.velocity *= 0.65;
		
		self.velocity_z = 0;
		if(time < self.attacking)
			self.velocity *= 0.25;
	}
	self.nextthink = time + 0.1;
	self.think = monster_think;
}

void() info_monster_start1 =
{
	spawns++;
}

void() info_monster_path =
{

}

vector() findspawn =
{
	local entity point;
	point = find(world, classname, "info_monster_start1");
	local float select = random() * spawns;
	select = floor(select);
	local float i = 1;
	//bprint(PRINT_HIGH, strcat(ftos(select), "/", ftos(spawns), "\n"));
	while(i <= select)
	{
		i++;
		point = find(point, classname, "info_monster_start1");
	}
		
	return point.origin;
}

void() disappear =
{
	if(self.classname != "enemy")
		powerup_in = FALSE;
	self.score += 0.5;
	if(self.score == floor(self.score))
		self.alpha = 0.01;
	else
		self.alpha = 1;
	if(self.score > 3)
		remove(self);
	self.nextthink = time + 0.25;
	self.think = disappear;
}

void() monstertouch =
{
	if(other.classname == "enemy")
	{
		if(self.mass > other.mass)
		{
			other.velocity += (other.origin - self.origin) * 6;
			other.velocity_z = 0;
		}
	}
	else if(other.classname == "player" && time > self.attacking)
	{
		if(other.health > 0)
			damage(other, self, 8 + rint(random() * 4));
		self.attacking = time + 0.5;
		self.frame = 3 + rint(random());
	}
}

void(vector pos) spawn_monster =
{
	local entity monster;
	monster = spawn();
	setorigin(monster, pos + [0, 0, 1]);
	setsize(monster, [-16, -16, 0], [16, 16, 64]);
	monster.classname = "enemy";
	setmodel(monster, "models/enemy.iqm");
	monster.solid = SOLID_SLIDEBOX;
	monster.movetype = MOVETYPE_WALK;
	monster.nextthink = time + 0.1;
	monster.think = monster_think;
	monster.health = 50;
	monster.mass = random();
	monster.touch = monstertouch;
	monster.frame = 1;
	monster.score = 0;
	droptofloor();
	
	total_monsters++;
}

void() roundstart;

void() gamemanager_think =
{
	if(total_monsters == 0 && guystokill == 0)
	{
		sound(self,0,"sound/roundcomplete.wav", 1, 0);
		self.nextthink = time + 1;
		self.think = roundstart;
		return;
	}
	if((time > previtem + 5) && powerup_in == FALSE)
	{
		if(random() > 0.5)
		{
			spawnpowerup();
		}
		else
			previtem = time + 3;
	}
	local float asd = 6 + round * 2;
	if(asd > 25)
		asd = 25;
	if(total_monsters < asd)
	{
		if(guystokill > 0)
		{
			spawn_monster(findspawn());
			guystokill--;
		}
	}
		
	if(round < 3)
		self.nextthink = time + 4;
	else if(round < 5)
		self.nextthink = time + 3;
	else if(round < 7)
		self.nextthink = time + 2;
	else
		self.nextthink = time + 1;
		
	self.think = gamemanager_think;
}

void() countdown =
{
	if(count > 0)
	{
		if(count <= 3)
			sound(self, 0, strcat("sound/",ftos(count),".wav"), 1, 0);
		else if(count == 5)
			sound(self,0,"sound/newround.wav", 1, 0);
		self.nextthink = time + 1;
		self.think = countdown;
	}
	else
	{
		sound(self, 0, "sound/fight.wav", 1, 0);
		self.nextthink = time + 1;
		self.think = gamemanager_think;
	}
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, 0);
	WriteByte(MSG_MULTICAST, count);
	multicast('0 0 0', MULTICAST_ALL);
	
	count--;
}

void() roundstart =
{
	round++;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, 4);
	WriteByte(MSG_MULTICAST, round);
	multicast('0 0 0', MULTICAST_ALL);
	guystokill = 10 * round;
	count = 5;
	self.nextthink = time + 1;
	self.think = countdown;
}