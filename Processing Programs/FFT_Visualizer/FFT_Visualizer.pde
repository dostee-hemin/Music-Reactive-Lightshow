import processing.sound.*;

int bands = 512;                     // Number of frequency bands for the FFT

FFT fft;                             // FFT object to analyze the frequency spectrum
SoundFile file;                      // SoundFile object to load and play the MP3 file
float[] spectrum = new float[bands]; // Array to store the FFT spectrum data

int currentVisualization = 0;        // ID of the visualization to display

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

  // Display the current visualization
  switch(currentVisualization) {
    case 0:
      drawBarGraph();
      break;
    case 1:
      drawSpectrogram();
      break;
    case 2:
      drawAverageValue();
      break;
  }

  // Display instructions to change the visualization
  fill(0);
  noStroke();
  textSize(30);
  textAlign(CENTER, CENTER);
  text("Click the Mouse to Change Visualization", width/2, 20);
}

// Everytime the user clicks the mouse, the screen is reset and the visualization changes
void mousePressed() {
  currentVisualization = (currentVisualization+1) % 3;
  background(255);
}