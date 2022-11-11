
// custom instances
Racket racket;
Ball ball;
GameState gameState = GameState.START;

// score
int score;

// objects
int objectSpeed = 1;
int originalObjectInterval = 5000;
int maxObjectIntervalOffset = 4000;
float lastAddTime = 0;
int objectHeight = 15;
int objectWidth = 50;
ArrayList<Object> objects = new ArrayList<>();

// timer
float timeRoundStarted;
float timePlayed;

// Buttons
int buttonHeight = 50;
int buttonWidth = 100;

// Display
int displayHeight, displayWidth;

void setup() {
  // FOR IOS
  // comment start if on ios
  //size(screenWidth, screenHeight);
  //displayWidth = screenWidth;
  //displayHeight = screenHeight;
  // comment end

  // FOR OTHER
  // comment start if on other
  size(500, 500);
  displayWidth = 500;
  displayHeight = 500;
  // comment end
  
  racket = new Racket(mouseX, mouseY, 100, 10, 20, 100);
  ball = new Ball(displayWidth/4, displayHeight/5);
}

void draw() {
  background(255);
  
  switch(gameState) {
    case START:
      initScreen();
      break;
    case GAME:
      gameScreen();
      break;
    case GAMEOVER:
      gameOverScreen();
      break;
  }
  
}

void initScreen() {
  background(0);

  stroke(0);
  fill(50);
  rectMode(CENTER);
  rect(displayWidth/2, displayHeight/2, buttonWidth, buttonHeight, 5);

  fill(255);
  textAlign(CENTER);
  textSize(20);
  text("Start", displayWidth/2, displayHeight/2+7);
}

void gameScreen() {
  background(255);
  stroke(200);

  // ball & racket
   racket.update();
  ball.update();

  // objects
  objectAdder();
  objectHandler();

  // timer
  drawTimer();

  // score
  drawScore();
}

void gameOverScreen() {
  background(0);
  textAlign(CENTER);

  // score label
  stroke(100);
  fill(100);
  textSize(20);
  text("Score", displayWidth / 2, displayHeight / 2 - 80);
  // score number
  stroke(255);
  fill(255);
  textSize(100);
  text(score, displayWidth / 2, displayHeight / 2);

  // time label
  stroke(100);
  fill(100);
  textSize(15);
  text("Time played", displayWidth /2, displayHeight /2 + 50);
  // time number
  stroke(200);
  fill(200);
  textSize(35);
  text(formatTime(timePlayed), displayWidth /2, displayHeight /2 + 85);

  // PLAY AGAIN BUTTON
  stroke(0);
  fill(50);
  rect(displayWidth/2, displayHeight/2 + 150, buttonWidth+10, buttonHeight, 5);
  fill(255);
  textAlign(CENTER);
  textSize(20);
  text("Play Again", displayWidth /2, displayHeight /2 + 155);
}

//--------------------------------------
//--------------- INPUTS ---------------
//--------------------------------------

public void mousePressed() {
  // if the initial screen is active, start game on click
  if (gameState == GameState.START) {
    if (mouseX < displayWidth/2 - buttonWidth/2 || mouseX > displayWidth/2 + buttonWidth/2 ||
      mouseY < displayHeight/2 - buttonHeight/2 || mouseY > displayHeight/2 + buttonHeight/2) return;
    startGame();
  } else if (gameState == GameState.GAMEOVER) {
    if (mouseX < displayWidth/2 - (buttonWidth+10)/2 || mouseX > displayWidth/2 + (buttonWidth+10)/2 ||
      mouseY < displayHeight/2 + 150 - buttonHeight/2 || mouseY > displayHeight/2 + 150 + buttonHeight/2) return;
    startGame();
  }
}

//----------------------------------------------------
//--------------- OTHER FUNCTIONS --------------------
//----------------------------------------------------


// This method sets the necessary variables to start the game
void startGame() {
  // gravity
  ball.speedY = 0;
  ball.speedX = 0;

  // ball
  ball.x = displayWidth/4;
  ball.y = displayHeight/5;

  // screen
  gameState = GameState.GAME;

  // objects
  objects = new ArrayList<Object>();

  // time
  timeRoundStarted = millis();

  // score
  score = 0;
}

// This method sets the necessary variables to end the round
void gameOver() {
  gameState = GameState.GAMEOVER;
}


//-------------
//--- SCORE ---
//-------------

void drawScore() {
  stroke(0);
  fill(0);
  textAlign(RIGHT, TOP);
  text(score, displayWidth -10, 10);
}


//-------------
//--- TIMER ---
//-------------

void drawTimer() {
  timePlayed = (millis()-timeRoundStarted)/1000;

  stroke(0);
  fill(0);
  textAlign(LEFT, TOP);
  text(formatTime(timePlayed), 10, 10);
}

String formatTime(float timeInSecs) {
  int minutes = floor(timeInSecs / 60);
  float seconds = round((timeInSecs - minutes * 60)*1000);
  seconds /= 1000;

  String formattedMinutes = "";
  if (minutes < 10) formattedMinutes = "0";
  formattedMinutes = formattedMinutes + minutes;

  String formattedSeconds = "";
  if (seconds < 10) formattedSeconds = "0";
  formattedSeconds = formattedSeconds + seconds;

  return formattedMinutes + ":" + formattedSeconds;
}

