//The instance of nature (f.e. manages grass)
Nature nature = new Nature();
Creatures creatures = new Creatures();
Overlay overlay = new Overlay();

//Runs once to set things up
void setup() {
  //Set the size of the screen
  fullScreen();
  //size(1280, 720);
  textSize(16);
  rectMode(CENTER);
}

//Runs at 60fps to render things
void draw() {
  //White background
  background(220, 255, 200);
  strokeWeight(2);
  
  //Now update and draw nature
  nature.update();
  nature.render();
  
  //Next update and draw creatures
  creatures.update();
  creatures.render();
  
  //Finally render the overlay
  overlay.render();
}

/**
 Small substitute function for creating a new PVector
 **/
PVector vec(float x, float y) {
  return new PVector(x, y);
}

class Overlay{
  void render(){
    stroke(80);
    fill(255, 180);
    rect(width / 2 - 1, 14, width + 2, 30);
    
    fill(0);
    text("FPS: " + int(frameRate), 10, 20);
    divider(90);
    text("Grass: " + nature.grassAmt, 100, 20);
    divider(190);
    text("Herbivores: " + creatures.herbivoreAmt, 200, 20);
    text("Avg. size: " + round(creatures.avgHerbSize), 340, 20); 
    divider(490);
    text("Carnivores: " + creatures.carnivoreAmt, 500, 20);
    text("Avg. size: " + round(creatures.avgCarnSize), 640, 20); 
    
  }
  
  void divider(int x){
    line(x, 0, x, 30);
  }
}
