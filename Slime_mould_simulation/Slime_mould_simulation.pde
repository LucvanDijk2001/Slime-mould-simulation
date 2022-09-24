/*
//====agent map (map with all the agents) //agents leave trails on the trail map
 */

/*
//====trail map (map that holds intensities
 -trail intensities decide agent steering behaviour
 -needs to undergo diffusion and decay process every step 
 -diffusion = get particle positions, apply trail and mean filter on 3x3 basis
 -decay = multiplicative (i assume something like *0.8 on every trail value) 
 
 - trail should have:
 - decay factor (multiplication at which decay happens) (like 0.8);
 - diffuce size (mean map size (default would be 3x3))
 */
enum REFLECTIONS
{
  LEFT, 
    RIGHT, 
    TOP, 
    BOTTOM
}

enum SENSORDIRECTIONS
{
  SENSORDIRECTIONLEFT, 
    SENSORDIRECTIONMIDDLE, 
    SENSORDIRECTIONRIGHT
}

//population
Population p;

int agentAmount = 10000;

//trail maps
float trailMap[][];
float trailBuffer[][];

//program properties
float decayFactor =0.01;
float cellSize = 2;
float sensorDistance = 9;
int sensorSize = 2;
float sensorAngle = 45;
float rotationAngle = 6;
float randomAngleAdd = 5;
float depositionAmount = 0.5;

float c = 0;

Slider sliders[] = new Slider[]
  {
  new Slider(0, 1, 10, 30, 100, "decay factor"), 
  new Slider(1, 10, 10, 70, 100, "cell size"), 
  new Slider(1, 100, 10, 110, 100, "sensor distance"), 
  new Slider(1, 10, 10, 150, 100, "sensor size", true), 
  new Slider(10, 135, 10, 190, 100, "sensor angle"), 
  new Slider(0, 20, 10, 230, 100, "rotation angle"), 
  new Slider(0, 20, 10, 270, 100, "random angle add"), 
  new Slider(0, 5, 10, 310, 100, "cell move speed")
};

Button randomizeButton = new Button(10, 330, 100, 40, "Randomize");
Button resetButton = new Button(10, 380, 100, 40, "Reset");
Button visualizeButton = new Button(10, 430, 100, 40, "Visualize");

boolean mouseDown = false;
boolean visualize = false;

float visualizeScale = 3;

//==========================================SETUP======================================
void setup()
{
  //create canvas
  size(600, 600);
  background(0);
  colorMode(HSB);
  noStroke();

  //initialize trailmap and buffer
  trailMap = new float[width][height];
  trailBuffer = new float[width][height];

  //create slime agents
  p = new Population(agentAmount);

  //set initial slider values
  sliders[0].SetValue(0.01);
  sliders[1].SetValue(0.4);
  sliders[2].SetValue(0.09);
  sliders[3].SetValue(0.2);
  sliders[4].SetValue(0.28);
  sliders[5].SetValue(0.8);
  sliders[6].SetValue(0.25);
  sliders[7].SetValue(0.7);
}

void draw()
{
  //alpha over screen
  fill(0, 0, 0, 25.5);
  noStroke();
  rect(-10, -10, width+10, height+10);

  //set trail path to trail buffer
  for (int x = 0; x < width; x++)
  {
    for (int y = 0; y < height; y++)
    {
      trailMap[x][y] = trailBuffer[x][y];
    }
  }

  if (decayFactor >= 1)
  {
    for (int x = 0; x < width; x++)
    {
      for (int y = 0; y < height; y++)
      {
        trailMap[x][y] = 0;
        trailBuffer[x][y] = 0;
      }
    }
  }

  //update all agents (they read from the trail path but emplace to the buffer)
  p.Update();

  //apply mean diffuse filter
  DiffuseBuffer();

  //update trail path buffer with decay
  DecayBuffer();

  noStroke();
  //show agents
  p.Show();

  //show trailmap
  /*
  for(int i = 0; i < width; i++)
   {
   for(int j = 0; j < height; j++)
   {
   circle(i,j,trailMap[i][j] * 5);
   }
   }
   */

  //update slider values
  decayFactor =      sliders[0].currentVal;
  cellSize =         sliders[1].currentVal;
  sensorDistance =   sliders[2].currentVal;
  sensorSize =  (int)sliders[3].currentVal;
  sensorAngle =      sliders[4].currentVal;
  rotationAngle =    sliders[5].currentVal;
  randomAngleAdd =   sliders[6].currentVal;
  depositionAmount = sliders[7].currentVal;

  for (int i = 0; i < sliders.length; i++)
  {
    sliders[i].Update();
    sliders[i].Show();
  }

  if (mousePressed)
  {
    if (!mouseDown)
    {
      mouseDown = true; 
      if (randomizeButton.OnButton())
      {
        for (int i = 2; i < sliders.length; i++)
        {
          sliders[i].SetValue(random(0, 1));
        }
      }
      if (resetButton.OnButton())
      {
        //set initial slider values
        sliders[0].SetValue(0.01);
        sliders[1].SetValue(0.4);
        sliders[2].SetValue(0.09);
        sliders[3].SetValue(0.2);
        sliders[4].SetValue(0.28);
        sliders[5].SetValue(0.8);
        sliders[6].SetValue(0.25);
        sliders[7].SetValue(0.7);
      }
      if (visualizeButton.OnButton())
      {
        visualize = !visualize;
      }
    }
  } else
  {
    mouseDown = false;
  }

  VisualizeAgent();

  stroke(255);
  fill(255);
  randomizeButton.Show();
  resetButton.Show();
  visualizeButton.Show();
}

