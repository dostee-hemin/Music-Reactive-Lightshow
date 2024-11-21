import processing.sound.*;

int bands = 512;                     // Number of frequency bands for the FFT

FFT fft;                             // FFT object to analyze the frequency spectrum
SoundFile file;                      // SoundFile object to load and play the MP3 file
float[] spectrum = new float[bands]; // Array to store the FFT spectrum data

void setup() {
  size(800, 600);
  
  // Load the MP3 file and start playing it
  file = new SoundFile(this, "8 bit hero - intro sequence.mp3");
  file.play();  

  // Initialize the FFT object with the number of bands and set the audio input source to the sound file
  fft = new FFT(this, bands);
  fft.input(file);

  background(255);
}

void draw() {
  // Perform FFT analysis and store the result in the spectrum array
  fft.analyze(spectrum);

  // When the spectrogram reaches the end of the screen width, reset the canvas
  if(frameCount % width == 0) background(255);

  loadPixels();
  // Loop through every band in the spectrum
  for(int i=0; i<bands; i++) {
    // Set the intensity of the spectrum value to a value between 0 and 1
    float intensity = map(spectrum[i],0,0.05,0,1);

    // Calculate the position of the current band pixel
    float x = frameCount%width;           // Moves to the right according to the frameCount
    float y = height-(height-bands)/2-i;  // Low-to-high frequencies go from the bottom to top

    // Get the index of the current pixel by converting the 2D-coordinates to a 1D-value
    int pixelIndex = int(x + y * width);

    // Set the pixel color to an orangish value based on the intensity of the current band
    pixels[pixelIndex] = color(intensity*255,intensity*100,0);
  }
  updatePixels();
}