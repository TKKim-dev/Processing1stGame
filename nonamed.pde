import processing.sound.*; //<>//
Player p1; //<>//
ArrayList<Skill> skillList = new ArrayList<Skill>();
ArrayList<AI> AIList = new ArrayList<AI>();
SoundFile hitSound;
PShape AIShape, p1Shape;
Camera worldCamera;
float mapWidth, mapHeight; // 나중에 Load 할 맵의 크기. 우선 1600 1200 짜리 맵 써보기
PImage background;

void setup() {
  mapWidth = 1600;
  mapHeight = 1200;
  smooth();
  frameRate(75);
  rectMode(CENTER);
  p1=new Player(1, 800, 600);
  hitSound = new SoundFile(this, "hitSound.wav");
  background = loadImage("background.jpg");
  
  p1Shape = loadShape("pikachu.svg");
  AIShape = loadShape("zubat.svg");
  addPlayerSkill(new Skill1()); // 여기의 SKill1R 은 몇번째 스킬인지랑은 상관 없음! 처음에 무슨 스킬을 고르는지에 따라 여기서 갈리게 됨. (혹은 무슨 직업을 고르는지에 따라)  
  worldCamera = new Camera();
}

void settings() {
  fullScreen();
  //size(800, 600);
}

void draw() {
  
  pushMatrix();
  translate(-worldCamera.pos.x, -worldCamera.pos.y);
  worldCamera.update();
  image(background, 0, 0);
  background(255);
  p1.run();
  for(AI TEMP : AIList) {
    TEMP.run();
  }
  for(int i=0; i < AIList.size(); i++) {
    if(!AIList.get(i).isActive) {
      AIList.remove(i);
    }
  }
  text(p1.distanceLeft, p1.location.x-20, p1.location.y-30);
  text(frameRate, width - 20, height - 30);
  text("Prese A KEY to Add random AI with 100 HP", mapWidth /2 - 140, mapHeight / 2 - 130);
  displayProjectiles();
  updateProjectiles();
  if(p1.CCFrameCount > 0) {
    fill(255, 0, 0);
    text(int(p1.CCFrameCount), p1.location.x - 7, p1.location.y + 35);
  }
  popMatrix();
}

public void addPlayerSkill(Skill skill) {   // 네트워크 게임이므로, 다른 이들의 스킬까지 관리할 필요는 없음. 그건 그냥 투사체의 형식으로 관리하면 된다.
    skillList.add(skill);
}
public void displayProjectiles() {
  for (Projectile temp : p1.projectileList)
  {
    temp.display();
  }
  for(AI AITemp : AIList)
  {
    for (Projectile temp : AITemp.projectileList)
    {
      temp.display();
    }
  }
}
public void updateProjectiles() {
  for (Projectile temp : p1.projectileList)
  {
    temp.update();
    for(AI AITemp : AIList) {
      if(calculateCollision(AITemp.collisionShape,temp.projectileCollisionShape)) {  // projectile 상태를 업데이트 할 때(이동시킬 때) 충돌 판정도 같이 함!
        temp.deactivate();
        AITemp.setHitEvent(true);
        hitSound.play();
      }
    }
  }
  
  for (AI AITemp : AIList)
  {
    for(Projectile PTemp : AITemp.projectileList) {
      PTemp.update();
      if(calculateCollision(PTemp.projectileCollisionShape, p1.collisionShape)) {  // projectile 상태를 업데이트 할 때(이동시킬 때) 충돌 판정도 같이 함!
        PTemp.deactivate();
        p1.setHitEvent(true);
      }
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
       float horValue = (temp.x - objectA.location.x) * objectA.direction.x + (temp.y - objectA.location.y) * objectA.direction.y;
       float verValue = (temp.y - objectA.location.y) * objectA.direction.x - (temp.x - objectA.location.x) * objectA.direction.y;
       if(horValue < 0) {
         horValue *= -1;
       } 
       if(verValue < 0) {
         verValue *= -1;
       }
       if(horValue < objectA.shapeWidth/2 && verValue < objectA.shapeHeight/2) {  // 충돌 감지!
         return true; //<>//
       }
     }
     for(PVector temp : coordinatesA) {
       float horValue = (temp.x - objectB.location.x) * objectB.direction.x + (temp.y - objectB.location.y) * objectB.direction.y;
       float verValue = (temp.y - objectB.location.y) * objectB.direction.x - (temp.x - objectB.location.x) * objectB.direction.y;
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

public void mousePressed() {
  if (mouseButton == LEFT) {
    for(Skill temp : skillList) {
      if(temp.isActiveOnReady) {
        temp.activate(); //<>//
        temp.setActiveOnReady(false);
        break;
      }
      p1.fireEvent(1); // 일반적인 총알 발사!
    }
  }
  if (mouseButton == RIGHT) {
    p1.move(worldCamera.pos.x + mouseX, worldCamera.pos.y + mouseY); // 만약 skillOnReady 가 active 라면.. 그대로 두기!
  }
}

public void keyPressed() {
  if(keyCode == SHIFT) {
    if(skillList.get(0).isActiveOnReady && p1.isAbleTo('s') /*여기에 스킬 쿨타임 관련 조건 넣기*/) {  // 이미 On 되어있을 때 한번 더 누르면 스킬 취소
      
      skillList.get(0).setActiveOnReady(false);
    } else {    
      for(int i = 0; i < skillList.size(); i++) { // 다른 스킬의 OnReady 상태일 때 이 스킬을 사용하면 다른 것들을 false 로 만들고 얘만 true 로 설정함!
        skillList.get(i).setActiveOnReady(false);
      }
      skillList.get(0).setActiveOnReady(true);
    }
  }
  if(keyCode == 'A') {
    AI temp = new AI();
    AIList.add(temp);
  }
  if(keyCode == ' ') {
    worldCamera.reset();
  }
  if(keyCode == LEFT) {
    surface.setLocation(400, 400);
  }
}

//  ※ 구현해야 하는 것
// ※플레이어와 AI에 PShape 로 적당한 이미지 찾아서 넣고, 그에 알맞게 충돌 범위 구현해놓기.
// ※Shift 스킬 사용 효과 만들기. 플레이어 스킬[0]에 Skill1R 을 할당하는 것.
// ※
// ※