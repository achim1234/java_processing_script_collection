// === COMPLETE DRIVER-STYLE 2D MVP ===

Car player;
ArrayList<Human> humans = new ArrayList<Human>();
ArrayList<Tree> trees = new ArrayList<Tree>();
int score = 0;
int targetScore = 15;

boolean upPressed, downPressed, leftPressed, rightPressed;

int lives = 3;
boolean gameOver = false;

void setup() {
  size(800, 600);
  rectMode(CENTER);

  player = new Car(2000, 1000);

  // humans
  for (int i = 0; i < 15; i++) {
    humans.add(new Human(random(200, 3800), random(200, 3800)));
  }

  // trees on sidewalks only
  for (int i = 200; i < 3800; i += 250) {
    trees.add(new Tree(i, 880));
    trees.add(new Tree(i, 1120));
    trees.add(new Tree(1880, i));
    trees.add(new Tree(2120, i));
  }
}

void draw() {
  background(25, 25, 35);

  translate(width/2 - player.x, height/2 - player.y);

  drawMap();

  for (Tree t : trees) t.display();

  for (Human h : humans) {
    h.update();
    h.display();
  }

  if (!gameOver) player.update();

  player.display();

  drawGoal();
  checkWin();
  drawUI();
}

// === MAP ===
void drawMap() {

  fill(60);
  rect(2000, 1000, 4000, 120);
  rect(2000, 1000, 120, 4000);

  // yellow markings
  stroke(255, 200, 0);
  strokeWeight(3);
  for (int i = 0; i < 4000; i += 40) {
    line(i, 1000, i + 20, 1000);
    line(2000, i, 2000, i + 20);
  }

  noFill();
  rect(2000, 1000, 4000, 120);
  rect(2000, 1000, 120, 4000);
  noStroke();

  // sidewalks
  fill(100);
  rect(2000, 880, 4000, 40);
  rect(2000, 1120, 4000, 40);
  rect(1880, 1000, 40, 4000);
  rect(2120, 1000, 40, 4000);

  // buildings
  fill(150, 80, 80);
  rect(800, 200, 1200, 300);
  fill(80, 120, 150);
  rect(3200, 200, 1200, 300);
  fill(100, 140, 100);
  rect(800, 3000, 1200, 1200);
  fill(140, 100, 140);
  rect(3200, 3000, 1200, 1200);
}

// === GOAL ===
void drawGoal() {
  fill(0, 200, 0);
  rect(3500, 1000, 120, 120);
}

void checkWin() {
  if (!gameOver &&
      player.x > 3440 && player.x < 3560 &&
      player.y > 940 && player.y < 1060) {

    pushMatrix();
    resetMatrix();
    fill(255);
    textSize(40);
    textAlign(CENTER);
    text("YOU WIN", width/2, height/2);
    popMatrix();
  }
}

// === UI ===
void drawUI() {
  pushMatrix();
  resetMatrix();

  fill(255);
  textSize(20);
  textAlign(LEFT);
  text("Lives: " + lives, 20, 30);
  text("Score: " + score, 20, 60);

  if (gameOver) {
    textSize(50);
    textAlign(CENTER);
    text("GAME OVER", width/2, height/2);
  }

  if (score >= targetScore) {
    textSize(40);
    textAlign(CENTER);
    text("YOU WIN!", width/2, height/2);
  }

  popMatrix();
}

// === INPUT ===
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

// === CAR ===
class Car {
  float x, y;
  float angle;
  float speed = 0;

  float maxSpeed = 6;
  float accel = 0.25;
  float friction = 0.97;

  float turnInput = 0;
  float turnVelocity = 0;
  float turnSmooth = 0.1;
  float maxTurn = 0.05;

  int invulnTimer = 0; // 🔥 prevents multi-hit

  Car(float x, float y) {
    this.x = x;
    this.y = y;
    this.angle = -HALF_PI;
  }

  void update() {

    if (invulnTimer > 0) invulnTimer--;

    if (upPressed) speed += accel;
    if (downPressed) speed -= accel;

    speed *= friction;
    speed = constrain(speed, -maxSpeed, maxSpeed);

    turnInput = 0;
    if (leftPressed) turnInput -= 1;
    if (rightPressed) turnInput += 1;

    turnVelocity = lerp(turnVelocity, turnInput, turnSmooth);

    if (abs(speed) > 0.1) {
      angle += turnVelocity * maxTurn * speed;
    }

    float nextX = x + cos(angle) * speed;
    float nextY = y + sin(angle) * speed;

    if (!isBlocked(nextX, nextY)) {
      x = nextX;
      y = nextY;
    } else {
      crash();
    }
  }

  boolean isBlocked(float px, float py) {

    // buildings
    if (px > 200 && px < 1400 && py > 0 && py < 350) return true;
    if (px > 2600 && px < 3800 && py > 0 && py < 350) return true;
    if (px > 200 && px < 1400 && py > 2400 && py < 3800) return true;
    if (px > 2600 && px < 3800 && py > 2400 && py < 3800) return true;

    // trees
    for (Tree t : trees) {
      if (dist(px, py, t.x, t.y) < 20) return true;
    }

    return false;
  }

  void crash() {
    if (invulnTimer > 0) return; // 🔥 KEY FIX

    speed = 0;
    lives--;

    invulnTimer = 60; // ~1 second protection

    if (lives <= 0) gameOver = true;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);

    // flash when invulnerable
    if (invulnTimer > 0 && frameCount % 10 < 5) {
      fill(255, 100, 100);
    } else {
      fill(220);
    }

    rect(0, 0, 40, 20);

    stroke(255, 0, 0);
    line(0, 0, 20, 0);
    noStroke();

    popMatrix();
  }
}

// === TREE ===
class Tree {
  float x, y;

  Tree(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void display() {
    fill(100, 60, 20);
    rect(x, y + 10, 10, 20);

    fill(50, 160, 60);
    ellipse(x, y, 40, 40);
  }
}

// === HUMAN ===
class Human {
  float x, y;
  float dir;
  float speed;
  boolean alive = true;

  Human(float x, float y) {
    this.x = x;
    this.y = y;
    dir = random(TWO_PI);
    speed = random(0.5, 1.5);
  }

  void update() {
    if (!alive) return;

    x += cos(dir) * speed;
    y += sin(dir) * speed;

    if (random(1) < 0.02) dir += random(-1, 1);

    // 🚗 collision with car
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
