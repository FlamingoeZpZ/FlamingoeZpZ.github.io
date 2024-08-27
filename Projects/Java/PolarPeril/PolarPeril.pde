/* @pjs preload="data/Game/ballpile.png, data/Game/Floor.png, data/Game/gameOver.png, 
 data/Game/Igloo.png, data/Game/ladder.png, data/Game/youWin.png, data/Game/Platform.png, 
 data/Burst/0.png, data/Burst/1.png, data/Burst/2.png, data/Burst/3.png, data/Burst/4.png, 
 data/Burst/5.png, data/Burst/6.png, data/Burst/7.png, data/Burst/8.png, data/Burst/9.png, 
 data/Burst/10.png, data/Burst/11.png, data/Burst/12.png, data/Burst/13.png, data/Burst/14.png, 
 data/Burst/15.png, data/Burst/16.png, data/Burst/17.png, data/Burst/18.png, data/Burst/19.png, 
 data/Ball/ball0.png, data/Ball/ball1.png, data/Ball/ball2.png, data/Ball/ball3.png, 
 data/Ball/sliced_ball0.png, data/Ball/sliced_ball1.png, data/Ball/sliced_ball2.png, 
 data/Penguin/penguin0.png, 
 data/Game/jagged2.jpg, 
 data/Penguin/penguinFall0.png, data/Penguin/penguinFall1.png, 
 data/Penguin/penguinWaddle0.png, data/Penguin/penguinWaddle1.png, data/Penguin/penguinWaddle2.png, 
 data/Penguin/penguinWaddle3.png, 
 data/Player/pAttack0.png, data/Player/pAttack1.png, data/Player/pAttack2.png, data/Player/pAttack3.png, 
 data/Player/pAttack4.png, data/Player/pAttack5.png, data/Player/pAttack6.png, data/Player/pAttack7.png, 
 data/Player/pAttack8.png, data/Player/pAttack9.png, data/Player/pAttack10.png, 
 data/Player/pIdle0.png, data/Player/pIdle1.png, data/Player/pIdle2.png, data/Player/pIdle3.png, 
 data/Player/pFall0.png, data/Player/pFall1.png, 
 data/Player/pJump0.png, data/Player/pJump1.png, data/Player/pJump2.png, data/Player/pJump3.png, 
 data/Player/pRoll0.png, data/Player/pRoll1.png, data/Player/pRoll2.png, data/Player/pRoll3.png, 
 data/Player/pRun0.png, data/Player/pRun1.png, data/Player/pRun2.png, data/Player/pRun3.png, 
 data/Player/pRun4.png, data/Player/pRun5.png, 
 data/Yeti/BobStand0.png, data/Yeti/BobStand1.png, 
 data/Yeti/BobDance0.png, data/Yeti/BobDance1.png, 
 data/Yeti/BobToss0.png, data/Yeti/BobToss1.png, data/Yeti/BobToss2.png" */


Player player;
Floor [] floors = new Floor[10];
Platform[] platforms = new Platform[2];
boolean debug = true;
ArrayList<Snowball> snowballs = new ArrayList<Snowball>();
float camY;
float camSpeed = 0.1;
int startDelay;

int floorsGenerated;

boolean isGameOver;


void setup()
{
  size(900, 675);
  loadImages();
  imageMode(CENTER);
  textAlign(CENTER);
  colorMode(HSB, 360, 100, 100);
  reset();
}

