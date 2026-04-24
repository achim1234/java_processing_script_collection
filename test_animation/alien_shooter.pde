// Alien vs Asteroids (CLEAN FINAL VERSION)
 
Player player;
ArrayList<Asteroid> asteroids;
ArrayList<Laser> lasers;
ArrayList<Star> stars;
 
int score = 0;
int wave = 1;
boolean gameOver = false;
 
int lastShotTime = 0;
int reloadTime = 180;
 
boolean up, down, left, right;
 
void settings() {
  size(900, 1600);
}
 
void setup() {
  player = new Player(width/2, height/2);
 
  asteroids = new ArrayList<Asteroid>();
  lasers = new ArrayList<Laser>();
  stars = new ArrayList<Star>();
 
  for (int i = 0; i < 120; i++) {
    stars.add(new Star());
  }
 
  spawnWave(wave);
}
 
void draw() {
  background(0);
 
  for (Star s : stars) s.display();
 
  if (!gameOver) {
 
    player.update();
    player.display();
 
    if (mousePressed && millis() - lastShotTime > reloadTime) {
      shootLaser();
    }
 
    for (int i = lasers.size() - 1; i >= 0; i--) {
      Laser l = lasers.get(i);
      l.update();
      l.display();
 
      if (l.isDead()) lasers.remove(i);
    }
 
    for (int i = asteroids.size() - 1; i >= 0; i--) {
      Asteroid a = asteroids.get(i);
      a.update();
      a.display();
 
      if (a.collidesWith(player)) {
        gameOver = true;
      }
 
      boolean hit = false;
 
      for (int j = lasers.size() - 1; j >= 0; j--) {
        Laser l = lasers.get(j);
 
        if (a.collidesWithLaser(l)) {
          lasers.remove(j);
          hit = true;
          score += (int)a.radius;
          break;
        }
      }
 
      if (hit) asteroids.remove(i);
    }
 
    if (asteroids.size() == 0) {
      wave++;
      spawnWave(wave);
    }
 
    fill(255);
    textSize(16);
    text("Score: " + score, 20, 30);
    text("Wave: " + wave, 20, 55);
 
  } else {
 
    fill(255, 0, 0);
    textAlign(CENTER);
    textSize(48);
    text("GAME OVER", width/2, height/2);
 
    fill(255);
    textSize(20);
    text("Press R to restart", width/2, height/2 + 60);
 
    textAlign(LEFT);
  }
}
 
/* ================= SHOOT ================= */
 
void shootLaser() {
 
  PVector dir = new PVector(mouseX - player.pos.x, mouseY - player.pos.y);
 
  if (dir.mag() > 0.001) {
    dir.normalize();
    lasers.add(new Laser(player.pos.x, player.pos.y, dir));
    lastShotTime = millis();
  }
}
 
/* ================= INPUT ================= */
 
void keyPressed() {
  if (key == 'w') up = true;
  if (key == 's') down = true;
  if (key == 'a') left = true;
  if (key == 'd') right = true;
 
  if ((key == 'r' || key == 'R') && gameOver) {
    score = 0;
    wave = 1;
    gameOver = false;
    setup();
  }
}
 
void keyReleased() {
  if (key == 'w') up = false;
  if (key == 's') down = false;
  if (key == 'a') left = false;
  if (key == 'd') right = false;
}
 
/* ================= SPAWN ================= */
 
void spawnWave(int w) {
  int count = 2 + w;
 
  for (int i = 0; i < count; i++) {
    float angle = random(TWO_PI);
    float dist = max(width, height)/2 + random(50, 150);
 
    asteroids.add(new Asteroid(
      player.pos.x + cos(angle)*dist,
      player.pos.y + sin(angle)*dist
    ));
  }
}
 
/* ================= PLAYER ================= */
 
class Player {
  PVector pos, vel;
  float speed = 3;
  float friction = 0.9;
  float radius = 34;
 
  Player(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
  }
 
  void update() {
 
    PVector input = new PVector(0, 0);
 
    if (up) input.y -= 1;
    if (down) input.y += 1;
    if (left) input.x -= 1;
    if (right) input.x += 1;
 
    if (input.mag() > 0) {
      input.normalize();
      input.mult(speed * 0.3);
    }
 
    vel.add(input);
    vel.mult(friction);
    vel.limit(5);
 
    pos.add(vel);
 
    if (pos.x < 0) pos.x = width;
    if (pos.x > width) pos.x = 0;
    if (pos.y < 0) pos.y = height;
    if (pos.y > height) pos.y = 0;
  }
 
