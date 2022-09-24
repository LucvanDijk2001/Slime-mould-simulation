class Button
{
  float x,y,w,h;
  String t;
  Button(float _x, float _y, float _w, float _h, String _t)
  {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    t = _t;
  }
  
  void Show()
  {
    noFill();
    strokeWeight(3);
    textAlign(CENTER);
    rect(x,y,w,h);
    text(t,x+w/2,y+h/2+5);
  }
  
  boolean OnButton()
  {
    return mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h;
  }
}
