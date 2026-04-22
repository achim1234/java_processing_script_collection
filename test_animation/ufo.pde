// ============================
// BETTER UFO + sichtbare Aliens
// ============================

float angle = 0;

int numStars = 800;
PVector[] stars = new PVector[numStars];

void setup() {
  size(900, 1600, P3D);

  for (int i = 0; i < numStars; i++) {
    stars[i] = new PVector(
      random(-2000, 2000),
      random(-2000, 2000),
      random(-2000, 2000)
    );
  }
}

void draw() {
  background(0);

  // wichtig: Licht!
  ambientLight(80, 80, 80);
  pointLight(0, 255, 200, 0, -200, 300);

  translate(width/2, height/2, -800);

  rotateX(0.2);
  rotateY(angle * 0.2);

  drawStars();

  pushMatrix();
  float ufoX = sin(angle) * 300;
  float ufoY = cos(angle * 0.5) * 150;
  float ufoZ = cos(angle) * 200;

  translate(ufoX, ufoY, ufoZ);
  rotateY(angle);

  drawUFO();
  popMatrix();

  angle += 0.01;
}

// ============================
// Sterne
// ============================
void drawStars() {
  strokeWeight(2);

  for (int i = 0; i < numStars; i++) {
    stroke(200 + random(55));
    point(stars[i].x, stars[i].y, stars[i].z);
  }
}

// ============================
// UFO
// ============================
void drawUFO() {

  noStroke();

  // Hauptscheibe (dicker!)
  fill(160);
  pushMatrix();
  rotateX(HALF_PI);
  scale(1.5, 1.5, 0.3);
  sphere(120);
  popMatrix();

  // Unterer Ring mit Lichtern
  pushMatrix();
  rotateX(HALF_PI);
  for (int i = 0; i < 12; i++) {
    float a = TWO_PI / 12 * i;
    float x = cos(a) * 140;
    float y = sin(a) * 140;

    pushMatrix();
    translate(x, y, 0);
    fill(0, 255, 200);
    sphere(6);
    popMatrix();
  }
  popMatrix();

  // Glaskuppel
  pushMatrix();
  translate(0, -60, 0);
  fill(100, 200, 255, 80);
  sphere(90);
  popMatrix();

  // Innenlicht (macht Aliens sichtbar)
  pointLight(0, 255, 150, 0, -50, 100);

  // Aliens (größer + heller)
  drawAlien(-40, -40, 20, 1.6);
  drawAlien(40, -40, 20, 1.6);
  drawAlien(0, -10, 40, 1.0);
}

// ============================
// Alien
// ============================
void drawAlien(float x, float y, float z, float s) {
  pushMatrix();
  translate(x, y, z);
  scale(s);

  // glow effekt
  emissive(0, 255, 150);

  // Körper
  fill(0, 255, 150);
  sphere(25);

  // Kopf
  translate(0, -35, 0);
  sphere(20);

  // Augen (größer!)
  fill(0);
  pushMatrix();
  translate(-7, 0, 15);
  sphere(6);
  popMatrix();

  pushMatrix();
  translate(7, 0, 15);
  sphere(6);
  popMatrix();

  emissive(0); // reset

  popMatrix();
}

