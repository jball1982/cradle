//Create array to hold our balls. I wouldn't mess with this much!
int NBalls = 2;
Ball[] balls = new Ball[NBalls];


float dt = 0.1;           //Time scaling factor. Higher => faster, more unstable
boolean unClicked = true;       //Must be true for correct functioning

//Here's the set of parameters to play with
boolean quickAddMode = true;    //False-> one ball per click. True->hold to create many
boolean randomSizes = true;    //False-> same size for all. True->pick from range

int rad_min = 5;            //Smallest radius when randomSizes = true
int rad_max = 20;           // Largest radius when randomSizes = true
int rad_const = 25;         //Radius when randomSizes = false

int jiggle_coefficient = 0;     //Suggested range: 0.0->50.0 
int drag_coefficient = 1;       //Suggested range: 0.1->5.0
int push_coefficient = 10;      //Suggested range: 2.0->25.0
int pull_coefficient = 0;      //Suggested range: 0.1->20.0

void setup() {
  size(500, 400);
  //Setup the font
  //f = createFont("SourceCodePro-Regular.ttf", 25);
  //textFont(f);

  //Initialize the first few 
  for (int n=0; n < balls.length; n++) {
    balls[n] = new Ball(250, 200);
  }
}


void draw() {
  //Clear background
  background(0);

  //Accumulate push/pull forces for each possible pair
  for (int m=0; m<balls.length; m++) {
    for (int n=0; n<balls.length; n++) {
      if (m!=n) {
        balls[m].addForces(balls[n]);
      }
    }
  }

  //Draw each
  for (int n=0; n<balls.length; n++) {
    balls[n].update();
  }

  //Add new members when the user clicks (quickAddMode adds them....rapidly)
  if (mousePressed && (unClicked || quickAddMode)) {
    Ball[] newballs = (Ball[]) append(balls, new Ball(mouseX, mouseY));
    balls = newballs;
    //balls = append(balls, new Ball(mouseX, mouseY));
    unClicked = false;
  }

  //One word tutorial:
  fill(255);
  text("Click!", 10, 25);
}