  void display() {
 
    PVector aimDir = new PVector(mouseX - pos.x, mouseY - pos.y);
    if (aimDir.mag() > 0) aimDir.normalize();
 
    noStroke();
 
    // UFO
    fill(150);
    ellipse(pos.x, pos.y, 60, 34);
 
    fill(180);
    arc(pos.x, pos.y - 6, 48, 24, PI, TWO_PI);
 
    // alien
    fill(255, 100, 200);
    ellipse(pos.x, pos.y - 14, 30, 36);
 
    fill(255, 150, 220);
    ellipse(pos.x, pos.y - 30, 26, 26);
 
    // eyes
    fill(0, 255, 100);
    ellipse(pos.x - 6, pos.y - 32, 5, 6);
    ellipse(pos.x + 6, pos.y - 32, 5, 6);
 
    // gun
    stroke(0, 255, 120);
    strokeWeight(3);
 
    line(
      pos.x,
      pos.y - 10,
      pos.x + aimDir.x * 32,
      pos.y - 10 + aimDir.y * 32
    );
 
    noStroke();
 
    // thruster
    if (vel.mag() > 0.2) {
 
      PVector back = vel.copy();
      back.normalize();
      back.mult(-25);
 
      float flick = random(8, 14);
 
      fill(0, 255, 120, 180);
      ellipse(pos.x + back.x, pos.y + back.y, flick, flick);
 
      fill(255, 140, 0, 140);
      ellipse(pos.x + back.x*1.2, pos.y + back.y*1.2, flick*0.6, flick*0.6);
    }
  }
}
 
/* ================= ASTEROID ================= */
 
class Asteroid {
  PVector pos, vel;
  float radius;
  ArrayList<PVector> verts;
 
  Asteroid(float x, float y) {
    pos = new PVector(x, y);
    radius = random(15, 40);
 
    float speed = random(1, 3);
 
    vel = PVector.sub(player.pos, pos);
    if (vel.mag() > 0) vel.normalize();
    vel.mult(speed);
 
    verts = new ArrayList<PVector>();
    int n = (int)random(5, 12);
 
    for (int i = 0; i < n; i++) {
      float a = map(i, 0, n, 0, TWO_PI);
      float r = radius * random(0.7, 1.3);
      verts.add(new PVector(cos(a)*r, sin(a)*r));
    }
  }
 
  void update() {
    pos.add(vel);
 
    if (pos.x < -radius) pos.x = width + radius;
    if (pos.x > width + radius) pos.x = -radius;
    if (pos.y < -radius) pos.y = height + radius;
    if (pos.y > height + radius) pos.y = -radius;
  }
 
  void display() {
    fill(150, 100, 100);
    stroke(200);
    strokeWeight(2);
 
    beginShape();
    for (PVector v : verts) {
      vertex(pos.x + v.x, pos.y + v.y);
    }
    endShape(CLOSE);
  }
 
  boolean collidesWith(Player p) {
    return dist(pos.x, pos.y, p.pos.x, p.pos.y) < radius + p.radius;
  }
 
  boolean collidesWithLaser(Laser l) {
    return dist(pos.x, pos.y, l.pos.x, l.pos.y) < radius;
  }
}
 
/* ================= LASER ================= */
 
class Laser {
  PVector pos, vel;
  PVector prevPos;
 
  float life = 0;
  float maxLife = 120;
 
  Laser(float x, float y, PVector dir) {
    pos = new PVector(x, y);
    prevPos = pos.copy();
    vel = dir.copy();
    vel.mult(14);
  }
 
  void update() {
    prevPos = pos.copy();
    pos.add(vel);
    life++;
  }
 
  void display() {
 
    stroke(0, 255, 120, 60);
    strokeWeight(8);
    line(prevPos.x, prevPos.y, pos.x, pos.y);
 
    stroke(0, 255, 200, 160);
    strokeWeight(4);
    line(prevPos.x, prevPos.y, pos.x, pos.y);
 
    stroke(255);
    strokeWeight(2);
    line(prevPos.x, prevPos.y, pos.x, pos.y);
  }
 
  boolean isDead() {
    return life > maxLife ||
      pos.x < 0 || pos.x > width ||
      pos.y < 0 || pos.y > height;
  }
}
 
/* ================= STAR ================= */
 
class Star {
  float x, y;
 
  Star() {
    x = random(width);
    y = random(height);
  }
 
  void display() {
    stroke(255);
    point(x, y);
  }
}