void DecayBuffer()
{
  for (int x = 0; x < width; x++)
  {
    for (int y = 0; y < height; y++)
    {
      trailBuffer[x][y] -= decayFactor;
      trailBuffer[x][y] = constrain(trailBuffer[x][y], 0, 1);
    }
  }
}

void DiffuseBuffer()
{
  float bufferBuffer[][] = new float[width][height];
  for (int x = 0; x < width; x++)
  {
    for (int y = 0; y < height; y++)
    {
      bufferBuffer[x][y] = trailBuffer[x][y];
    }
  }

  for (int x = 0; x < width; x++)
  {
    for (int y = 0; y < height; y++)
    {
      //get num neightbours and add to sum
      float sum = 0;
      int NBCount = 1; //1 because it includes self;

      //left
      if (x > 0) {
        sum += bufferBuffer[x-1][y];
        NBCount++;
      }

      //up
      if (y > 0) {
        sum += bufferBuffer[x][y-1];
        NBCount++;
      }

      //right
      if (x < width-1) {
        sum += bufferBuffer[x+1][y];
        NBCount++;
      }

      //down
      if (y < height-1) {
        sum += bufferBuffer[x][y+1];
        NBCount++;
      }

      //top left
      if (x > 0 && y > 0) {
        sum += bufferBuffer[x-1][y-1];
        NBCount++;
      }

      //top right
      if ( x < width-1 && y > 0) {
        sum += bufferBuffer[x+1][y-1];
        NBCount++;
      }

      //bottom left
      if (x > 0 && y < height-1) {
        sum += bufferBuffer[x-1][y+1];
        NBCount++;
      }

      //bottom right
      if ( x < width-1 && y < height-1) {
        sum += bufferBuffer[x+1][y+1];
        NBCount++;
      }

      trailBuffer[x][y] = sum/NBCount;//average of neighbours;
    }
  }
}

void VisualizeAgent()
{
  if (visualize)
  {
    fill(255);
    strokeWeight(1);

    //main body
    float hw = width/2;
    float hh = height/2;
    circle(hw, hh, cellSize*visualizeScale);

    //movespeed
    stroke(70, 255, 255);
    strokeWeight(4);

    line(hw, hh, hw, hh-depositionAmount * visualizeScale * 3);
    
    //rotation angle lines
    strokeWeight(1);
    stroke(160,255,255);
    float rlx = sin(radians(180-rotationAngle))*visualizeScale * 30;
    float rly = cos(radians(180-rotationAngle))*visualizeScale * 30;
    float rrx = sin(radians(180+rotationAngle))*visualizeScale * 30;
    float rry = cos(radians(180+rotationAngle))*visualizeScale * 30;
    line(hw,hh,hw+rlx,hh+rly);
    line(hw,hh,hw+rrx,hh+rry);
    
    //random angle lines
    strokeWeight(1);
    stroke(16,255,255);
    float ralx = sin(radians(180-randomAngleAdd))*visualizeScale * 20;
    float raly = cos(radians(180-randomAngleAdd))*visualizeScale * 20;
    float rarx = sin(radians(180+randomAngleAdd))*visualizeScale * 20;
    float rary = cos(radians(180+randomAngleAdd))*visualizeScale * 20;
    
    line(hw,hh,hw+ralx,hh+raly);
    line(hw,hh,hw+rarx,hh+rary);

    //sensors
    fill(255, 255, 150);
    strokeWeight(1);
    stroke(255);
    float slx = sin(radians(180-sensorAngle))*sensorDistance*visualizeScale;
    float sly = cos(radians(180-sensorAngle))*sensorDistance*visualizeScale;
    float smx = sin(radians(180))*sensorDistance*visualizeScale;
    float smy = cos(radians(180))*sensorDistance*visualizeScale;
    float srx = sin(radians(180+sensorAngle))*sensorDistance*visualizeScale;
    float sry = cos(radians(180+sensorAngle))*sensorDistance*visualizeScale;
    circle(hw+slx, hh+sly, sensorSize*visualizeScale);
    circle(hw+smx, hh+smy, sensorSize*visualizeScale);
    circle(hw+srx, hh+sry, sensorSize*visualizeScale);

    //sensor lines
    stroke(0, 255, 255);
    strokeWeight(1);

    line(hw, hh, hw+slx, hh+sly);
    line(hw, hh, hw+smx, hh+smy);
    line(hw, hh, hw+srx, hh+sry);
  }
}
