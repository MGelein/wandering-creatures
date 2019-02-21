class Creature {
  //The position of the creature
  PVector pos;
  //The velocity of the creature
  PVector vel = new PVector();
  //The acceleration of the creature
  PVector acc = new PVector();
  //The maximum speed of the creature
  float maxVel = 5;
  //The mass of the object, depends on the size
  float mass;
  //The size of the creature
  float size = 10;
  //The amount of energy this creature has
  float energy = 15;
  //Amount of frames we lived
  int age = 0;

  //The color of this creature;
  color c = color(180);

  /**
   Create a new creature at the given position
   **/
  Creature(float x, float y) {
    pos = vec(x, y);
    size = random(7, 15);
    mass = size / 3;
    maxVel = size / 3;
  }

  /**
   Update the creature's movement
   **/
  void update() {
    //First accelerate the velocity
    vel.add(acc);
    //Now add velocity to position
    pos.add(vel);
    //Always at least apply 0.99 friction, but for higher mass, apply less
    vel.mult(min((0.925) + (mass * 0.01), 0.99));
    
    //Take away energy depending on mass and acceleration
    energy -= (acc.mag() * mass * mass) / 500 + 0.01;
    //Reset the accelertion
    acc.setMag(0);
    //Add to age
    age++;
  }

  /**
   Apply a force to the creature, these all get summed before
   applying
   **/
  void applyForce(PVector f) {
    f.div(mass);
    acc.add(f);
  }

  /**
   Apply a force to the creature, these all get summed before
   applying
   **/
  void applyForce(float x, float y) {
    applyForce(vec(x, y));
  }

  void render() {
    pushMatrix();
    strokeWeight(1);
    //First translate to match the position and rotation of the creature
    translate(pos.x, pos.y);
    rotate(vel.heading() - HALF_PI);
    //Now draw it
    fill(c);
    stroke(40);
    //The body
    beginShape();
    vertex(-size, 0);
    vertex(0, size * 2);
    vertex(size, 0);
    vertex(0, -size);
    endShape(CLOSE);
    popMatrix();
  }
}

class WanderCreature extends SeekCreature {
  //How long we have to wander for
  private int wanderTime = 0;
  //How long we have wandered
  private int wanderFrames = 0; 
  //Random vector to wander towards
  PVector target = new PVector();

  private float wanderForce = 0.1;
  /**
   Creates a new wandering creature
   **/
  WanderCreature(float x, float y) {
    super(x, y);
  }

  //Wander with default strength (1)
  void wander() {
    wander(1.0f);
  }

  //Applies velocity updates, but also wanders around
  void wander(float strength) {
    //If we're done going towards this goal
    if (wanderFrames >= wanderTime || PVector.sub(target, pos).mag() < 1) {
      //Get a new goal
      target = new PVector(random(width), random(height));
      wanderFrames = 0;
      //WAnder between 1 to 2 seconds
      wanderTime = (int) random(30, 60);
    } else {
      seek(target, wanderForce * strength);
      wanderFrames++;
    }
  }
}

//Seek and Avoid creature
class SeekCreature extends Creature {

  private float maxSeekForce = 1;
  private float maxAvoidForce = 1;
  private float safeSpace = 300;

  //Create a new seekcreature
  SeekCreature(float x, float y) {
    super(x, y);
  }

  //Seek with default (1) strength
  void seek(PVector target) {
    seek(target, 1);
  }

