import processing.sound.*; //<>//

Player p1; //<>// //<>//
SoundFile hitSound = new SoundFile(this, "hitSound.wav");
AI AI1;

void setup() {
  smooth();
  frameRate(75);
  background(255);
  rectMode(CENTER);
  p1=new Player(1, 200, 200); // 200은 initail location
  AI1=new AI();
  hitSound = new SoundFile(this, "hitSound.wav");
}

void settings() {
  fullScreen();
}

void draw() {
  background(255);
  p1.run();
  AI1.run();
  text(frameRate, width - 40, height - 30);
  //text(p1.location.x, p1.location.x, p1.location.y - 20);
  //println(p1.bulletCollisionList);
  updateBullets();
  displayBullets();
  
}

public void displayBullets() {
  for (Bullet temp : p1.bulletList)
  {
    temp.display();
  }
  for (Bullet temp : AI1.bulletList)
  {
    temp.display();
  }
}
public void updateBullets() {
  for (Bullet temp : p1.bulletList)
  {
    temp.update();
    if(calculateCollision(AI1.collisionShape,temp.bulletCollisionShape)) {  // bullet 상태를 업데이트 할 때(이동시킬 때) 충돌 판정도 같이 함!
      temp.deactivateBullet();
      AI1.setHitEvent(true);
      hitSound.play();
      text("!!!", AI1.location.x - 5, AI1.location.y - 30);
    }
  }
  
  for (Bullet temp : AI1.bulletList)
  {
    temp.update();
    if(calculateCollision(p1.collisionShape,temp.bulletCollisionShape)) {  // bullet 상태를 업데이트 할 때(이동시킬 때) 충돌 판정도 같이 함!
      temp.deactivateBullet();
      AI1.setHitEvent(true);
      text("!!!", p1.location.x - 5, p1.location.y - 30);
    }    
  }  
}

boolean calculateCollision(CollisionShape objectA, CollisionShape objectB) { // 양 Shape 같의 충돌 판정. 원과 사각형 두 가지로 나타내었으므로, 각각이 다른 계산 과정을 가져야 함
  ArrayList<PVector> coordinatesA = new ArrayList<PVector>();
  ArrayList<PVector> coordinatesB = new ArrayList<PVector>();
  if(objectA.shapeType == 'R') {   // 해당 콜리젼 Shape 가 사각형 모양일 경우, 벡터 연산을 이용하여 사각형의 각 꼭지점을 coordinateA ArrayList 에 저장
    for(int i = 1; i >= -1; i-=2) {
      for(int j = 1; j >= -1; j -= 2) {
        coordinatesA.add(new PVector(objectA.location.x + i * objectA.shapeWidth/2 * objectA.direction.x + j * objectA.shapeHeight/2 * objectA.verticalVector.x, objectA.location.y + i * objectA.shapeWidth/2 * objectA.direction.y + j * objectA.shapeHeight/2 * objectA.verticalVector.y));
      }
    }
  }
  if(objectB.shapeType == 'R') {    // 해당 콜리젼 Shape 가 사각형 모양일 경우, 벡터 연산을 이용하여 사각형의 각 꼭지점을 coordinateA ArrayList 에 저장
    for(int i=1;i>=-1;i-=2) {
      for(int j=1;j>=-1;j-=2) {
        coordinatesB.add(new PVector(objectB.location.x + i * objectB.shapeWidth/2 * objectB.direction.x + j * objectB.shapeHeight/2 * objectB.verticalVector.x, objectB.location.y + i * objectB.shapeWidth/2 * objectB.direction.y + j * objectB.shapeHeight/2 * objectB.verticalVector.y));
      }
    }
  }
  if(objectA.shapeType == 'R' && objectB.shapeType == 'R') { // 둘 다 rectangle인 경우의 연산
    for(PVector temp : coordinatesB) {
       float horValue = (temp.x - objectA.location.x) * objectA.direction.x - (temp.y - objectA.location.y) * objectA.direction.y;
       float verValue = (temp.x - objectA.location.x) * objectA.direction.y + (temp.y - objectA.location.y) * objectA.direction.x;
       if(horValue < 0) {
         horValue *= -1;
       } 
       if(verValue < 0) {
         verValue *= -1;
       }
       if(horValue < objectA.shapeWidth/2 && verValue < objectA.shapeHeight/2) {  // 충돌 감지!
         return true;
       }
     }
     for(PVector temp : coordinatesA) {
       float horValue = (temp.x - objectB.location.x) * objectB.direction.x - (temp.y - objectB.location.y) * objectB.direction.y;
       float verValue = (temp.x - objectB.location.x) * objectB.direction.y + (temp.y - objectB.location.y) * objectB.direction.x;
       if(horValue < 0) {
         horValue *= -1;
       } 
       if(verValue < 0) {
         verValue *= -1;
       }
       if(horValue < objectB.shapeWidth/2 && verValue < objectB.shapeHeight/2) {  // 충돌 감지!
         return true;
       }
     }
     return false;
  } else if(objectA.shapeType != objectB.shapeType) {  // 둘의 타입이 다른 경우, 즉 하나는 원이고 하나는 사각형 둘 간의 연산
    if(objectA.shapeType == 'R') {   // A가 사각형이면 무조건 나머지는 원이 된다
      for(PVector temp : coordinatesA) {
        if(PVector.dist(temp, objectB.location) < objectB.shapeWidth / 2) {  // B는 원이므로 shapeWidth 가 radius 와 같은 역할. coordinatesA 의 좌표와 원의 중심과의 거리가 반지름보다 작으면!
          return true;
        }
      } 
      return false;
    }
      else {
        for(PVector temp : coordinatesB) {
          if(PVector.dist(temp, objectA.location) < objectA.shapeWidth / 2) {  // B는 원이므로 shapeWidth 가 radius 와 같은 역할. coordinatesA 의 좌표와 원의 중심과의 거리가 반지름보다 작으면!
            return true;
          }
        }          
      }
      return false; 
    } else if(PVector.dist(objectA.location, objectB.location) < objectA.shapeWidth / 2 + objectB.shapeWidth / 2) { // 둘 다 원인 경우
      return true;
    }
    return false;
}