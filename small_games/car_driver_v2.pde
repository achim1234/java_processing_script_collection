
Car player;
ArrayList<Human> humans = new ArrayList<Human>();
ArrayList<Tree> trees = new ArrayList<Tree>();

boolean upPressed, downPressed, leftPressed, rightPressed;

int lives = 3;
int score = 0;
int targetScore = 15;

boolean gameOver = false;

void setup() {
  size(800, 600);
  rectMode(CENTER);

  player = new Car(2000, 1000);

  // humans
  for (int i = 0; i < 20; i++) {
    humans.add(new Human(random(300, 3700), random(300, 3700)));
  }

  // trees ONLY sidewalks
  for (int i = 300; i < 3700; i += 250) {
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

  if (!gameOver) {
    player.update();
  }

  player.display();

  drawGoal();
  drawUI();
  checkWin();
}

// ================= MAP =================

void drawMap() {

  // roads
  fill(60);
  rect(2000, 1000, 4000, 140);
  rect(2000, 1000, 140, 4000);

  // yellow center lines
  stroke(255, 200, 0);
  strokeWeight(3);

  for (int i = 0; i < 4000; i += 50) {
    line(i, 1000, i + 25, 1000);
    line(2000, i, 2000, i + 25);
  }

  noStroke();

  // sidewalks
  fill(100);
  rect(2000, 860, 4000, 40);
  rect(2000, 1140, 4000, 40);
  rect(1860, 1000, 40, 4000);
  rect(2140, 1000, 40, 4000);

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

// ================= GOAL =================

void drawGoal() {
  fill(0, 200, 0);
  rect(3500, 1000, 120, 120);
}

// ================= UI =================

void drawUI() {
  pushMatrix();
  resetMatrix();

  fill(255);
  textSize(18);
  textAlign(LEFT);
  text("Lives: " + lives, 20, 30);
  text("Score: " + score + " / " + targetScore, 20, 55);

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

// ================= WIN =================

void checkWin() {
  if (score >= targetScore) return;

  if (player.x > 3440 && player.x < 3560 &&
      player.y > 940 && player.y < 1060) {

    score = targetScore;
  }
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

// ================= CAR =================

class Car {
  float x, y;
  float angle;
  float speed = 0;

  float maxSpeed = 6;
  float accel = 0.2;
  float friction = 0.95;

  float turn = 0;
  float turnSmooth = 0.08;

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

    turn = lerp(turn, targetTurn, turnSmooth);

    if (abs(speed) > 0.05) {
      angle += turn * 0.04 * speed;
    }

    float nx = x + cos(angle) * speed;
    float ny = y + sin(angle) * speed;

    if (!blocked(nx, ny)) {
      x = nx;
      y = ny;
    } else {
      crash();
    }
  }

  boolean blocked(float px, float py) {

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

    if (invuln > 0 && frameCount % 6 < 3) fill(255, 80, 80);
    else fill(220);

    rect(0, 0, 40, 20);

    stroke(255, 0, 0);
    line(0, 0, 20, 0);
    noStroke();

    popMatrix();
  }
}

// ================= TREE =================

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

// ================= HUMAN =================

class Human {
  float x, y;
  float dir = random(TWO_PI);
  float speed = random(0.5, 1.2);
  boolean alive = true;
  
  Human(float x, float y) {
    this.x = x;
    this.y = y;
    dir = random(TWO_PI);
    speed = random(0.5, 1.2);
  }

  void update() {
    if (!alive) return;

    x += cos(dir) * speed;
    y += sin(dir) * speed;

    if (random(1) < 0.02) dir += random(-0.5, 0.5);

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
