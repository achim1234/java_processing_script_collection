// ================= GLOBAL =================

Car player;
ArrayList<Human> humans = new ArrayList<Human>();
ArrayList<Tree> trees = new ArrayList<Tree>();
ArrayList<AICar> aiCars = new ArrayList<AICar>();
ArrayList<House> houses = new ArrayList<House>();
ArrayList<TrafficLight> lights = new ArrayList<TrafficLight>();

boolean upPressed, downPressed, leftPressed, rightPressed;

int lives = 30;
int score = 0;
boolean gameOver = false;

int TRAFFIC_DENSITY = 100;

// map
int worldSize = 6000;
int roadSpacing = 600;
int roadWidth = 140;

// ================= SETUP =================

void setup() {
  size(800, 600);
  rectMode(CENTER);

  player = new Car(worldSize/2, worldSize/2);

  generateWorld();
}

// ================= WORLD =================

void generateWorld() {

  // houses
  for (int x = 0; x < worldSize; x += roadSpacing) {
    for (int y = 0; y < worldSize; y += roadSpacing) {
      houses.add(new House(x + roadSpacing/2, y + roadSpacing/2,
        roadSpacing - roadWidth, roadSpacing - roadWidth));
    }
  }

  // trees
  for (int i = 200; i < worldSize; i += 300) {
    for (int j = 200; j < worldSize; j += roadSpacing) {
      trees.add(new Tree(i, j - roadWidth/2 - 40));
      trees.add(new Tree(i, j + roadWidth/2 + 40));
      trees.add(new Tree(j - roadWidth/2 - 40, i));
      trees.add(new Tree(j + roadWidth/2 + 40, i));
    }
  }

  // humans
  for (int i = 0; i < 40; i++) {
    humans.add(new Human(random(200, worldSize-200), random(200, worldSize-200)));
  }

  // AI cars
  for (int i = 0; i < TRAFFIC_DENSITY; i++) {
    aiCars.add(new AICar(randomRoadPos(), randomRoadPos()));
  }

  // traffic lights
  for (int i = 0; i <= worldSize; i += roadSpacing) {
    for (int j = 0; j <= worldSize; j += roadSpacing) {
      lights.add(new TrafficLight(i, j));
    }
  }
}

// ================= DRAW =================

void draw() {
  background(30);

  translate(width/2 - player.x, height/2 - player.y);

  drawRoads();

  for (House h : houses) h.display();
  for (Tree t : trees) t.display();

  for (TrafficLight l : lights) {
    l.update();
    l.display();
  }

  for (AICar c : aiCars) {
    c.update();
    c.display();
  }

  for (Human h : humans) {
    h.update();
    h.display();
  }

  if (!gameOver) player.update();
  player.display();

  drawUI();
}

// ================= ROADS =================

void drawRoads() {

  fill(60);

  for (int i = 0; i <= worldSize; i += roadSpacing) {
    rect(worldSize/2, i, worldSize, roadWidth);
    rect(i, worldSize/2, roadWidth, worldSize);
  }

  stroke(255, 200, 0);

  for (int i = 0; i <= worldSize; i += roadSpacing) {
    for (int j = 0; j < worldSize; j += 40) {
      line(j, i, j+20, i);
      line(i, j, i, j+20);
    }
  }

  noStroke();
}

// ================= TRAFFIC LIGHT =================

class TrafficLight {
  float x, y;
  int state = 0; // 0 = horizontal green, 1 = vertical green
  int timer = 0;

  TrafficLight(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    timer++;
    if (timer > 180) { // change every ~3 sec
      state = (state + 1) % 2;
      timer = 0;
    }
  }

  void display() {
    pushMatrix();
    translate(x, y);

    // pole
    fill(80);
    rect(0, 0, 10, 30);

    // light
    if (state == 0) fill(0, 255, 0);
    else fill(255, 0, 0);

    ellipse(0, -20, 10, 10);

    popMatrix();

    drawStopSign();
  }

  void drawStopSign() {
    fill(200, 0, 0);
    rect(x + 20, y + 20, 12, 12);
  }
}

// ================= PLAYER =================

class Car {
  float x, y, angle, speed;
  float maxSpeed = 6;
  float accel = 0.2;
  float friction = 0.95;
  float turn = 0;
  int invuln = 0;

  Car(float x, float y) {
    this.x = x;
    this.y = y;
    angle = -HALF_PI;
  }

  void update() {

    if (invuln > 0) invuln--;

    if (upPressed) speed += accel;
    if (downPressed) speed -= accel;

    speed *= friction;
    speed = constrain(speed, -maxSpeed, maxSpeed);

    float targetTurn = 0;
    if (leftPressed) targetTurn -= 1;
    if (rightPressed) targetTurn += 1;

    turn = lerp(turn, targetTurn, 0.08);

    if (abs(speed) > 0.05) {
      angle += turn * 0.04 * speed;
    }

    float nx = x + cos(angle) * speed;
    float ny = y + sin(angle) * speed;

    if (!isRoad(nx, ny)) {
      crash();
    } else {
      x = nx;
      y = ny;
    }

    checkAICollision();
  }

