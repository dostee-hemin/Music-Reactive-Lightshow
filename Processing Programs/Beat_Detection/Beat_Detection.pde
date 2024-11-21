import processing.sound.*;

int bands = 512;                     // Number of frequency bands for the FFT
int samplingRate = 44100;            // Sampling rate of audio file
int lowPassFrequency = 300;          // The maximum frequency we will hear (in Hertz)

FFT fft;                             // FFT object to analyze the frequency spectrum
LowPass lowPass;                     // LowPass object that will limit the frequencies we hear to only low frequencies
SoundFile file;                      // SoundFile object to load and play the MP3 file
float[] spectrum = new float[bands]; // Array to store the FFT spectrum data
int maxBandIndex;                    // The highest index of the band in the low pass range

float previousValue;                 // The average value of the spectrum calculated on the previous frame 
float minValue;                      // The minimum average value of the spectrum we've seen so far
float maxValue;                      // The maximum average value of the spectrum we've seen so far

void setup() {
  size(800, 600);
  
  // Load the MP3 file and start playing it
  file = new SoundFile(this, "8 bit hero - intro sequence.mp3");
  file.play();  

  // Create the low pass filter and apply the threshold to the audio file
  lowPass = new LowPass(this);
  lowPass.process(file, lowPassFrequency);

  // Initialize the FFT object with the number of bands and set the audio input source to the sound file
  fft = new FFT(this, bands);
  fft.input(file);

  // Calculate the last band in the array that is within the low pass range
  maxBandIndex = lowPassFrequency * bands / (samplingRate/2);

  background(255);
}

void draw() {
  // Perform FFT analysis and store the result in the spectrum array
  fft.analyze(spectrum);

  // When the spectrogram reaches the end of the screen width, reset the canvas
  if(frameCount % width == 0) background(255);

  // Calculate the average value of every band within the low pass frequency range
  float sumOfValues = 0;
  for(int i=0; i<maxBandIndex; i++) sumOfValues += spectrum[i];
  float averageValue = sumOfValues / maxBandIndex;

  // Keep track of the minimum and maximum values we've seen so far
  minValue = min(minValue, averageValue);
  maxValue = max(maxValue, averageValue);

  // Draw the line from the previous value to the current value
  stroke(0);
  strokeWeight(1);
  float x = frameCount % width;
  float yPrevious = map(previousValue, minValue, maxValue, height*0.6, height*0.4);
  float yCurrent = map(averageValue, minValue, maxValue, height*0.6, height*0.4);
  line(x-1, yPrevious, x, yCurrent);

  // Set the next frame's previous value to be the current average value
  previousValue = averageValue;
}