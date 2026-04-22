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

  ambientLight(100, 100, 100);
  pointLight(0, 255, 200, 0, -200, 300);

  translate(width/2, height/2, -600); // näher ran!

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
void drawStars() {
  strokeWeight(2);

  for (int i = 0; i < numStars; i++) {
    stroke(200 + random(55));
    point(stars[i].x, stars[i].y, stars[i].z);
  }
}

// ============================
void drawUFO() {

  noStroke();

  // Hauptkörper
  fill(160);
  pushMatrix();
  rotateX(HALF_PI);
  scale(1.5, 1.5, 0.3);
  sphere(120);
  popMatrix();

  // Lichterring
  pushMatrix();
  rotateX(HALF_PI);
  for (int i = 0; i < 12; i++) {
    float a = TWO_PI / 12 * i;
    float x = cos(a) * 140;
    float y = sin(a) * 140;

    pushMatrix();
    translate(x, y, 0);
    emissive(0, 255, 200);
    sphere(8);
    emissive(0);
    popMatrix();
  }
  popMatrix();

  // 👉 ALIENS ZUERST ZEICHNEN (wichtig!)
  drawAlien(-40, -40, 40, 1.8);
  drawAlien(40, -40, 40, 1.8);
  drawAlien(0, -10, 60, 1.2);

  // 👉 dann transparente Kuppel
  hint(DISABLE_DEPTH_MASK); // Trick!
  pushMatrix();
  translate(0, -60, 0);
  fill(100, 200, 255, 50); // sehr transparent
  sphere(110);
  popMatrix();
  hint(ENABLE_DEPTH_MASK);
}

// ============================
void drawAlien(float x, float y, float z, float s) {
  pushMatrix();
  translate(x, y, z);
  scale(s);

  // starkes Eigenlicht
  emissive(0, 255, 150);

  // Körper
  fill(50, 255, 180);
  sphere(30);

  // Kopf
  translate(0, -40, 0);
  sphere(25);

  // große Augen
  fill(0);
  pushMatrix();
  translate(-8, 0, 18);
  sphere(7);
  popMatrix();

  pushMatrix();
  translate(8, 0, 18);
  sphere(7);
  popMatrix();

  emissive(0);
  popMatrix();
}

