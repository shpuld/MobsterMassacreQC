
void() disappear;

void() nullfunc =
{

}

void(entity target, entity attacker) killed =
{
	if(target.classname == "enemy")
	{
		if(target.frame != 2)
			target.frame = 2;
		target.solid = SOLID_NOT;
		setsize(target, '-16 -16 0', '16 16 16'); 
		target.touch = nullfunc;
		target.movetype = MOVETYPE_STEP;
		target.nextthink = time + 1;
		target.think = disappear;
		total_monsters--;
		if(attacker.classname == "player")
		{
			attacker.score++;
		}
	}
	
	if(target.classname == "player")
	{
		msg_entity = target;
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, 5);
		WriteShort(MSG_MULTICAST, target.score);
		multicast('0 0 0', MULTICAST_ONE);
		sound(target,0,"sound/gameover.wav",1,0);
	}
}

void(entity target, entity attacker, float amount) damage =
{
	target.health -= amount;
	if(random() > 0.5)
		sound(target, 1, "sound/pain1.wav", 0.5, 0.8);
	else
		sound(target, 1, "sound/pain2.wav", 0.5, 0.8);
		
	if(target.classname == "player")
	{
		msg_entity = target;
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, 6);
		multicast('0 0 0', MULTICAST_ONE);
	}
	if(target.health <= 0)
	{
		killed(target, attacker);
	}
}

void() projectiletouch =
{	

	sound(self, 0, "sound/impact.wav", 0.8 - random() * 0.4, 0.75, 92 + (random()*12));
	if(other != self.owner)
	{
		if(other.classname != "enemy")
		{
			pointparticles(particleeffectnum("particles.sparks"),self.origin,(-1 * self.velocity), 1);
		}
		else if(other.health > 0)
		{
			pointparticles(particleeffectnum("particles.bloodhit"),self.origin + 4*normalize(self.velocity),(-1 * self.velocity), 1);
			
			if(self.classname == "pistol_projectile")
			{
				damage(other, self.owner, 12);
				other.velocity += self.velocity * 0.15;
			}
			else if(self.classname == "shotgun_projectile")
			{
				if(time < self.attacking + 0.15)
					damage(other, self.owner, 35);
				else if(time < self.attacking + 0.3) 
					damage(other, self.owner, 25);
				else
					damage(other, self.owner, 15);
				other.velocity += self.velocity * 0.2;
			}
			else if(self.classname == "ak_projectile")
			{
				damage(other, self.owner, 22);
				other.velocity += self.velocity * 0.2;
			}
			else
			{
				damage(other, self.owner, 55);
				other.velocity += self.velocity * 0.2;
			}
		}
		remove(self);
	}
}

void() fire =
{
	local vector dir, pos;
	makevectors([0, self.aimyaw, 0]);
	dir = v_forward;
	pos = self.origin + dir * 4 + '0 0 32';
	if(self.weapon == 0 && semi)
	{
		self.ammo_shells--;
		newmis = spawn();
		setorigin(newmis, pos);
		setsize(newmis, '0 0 0', '0 0 0');
		newmis.solid = SOLID_BBOX;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.velocity = dir * 1800;
		setmodel(newmis, "models/bullet.iqm");
		newmis.scale = 1;
		newmis.touch = projectiletouch;
		newmis.owner = self;
		newmis.angles = vectoangles(dir);
		newmis.fixangle = TRUE;
		newmis.classname = "pistol_projectile";
		sound(self, 0, "sound/gunshot1.wav", 1, 0.5, 99 + (random()*2));
		self.attacking = time + 0.1;
		semi = FALSE;
		
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, 8);
		multicast(self.origin, MULTICAST_PVS);
	}
	else if(self.weapon == 1 && semi)
	{
		local float scount = 0;
		sound(self, 0, "sound/gunshot2.wav", 1, 0.5, 99 + (random()*2));
		self.ammo_shells--;
		while(scount < 8)
		{
			newmis = spawn();
			setorigin(newmis, pos);
			dir_x += (random() - 0.5) * 0.21;
			dir_y += (random() - 0.5) * 0.21;
			setsize(newmis, '0 0 0', '0 0 0');
			newmis.solid = SOLID_BBOX;
			newmis.movetype = MOVETYPE_FLYMISSILE;
			newmis.velocity = dir * 1800;
			setmodel(newmis, "models/bullet.iqm");
			newmis.scale = 1;
			newmis.touch = projectiletouch;
			newmis.owner = self;
			newmis.angles = vectoangles(dir);
			newmis.fixangle = TRUE;
			newmis.classname = "shotgun_projectile";
			newmis.attacking = time;
			scount++;
		}
		self.attacking = time + 0.5;
		semi = FALSE;
		
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, 8);
		multicast(self.origin, MULTICAST_PVS);
	}
	else if(self.weapon == 2)
	{
		self.ammo_shells--;
		newmis = spawn();
		setorigin(newmis, pos);
		dir_x += (random() - 0.5) * 0.15;
		dir_y += (random() - 0.5) * 0.15;
		setsize(newmis, '0 0 0', '0 0 0');
		newmis.solid = SOLID_BBOX;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.velocity = dir * 1400;
		setmodel(newmis, "models/bullet.iqm");
		newmis.scale = 1;
		newmis.touch = projectiletouch;
		newmis.owner = self;
		newmis.angles = vectoangles(dir);
		newmis.fixangle = TRUE;
		newmis.classname = "ak_projectile";
		sound(self, 0, "sound/gunshot3.wav", 1, 0.5, 99 + (random()*2));
		self.attacking = time + 0.07;
		semi = FALSE;
		
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, 8);
		multicast(self.origin, MULTICAST_PVS);
	}
	else if(self.weapon == 3 && semi)
	{
		self.ammo_shells--;
		newmis = spawn();
		setorigin(newmis, pos);
		setsize(newmis, '0 0 0', '0 0 0');
		newmis.solid = SOLID_BBOX;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.velocity = dir * 3000;
		setmodel(newmis, "models/bullet.iqm");
		newmis.scale = 1.4;
		newmis.touch = projectiletouch;
		newmis.owner = self;
		newmis.angles = vectoangles(dir);
		newmis.fixangle = TRUE;
		newmis.classname = "revolver_projectile";
		sound(self, 0, "sound/gunshot4.wav", 1, 0.5, 99 + (random()*2));
		self.attacking = time + 0.5;
		semi = FALSE;
		
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, 8);
		multicast(self.origin, MULTICAST_PVS);
	}
	
	if(self.ammo_shells <= 0)
	{
		self.weapon = 0;
	}
}

