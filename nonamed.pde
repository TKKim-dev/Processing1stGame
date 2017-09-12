  Player p1; //<>// //<>// //<>//
  ArrayList<Bullet> bullets = new ArrayList<Bullet>();
  
  
public void b_display() {
  for(Bullet temp : bullets)
  {
    temp.display();
  }
}
public void b_update() {
  for(Bullet temp : bullets)
  {
    temp.update();
  }
}
  
  
  
void setup() {
  background(255);
  rectMode(CENTER);
  p1=new Player(1,200, 200); // 200은 initail location
}

void settings() {
  size(800,800);
}

void draw() {
  background(255);
  p1.run();
  text(frameRate, width - 40, height - 30);
  text(int(p1.movframecount), p1.location.x, p1.location.y - 20);
  b_update();
  b_display();
}