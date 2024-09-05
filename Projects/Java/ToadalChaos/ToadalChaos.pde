/* @pjs preload="data/Powerups/flyfooditem.png", "data/Powerups/tadpole.png", 
               "data/Powerups/biglegs.png", "data/Powerups/turtleshell.png", 
               "data/Powerups/poweruptrap.png", "data/Backgrounds/swamp.jpg", 
               "data/Backgrounds/cover.jpg", "data/Toad/toadidle0.png", 
               "data/Toad/toadidle1.png", "data/Toad/toadidle2.png", 
               "data/Toad/toadidle3.png", "data/Toad/toadidle4.png", 
               "data/Toad/toadjump0.png", "data/Toad/toadjump1.png", 
               "data/Toad/toadjump2.png", "data/Toad/toadjump3.png", 
               "data/Toad/toadhurt0.png", "data/Obelisk/obeliskshoot0.png", 
               "data/Obelisk/obeliskshoot1.png", "data/Obelisk/obeliskshoot2.png", 
               "data/Obelisk/obeliskshoot3.png", "data/Obelisk/obeliskshoot4.png", 
               "data/Obelisk/obeliskidle0.png", "data/Obelisk/obeliskidle1.png", 
               "data/Obelisk/obeliskidle2.png", "data/Obelisk/obeliskidle3.png", 
               "data/Obelisk/projectile.png", "data/Gameplay/explosion0.png", 
               "data/Gameplay/explosion1.png", "data/Gameplay/explosion2.png", 
               "data/Gameplay/explosion3.png", "data/Wasp/wasp0.png", 
               "data/Wasp/wasp1.png"; */




//Step 1 - Create a variable
Player player;
int trueWidth;
int trueHeight;
float camX;
float camY;

Obelisk [] obelisks = new Obelisk[10];
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<IDamagable> targets = new ArrayList<IDamagable>();
ArrayList<PowerUp> powerups = new ArrayList<PowerUp>();
ArrayList<Wasp> wasps = new ArrayList<Wasp>();

boolean isGameRunning;
int score;
int level;

void setup()
{
  size(800, 800);

  loadImages();
  imageMode(CENTER);

  trueWidth = bg.width;
  trueHeight = bg.height;

  textAlign(CENTER);
}

void draw()
{
  if (!isGameRunning)
  {
    image(coverArt, width/2, height/2);
    return;
  }

  background(0);


  handleBackground();

  //Render Camera Elements
  pushMatrix();
  translate(camX, camY);
  image(bg, trueWidth/2, trueHeight/2);

  //Reverse for loop to prevent index skipping
  for (int i = projectiles.size()-1; i >=0; --i)
  {
    Projectile current = projectiles.get(i);
    current.display();

    //Reverse loop incase we want to delete targets
    for (int j  = targets.size()-1; j >= 0; --j)
    {
      //Be careful, use j instead of i
      IDamagable target = targets.get(j);
      if (target.collide(current) && current.owner != target)
      {

        // You can also create a variable in Projectile to make this dynamic
        target.takeDamage(1);

        //Be careful, use i here as j is for targets.
        projectiles.remove(i);

        //break ends the loop
        break;
      }
    }
  }

  for (int i = powerups.size() -1; i >= 0; --i)
  {
    PowerUp current = powerups.get(i);
    current.display();
    if (current.collide(player))
    {
      player.ApplyUpgrade(current.upgrade);
      powerups.remove(i);
    }
  }

  for (int i = 0; i  <obelisks.length; ++i)
  {
    obelisks[i].display();
  }

  for (int i = wasps.size()-1; i >= 0; i-=1)
  {
    wasps.get(i).display();
  }

  popMatrix();

  //Render the player



  //Step 3 - Use
  player.display();

  fill(0, 0, 0);
  textSize(50);
  text(score, width/2, 50);

  //If player is alive.
  if (player.health > 0)
  {
    //Increase the score by 1
    score += 1;
    if (score > scoreReq * level)
    {
      levelUp();
    }
  } else
  {
    fill(0, 0, 0);
    textSize(96);
    text("GAME OVER\nTry Again?", width/2, height/2);
  }
}

