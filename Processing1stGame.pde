import processing.sound.*; //<>// //<>// //<>//
import java.net.*;

PFont pf;
int serverConnectionTime = 10000; // 서버가 몇 초 동안 클라이언트 접속을 기다릴건지
int runState; // 0: 메뉴 || 1. 서버 호스트 모드 || 2: (클라이언트) 서버 연결 모드 || 3: 네트워크 플레이 || 4: AI와 플레이
Player p1; //<>// //<>// //<>//
ArrayList<Skill> skillList = new ArrayList<Skill>(); // 플레이어가 소유한 스킬 리스트
ArrayList<AI> AIList = new ArrayList<AI>(); // AI 리스트, 나중에 삭제할 것
ArrayList<Button> buttons = new ArrayList<Button>(); // 메뉴 표시를 위한 버튼 배열
Button buttonT, buttonH, buttonJ; // 각각 T(테스트 플레이), H(호스트 - 서버 생성), J(서버 조인) 을 뜻함.
SoundFile hitSound; // 기본 공격 타격 사운드
PShape AIShape, p1Shape, p1Attack, AIAttack, buttonTShape; // AIShape(AI의 모양)
Camera worldCamera;
Server server;
float mapWidth, mapHeight; // 나중에 Load 할 맵의 크기. 우선 1600 1200 짜리 맵 써보기
PImage background;
float DEFAULT_MOVESPEED = 3;
float DEFAULT_FIRESPEED = 2;
float DEFAULT_DAMAGE = 1;
boolean shouldShowMenu;
boolean shouldCreateServer;
char menuSelected;

void setup() {
  pf = loadFont("HGS-36.vlw");
  runState = 0; // 우선 메뉴 표시부터 해야하지만 아직 구현이 안되었으므로 클라이언트 연결부터
  background(0);
  mapWidth = 1600;
  mapHeight = 1200;
  smooth();
  frameRate(75);
  rectMode(CENTER);
  p1=new Player(800, 600);
  hitSound = new SoundFile(this, "hitSound.wav");
  background = loadImage("background.jpg");
  background.resize(width, height);
  p1Shape = loadShape("pikachu.svg");
  AIShape = loadShape("zubat.svg");
  p1Attack = loadShape("p1Attack.svg");
  AIAttack = loadShape("zubat_attack.svg");
  buttonTShape = loadShape("buttonT.svg");
  addPlayerSkill(new Skill1()); // 여기의 SKill1R 은 몇번째 스킬인지랑은 상관 없음! 처음에 무슨 스킬을 고르는지에 따라 여기서 갈리게 됨. (혹은 무슨 직업을 고르는지에 따라)
  addPlayerSkill(new Skill2());
  worldCamera = new Camera();
  shouldShowMenu = true;
  shouldCreateServer = true;
}

void settings() {
  //fullScreen();
  size(600, 600);
}