  //Seeks the provided point
  void seek(PVector target, float strength) {
    //Find the desired distance to go there
    PVector desired = PVector.sub(target, pos);
    //Only desire to move about 5 percent of that distance, this makes sure that we stop on time
    //desired.mult(0.25 / mass);
    desired.mult(strength);
    //Limit it
    if (desired.mag() > maxVel) {
      desired.normalize();
      desired.mult(maxVel);
    }
    //Get the required steering force
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxSeekForce);
    //If there is very little movement left, don't steer
    if (steer.mag() < 0.1) steer.mult(0);
    applyForce(steer);
  }

  //Avoid is similar to seek
  void avoid(PVector target, float strength) {
    //Find the desired distance to go there
    PVector desired = PVector.sub(target, pos);
    //The farther we are, the less we move
    if (desired.mag() > safeSpace) {//Safe distance
      return;
    } else {
      //How much is left from the safe space [0-1]
      float ratio = (safeSpace - desired.mag()) / safeSpace;
      desired.mult(ratio);
    }

    //Get the required steering force
    PVector steer = PVector.sub(desired, vel);
    steer.mult(strength);
    steer.rotate(PI);
    steer.limit(maxAvoidForce);
    //If there is very little movement left, don't steer
    if (steer.mag() < 0.1) steer.mult(0);
    applyForce(steer);
  }
}

//A mouse look alike creature
class Mouse extends WanderCreature {
  //The vector for the tailpieces
  PVector tailPcs[] = new PVector[10];

  //Creates a new mouse
  Mouse(float x, float y) {
    super(x, y);
    for (int i = 0; i < tailPcs.length; i++) {
      tailPcs[i] = pos.copy();
    }
  }

  //Update the mouse, and its tail
  void update() {
    //First update superclass
    super.update();
    //Wrap around the edges
    if (pos.y > height) moveToTop(this);
    else if (pos.y < 0) moveToBottom(this);
    if (pos.x > width) moveToLeft(this);
    else if (pos.x < 0) moveToRight(this);

    //Update the moving of the tailpieces
    for (int i = tailPcs.length - 2; i >= 0; i--) {
      tailPcs[i + 1] = tailPcs[i];
    }
    tailPcs[0] = pos.copy();
  }

  /**
   Render the Mouse (override of normal creature render)
   **/
  void render() {
    strokeWeight(1);
    pushMatrix();
    //First translate to match the position and rotation of the creature
    translate(pos.x, pos.y);
    rotate(vel.heading() - HALF_PI);
    //Now draw it
    fill(180);
    stroke(40);
    //The body
    beginShape();
    vertex(-size, 0);
    vertex(0, size * 2);
    vertex(size, 0);
    vertex(0, -size);
    endShape(CLOSE);
    //Draw the 'eyes'
    fill(255);
    circle(size * 0.5, size, size * 0.5);
    circle(-size * 0.5, size, size * 0.5);
    fill(0);
    noStroke();
    circle(size * 0.5, size * 1.1, size * 0.2);
    circle(-size * 0.5, size * 1.1, size * 0.2);

    //A little nose
    fill(255, 178, 165);
    circle(0, size * 2, size * 0.4);

    //Now draw the tail
    stroke(255, 178, 165);
    float w = 10;
    float diff = w / (tailPcs.length - 3);
    noFill();
    popMatrix();
    for (int i = 3; i < tailPcs.length - 1; i++) {
      strokeWeight(w);
      w -= diff;
      line(tailPcs[i].x, tailPcs[i].y, tailPcs[i + 1].x, tailPcs[i + 1].y);
    }
  }
}

/**
 The creature manager
 **/
class Creatures {
  //List of all herbivores
  ArrayList<Herbivore> herbivores = new ArrayList<Herbivore>();
  ArrayList<Herbivore> herbToRemove = new ArrayList<Herbivore>();
  ArrayList<Herbivore> herbToAdd = new ArrayList<Herbivore>();
  int herbivoreAmt = 0;
  float avgHerbSize = 0;

  //List of all carnivores
  ArrayList<Carnivore> carnivores = new ArrayList<Carnivore>();
  ArrayList<Carnivore> carnToRemove = new ArrayList<Carnivore>();
  ArrayList<Carnivore> carnToAdd = new ArrayList<Carnivore>();
  int carnivoreAmt = 0;
  float avgCarnSize = 0;