void handleBackground()
{
  float deltaX = camX;
  float deltaY = camY;


  if (player.xSpeed < 0  && player.x < deadZoneXMin) {
    camX -= player.xSpeed;
  } else if ( player.xSpeed > 0 && player.x  > deadZoneXMax) {
    camX -= player.xSpeed;
  }
  if (player.ySpeed < 0 && player.y < deadZoneYMin) {
    camY -= player.ySpeed;
  } else if (player.ySpeed > 0 && player.y  > deadZoneYMax) {
    camY -=player.ySpeed;
  }


  //Constrain the camera to stay on the map
  camX = round(constrain(camX, -trueWidth + width, 0));
  camY = round(constrain(camY, -trueHeight + height, 0));

  player.x -= deltaX - camX;
  player.y -= deltaY - camY;
}

void reset()
{
  isGameRunning = true;
  score = 0;
  level = 0;

  obeliskRange = startRange;
  obeliskFireTime = startFireTime;
  projectileSpeed = startSpeed;

  projectiles.clear();
  powerups.clear();
  targets.clear();
  wasps.clear();

  //Step 2 - Initialize
  player = new Player(width/2, height/2); //x, y, speed (Based on constructor)
  targets.add(player);
  for (int i = 0; i  <obelisks.length; ++i)
  {
    obelisks[i] = new Obelisk();
    targets.add(obelisks[i]);
  }

  camX = player.x-width/2;
  camY = player.y-height/2;
}