void draw() {
  switch(runState) {
    case 0: // #######메뉴#######
      background(0);
      textAlign(LEFT);
      textFont(pf, 36);
      text("Select Menu: ", 60, 50);
      text("Press 1 to Host New Server", 0, 90);
      text("Press 2 to Join Private Server", 0, 130);
      text("Press 3 to Play With AI", 0, 170);
      if(keyPressed) {
        switch(key) {
          case 49: // 1번 선택
            runState = 1;
            if(!shouldCreateServer) server.connectionStandbyTime = millis(); // 서버를 선택했다가 시간 안에 클라이언트가 접속하지 않은 경우, 다시 시간을 리셋
            return;
          case 50: // 2번 선택
            runState = 2;
            return;
          case 51: // 3번 선택
            runState = 4;
            return;
        } //switch(keyCode)
      } //if(keyPressed)
      break;
      
    case 1: // #######서버 호스트 모드#######
      try {
        if(shouldCreateServer) {
          server = new Server(8282);
          shouldCreateServer = false;
        }
        background(0);
        textAlign(CENTER);
        textFont(pf, 36);
        text("Connection Time Left : " + int((serverConnectionTime - millis() + server.connectionStandbyTime) / 1000), width / 2, 50);
        for(int i = 0; i < server.addressList.size(); i++) text("Connection Established with - " + server.addressList.get(i).getHostAddress() + ": " + server.portList.get(i), width / 2, 100 + i * 100); 
        server.initialConnection();
      } catch (Exception e) {
      } //catch
      break;
      
    case 2: // #######(클라이언트) 서버 연결 모드#######
      //Client(); // 서버의 InetAddress 와 포트를 입력해야함.
      break;
      
    case 3: // #######네트워크 플레이!#######
      break;
      
    case 4: // #######AI와 플레이!#######
      pushMatrix();
      worldCamera.update();
      translate(-worldCamera.pos.x, -worldCamera.pos.y);
      background(255);
      p1.run();
      for(AI TEMP : AIList) {
        TEMP.run();
      } //for(AI TEMP~
      for(int i=0; i < AIList.size(); i++) {
        if(!AIList.get(i).isActive) {
          AIList.remove(i);
        } //if(~AI~
      } //for(int~
      textFont(pf, 24);
      text(int(p1.distanceLeft), p1.location.x, p1.location.y-30);
      text(frameRate, width / 2, height / 2);
      text("Prese A KEY to Add random AI with 100 HP", mapWidth /2 - 140, mapHeight / 2 - 130);
  
      updateProjectiles();
      displayProjectiles();
      if(p1.CCFrameCount[0] > 0) {
        fill(255, 0, 0);
        text(p1.CCFrameCount[0], p1.location.x - 7, p1.location.y + 35);
      } //if(p1
      popMatrix();  
      break;
  } //switch(runState)
}

public void addPlayerSkill(Skill skill) {
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
         return true;
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
        temp.activate();
        temp.setActiveOnReady(false);
        break;
      }
      p1.fireEvent(); // 일반적인 총알 발사!
    }
  }
  if (mouseButton == RIGHT) {
    if(!p1.disableMove) p1.move(p1.newMouseX, p1.newMouseY); // 만약 skillOnReady 가 active 라면.. 그대로 두기!
  }
}

public void keyPressed() {
  if(keyCode == SHIFT) {
    if(skillList.get(0).isActiveOnReady && p1.isAbleToSkill) { ///*여기에 스킬 쿨타임 관련 조건 넣기*/) {  // 이미 On 되어있을 때 한번 더 누르면 스킬 취소
      
      skillList.get(0).setActiveOnReady(false);
    } else {
      for(int i = 0; i < skillList.size(); i++) { // 다른 스킬의 OnReady 상태일 때 이 스킬을 사용하면 다른 것들을 false 로 만들고 얘만 true 로 설정함!
        skillList.get(i).setActiveOnReady(false);
      }
      skillList.get(0).setActiveOnReady(true);
    }
  }
  if(keyCode == 'Q') {
    if(skillList.get(1).isActiveOnReady && p1.isAbleToSkill) { ///*여기에 스킬 쿨타임 관련 조건 넣기*/) {  // 이미 On 되어있을 때 한번 더 누르면 스킬 취소
      
      skillList.get(1).setActiveOnReady(false);
    } else {
      for(int i = 0; i < skillList.size(); i++) { // 다른 스킬의 OnReady 상태일 때 이 스킬을 사용하면 다른 것들을 false 로 만들고 얘만 true 로 설정함!
        skillList.get(i).setActiveOnReady(false);
      }
      skillList.get(1).setActiveOnReady(true);
    }
  }  
  if(keyCode == 'A') {
    AI temp = new AI();
    AIList.add(temp);
  }
  if(keyCode == ' ') {
    worldCamera.reset();
  }  
}

//  ※ 구현해야 하는 것
// ※플레이어와 AI에 PShape 로 적당한 이미지 찾아서 넣고, 그에 알맞게 충돌 범위 구현해놓기.
// ※Shift 스킬 사용 효과 만들기. 플레이어 스킬[0]에 Skill1R 을 할당하는 것.
// ※
// ※