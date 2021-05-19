class Animation {
  PImage[] images;
  int imageCount;
  int frame;
    
  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = "images\\" + imagePrefix + "\\" +  imagePrefix + nf(i, 4) + ".png";
      images[i] = loadImage(filename);
    }
    
  }

  
  void display(float xpos, float ypos, float image_width, float image_height, boolean iterate_frame) {
    
    if (iterate_frame) frame = (frame+1) % imageCount;
    image(images[frame], xpos, ypos, image_width, image_height);
  }
  
  
  int getWidth() {
    return images[0].width;
  }
}