float t = 0;
void draw()
{
  //HexCode
  background(#162d35);
  
  tint(230,80,33);
  
 
  //281 is just some magic number based on the image.
  image(bg,width/2, int(floor(camY/4) % 210) + height/2 - (112) );
  
  ///camY %= k + height/2;
  for (int i = 0; i < floors.length; i += 1)
  {
    floors[i].display();
  }
  fill(255);
   text(frameRate, 100, 100);
  textSize(32);
  text("SCORE: " + (floorsGenerated-floors.length), 100, 40);

  tint(0, 0, 100);

  for (int i = 0; i < platforms.length; i += 1)
  {
    platforms[i].display();
  }

  player.display();

  for (int i = snowballs.size()-1; i >=0; i--)
  {
    Snowball current = snowballs.get(i);
    current.display();

    if (current.y > height + 100)
    {
      snowballs.remove(i);
      continue;
    }
    if (current.collide(player))
    {
      if (player.isAttacking)
      {
        current.markDestroyed();
      } else
      {
        isGameOver = true;
      }
    }
  }

  if (isGameOver)
  {
    textSize(128);
    startDelay -= 1;
    fill(abs(startDelay)%360, 100, 100);
    text("GAME OVER", width/2, height/2);
    textSize(32);
    fill(0, 0, 0);
    text("Press to play again", width/2, height/2 + 64);
    return;
  } 

  moveCamera();

  if (player.y > height + 50)
  {
    isGameOver = true;
  }
}

void moveCamera()
{
  //If we just kept increasing without %, we're risking floating point error
  startDelay -= 1;
  if (startDelay > 0) return;
  camY = (camY + (camSpeed * floorsGenerated / 3));// % (height);
}

void reset()
{
  isGameOver = false;
  player =  new Player();
  floorsGenerated = 0;
  camY = 0;
  startDelay = 200;

  floors[0] = new Floor( width/2, height, 0, 1);
  player.currentFloor = floors[0];
  player.x = width/2;

  snowballs.clear();


  for (int i = 1; i < floors.length; i+=1)
  {
    floors[i] = new Floor();//new Floor((i * 400)%width + 100, (int((i * 400) / width)+1)* 200- 100, random(-45,45), random(0.25,0.5));
  }
  platforms[0] = new Platform(100, height - 200);
  platforms[1] = new Platform(width-100, height - 200);
}

class Animation
{
  int rate;
  PImage [] images;
  boolean cancelable;

  public Animation(String path, String extension, int len, int rate, boolean cancelable)
  {
    images = new PImage[len];
    this.rate = rate;
    this.cancelable = cancelable;
    for (int i = 0; i < len; ++i)
    {
      images[i] = loadImage(path + i + extension);
    }
  }

  public Animation(String path, String extension, int len, int rate, boolean cancelable, float scale)
  {
    images = new PImage[len];
    this.rate = rate;
    this.cancelable = cancelable;
    for (int i = 0; i < len; ++i)
    {
      images[i] = loadImage(path + i + extension);
      images[i].resize((int)(images[i].width * scale), (int)(images[i].height* scale));
    }
  }
}
class Animator
{
  Animation currentAnim;
  int currentFrame;
  int currentTick;
  boolean isLastTick;

  void setAnimation(Animation anim)
  {
    if (currentAnim == anim || (currentAnim != null && !currentAnim.cancelable && !isLastTick)) return;
    currentAnim = anim;
    currentFrame = 0;
    currentTick = 0;
  }

  boolean updateAnimation()
  {
    currentTick += 1;
    if (currentTick >= currentAnim.rate)
    {
      currentTick = 0;
      currentFrame += 1;
      if (currentFrame >= currentAnim.images.length)
      {
        currentFrame = 0;
        isLastTick = true;
        return true;
      }
    }
    isLastTick = false;
    return false;
  }

  PImage getCurrentImage()
  {
    return currentAnim.images[currentFrame];
  }
}

static Floor previous; //Technically don't need static because of processing, but this is static.
class Floor
{
  float x;
  float y;
  float x1;
  float y1;
  float x2; 
  float y2;

  float m;
  float b;
  float s;
  float angle;
  float halfH;

  float col = 180;

  Floor(float x, float y, float angle, float scale)
  {
    rebuildFloor(x, y, angle, scale);
  }

  Floor()
  {
    generateFloor();
  }

  void generateFloor()
  {
    //Set the X to the previousX.
    if (previous.x < width/2)
    {
      x  = previous.x2 + random(-300, 300) * previous.s;
    } else
    {
      x  = previous.x1 + random(-300, 300) * previous.s;
    }

    y  = min(previous.y2, previous.y1) - random(50) * previous.s - 50;

    //Set the Y to the 
    //float r = 1;
    //if(previous.angle != 0) r = previous.angle/abs(previous.angle);
    rebuildFloor(x, y, random(-30, 30), random(0.75, 1.25));
  }

  //Given some point and an angle, 30 degs up or down and a scale, create a floorImg.
  void rebuildFloor(float x, float y, float angle, float scale)
  {
    previous = this;
    floorsGenerated += 1;
    col = (floorsGenerated *5 + 180) % 360;
    //1. Bind variables;
    s = scale;
    this.x =x;
    this.y =y;

    halfH = s * floorImg.height / 2;

    //1. use SOH CAH TOA to find the second point
    float rads = radians(angle); //Image needs to be rotated 90degs
    this.angle = radians(angle);
    float d = floorImg.width;
    float xDiff = cos(rads) * d/2 * s;
    float yDiff = sin(rads) * d/2 * s;

    //2. Apply
    x1 = x-xDiff ;
    y1 = y-yDiff - floorImg.height/2 * s;
    x2 = x+xDiff ;
    y2 = y+yDiff - floorImg.height/2 * s;

    //3. Calculate the slope.
    float rise = y2-y1;
    float run = x2-x1;
    m = rise/run;

    b = -(m*x-y);
  }


  void display()
  {
    tint(col, 33, 100);
    pushMatrix();
    translate(x, ceil(y + camY));
    scale(s, s);
    rotate(angle);
    translate(-x, -ceil(y + camY));
    image(floorImg, x, ceil(y + camY));
    popMatrix();

    if (debug)
    {
      stroke(255, 0, 0);
      line(x1, y1 + camY, x2, y2 + camY);
      fill(0);
      textSize(32);
    }

    if (min(y1, y2) + camY > height + 100)
    {
      generateFloor();
    }
  }

  float getExpectedY(float x, float yOffset)
  {
    return m * x + b - yOffset - halfH + camY;
  }

  boolean isOnFloor(float x)
  {
    return x > x1 && x < x2;
  }
}

abstract  class GameObject
{
  float x = 50;
  float y = 50;
  float halfW;
  float halfH;
  PImage img;

  GameObject(PImage img, float x, float y)
  {
    this.x = x;
    this.y = y;
    this.img = img;
    halfW = img.width/2;
    halfH = img.height/2;
  }

  void display()
  {
    image(img, x, y);
    if(isGameOver) return;
    update();
  }

  abstract void update();

  boolean collide(GameObject other)
  {
    if(x - halfW < other.x + other.halfW && x + halfW > other.x - other.halfW && y - halfH < other.y + other.halfH && y + halfH > other.y - other.halfH)
    {
      return true;
    }  
    return false;
  }
}

PImage ballPile;
PImage floorImg;
PImage gameOver;
PImage igloo;
PImage ladder;
PImage youWin;
PImage platformImg;
PImage bg;

Animation burst;

Animation ballRoll;
Animation ballBreak;

Animation playerAttack;
Animation playerIdle;
Animation playerFall;
Animation playerJump;
Animation playerRoll;
Animation playerRun;

Animation penguinIdle;
Animation penguinFall;
Animation penguinWaddle;

Animation yetiIdle;
Animation yetiDance;
Animation yetiThrow;

void loadImages()
{
  //Game
  bg = loadImage("data/Game/jagged2.jpg");
  bg.resize(width,width);
  ballPile = loadImage("data/Game/ballpile.png");
  floorImg = loadImage("data/Game/Floor.png");
  gameOver = loadImage("data/Game/gameOver.png");
  igloo = loadImage("data/Game/Igloo.png");
  ladder = loadImage("data/Game/ladder.png");
  youWin = loadImage("data/Game/youWin.png");
  platformImg = loadImage("data/Game/Platform.png");
  //String path, String extension, int len, int rate, boolean cancelable
  //String path, String extension, int len, int rate, boolean cancelable, float scale

  burst = new Animation("data/Burst/", ".png", 20, 2, false);

  //Ball
  ballRoll = new Animation("data/Ball/ball", ".png", 4, 4, true);
  ballBreak = new Animation("data/Ball/sliced_ball", ".png", 3, 4, false);

  // Penguin
  penguinIdle = new Animation("data/Penguin/penguin", ".png", 1, 20, true);
  penguinFall = new Animation("data/Penguin/penguinFall", ".png", 2, 4, true);
  penguinWaddle = new Animation("data/Penguin/penguinWaddle", ".png", 4, 4, true);

  //Player
  playerAttack = new Animation("data/Player/pAttack", ".png", 11, 2, false);
  playerIdle = new Animation("data/Player/pIdle", ".png", 4, 8, true);
  playerFall = new Animation("data/Player/pFall", ".png", 2, 4, true);
  playerJump = new Animation("data/Player/pJump", ".png", 4, 4, true);
  playerRoll = new Animation("data/Player/pRoll", ".png", 4, 4, true);
  playerRun = new Animation("data/Player/pRun", ".png", 6, 4, true);
  
  //Yeti
  yetiIdle = new Animation("data/Yeti/BobStand" ,".png", 2, 20, true);
  yetiDance = new Animation("data/Yeti/BobDance" ,".png", 2, 8, true);
  yetiThrow = new Animation("data/Yeti/BobToss" ,".png", 3, 8, true);
}

class MovingObject extends GameObject
{
  float xSpeed;
  float ySpeed;
  float speed = 5;

  boolean isFacingLeft;
  Animator animator = new Animator();

  final static float gravity = 0.1; // This is how we declare true constants in java. 
  
  MovingObject(float x, float y, float speed, Animation anim)
  {
    super(anim.images[0], x, y);
    this.speed = speed;
    animator.setAnimation(anim);
  }

  void display()
  {
    pushMatrix();

    translate(x, y);
    if (isFacingLeft)
    {
      scale(-1, 1);
    }
    translate(-x, -y);

    super.display();
    popMatrix();
  }

  void update()
  {
    if (animator.updateAnimation())
    {
      onAnimEnd();
    }
    img = animator.getCurrentImage();

    move();
    handleAnimations();
  }

  void move()
  {
    x += xSpeed;
    if (currentFloor != null)
    {
      y = currentFloor.getExpectedY(x, halfH);
      if (!currentFloor.isOnFloor(x))
      {
        currentFloor = null;
      }
    } else 
    {
      y += ySpeed;
      ySpeed += gravity;
    }

    if (xSpeed > 0) { 
      isFacingLeft = false;
    } else if (xSpeed < 0) {
      isFacingLeft = true;
    }

    handleGround();
  }

  void handleAnimations()
  {
  }

  void onAnimEnd()
  {
  }

  Floor currentFloor;
  //This is a highly specific function that only handles floors correctly in this context.
  //because of that it's simple and fast, but not flexible.
  void handleGround()
  {
    //When we start going down (any reason) search every floor for the first one that we can possibly land on ( expected Y on the floor given our X is above it)
    if (ySpeed < 0 || currentFloor != null) return; //Going up

    for (int i = 0; i < floors.length; ++i)
    {
      //Start at the current top
      Floor check = floors[(floorsGenerated - i - 1) % 10];
      //If the platform is currently below us and the platform is above our next position (about to fall on it) and we'll be on the floor in the next move
      float expected = check.getExpectedY(x, halfH);
      //Note we subtract halfH so that the rolling animation feels more accurate to our hitbox.
      if (expected > y - ySpeed - halfH&& expected <= y + ySpeed && check.isOnFloor(x))
      {
        currentFloor = check;
        onGrounded();
      }
    }
    //Once we've found that floor, just check if we've gone past it. 
    //If we've gone past it, then check if y - ySpeed is valid. if it is, then ground ourselves
    //If it's not, then check if there's a floor underneath.
    //If there's a floor underneath, then set the current target to the floor underneath, and recurse.


    //We can get our objects to follow the floor by checking each floor from top to bottom when falling.


    //BinarySearch find the closest?
    //Linear search is definitely easier, just go top to bottom

    //Check if our expected Y on the floor given our X is above it. If it is, then that's our targeted floor.
  }
  void onGrounded()
  {
    ySpeed = 0;
  }
}

class Platform extends GameObject
{
  Yeti yeti;
  float targetY;
  float offset;
  final static int ticks = 10;
  float pileX;
  float pileY;

  Platform(float x, float y)
  {
    super(platformImg, x, y);
    yeti = new Yeti(this);
    targetY = y;
    offset = yeti.img.height - 15; //Consistency.
    yeti.y = y - offset;
    pileX = x;
    if (x < width/2)
    {
      pileX-=img.width/2 - ballPile.width/2;
    } else
    {
      pileX+=img.width/2 - ballPile.width/2;
    }
    pileY = y - offset;
  }

  void display()
  {
    super.display();
    image(ballPile, pileX, pileY);
    yeti.display();
  }  

  void update()
  {
    if (isMoving())
    {
      y += (targetY - y) / ticks;
      yeti.y = y - offset;
      pileY = y-offset;
    }
  }

  void move()
  {
    //Choose a random Y.
    targetY = random(height/2, height- img.height);
  }
  
  boolean isMoving()
  {
    return abs(targetY - y) > 0.1;
  }
}

class Player extends MovingObject
{
  float jumpForce = 5;

  boolean isAttacking;

  int maxJumps = 2;
  int curJumps;
  boolean canAttack = true;

  Player()
  {
    super(50, 50, 5, playerIdle);
  }

  void handleAnimations()
  {

    //Sort in order of priority.
    if (ySpeed > 0) animator.setAnimation(playerFall);
    else if (ySpeed == 0)
      if (xSpeed != 0) animator.setAnimation(playerRun);
      else animator.setAnimation(playerIdle);
  }

  void jump()
  {
    //Single statement ifs do not need squiggles.
    if (curJumps > maxJumps || isAttacking) return;
    curJumps += 1;
    animator.setAnimation(playerJump);
    ySpeed = -jumpForce;
    currentFloor = null;
  }

  void onAnimEnd()
  {
    if (animator.currentAnim == playerJump)
    {
      animator.setAnimation(playerRoll);
    } else if (animator.currentAnim == playerAttack)
    {
      if (currentFloor == null)
      {
        animator.setAnimation(playerRoll);
      } else
      {
        animator.setAnimation(playerIdle);
      }  
      isAttacking = false;
    }
  }

  void attack()
  {
    if (isAttacking || !canAttack) return; //currentFloor == null || 
    isAttacking = true;
    animator.setAnimation(playerAttack);
    canAttack = currentFloor != null;
  }

  void onGrounded()
  {
    super.onGrounded();
    curJumps = 0;
    canAttack = true;
  }
}

class Snowball extends MovingObject
{
  boolean isDestroyed;
  Snowball(float x, float y)
  {
    super(x, y, random(5, 15), ballRoll);

    float xDiff = width/2-x;
    float yDiff = random(-100,100)-y;
    float d = sqrt(xDiff * xDiff + yDiff * yDiff);
    xSpeed = xDiff/d * speed;
    ySpeed = yDiff/d * speed;
  }

  void move()
  {
    if(isDestroyed) return;
    super.move();
    if(currentFloor != null)
    {
      xSpeed += sin(currentFloor.angle) * gravity;
    }
  }
  
  boolean collide(GameObject other)
  {
    if(isDestroyed) return false;
    return super.collide(other);
  }
  
  void onGrounded()
  {
    super.onGrounded();
    xSpeed /= 2;
  }
  
 
  void markDestroyed()
  {
    animator.setAnimation(ballBreak);
    isDestroyed=  true;
  }
  void onAnimEnd()
  {
    if(animator.currentAnim == ballBreak)
    {
      snowballs.remove(this);
    }
  }
}



class Yeti extends GameObject
{
  Animator animator = new Animator();
  boolean isFacingLeft;
  float minT = 30;
  float maxT = 60;
  float cT;
  Platform platform;

  Yeti(Platform platform)
  {
    super(yetiIdle.images[0], platform.x, 0);
    animator.setAnimation(yetiIdle);
    this.platform = platform;
    isFacingLeft = x > width/2;
  }

  void display()
  {
    pushMatrix();

    translate(x, y);
    if (isFacingLeft)
    {
      scale(-1, 1);
    }
    translate(-x, -y);

    super.display();
    popMatrix();
  }

  void update()
  {
    if (animator.updateAnimation())
    {
      onAnimEnd();
    }
    img = animator.getCurrentImage();

    cT -= 1;
    if (cT < 0)
    {
      animator.setAnimation(yetiDance);
    }
  }

  void onAnimEnd()
  {
    if (animator.currentAnim == yetiThrow  )
    {
      animator.setAnimation(yetiIdle);
      for (int i = (int)random(floorsGenerated/floors.length); i >=0; i -=1)
      {
        snowballs.add(new Snowball(x, y));
      }
      cT = random(minT, maxT);
      platform.move();
    } else if (animator.currentAnim == yetiDance && !platform.isMoving())
    {
      animator.setAnimation(yetiThrow);
      cT = 10000; // lazy impossibly high num
    }
  }
}

boolean left;
boolean right;

void mousePressed()
{
  if (isGameOver)
  {
    reset();
    return;
  }
  player.attack();
}

void keyPressed()
{
  if (keyCode == LEFT || key == 'a' || key == 'A')
  {
    left = true;  
    player.xSpeed = -player.speed;
  }
  if (keyCode == RIGHT || key == 'd' || key == 'D')
  {
    right=true;
    player.xSpeed = player.speed;
  }
  if (keyCode == UP || key == ' ')
  {
    //You can do += for a different effect.
    player.jump();
  }
}

void keyReleased()
{
  if (keyCode == LEFT || key == 'a' || key == 'A')
  {
    left = false;
    if (right)
    {
      player.xSpeed = player.speed;
    } else
    {
      player.xSpeed = 0;
    }
  }
  if (keyCode == RIGHT || key == 'd' || key == 'D')
  {
    right=false;
    if (left)
    {
      player.xSpeed = -player.speed;
    } else
    {
      player.xSpeed = 0;
    }
  }
}