  //Update all creatures
  void update() {
    manageHerbivores();
    manageCarnivores();
  }

  //Handle the management of all the herbivores
  void manageHerbivores() {
    //Spawn a herbivore if there is not one right now (not even decayin)
    if (herbivores.size() < 1) spawnHerbivore();

    herbivoreAmt = 0;
    float sum = 0;
    for (Herbivore h : herbivores) {
      //Add it, if it needs removing
      if (h.decayed) herbToRemove.add(h);
      //Else update
      else h.update();
      
      if(!h.dead) herbivoreAmt++;
      if(!h.dead) sum += h.size;
    }
    avgHerbSize = sum / herbivoreAmt;
    //Clean lists
    if (herbToRemove.size() > 0) {
      for (Herbivore h : herbToRemove) {
        herbivores.remove(h);
      }
      herbToRemove.clear();
    }

    if (herbToAdd.size() > 0) {
      for (Herbivore h : herbToAdd) {
        herbivores.add(h);
      }
      herbToAdd.clear();
    }
  }
  
  //Handle the management of all the carnivores
  void manageCarnivores() {
    //Spawn a herbivore if there is not one right now
    if (carnivores.size() < 1) spawnCarnivore();

    carnivoreAmt = 0;
    float sum = 0;
    for (Carnivore c : carnivores) {
      //Add it, if it needs removing
      if (c.decayed) carnToRemove.add(c);
      //Else update
      else c.update();
      
      if(!c.dead) carnivoreAmt ++;
      if(!c.dead) sum += c.size;
    }
    avgCarnSize = sum / carnivoreAmt;
    
    //Clean lists
    if (carnToRemove.size() > 0) {
      for (Carnivore c : carnToRemove) {
        carnivores.remove(c);
      }
      carnToRemove.clear();
    }

    if (carnToAdd.size() > 0) {
      for (Carnivore c : carnToAdd) {
        carnivores.add(c);
      }
      carnToAdd.clear();
    }
  }

  //Render all creatures
  void render() {
    for (Herbivore h : herbivores) h.render();
    for (Carnivore c : carnivores) c.render();
  }

  void spawnHerbivore(float x, float y, int amt) {
    while (amt > 0) {
      herbToAdd.add(new Herbivore(x, y));
      amt --;
    }
  }
  
  void spawnCarnivore(float x, float y, int amt) {
    while (amt > 0) {
      carnToAdd.add(new Carnivore(x, y));
      amt --;
    }
  }

  //Spawn a new herb from a parent
  void spawnHerbivore(Herbivore h, int amt) {
    while (amt > 0) {
      herbToAdd.add(new Herbivore(h));
      amt --;
    }
  }
  
  void spawnCarnivore(Carnivore c, int amt){
    while(amt > 0){
      carnToAdd.add(new Carnivore(c));
      amt --;
    }
  }

  //Add a new herbivore to the simulation
  void spawnHerbivore() {
    spawnHerbivore(random(width), random(height), 1);
  }
  
  void spawnCarnivore(){
    spawnCarnivore(random(width), random(height), 1);
  }
}

void moveToLeft(Mouse c) {
  float dist = 0 - c.pos.x;
  for (PVector v : c.tailPcs) {
    v.add(dist, 0);
  }
  c.pos.x = 0;
}

void moveToRight(Mouse c) {
  float dist = width - c.pos.x;
  for (PVector v : c.tailPcs) {
    v.add(dist, 0);
  }
  c.pos.x = width;
}

void moveToTop(Mouse c) {
  float dist = 0 - c.pos.y;
  for (PVector v : c.tailPcs) {
    v.add(0, dist);
  }
  c.pos.y = 0;
}

void moveToBottom(Mouse c) {
  float dist = height - c.pos.y;
  for (PVector v : c.tailPcs) {
    v.add(0, dist);
  }
  c.pos.y = height;
}
