class Camera {
  PVector pos; //Camera's position 

  Camera() {
    pos = new PVector(mapWidth / 2 - width / 2, mapHeight / 2 - height / 2);
  }

  void draw() {
    //The mouse's position is always relative to the screen and not the camera's position
    if (mouseX < 100 && pos.x >= 5) pos.x-=5;
    else if (mouseX > width - 100 && pos.x + width <= mapWidth - 5) pos.x+=5;
    if (mouseY < 100 && pos.y >= 5) pos.y-=5;
    else if (mouseY > height - 100 && pos.y + height <= mapHeight - 5) pos.y+=5;
    
    if (keyPressed) {
      if (key == 'w') pos.y -= 5;
      if (key == 's') pos.y += 5;
      if (key == 'a') pos.x -= 5;
      if (key == 'd') pos.x += 5;
    }
  }
}