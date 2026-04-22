int numParticles = 400;
Particle[] particles;

float t = 0;

void setup() {
  size(900, 1300);
  smooth(8);
  
  particles = new Particle[numParticles];
  for (int i = 0; i < numParticles; i++) {
    particles[i] = new Particle(random(width), random(height));
  }
  
  background(0);
}

void draw() {
  fill(0, 20); // leichter Trail
  noStroke();
  rect(0, 0, width, height);

  translate(width/2, height/2);
  
  for (int i = 0; i < numParticles; i++) {
    particles[i].move();
    particles[i].display();
  }
  
  t += 0.01;
}

// ================================
// Particle Class
// ================================
class Particle {
  float x, y;
  float angle;
  float speed;
  float size;
  
  Particle(float x_, float y_) {
    x = x_ - width/2;
    y = y_ - height/2;
    speed = random(0.5, 2);
    size = random(1, 4);
  }
  
  void move() {
    float n = noise(x * 0.002, y * 0.002, t);
    angle = n * TWO_PI * 2;
    
    // leichte Maus-Interaktion
    float dx = mouseX - width/2 - x;
    float dy = mouseY - height/2 - y;
    float dist = sqrt(dx*dx + dy*dy);
    
    if (dist < 200) {
      angle += atan2(dy, dx) * 0.05;
    }
    
    x += cos(angle) * speed;
    y += sin(angle) * speed;
    
    // wrap around
    if (x > width/2) x = -width/2;
    if (x < -width/2) x = width/2;
    if (y > height/2) y = -height/2;
    if (y < -height/2) y = height/2;
  }
  
  void display() {
    float hue = map(sin(t + x * 0.01), -1, 1, 100, 255);
    float alpha = map(speed, 0.5, 2, 50, 150);
    
    stroke(hue, 100, 255, alpha);
    strokeWeight(size);
    
    point(x, y);
    
    // kleine Linien für mehr "Flow"
    line(x, y, x + cos(angle)*5, y + sin(angle)*5);
  }
}

