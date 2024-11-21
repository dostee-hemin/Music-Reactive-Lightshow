// Import the Processing Sound library
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
}

void draw() {
  // Perform FFT analysis and store the result in the spectrum array
  fft.analyze(spectrum);

  background(255);

  // Loop through each frequency band to draw the spectrum
  stroke(0);
  strokeWeight(1);
  for(int i = 0; i < bands; i++) {
    // Draw a vertical line for each band, where the line height is proportional to the spectrum value
    line(i, height, i, height - spectrum[i] * height * 5);
  }
}
