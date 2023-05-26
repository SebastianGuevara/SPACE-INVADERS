import processing.serial.*;
import ddf.minim.*;

Minim minim;
AudioPlayer file;

int pixelsize = 6;
int gridsize  = pixelsize * 7 + 5;
Player player;
ArrayList enemies = new ArrayList();
ArrayList bullets = new ArrayList();
int direction = 1;
boolean incy = false;
int score = 0;
PFont f;
Serial myPort;
int val;
PImage messiImage;
PImage ballImage;
boolean win = false;
int level = 0;
PImage image;

void setup() {
    background(0);
    noStroke();
    size(800, 600);
    player = new Player();    
    createEnemies();
    messiImage = loadImage("messi.png");
    ballImage = loadImage("ball.png");
    minim = new Minim(this);
    image = loadImage("holanda.png");
    image.resize(int(25), int(20));
    String portName = Serial.list()[4];
    myPort = new Serial(this, portName, 115200);
    f = createFont("Arial", 36, true);
}

void draw() {
    background(0);
    drawScore();
    player.draw();
    
    if(win){
      text("Game Over", 300, 300);
    }else{
      
        if(enemies.size() == 0){
          
          if(level == 0){
            file = minim.loadFile("w1.mp3");
            file.play();
            delay(3000);
            createEnemies1();
            image = loadImage("cro.png");
            image.resize(int(25), int(20));
          }
          if(level == 1){
            file = minim.loadFile("cw.mp3");
            file.play();
            delay(3000);
            createEnemies2();
            image = loadImage("fra.png");
            image.resize(int(25), int(20));
          }
          if(level == 2){
            file = minim.loadFile("fw.mp3");
            file.play();
            text("You win", 300, 300);
          }
          level++;
        }
          for (int i = 0; i < bullets.size(); i++) {
                BulletE bullet = (BulletE) bullets.get(i);   
                bullet.draw();
            }
        
            for (int i = 0; i < enemies.size(); i++) {
                Enemy1 enemy = (Enemy1) enemies.get(i);
                if (enemy.outside() == true) {
                    direction *= (-1);
                    incy = true;
                    break;
                }
            }
        
            for (int i = 0; i < enemies.size(); i++) {
                Enemy1 enemy = (Enemy1) enemies.get(i);
                if (!enemy.alive()) {
                    enemies.remove(i);
                } else {
                    enemy.draw();
                }
            }
       
        incy = false;
    }
}

void drawScore() {
    textFont(f);
    text("Score: " + String.valueOf(score), 300, 50);
}

void createEnemies() {
    for (int i = 0; i < width/gridsize/2; i++) {
        for (int j = 0; j <= 2; j++) {
            enemies.add(new Enemy1(i*gridsize, j*gridsize + 70));
        }
    }
}

void createEnemies1() {
    for (int i = 0; i < width/gridsize/2; i++) {
        for (int j = 0; j <= 3; j++) {
            enemies.add(new Enemy1(i*gridsize, j*gridsize + 70));
        }
    }
}

void createEnemies2() {
    for (int i = 0; i < width/gridsize/2; i++) {
        for (int j = 0; j <= 3; j++) {
            enemies.add(new Enemy1(i*gridsize, j*gridsize + 70));
        }
    }
}

class SpaceShip {
    int x, y;
    String sprite[];
    color baseColor = color(255, 255, 255);
    color nextColor = baseColor;

    void draw() {
        updateObj();
        drawSprite(x, y);
    }

    void drawSprite(int xpos, int ypos) {
        fill(nextColor);
        nextColor = baseColor;

        for (int i = 0; i < sprite.length; i++) {
            String row = (String) sprite[i];

            for (int j = 0; j < row.length(); j++) {
                if (row.charAt(j) == '1') {
                    rect(xpos + (j * pixelsize), ypos + (i * pixelsize), pixelsize, pixelsize);
                }
            }
        }
    }

    void updateObj() {
    }
}

class MessiPainting {
    int x, y;
    color baseColor = color(255, 255, 255);
    color nextColor = baseColor;

    void draw() {
        updateObj();
        drawSprite(x, y);
        check();
    }