void levelUp()
{
  level++;
  wasps.add(new Wasp());
  obeliskRange *= rangeMulti;
  obeliskFireTime *= fireRateMulti;
  projectileSpeed *= speedMulti;
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

  public Animation(String path, String extension, int len, int rate, boolean cancelable, float s)
  {
    images = new PImage[len];
    this.rate = rate;
    this.cancelable = cancelable;
    for (int i = 0; i < len; ++i)
    {
      images[i] = loadImage(path + i + extension);
      images[i].resize((int)(images[i].width * s), (int)(images[i].height* s));
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

abstract class GameObject
{
  float x = 50;
  float y = 50;

  float w;
  float h;
  float s = 1;

  PImage img;

  public GameObject(PImage img, float x, float y)
  {
    this.x = x;
    this.y = y;
    this.img = img;

    w = img.width;
    h = img.height;
  }

  void display()
  {
    //pushMatrix();
    //Move image to 0,0
    //translate(-x,-y);
    //s the image
    //s(s, s);
    //Move image to final position
    image(img, x, y);
    //popMatrix();

    //Optional debug hitbox
    //fill(255,255,255,100);
    //rect(x,y,w*s,h*s);
    if (player.health != 0) 
    { 
      update();
    }
  }


  abstract void update();

  float top()
  {
    return y-s*h/2;
  }
  float bottom()
  {
    return y+s*h/2;
  }
  float left()
  {
    return x-s*w/2;
  }
  float right()
  {
    return x+s*w/2;
  }

  boolean collide(GameObject other)
  {
    if (left() < other.right() && right()> other.left()
      && top() < other.bottom() && bottom()> other.top())
    {
      return true;
    }
    return false;
  }
}

PImage bg;
PImage coverArt;
PImage projectileImg;

PImage frenchFlyImg;
PImage tadpoleImg;
PImage bigLegsImg;
PImage turtleShellImg;
PImage powerupTrap;

Animation toadIdle;
Animation toadJump;
Animation toadHurt;
Animation obeliskShoot;
Animation obeliskIdle;
Animation obeliskAwaken;
Animation explosion;
Animation waspFly;

void loadImages()
{
  frenchFlyImg = loadImage("data/Powerups/flyfooditem.png");
  tadpoleImg = loadImage("data/Powerups/tadpole.png");
  bigLegsImg = loadImage("data/Powerups/biglegs.png");
  turtleShellImg = loadImage("data/Powerups/turtleshell.png");
  powerupTrap = loadImage("data/Powerups/poweruptrap.png");
  
  bg = loadImage("data/Backgrounds/swamp.jpg");
  bg.resize(2000,2000);
  coverArt = loadImage("data/Backgrounds/cover.jpg");
  
  //Location, Suffix, Rate, Length, isCancelable, (optional) s
  toadIdle = new Animation("data/Toad/toadidle", ".png", 5, 5, true, 1);
  toadJump= new Animation("data/Toad/toadjump", ".png", 5, 4, true, 1);
  toadHurt = new Animation("data/Toad/toadhurt", ".png", 1, 15, false, 1);
  
  obeliskShoot =  new Animation("data/Obelisk/obeliskshoot", ".png", 5, 5, true, 0.25f);
  obeliskIdle = new Animation("data/Obelisk/obeliskidle", ".png", 1, 1, true, 0.25f);
  obeliskAwaken = new Animation("data/Obelisk/obeliskidle", ".png", 4, 5, true, 0.25f);
  explosion = new Animation("data/Gameplay/explosion", ".png", 4, 4, false, 0.25f);
  projectileImg = loadImage("data/Obelisk/projectile.png");
  
  waspFly = new Animation("data/Wasp/wasp", ".png", 2, 3, true, 0.5f);
}

boolean up;
boolean down;
boolean left;
boolean right;

void mousePressed()
{
  if (!isGameRunning)
  {
    //Restart game
    reset();
  } else if (player.health == 0)
  {
    //Back to main menu
    isGameRunning = false;
  }
}

void keyPressed()
{
  if (!isGameRunning)
  {
    reset();
  }

  if (key == 'd' || key == 'D' || keyCode == RIGHT)
  {
    right = true;  
    player.xSpeed = player.speed;
  }
  if (key == 'a' || key == 'A' || keyCode == LEFT)
  {
    left = true;  
    player.xSpeed = -player.speed;
  }
  if (key == 'w' || key == 'W' || keyCode == UP)
  {
    up = true; 
    player.ySpeed = -player.speed;
  }
  if (key == 's' || key == 'S' || keyCode == DOWN)
  {
    down = true;  
    player.ySpeed = player.speed;
  }
}

void keyReleased()
{
  if (key == 'd' || key == 'D' || keyCode == RIGHT)
  {
    right = false;  
    player.xSpeed = 0;

    //if we're holding opposite direction, let's move there
    if (left)
    {
      player.xSpeed = -player.speed;
    }
  }
  if (key == 'a' || key == 'A' || keyCode == LEFT)
  {
    left = false;  
    player.xSpeed = 0;

    //if we're holding opposite direction, let's move there
    if (right)
    {
      player.xSpeed = player.speed;
    }
  }
  if (key == 'w' || key == 'W' || keyCode == UP)
  {
    up = false; 
    player.ySpeed = 0;

    //if we're holding opposite direction, let's move there
    if (down)
    {
      player.ySpeed = player.speed;
    }
  }
  if (key == 's' || key == 'S' || keyCode == DOWN)
  {
    down = false;  
    player.ySpeed = 0;

    //if we're holding opposite direction, let's move there
    if (up)
    {
      player.ySpeed = -player.speed;
    }
  }
}

interface IDamagable
{
  void takeDamage(float damage);
  void onDefeated();
  boolean collide(GameObject other);
}

interface IUpgradable
{
  void ApplyUpgrade(StatUpgrade stats);
}

//Intentional git conflict in all files when merging so we can take old version every time?
//Still will need to delete old files manually.
class Obelisk extends GameObject implements IDamagable
{

  Animator animator = new Animator();
  int fireTime;
  
  Obelisk()
  {
    super(obeliskIdle.images[0], 0, 0);
    placeRandom();
    animator.setAnimation(obeliskIdle);
  }

  void placeRandom()
  {
    x = random(trueWidth);
    y = random(trueHeight);
  }

  void update()
  {
    fill(255,0,0);
    textSize(32);
    
    
    img = animator.getCurrentImage();

    if (animator.updateAnimation())
    {
      if(animator.currentAnim == obeliskAwaken)
      {
        animator.setAnimation(obeliskShoot);
      }
      else if (animator.currentAnim == obeliskShoot)
      {
        shoot();
      }
      else if(animator.currentAnim == explosion)
      {
        onDefeated();
      }
    }

    //If we're exploding, don't do anything else
    if(animator.currentAnim == explosion) return;
    
    handleDetection();
    fireTime += 1;
  }

  void handleDetection()
  {
    //Step 1 (Target center of the player)
    float xDist = player.x - x - camX;
    float yDist = player.y - y - camY;

    //Step 2
    float dist = sqrt(xDist*xDist+yDist*yDist);

    //fill(0,255,0,120);
    //rect(player.x  - camX, player.y - camY, (player.w * player.s)/2,  (player.h * player.s)/2);
    //line( x, y,player.x + (player.w * player.s)/2  - camX,   player.y + (player.h * player.s)/2 - camY);
    //line( x, y,player.x + (player.w * player.s)/2  - camX + player.xSpeed * 5,   player.y + (player.h * player.s)/2 - camY + player.ySpeed * 5 );
    //fill(255,0,0,20);
    //circle(x,y,obeliskRange*2);

    //Step 3
    if (dist < obeliskRange && fireTime >= obeliskFireTime)
    {
      animator.setAnimation(obeliskAwaken);
      fireTime = -10000;
    }
  }


  void shoot()
  {
    //Step 1 (Target center of the player AND predict the players movement 5 ticks forward)
    float xDist = player.x + player.xSpeed * 5 - x - camX;
    float yDist = player.y + player.ySpeed * 5 - y - camY;

    //Step 2
    float dist = sqrt(xDist*xDist+yDist*yDist);

    //Step 3 (normalization, make the distance 1)
    float xDir = xDist / dist;
    float yDir = yDist / dist;

    //Step 4 Reset ourselves
    fireTime = 0;
    animator.setAnimation(obeliskIdle);

    //Step 5 Fire the projectile
    //Note: x and y position may need to be shifted
    projectiles.add(new Projectile(this, x, y, xDir * projectileSpeed, yDir * projectileSpeed));
  }

  void takeDamage(float damage)
  {
    animator.setAnimation(explosion);
  }
  void onDefeated()
  {
    chooseRandomPowerUp(x,y);
    fireTime = 0;
    placeRandom();
    animator.setAnimation(obeliskIdle);
    score += 1000;
  }
}

class Player extends GameObject implements IDamagable, IUpgradable
{
  float xSpeed;
  float ySpeed;
  float speed = 5;

  float health;
  float maxHealth = 15;

  boolean isFacingRight;

  Animator animator = new Animator();

  Player(float x, float y)
  {
    super(toadIdle.images[0], x, y);
    s = 0.33;
    animator.setAnimation(toadIdle);
    health = maxHealth;
  }

  void display()
  {
    float sW = w * s;
    float bot = y + h/2 * s + 20;
    fill(0);
    rect(x - sW/2, bot, sW, 10);
    fill(20, 0, 120);
    rect(x-2 - sW/2, bot-2, (sW-2) * (health/maxHealth), 10-2);


    pushMatrix();
    translate(x, y);
    scale(s, s);

    if (!isFacingRight)
    {
      scale(-1, 1);
    }
    translate(-x, -y);
    super.display();
    popMatrix();
  }

  void update()
  {
    move();

    img = animator.getCurrentImage();

    if (animator.updateAnimation())
    {
      //On Animation Ended (Not needed for this game)
    }
    
    lockToScreen();
  }

  void lockToScreen()
  {
    if (x > width - w/2 * s)
    {
      x = width - w/2 * s;
    } else if (x <  w/2 * s)
    {
      x =  w/2 * s;
    }
    if (y < h/2 * s)
    {
      y = h/2 * s;
    } else if (y > height - h/2 * s)
    {
      y = height - h/2 * s;
    }
  }
  
  void move()
  {
    x += xSpeed;
    y += ySpeed;

    if (xSpeed == 0 && ySpeed == 0)
    {
      animator.setAnimation(toadIdle);
    } else
    {
      animator.setAnimation(toadJump);
    }

    if (xSpeed < 0)
    {
      isFacingRight = false;
    } else if (xSpeed > 0)
    {
      isFacingRight = true;
    }
  }



  float top()
  {
    return super.top() - camY;
  }

  float bottom()
  {
    return super.bottom()-camY;
  }

  float left() {
    return super.left() - camX;
  }

  float right()
  {
    return super.right() - camX;
  }  

  void takeDamage(float damage)
  {
    animator.setAnimation(toadHurt);
    health -= damage;
    if (health <= 0)
    {
      health = 0;
      onDefeated();
    }
  }
  void onDefeated()
  {
    println("Game Over, Scored: " + score);
  }

  void ApplyUpgrade(StatUpgrade stats)
  {

    s = min(s * stats.sChange, 3);
    speed = min(speed * stats.speedChange, 15);
    maxHealth =  min(maxHealth * stats.maxHealthChange, 250);
    health = min((health + stats.healthChange) * stats.maxHealthChange, maxHealth);

    if (health < 0)
    {
      onDefeated();
    }
  }
}

//float sChange, float speedChange, float healthChange, float maxHealthChange
StatUpgrade sBooster = new StatUpgrade(1.1, 1, 5, 1.25);
StatUpgrade healthBooster = new StatUpgrade(1, 1.6, 15, 1);
StatUpgrade speedBooster =  new StatUpgrade(0.8, 1.4, 0, 1);
StatUpgrade maxHealthBooster = new StatUpgrade(1, 0.95, 15, 2);

PowerUp chooseRandomPowerUp(float x, float y)
{
  float rng = random(1);
  
  //25% for french fly
  if(rng < 0.25f) return new PowerUp(frenchFlyImg, sBooster,x,y);
  //25% for tadpole
  if(rng < 0.5f) return new PowerUp(tadpoleImg, healthBooster,x,y);
  //25% for bigLegs
  if(rng < 0.75f) return new PowerUp(bigLegsImg, speedBooster,x,y);
  //25% for turtleShell
  return new PowerUp(turtleShellImg, maxHealthBooster,x,y);
}


public class StatUpgrade
{
  //Final means constant
  final float sChange;
  final float speedChange;
  final float healthChange;
  final float maxHealthChange;
  
  StatUpgrade(float sChange, float speedChange, float healthChange, float maxHealthChange)
  {
    this.sChange = sChange;
    this.speedChange = speedChange;
    this.healthChange = healthChange;
    this.maxHealthChange = maxHealthChange;
  }
}

class PowerUp extends GameObject
{
  
  StatUpgrade upgrade;
  
  public PowerUp(PImage image, StatUpgrade upgrade, float x, float y)
  {
    super(image, x, y);
    this.upgrade = upgrade;
    powerups.add(this);
  }
  
  void update()
  {
    //Blank, you must include this, but you can do things like animate the object or have it despawn after some time
  }
  
  void ApplyTo(IUpgradable target)
  {
    target.ApplyUpgrade(upgrade);
  }
}

class Projectile extends GameObject
{
  float xSpeed;
  float ySpeed;
  
  GameObject owner;
  
  Projectile(GameObject owner, float x, float y, float xSpeed, float ySpeed)
  {
    super(projectileImg, x, y);
    this.owner = owner;
    this.xSpeed = xSpeed;
    this.ySpeed = ySpeed;
  }

  void update()
  {
    move();
  }

  void move()
  {
    x += xSpeed;
    y += ySpeed;
  }
}

//Game Settings
int scoreReq = 5000;
float rangeMulti = 1.2;
float fireRateMulti = 0.9;
float speedMulti = 1.05; 

//Obelisk Settings
float obeliskRange = 300;
float obeliskFireTime = 120;
float projectileSpeed = 10;

final float startRange = 300;
final float startFireTime = 120;
final float startSpeed = 10;

//Controls how the camera moves. should be between 0-800.
float deadZoneXMin = 200;
float deadZoneXMax = 600;
float deadZoneYMin = 200;
float deadZoneYMax = 600;

class Wasp extends GameObject
{
  Animator animations = new Animator();
  boolean isFacingRight;
  float speed;

  Wasp()
  {
    super(waspFly.images[0], 0, 0);
    if ((int)random(2) == 0)
    {
      x = - 200;
    } else
    {
      x = trueWidth + 100;
    }
    y = random(-200, trueHeight + 100);
    animations.setAnimation(waspFly);
    speed= random(1, 3);
  }

  void display()
  {


    pushMatrix();

    translate(x, y);


    if (isFacingRight)
    {
      scale(-1, 1);
    }
    translate(-x, -y);
    super.display();
    popMatrix();
  }

  void update()
  {

    img = animations.getCurrentImage();
    animations.updateAnimation();
    //Move towards the player.
    //If we collide reduce the player's health.

    //1st create direction vector. (copy paste from obelisk)
    float xDist = player.x - x - camX;
    float yDist = player.y - y - camY;

    float dist = sqrt(xDist * xDist + yDist * yDist);
    float xDir = xDist / dist;
    float yDir = yDist / dist;

    x += xDir * speed;
    y += yDir * speed;

    //Then if we collide player takes damage
    if (collide(player))
    {
      player.takeDamage(0.1);
    }

    if (xDir < 0)
    {
      isFacingRight = false;
    } else if (xDir > 0)
    {
      isFacingRight = true;
    }
  }
}
