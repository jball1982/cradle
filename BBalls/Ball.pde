//Class definition
class Ball {
  //x-y pairs to hold position, velocity, acceleration
  float px; 
  float py;
  float vx; 
  float vy;
  float ax; 
  float ay;

  //Radius
  float R;

  //RGB Color values
  float cr; 
  float cg; 
  float cb;


  Ball(float X, float Y) {
    //Initialize parameters. This check for quickAddMode helps things settle more quickly
    if (quickAddMode) {
      px = 10*randomGaussian()+X; 
      py = 10*randomGaussian()+Y;
    } else {
      px = X; 
      py = Y;
    }
    vx = 0; 
    vy = 0; 
    ax = 0; 
    ay = 0;
    cr = random(0, 255); 
    cg = random(0, 255); 
    cb = random(0, 255);

    //Draw size from a distribution or keep them the same
    if (randomSizes) {
      R = random(rad_min, rad_max);
    } else {
      R = rad_const;
    }
  }

  void addForces(Ball B) {
    //Calculate distance between ball_1 and ball_2 (B)
    float dx = px-B.px;
    float dy = py-B.py;
    float d = sqrt(dx*dx + dy*dy);

    //Unit vector pointing to ball_1 from ball_2
    float udx = dx/d;
    float udy = dy/d;

    //If they overlap, calculate push force. Smaller ball will get pushed more easily
    if (d<(R+B.R)) {
      ax = ax + push_coefficient*B.R*B.R/(R*R + B.R*B.R)*(R+B.R-d)*udx;
      ay = ay + push_coefficient*B.R*B.R/(R*R + B.R*B.R)*(R+B.R-d)*udy;
    } else {
      //If not overlapping, calculate pull force. Smaller ball will get pulled more easily
      ax = ax - pull_coefficient*B.R*B.R*udx/(d*d);
      ay = ay - pull_coefficient*B.R*B.R*udy/(d*d);
    }
  }

  void update() {
    //Add random noise to acceleration and add drag force
    ax = ax + jiggle_coefficient*randomGaussian() - drag_coefficient*vx;
    ay = ay + jiggle_coefficient*randomGaussian() - drag_coefficient*vy;

    //Accumulate velocity & position
    vx = vx + dt*ax; 
    vy = vy + dt*ay;
    px = px + dt*vx; 
    py = py + dt*vy;

    //Draw
    fill(cr, cg, cb);
    ellipse(px, py, 2*R, 2*R);

    //Reset acceleration to be calculated on next step
    ax = 0; 
    ay = 0;
  }
}

//Allows user to only add one ball per click if quickAddMode is false
void mouseReleased() {
  unClicked = true;
}