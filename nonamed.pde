Player p1; //<>// //<>// //<>//
AI AI1;
ArrayList<Bullet> bullets = new ArrayList<Bullet>();

void setup() {
  smooth();
  background(255);
  rectMode(CENTER);
  p1=new Player(1, 200, 200); // 200은 initail location
  AI1=new AI();
}

void settings() {
  size(800, 800);
}

void draw() {
  background(255);
  p1.run();
  AI1.run();
  text(frameRate, width - 40, height - 30);
  text(int(p1.distanceLeft), p1.location.x, p1.location.y - 20);
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
public void SetCollideShapes(int objectNum, char CollideShape, float radius, PVector ShapeLocation, PVector ShapeVelocity) { //특정 오브젝트에 CollideShape 를 추가함. 마치 bullet 추가하듯이. (추가할 오브젝트 번호, 추가할 모양(Ex. 'R'ectangle, 'C'ircle), radius, 좌표, 속도)
  //
}