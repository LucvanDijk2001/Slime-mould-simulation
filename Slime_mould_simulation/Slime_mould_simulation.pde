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
  new Slider(1, 5, 10, 70, 100, "cell size"), 
  new Slider(1, 100, 10, 110, 100, "sensor distance"), 
  new Slider(1, 10, 10, 150, 100, "sensor size", true), 
  new Slider(10, 135, 10, 190, 100, "sensor angle"), 
  new Slider(0, 20, 10, 230, 100, "rotation angle"), 
  new Slider(0, 20, 10, 270, 100, "random angle add"), 
  new Slider(0, 2, 10, 310, 100, "cell move speed")
};

Button randomizeButton = new Button(10, 330, 100, 40, "Randomize");

boolean mouseDown = false;

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
  sliders[1].SetValue(0.3);
  sliders[2].SetValue(0.09);
  sliders[3].SetValue(0.2);
  sliders[4].SetValue(0.28);
  sliders[5].SetValue(0.3);
  sliders[6].SetValue(0.25);
  sliders[7].SetValue(0.7);
}

void draw()
{
  //alpha over screen
  fill(0, 0, 0, 25.5);
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
  c++;
  while (c > 255)
  {
    c-= 255;
  }
  fill(c, 200, 160, 25.5);
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
        for (int i = 1; i < sliders.length; i++)
        {
          sliders[i].SetValue(random(0, 1));
        }
      }
    }
  } else
  {
    mouseDown = false;
  }

  randomizeButton.Show();
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
