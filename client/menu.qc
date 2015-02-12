//
//	Menu stuff
//


void() menu_single =
{
	in_menu = MENU_NONE;
	localcmd("map ld31\n");
	time_in_menu = 0;
};

void() menu_about =
{
	in_menu = MENU_ABOUT;
	time_in_menu = 0;
};

void() menu_quit =
{
	localcmd("quit\n");
};

void() menu_back =
{
	in_menu = MENU_MAIN;
	time_in_menu = 0;
};


//struct for all buttons, note pos and scale are going to be multiplied with width/height in draw step, so keep them between 0 and 1
var struct
{
	vector pos;
	vector scale;
	string text;
	float active; //used for mouseover hilight (positive values) and alpha (negative values)
	void() action; //function that is called when the button is pressed
	float group; //a bit field, button will be usable/visible when these bits are active
} buttons[] =
{
	{[0.375, 0.600, 0], [0.25, 0.05, 0], "New Game", -1, menu_single, MENU_MAIN},
	{[0.375, 0.675, 0], [0.25, 0.05, 0], "How to Play", -1, menu_about, MENU_MAIN},
	{[0.375, 0.750, 0], [0.25, 0.05, 0], "Quit", -1, menu_quit, MENU_MAIN},
	{[0.375, 0.900, 0], [0.25, 0.05, 0], "Back", -1, menu_back, MENU_SINGLE + MENU_ABOUT},
};

//REMEMBER TO UPDATE THIS CONST IF YOU ADD BUTTONS
const float BUTTONS_COUNT = 4;


//this function handles drawing the buttons and checking if they should be active/hilighted
void(float index) Update_Button = 
{
	if(in_menu != in_menu & buttons[index].group)
		buttons[index].active = -1;
		
	if(buttons[index].active == -1)
	{
		if(in_menu == in_menu & buttons[index].group)
			buttons[index].active = 1;
		else
			return;
	}
	
	local vector pos = buttons[index].pos;
	pos_x *= g_width;
	pos_y *= g_height;
	local vector scale = buttons[index].scale;
	scale_x *= g_width;
	scale_y *= g_height;
	
	local float alphafactor;
	
	if(buttons[index].active > 0)
		alphafactor = 1;
	else
		alphafactor = buttons[index].active + 1; //-1 invis, 0 normal
	
	if(cursor_pos_x > pos_x && cursor_pos_x < pos_x + scale_x && cursor_pos_y > pos_y && cursor_pos_y < pos_y + scale_y )
		buttons[index].active = 1;
	
	drawfill(pos, scale, [0.2,0.2,0.2] + [0.15,0.15,0.15]*buttons[index].active, 0.3 * alphafactor);
	drawline(1, pos, [pos_x + scale_x, pos_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //top outline
	drawline(1, pos, [pos_x, pos_y + scale_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //left outline
	drawline(1, [pos_x, pos_y + scale_y, 0], [pos_x + scale_x, pos_y + scale_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //bottom outline
	drawline(1, [pos_x + scale_x, pos_y, 0], [pos_x + scale_x, pos_y + scale_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //right outline
	drawstring(pos + [scale_x*0.05, scale_y*0.25, 0], buttons[index].text, [scale_y*0.5, scale_y*0.5, 1], [0.8,0.8,0.8], 1 * alphafactor, 1);
	
	if(buttons[index].active > 0)
	{
		buttons[index].active -= frametime * 5;
		if(buttons[index].active < 0)
			buttons[index].active = 0;
	}
};


void(float index) Button_Click = 
{
	//don't click if not active
	if(buttons[index].active == -1)
		return;
		
	local vector pos = buttons[index].pos;
	pos_x *= g_width;
	pos_y *= g_height;
	local vector scale = buttons[index].scale;
	scale_x *= g_width;
	scale_y *= g_height;
	
	if(cursor_pos_x > pos_x && cursor_pos_x < pos_x + scale_x && cursor_pos_y > pos_y && cursor_pos_y < pos_y + scale_y )
	{
		buttons[index].action(); //do whatever this button is supposed to do
	}
};


void() Menu_Click =
{
	float i;
	for(i = 0; i < BUTTONS_COUNT; i++)
	{
		Button_Click(i);
	}
};

void() Draw_Menu =
{
	if(serverkey("constate") != "disconnected")
		drawfill([0,0,0], [g_width, g_height, 0], [0, 0, 0], 0.75);
	else
		drawfill([0,0,0], [g_width, g_height, 0], [0, 0, 0], 1);
	local string title = "";
	switch(in_menu)
	{
		case MENU_MAIN:
			title = "Mobster Massacre";
			drawstring([0.225*g_width, 0.35*g_height, 0], "A Ludum Dare #31 Compo Entry", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawstring([0.4*g_width, 0.425*g_height, 0], "By Shpuld", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			break;
		case MENU_ABOUT:
			drawpic([g_width * 0.1,0,0],"menu/about.tga",[g_width * 0.8, g_height * 0.95, 0], [1,1,1], 1);
			break;
		default:
			title = "";
	}
	
	drawstring([0.2*g_width, 0.25*g_height, 0], title, [g_height * 0.05, g_height * 0.05, 1], [0.8, 0.8, 0.8], 1, 1);
	
	
	//Update buttons
	local float i;

	for(i = 0; i < BUTTONS_COUNT; i++)
	{
		Update_Button(i);
	}
};