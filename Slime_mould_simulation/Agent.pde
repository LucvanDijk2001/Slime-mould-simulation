class SlimeAgent
{
  /*
  //configurabe values should include:
   ==========TO ADD===============
   - deposit size (how much trail value is left behind)
   */


  //PVector position = new PVector(random(0,width),random(0,height)); //position of the particle
  PVector position = new PVector(width/2, height/2);
  PVector sensors[] = new PVector[3]; //particle sensors, sensor readings effect heading of particle (turning left/right or going straight ahead)
  float sensorReadings[] = new float[]{0, 0, 0};
  float c = random(0, 50);
  float direction = random(360);

  SlimeAgent()
  {
    for (int i = 0; i < sensors.length; i++)
    {
      sensors[i] = new PVector(0, 0);
    }
    CalculateSensorPositions();
  }

  void Update()
  {
    //====================temporary direction add=========================

    //let sensors check trail map using current position and size
    for (int i = 0; i < sensors.length; i++)
    {
      sensorReadings[i] = 0;
      for (int j = -sensorSize; j < sensorSize; j++)
      {
        for (int k = -sensorSize; k < sensorSize; k++)
        {
          int sx = (int)sensors[i].x+j;
          int sy = (int)sensors[i].y+k;
          if (sx > 0 && sx < width-1 && sy > 0 && sy < height-1)
          {
            sensorReadings[i] = trailMap[sx][sy];
          }
        }
      }
    }

    //steer according to sensor readings
    SENSORDIRECTIONS sensorDirection = GetDirection();

    float rotationAdd = 0;
    switch(sensorDirection)
    {
    case SENSORDIRECTIONLEFT:
      rotationAdd -= rotationAngle;
      break;

    case SENSORDIRECTIONMIDDLE:
      rotationAdd += random(-0.1, 0.1);
      break;

    case SENSORDIRECTIONRIGHT:
      rotationAdd += rotationAngle;
      break;
    }
    rotationAdd += random(-randomAngleAdd, randomAngleAdd);
    direction += rotationAdd;

    //add to position using new direction
    position.x += sin(radians(direction))*depositionAmount;
    position.y += cos(radians(direction))*depositionAmount;

    //clamp position and mirror x/y direction
    ClampPosition();

    //deposit trail based on deposit size
    for (int i = -depositSize; i < depositSize; i++)
    {
      for (int j = -depositSize; j < depositSize; j++)
      {
        int tx = (int)position.x+i;
        int ty = (int)position.y+j;
        if (tx >= 0 && tx < width && ty >= 0 && ty < height)
        {
          trailBuffer[tx][ty] += trailDepositValue;
        }
      }
    }

    //recalculate sensor positions
    CalculateSensorPositions();
  }

  void Show()
  {
    c++;
    while (c > 255)
    {
      c-= 255;
    }
    fill(c, 200, 160, 25.5);
    //draw pixel
    circle(position.x, position.y, cellSize);
  }

  void CalculateSensorPositions()
  {
    sensors[0].x = position.x + sin(radians(direction-sensorAngle))*sensorDistance;//left sensor
    sensors[0].y = position.y + cos(radians(direction-sensorAngle))*sensorDistance;//left sensor
    sensors[1].x = position.x + sin(radians(direction))*sensorDistance;            //middle sensor
    sensors[1].y = position.y + cos(radians(direction))*sensorDistance;            //middle sensor
    sensors[2].x = position.x + sin(radians(direction+sensorAngle))*sensorDistance;//right sensor
    sensors[2].y = position.y + cos(radians(direction+sensorAngle))*sensorDistance;//right sensor
  }

  void ClampPosition()
  {
    if (position.x < 0)
    {
      position.x = 0;
      Reflect(REFLECTIONS.LEFT);
    }

    if (position.x > width)
    {
      position.x = width-1;
      Reflect(REFLECTIONS.RIGHT);
    }

    if (position.y < 0)
    {
      position.y = 0;
      Reflect(REFLECTIONS.TOP);
    }

    if (position.y > height-1)
    {
      position.y = height;
      Reflect(REFLECTIONS.BOTTOM);
    }
  }

  void Reflect(REFLECTIONS r)
  {
    switch(r)
    {
    case LEFT:
      direction = 180 - (direction-180);
      break;

    case RIGHT:
      direction = 180 - (direction-180);
      break;

    case TOP:
      direction = 360 - (direction-180);
      break;

    case BOTTOM:
      direction = 360 - (direction-180);
      break;
    }
  }

  SENSORDIRECTIONS GetDirection()
  {
    if (sensorReadings[0] == sensorReadings[1] && sensorReadings[0] == sensorReadings[2])
    {
      return SENSORDIRECTIONS.SENSORDIRECTIONMIDDLE;
    } else if (sensorReadings[0] > sensorReadings[1] && sensorReadings[0] == sensorReadings[1])
    {
      return SENSORDIRECTIONS.SENSORDIRECTIONMIDDLE;
    } else if (sensorReadings[0] > sensorReadings[1] && sensorReadings[0] > sensorReadings[2])
    {
      return SENSORDIRECTIONS.SENSORDIRECTIONLEFT;
    } else if ( sensorReadings[1] > sensorReadings[0] && sensorReadings[1] > sensorReadings[2])
    {
      return SENSORDIRECTIONS.SENSORDIRECTIONMIDDLE;
    } else
    {
      return SENSORDIRECTIONS.SENSORDIRECTIONRIGHT;
    }
  }
}