    void drawSprite(int xpos, int ypos) {
        fill(nextColor);
        nextColor = baseColor;

        image(messiImage, xpos, ypos, 100, 100);
    }
        void check() {
        for (int i = 0; i < enemies.size(); i++) {
            Enemy1 enemy = (Enemy1) enemies.get(i);

            if (enemy.y > y && enemy.y < y + 10 * pixelsize) {
                win = true;
                file = minim.loadFile("dies.mp3");
                file.play();
                break;
            }
        }
        
    }
    
    void updateObj() {
    }
}

class Player extends MessiPainting {
    boolean canShoot = true;
    int shootdelay = 0;

    Player() {
        x = width/gridsize/2;
        y = height - (15 * pixelsize);

    }

    void updateObj() {
        if (myPort.available()>0){
          val = myPort.read();
          if(val==65){
            if (x > 10){
              x -= 50;
              print('A', x);
            }
          }
          if (val==66){
            if (x < 700){
               x += 50;
            }
            print('B',x);
          }
          if (val==67){
            file = minim.loadFile("ball.mp3");
            file.play();
            bullets.add(new BulletE(x, y,3));
            canShoot = false;
            shootdelay = 0;
            print('C');
          }
          if (val==68){
            bullets.add(new BulletE(x, y,7));
            canShoot = false;
            shootdelay = 0;
            print('D');
          }
        }        
        shootdelay++;
        
        if (shootdelay >= 2) {
            canShoot = true;
        }
    }
    
    
    void check() {
        for (int i = 0; i < enemies.size(); i++) {
            Enemy1 enemy = (Enemy1) enemies.get(i);

            if (enemy.y > y && enemy.y < y + 10 * pixelsize) {
                file = minim.loadFile("dies.mp3");
                file.play();
                win = true;
                break;
            }    
        }
    }
}

class Enemy extends SpaceShip {
    int life = 1;
    
    Enemy(int xpos, int ypos) {
        x = xpos;
        y = ypos;
        sprite    = new String[5];
        sprite[0] = "1011101";
        sprite[1] = "0101010";
        sprite[2] = "1111111";
        sprite[3] = "0101010";
        sprite[4] = "1000001";
    }

    void updateObj() {
        if (frameCount%30 == 0) {
            x += direction * gridsize;
        }
        
        if (incy == true) {
            y += gridsize / 2;
        }
    }

    boolean alive() {
        for (int i = 0; i < bullets.size(); i++) {
            BulletE bullet = (BulletE) bullets.get(i);
            
            if (bullet.x + 2 > x && bullet.x - 2 < x + 7 * pixelsize + 10 && bullet.y > y && bullet.y < y + 5 * pixelsize) {
                bullets.remove(i);
                life--;
                nextColor = color(255, 0, 0);
                
                if (life == 0) {
                    score += 50;
                    return false;
                }
                
                break;
            }
        }

        return true;
    }

    boolean outside() {
        return x + (direction*gridsize) < 0 || x + (direction*gridsize) > width - gridsize;
    }
}
class Enemy1 extends SpaceShip {
    int life = 1;

    Enemy1(int xpos, int ypos) {
        x = xpos;
        y = ypos;
        sprite    = new String[5];
        sprite[0] = "1011101";
        sprite[1] = "0101010";
        sprite[2] = "1111111";
        sprite[3] = "0101010";
        sprite[4] = "1000001";

    }

    void drawSprite(int xpos, int ypos) {
        image(image, xpos, ypos);
    }

    void updateObj() {
        if (frameCount % 30 == 0) {
            x += direction * gridsize;
        }

        if (incy == true) {
            y += gridsize / 2;
        }
    }

    boolean alive() {
        for (int i = 0; i < bullets.size(); i++) {
            BulletE bullet = (BulletE) bullets.get(i);

            if (bullet.x + 6> x && bullet.x  < x + 7 * pixelsize + 5 && bullet.y > y && bullet.y < y + 5 * pixelsize) {
                file = minim.loadFile("kill.mp3");
                file.play();
                bullets.remove(i);
                life--;
                nextColor = color(255, 0, 0);

                if (life == 0) {
                    score += 50;
                    return false;
                }

                break;
            }
        }

        return true;
    }

