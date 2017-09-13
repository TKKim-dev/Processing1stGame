Player p1; //<>// //<>// //<>//
ArrayList<Bullet> bullets = new ArrayList<Bullet>();

void setup() {
  background(255);
  rectMode(CENTER);
  p1=new Player(1, 200, 200); // 200은 initail location
}

void settings() {
  size(800, 800);
}

void draw() {
  background(255);
  p1.run();
  text(frameRate, width - 40, height - 30);
  text(p1.distanceLeft, p1.location.x, p1.location.y - 20);
  updateBullets();
  displayBullets();
}

public void displayBullets() {
  for (Bullet temp : bullets)
  {
    temp.display();
  }
}
public void updateBullets() {
  for (Bullet temp : bullets)
  {
    temp.update();
  }
}