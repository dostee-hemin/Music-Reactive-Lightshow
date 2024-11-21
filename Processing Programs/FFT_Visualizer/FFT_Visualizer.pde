import processing.sound.*;

int bands = 512;                     // Number of frequency bands for the FFT

FFT fft;                             // FFT object to analyze the frequency spectrum
SoundFile file;                      // SoundFile object to load and play the MP3 file
float[] spectrum = new float[bands]; // Array to store the FFT spectrum data

float previousValue;                 // The average value of the spectrum calculated on the previous frame 

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

  // Calculate the average value of every band in the spectrum
  float sumOfValues = 0;
  for(int i=0; i<bands; i++) sumOfValues += spectrum[i];
  float averageValue = sumOfValues / bands;
  averageValue = map(averageValue,0,0.05,0,1); // Scale the average to a value between 0 and 1

  // Draw the line from the previous value to the current value
  stroke(0);
  strokeWeight(1);
  float x = frameCount % width;
  line(x-1,height*0.75-previousValue*height,x,height*0.75-averageValue*height);

  // Set the next frame's previous value to be the current average value
  previousValue = averageValue;
}