    boolean outside() {
        return x + (direction * gridsize) < 0 || x + (direction * gridsize) > width - gridsize;
    }
}

class Enemy2 extends SpaceShip {
    int life = 1;
    PImage image;

    Enemy2(int xpos, int ypos) {
        x = xpos;
        y = ypos;
        sprite    = new String[5];
        sprite[0] = "1011101";
        sprite[1] = "0101010";
        sprite[2] = "1111111";
        sprite[3] = "0101010";
        sprite[4] = "1000001";
        image = loadImage("cro.png");
        image.resize(int(25), int(20));

    }

    void drawSprite(int xpos, int ypos) {
        image(image, xpos, ypos);
    }

    void updateObj() {
        if (frameCount % 30 == 0) {
            x += direction * gridsize;
        }

        if (incy == true) {
            y += gridsize / 2;
        }
    }

    boolean alive() {
        for (int i = 0; i < bullets.size(); i++) {
            BulletE bullet = (BulletE) bullets.get(i);

            if (bullet.x + 6> x && bullet.x  < x + 7 * pixelsize + 5 && bullet.y > y && bullet.y < y + 5 * pixelsize) {
                file = minim.loadFile("kill.mp3");
                file.play();
                bullets.remove(i);
                life--;
                nextColor = color(255, 0, 0);

                if (life == 0) {
                    score += 50;
                    return false;
                }

                break;
            }
        }

        return true;
    }

    boolean outside() {
        return x + (direction * gridsize) < 0 || x + (direction * gridsize) > width - gridsize;
    }
}

class Enemy3 extends SpaceShip {
    int life = 1;
    PImage image;

    Enemy3(int xpos, int ypos) {
        x = xpos;
        y = ypos;
        sprite    = new String[5];
        sprite[0] = "1011101";
        sprite[1] = "0101010";
        sprite[2] = "1111111";
        sprite[3] = "0101010";
        sprite[4] = "1000001";
        image = loadImage("fra.png");
        image.resize(int(25), int(20));

    }

    void drawSprite(int xpos, int ypos) {
        image(image, xpos, ypos);
    }

    void updateObj() {
        if (frameCount % 30 == 0) {
            x += direction * gridsize;
        }

        if (incy == true) {
            y += gridsize / 2;
        }
    }

    boolean alive() {
        for (int i = 0; i < bullets.size(); i++) {
            BulletE bullet = (BulletE) bullets.get(i);

            if (bullet.x + 6> x && bullet.x  < x + 7 * pixelsize + 5 && bullet.y > y && bullet.y < y + 5 * pixelsize) {
                file = minim.loadFile("kill.mp3");
                file.play();
                bullets.remove(i);
                life--;
                nextColor = color(255, 0, 0);

                if (life == 0) {
                    score += 50;
                    return false;
                }

                break;
            }
        }

        return true;
    }

    boolean outside() {
        return x + (direction * gridsize) < 0 || x + (direction * gridsize) > width - gridsize;
    }
}
class Bullet {
    int x, y, bullColor, bullSize;

    Bullet(int xpos, int ypos, int bulletColor, int bulletSize) {
        x = xpos + gridsize/2 - 4;
        y = ypos;
        bullColor = bulletColor;
        bullSize = bulletSize;
    }

    void draw() {
        fill(255);
        fill(bullColor,0,0);
        rect(x, y, pixelsize*bullSize, pixelsize*bullSize);
        y -= pixelsize * 2;
    }
}
class BulletE {
    int x, y, bullSize;

    BulletE(int xpos, int ypos, int bulletSize) {
        x = xpos + gridsize / 2 - 4;
        y = ypos;
        bullSize = bulletSize;
    }

    void draw() {
        image(ballImage, x, y, pixelsize * bullSize, pixelsize * bullSize);
        y -= pixelsize * 2;
    }
}

class Bullet2 {
    int x, y;

    Bullet2(int xpos, int ypos) {
        x = xpos + gridsize/2 - 4;
        y = ypos;
    }

    void draw() {
        fill(255,0,0);
        rect(x, y, pixelsize*2, pixelsize*2);
        y -= pixelsize * 2;
    }
}

void stop() {
  file.close();
  minim.stop();
  super.stop();
}