//---------------
//--- OBJECTS ---
//---------------

void objectAdder() {
  int objectInterval = originalObjectInterval + int(random(-maxObjectIntervalOffset, maxObjectIntervalOffset));
  if (millis()-lastAddTime > objectInterval) {
    int randX = round(random(0, displayWidth - objectWidth) + objectWidth/2);
    ObjectType t = ObjectType.NOTHING;
    if (random(0, 1) > 0.5) t = ObjectType.COIN;
    Object randObject = new Object(randX, -objectHeight, objectWidth, objectHeight, t);
    objects.add(randObject);
    lastAddTime = millis();
  }
}

void objectHandler() {
  for (int i = 0; i < objects.size(); i++) {
    if (objectRemover(i)) {
      return;
    }

    objects.get(i).update();
    watchObjectCollision(i);
  }
}

void watchObjectCollision(int index) {
  Object object = objects.get(index);

  // ball in object
  if (
    (ball.x + (ball.size/2) > object.x - objectWidth/2) &&
    (ball.x - (ball.size/2) < object.x - objectWidth/2 + objectWidth) &&
    (ball.y + (ball.size/2) > object.y - objectHeight/2) &&
    (ball.y - (ball.size/2) < object.y - objectHeight/2 + objectHeight)
    ) {
    if (object.t == ObjectType.COIN) score++;
    objects.remove(index);
  }
}

boolean objectRemover(int index) {
  Object object = objects.get(index);
  if (object.y - object.h  >= displayHeight) {
    objects.remove(index);
    return true;
  }
  return false;
}

// --------------- CLASSES ---------------

class Racket {
  float x, y, pY, w, h, bounceRate, zoneSize;
  color c = color(105, 137, 150);

  Racket (float x, float y, float w, float h,
    float bounceRate, float zoneSize) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.bounceRate = bounceRate;
    this.zoneSize = zoneSize;
  };

  void update() {
    x = min(displayWidth - w/2, max(0 + w/2, mouseX));
    y = min(displayHeight - h/2, max(displayHeight-zoneSize + h/2, mouseY));
    this.draw();
    makeBallBounce();
  };

  void draw() {
    stroke(200);
    line(0, displayHeight - zoneSize, displayWidth, displayHeight-100);

    stroke(c);
    fill(c);
    rectMode(CENTER);
    rect(x, y, w, h, 2);
  };

  void makeBallBounce() {
    float overhead = y - pY;
    pY = y;

    if ((ball.x + (ball.size/2) > x - (w/2)) && (ball.x - (ball.size/2) < x + (w/2))) {
      if (dist(ball.x, ball.y, ball.x, y - h/2) <= (ball.size/2) + abs(overhead)) {
        ball.makeBounceBottom(y - h/2);
        // racket moving up
        if (overhead < 0) {
          ball.y += overhead;
          ball.speedY += overhead;
          ball.speedX = (ball.x - x)/5;
        }
      }
    }
  };
};

class Ball {
  float x, y, speedY, speedX;
  int size = 20;
  float gravity = 0.1;
  float airfriction = 0.0001;
  float friction = 0.1;
  color c = color(235, 186, 185);

  Ball (float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    applyGravity();
    applyHorizontalSpeed();
    keepInScreen();
    this.draw();
  };

  void draw() {
    stroke(c);
    fill(c);
    ellipse(x, y, size, size);
  };

  void applyGravity() {
    speedY += gravity;
    y += speedY;
    speedY -= speedY * airfriction;
  };

  void applyHorizontalSpeed() {
    x += speedX;
    speedX -= speedX * airfriction;
  };

  // bounce
  void makeBounceBottom(float surface) {
    y = surface - (size/2);
    speedY *= -1;
    speedY -= speedY * friction;
  };
  void makeBounceTop(float surface) {
    y = surface + (size/2);
    speedY *= -0.5;
    speedY -= speedY * friction;
  };
  void makeBounceLeft(float surface) {
    x = surface + (size/2);
    speedX *= -1;
    speedX -= speedX * friction;
  };
  void makeBounceRight(float surface) {
    x = surface - (size/2);
    speedX *= -1;
    speedX -= speedX * friction;
  };

  // keep ball in screen
  void keepInScreen() {
    // ball hits floor
    if (y + (size/2) > displayHeight) {
      gameOver();
    }
    // ball hits ceiling
    if (y - (size/2) < 0) {
      makeBounceTop(0);
    }
    // ball hits left
    if (x - (size/2) < 0) {
      makeBounceLeft(0);
    }
    // ball hits right
    if (x + (size/2) > displayWidth) {
      makeBounceRight(displayWidth);
    }
  }
};

class Object {
  float x, y, w, h;
  ObjectType t;
  color c;
  
  Object (float x, float y, float w, float h, ObjectType t) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.t = t;
  };
  
  void update() {
    y += objectSpeed;
    
    this.draw();
  };
  
  
  void draw(){
    color c = color(t.r, t.g, t.b);
    stroke(c);
    fill(c);
    rect(x, y, w, h, 1);
  };
}

enum ObjectType {
  NOTHING(200, 200, 200),
  COIN(225, 181, 38);
  
  
  int r;
  int g;
  int b;
  
  ObjectType(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  };
};

enum GameState {
  START,
  GAME,
  GAMEOVER
};
