//The size of grass pieces
final int maxGrassAmt = 10;
final int minGrassAmt = 3;
//Amount of time the grass can live
final int maxAge = 1800;
final int minAge = 300;
final float growAmt = 0.05;

ArrayList<Grass> grassPool = new ArrayList<Grass>();

Grass getGrass(){
  if(grassPool.size() > 0){
    Grass g = grassPool.get(0);
    return g.init();
  }else{
    return new Grass();
  }
}

//A single piece of grass, holds a certain amount of energy
class Grass {
  //The position of the grass
  PVector pos;
  //The amount of grass in this grass
  float amt = 5;
  //Amount of frames the grass has lived
  int age = 0;
  //If we have been eaten
  boolean eaten = false;
  
  color c;

  //Creates a new Grass instance
  Grass() {
    init();
  }
  
  Grass init(){
    pos = new PVector(random(width), random(height));
    amt = random(minGrassAmt, maxGrassAmt);
    age = (int) random(minAge, maxAge);
    c = color(random(50, 180), random(140, 200), 0);
    eaten = false;
    return this;
  }

  boolean update() {
    //If we're eaten, we can no longer update
    if (eaten) return false;
    //Increment our age
    //age--;
    //Grass get less nutrient as it keeps on living
    if(amt < 200) amt += growAmt;
    //If we're done with living, return false
    if (age < 0) return false;
    return true;
  }

  //Renders this grass
  void render() {
    //Black stroke
    noStroke();
    //Green fill
    fill(c);
    //Circle
    circle(pos.x, pos.y, amt);
  }
}

/**
 Manages resources, amongst which grass
 **/
class Nature {
  //Amount of frames for grass to grow
  int grassGrowInterval = 5;
  //All pieces of grass in the environment
  ArrayList<Grass> grass = new ArrayList<Grass>();
  ArrayList<Grass> grassToRemove = new ArrayList<Grass>();
  
  int grassAmt = 0;

  //Updates nature
  void update() {
    //If we're ready to grow new grass, grow it, only if we're not overgrown yet
    if (frameCount % grassGrowInterval == 0 && grass.size() < 400) grass.add(new Grass());
    //Always update all grass
    for (Grass g : grass) {
      if (!g.update()) grassToRemove.add(g);
    }
    //Empty the array after removing
    if (grassToRemove.size() > 0) {
      //Check if we needt o remove any
      for (Grass g : grassToRemove) {
        grass.remove(g);
        //Add to pool
        grassPool.add(g);
      }
      grassToRemove.clear();
    }
    //Update the amount of grass that is left
    grassAmt = grass.size();
  }

  //Renders nature
  void render() {
    for (Grass g : grass) g.render();
  }
}
