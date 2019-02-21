class Herbivore extends WanderCreature {
  //If we're dead
  boolean dead = false;
  //If we're fully decayed
  boolean decayed = false;
  //The amount of health left
  float health = 0;

  /**
   Create a new Herbivore at the specified location
   **/
  Herbivore(float x, float y) {
    super(x, y);
    c = color(0, 158, 152);
    health = size;
  }

  //Create a new herbivore from a parent
  Herbivore(Herbivore parent) {
    this(parent.pos.x, parent.pos.y);
    //10 adjustment
    size = random(0.9, 1.1) * parent.size;
    //Start with same starting energy as parrent cost to make you
    energy = size * 2;
    //On larger population, new spawn are not as healthy
    if (random(1000) < creatures.herbivoreAmt) energy *= 0.3f;
    mass = size / 3;
    health = size;
  }

  //Updates this herbivore
  void update() {
    if (!dead) {
      //Update the superclass
      super.update();

      if (energy > size * size && age > size * 10) {//If we have enough energy to procreate and are older than one second
        energy -= size * 2;
        //Add a child to the world
        creatures.spawnHerbivore(this, 1);
      } else if (age > size * 5) {
        //Else seek grass to multiply, if there is no grass, wander
        if (!seekGrass()) wander();
      } else {
        wander();
      }
    }
    //And always avoid the closest carnivore
    Carnivore car = findClosestCarnivore();
    if (car != null) {
      PVector diff = PVector.sub(car.pos, pos);
      avoid(car.pos, (diff.mag() / 200) * 10 + 1);
    }
    //If we go below 0 energy, we die
    if ((energy < 0 || age > size * 100) && !dead) {
      dead = true;
      c = color(123, 174, 157);
    }

    //Decay, this means the predators can still eat some
    if (dead) {
      //Slowly decrease size
      size -= 0.01;
      if (size < 0.1) decayed = true;
    }
  }

  Carnivore findClosestCarnivore() {
    //The recordholder
    Carnivore record = null;
    float dist = 999999999;
    PVector diff;
    //Go through every piece of grass
    for (Carnivore c : creatures.carnivores) {
      diff = PVector.sub(c.pos, pos);
      //If this is a new record, set it
      if (diff.magSq() < dist && !c.dead) {
        record = c;
        dist = diff.magSq();
      }
    }
    //Ignore distant predators
    if (sqrt(dist) > 200) record = null;

    //Return the record;
    return record;
  }

  //Go towards this grass piece
  boolean seekGrass() {
    //Try to find a close piece of grass
    Grass c = findClosestGrass();
    if (c == null) return false;
    //If we make it to here, we can seek for it
    seek(c.pos);
    return true;
  }

  /**
   Try to find the closest piece of grass
   **/
  Grass findClosestGrass() {
    //The recordholder
    Grass record = null;
    float dist = 999999999;
    PVector diff;
    //Go through every piece of grass
    for (Grass g : nature.grass) {
      diff = PVector.sub(g.pos, pos);
      //If this is a new record, set it
      //Also keep in mind how large grass is, prefer bigger pieces
      if (diff.magSq() * g.amt < dist && !g.eaten) {
        record = g;
        dist = diff.magSq() * g.amt;
      }
    }
    //Check if the record holder is close enough to eat
    if (record != null && sqrt(dist / record.amt) <= size + record.amt * 3) {
      //Add the food amount
      energy += min(size * 0.05, record.amt);
      record.amt -= size * 0.05;
      //And set the grass as eaten
      if (record.amt < 0.1) record.eaten = true;
    }

    //Ignore distant grass
    if (record != null && sqrt(dist) > 200) record = null;

    //Return the record holder
    return record;
  }
}

//The carnivore class
class Carnivore extends WanderCreature {
  //If we're dead
  boolean dead = false;
  //If we're fully decayed
  boolean decayed = false;

  Carnivore(float x, float y) {
    super(x, y);
    c = color(217, 89, 59);
  }

  Carnivore(Carnivore parent) {
    this(parent.pos.x, parent.pos.y);
    //10 adjustment
    size = random(0.9, 1.1) * parent.size;
    //Start with same starting energy as twice size  of parent
    energy = size * 2;
    //On larger populations, new spawns are not as strong
    if (random(1000) < creatures.carnivoreAmt) energy *= 0.3;
    mass = size / 3;
  }

  void update() {
    if (!dead) {
      if (energy > size * size && age > size * 10) {//If we have enough energy to procreate and are older than one second
        energy -= size * size;
        //Add a child to the world
        creatures.spawnCarnivore(this, 1);
      } else if (age > size * 5) {
        //Else seek grass to multiply, if there is no grass, wander
        if (!seekPrey()) wander();
      } else {
        wander();
      }
      //Update the superclass
      super.update();
    }
    //If we go below 0 energy, we die
    if ((energy < 0 || age > size * 100) && !dead) {
      dead = true;
      c = color(217, 174, 59);
    }

    if (dead) {
      //Slowly decrease size
      size -= 0.01;
      if (size < 0.1) decayed = true;
    }
  }

  //Go towards this grass piece
  boolean seekPrey() {
    //Try to find a close piece of grass
    Herbivore c = findClosestPrey();
    if (c == null) return false;
    //If we make it to here, we can seek for it
    seek(c.pos);
    return true;
  }

  /**
   Try to find the closest piece of grass
   **/
  Herbivore findClosestPrey() {
    //The recordholder
    Herbivore record = null;
    float dist = 999999999;
    PVector diff;
    //Go through every piece of grass
    for (Herbivore h : creatures.herbivores) {
      //Only go after alive ones
      //if(h.dead) continue;
      diff = PVector.sub(h.pos, pos);
      //If this is a new record, set it
      if (diff.magSq() * h.size < dist && !h.decayed) {
        record = h;
        dist = diff.magSq() * h.size;
      }
    }
    //Check if the record holder is close enough to eat
    if (record != null && sqrt(dist / record.size) <= size + record.size) {
      //Add the food amount (or a bite, to be more precise)
      energy += size * 0.5;
      record.health -= size * 0.5;
      //And set the grass as eaten
      if (record.health < 0) record.decayed = true;
    }

    //Ignore distant grass
    if (record != null && sqrt(dist) > 200) record = null;

    //Return the record holder
    return record;
  }
}
