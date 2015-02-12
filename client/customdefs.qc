//Various globals that are used in this FTEQW example are defined here, they are not used by the engine itself

#pragma warning disable Q302
vector cursor_pos; /* Current mouse cursor position, updated in csqc_inputevent */
float g_width, g_height; /* Globals for screen width and height */

//Menu stuff
float in_menu; //what menu are we in
float time_in_menu;

const float MENU_NONE = 0;
const float MENU_MAIN = 1;
const float MENU_SINGLE = 2;
const float MENU_MULTI = 4;
const float MENU_SETTINGS = 8;
const float MENU_ABOUT = 16;
const float MENU_JOIN = 32;

entity player;
vector player_forward;
vector player_right;
vector player_org;
entity click;
entity wep;
entity torso;
entity muzzleflash;
float torso_offset;
float player_skel;
.float animdir;
vector aimpos;
.vector oldorg;
float countdowntime;
float countdown2;
float mheld;
float weapon;
float attackfinished;
float semi;
float ammo;
.float oframe1;
.float oframe2;
.float f1start;
.float f2start;
float muzzleoffset;
float round;
float score;
float timeingameover;
float dmgtime;
float reloading;
string nextmodel;
