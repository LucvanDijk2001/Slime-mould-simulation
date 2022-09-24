class Slider
{

  class SliderDot
  {
    float x, y;
    float r = 15;
  }
  boolean movePoint = false;
  float x=0, y=0, w=100, min=0, max=1;
  float currentVal = 0;
  boolean isIntSlider = false;
  SliderDot point;
  String name = "Slider";

  Slider(float mi, float ma, float _x, float _y, float _w, String n)
  {
    min = mi;
    max = ma;
    x = _x;
    y = _y;
    w = _w;
    currentVal = min;
    point = new SliderDot();
    point.x = x + w/2;
    point.y = y;
    name = n;
    currentVal = map(point.x, x, x+w, min, max);
  }
  Slider(float mi, float ma, float _x, float _y, float _w, String n, boolean integer)
  {
    min = mi;
    max = ma;
    x = _x;
    y = _y;
    w = _w;
    currentVal = min;
    point = new SliderDot();
    point.x = x + w/2;
    point.y = y;
    name = n;
    currentVal = map(point.x, x, x+w, min, max);
    isIntSlider = integer;
    if (isIntSlider) {
      currentVal = (int)currentVal;
    }
  }

  void SetValue(float v)
  {
    while (v>1) {
      v--;
    }

    point.x = x + w*v;

    currentVal = map(point.x, x, x+w, min, max);
    if (isIntSlider) {
      currentVal = (int)currentVal;
    }
  }

  void Update()
  {
    if (mousePressed)
    {
      if (mouseX > point.x-point.r/2 && mouseX < point.x+point.r/2 && mouseY > point.y-point.r/2 && mouseY < point.y+point.r/2)
      {
        movePoint = true;
      }
    } else
    {
      movePoint = false;
    }

    if (movePoint)
    {
      point.x = mouseX;
      point.x = constrain(point.x, x, x+w);
      currentVal = map(point.x, x, x+w, min, max);
      if (isIntSlider) {
        currentVal = (int)currentVal;
      }
    }
  }

  void Show()
  {
    fill(255);
    stroke(255);
    strokeWeight(2);
    line(x, y, x+w, y);
    circle(point.x, point.y, point.r);
    textAlign(LEFT);
    text(name, x, y-15);
    if (isIntSlider)
    {
      text((int)currentVal, x + w + 10, y);
    } else
    {
      text(currentVal, x + w + 10, y);
    }
  }
}