void() info_pickup =
{
	powerups++;
}

vector() findpowerupspawn =
{
	local entity point;
	point = find(world, classname, "info_pickup");
	local float select = random() * powerups;
	select = floor(select);
	local float i = 1;
	//bprint(PRINT_HIGH, strcat(ftos(select), "/", ftos(spawns), "\n"));
	while(i <= select)
	{
		i++;
		point = find(point, classname, "info_pickup");
	}
		
	return point.origin;
}

void() shotguntouch =
{
	if(other.classname != "player")
		return;
		
	remove(self);
	//sound(other, 0, "sound/pickup.wav", 1, 0.5);
	msg_entity = other;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, 1);
	multicast('0 0 0', MULTICAST_ONE);
	powerup_in = FALSE;
	previtem = time;
	other.weapon = 1;
	other.ammo_shells = 6;
	
	
	sound(other,0,"sound/pickup.wav",1,0.6);
	float randy = ceil(random()*5);
	sound(other,0,strcat("sound/voice",ftos(randy),".wav"),1,0);
}

void() mgtouch =
{
	if(other.classname != "player")
		return;
		
	remove(self);
	//sound(other, 0, "sound/pickup.wav", 1, 0.5);
	msg_entity = other;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, 2);
	multicast('0 0 0', MULTICAST_ONE);
	powerup_in = FALSE;
	previtem = time;
	other.weapon = 2;
	other.ammo_shells = 30;
	
	sound(other,0,"sound/pickup.wav",1,0.6);
	float randy = ceil(random()*5);
	sound(other,0,strcat("sound/voice",ftos(randy),".wav"),1,0);
}

void() revolvertouch =
{
	if(other.classname != "player")
		return;
		
	remove(self);
	//sound(other, 0, "sound/pickup.wav", 1, 0.5);
	msg_entity = other;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, 3);
	multicast('0 0 0', MULTICAST_ONE);
	powerup_in = FALSE;
	previtem = time;
	other.weapon = 3;
	other.ammo_shells = 6;

	sound(other,0,"sound/pickup.wav",1,0.6);
	float randy = ceil(random()*5);
	sound(other,0,strcat("sound/voice",ftos(randy),".wav"),1,0);
}

void() spawnpowerup =
{
	//bprint(PRINT_HIGH, "spawned powerup\n");
	powerup_in = TRUE;
	local float rrr = random();
	local entity item;
	item = spawn();
	setorigin(item, findpowerupspawn() + [0, 0, 1]);
	setsize(item, [-32, -32, 0], [32, 32, 64]);

	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_NONE;
	
	item.score = 0;
	item.nextthink = time + 8;
	item.think = disappear;
	
	item.modelflags += MF_ROTATE;
	item.scale = 2;
	item.effects = EF_DIMLIGHT;
	item.pflags = PFLAGS_NOSHADOW;
	
	previtem = time;

	if(rrr < 0.33)
	{
		item.classname = "shotgun";
		setmodel(item, "models/shotgun.iqm");
		item.touch = shotguntouch;
	}
	else if(rrr < 0.66)
	{
		item.classname = "mg";
		setmodel(item, "models/mg.iqm");
		item.touch = mgtouch;
	}
	else
	{
		item.classname = "revolver";
		setmodel(item, "models/revolver.iqm");
		item.touch = revolvertouch;
	}

	droptofloor();
}