  void checkAICollision() {
    if (invuln > 0) return;

    for (AICar c : aiCars) {
      if (dist(x, y, c.x, c.y) < 30) {
        crash();
        break;
      }
    }
  }

  void crash() {
    if (invuln > 0) return;
    speed = 0;
    lives--;
    invuln = 60;
    if (lives <= 0) gameOver = true;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);

    fill(50, 120, 255);
    rect(0, 0, 42, 22, 5);

    popMatrix();
  }
}

// ================= AI =================

class AICar {
  float x, y, angle;
  float speed;

  AICar(float x, float y) {
    this.x = x;
    this.y = y;
    speed = random(1.5, 3.5);
    angle = random(4) * HALF_PI;
  }

  void update() {

    // check traffic light
    for (TrafficLight l : lights) {
      if (dist(x, y, l.x, l.y) < 80) {

        if (l.state == 1) { // red for horizontal
          if (abs(angle) < 0.1 || abs(angle - PI) < 0.1) {
            return; // stop
          }
        }

        if (l.state == 0) { // red for vertical
          if (abs(angle - HALF_PI) < 0.1 || abs(angle + HALF_PI) < 0.1) {
            return;
          }
        }
      }
    }

    float nx = x + cos(angle) * speed;
    float ny = y + sin(angle) * speed;

    if (isRoad(nx, ny)) {
      x = nx;
      y = ny;
    } else {
      angle += random(1) < 0.5 ? HALF_PI : -HALF_PI;
    }
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);

    fill(200, 60, 60);
    rect(0, 0, 40, 20, 5);

    popMatrix();
  }
}

// ================= HOUSE =================

class House {
  float x, y, w, h;
  int type;

  House(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    type = int(random(3));
  }

  void display() {
    if (type == 0) {
      fill(150, 90, 90);
      rect(x, y, w, h);
    } else if (type == 1) {
      fill(180, 140, 90);
      rect(x - w*0.25, y, w*0.4, h*0.8);
      fill(140, 100, 60);
      rect(x + w*0.25, y, w*0.4, h*0.6);
    } else {
      fill(120, 160, 120);
      rect(x - w*0.3, y, w*0.25, h*0.5);
      fill(160, 120, 160);
      rect(x, y, w*0.25, h*0.7);
      fill(100, 140, 180);
      rect(x + w*0.3, y, w*0.25, h*0.5);
    }
  }
}

// ================= TREE =================

class Tree {
  float x, y, size;
  color leafColor;

  Tree(float x, float y) {
    this.x = x;
    this.y = y;
    size = random(30, 50);
    leafColor = color(random(40, 80), random(140, 200), random(40, 80));
  }

  void display() {
    fill(100, 60, 20);
    rect(x, y + 10, 8, 18);
    fill(leafColor);
    ellipse(x, y, size, size);
  }
}

// ================= HUMAN =================

class Human {
  float x, y;
  boolean alive = true;

  Human(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    if (!alive) return;
    if (dist(x, y, player.x, player.y) < 20) {
      alive = false;
      score++;
    }
  }

  void display() {
    if (!alive) return;
    fill(255, 200, 150);
    ellipse(x, y, 10, 10);
  }
}

// ================= HELPERS =================

boolean isRoad(float x, float y) {
  for (int i = 0; i <= worldSize; i += roadSpacing) {
    if (abs(y - i) < roadWidth/2) return true;
    if (abs(x - i) < roadWidth/2) return true;
  }
  return false;
}

float randomRoadPos() {
  return floor(random(worldSize / roadSpacing)) * roadSpacing;
}

// ================= UI =================

void drawUI() {
  pushMatrix();
  resetMatrix();

  fill(255);
  text("Lives: " + lives, 20, 20);
  text("Score: " + score, 20, 40);

  if (gameOver) {
    textSize(40);
    text("GAME OVER", width/2 - 100, height/2);
  }

  popMatrix();
}

// ================= INPUT =================

void keyPressed() {
  if (key == 'w' || keyCode == UP) upPressed = true;
  if (key == 's' || keyCode == DOWN) downPressed = true;
  if (key == 'a' || keyCode == LEFT) leftPressed = true;
  if (key == 'd' || keyCode == RIGHT) rightPressed = true;
}

void keyReleased() {
  if (key == 'w' || keyCode == UP) upPressed = false;
  if (key == 's' || keyCode == DOWN) downPressed = false;
  if (key == 'a' || keyCode == LEFT) leftPressed = false;
  if (key == 'd' || keyCode == RIGHT) rightPressed = false;
}
