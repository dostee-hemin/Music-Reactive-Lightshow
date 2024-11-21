import processing.sound.*;
import java.io.File;
import java.time.format.DateTimeFormatter;  
import java.time.LocalDateTime; 

int bands = 512;                     // Number of frequency bands for the FFT
int samplingRate = 44100;            // Sampling rate of audio file
int lowPassFrequency = 200;          // The maximum frequency we will hear (in Hertz)

ArrayList<String> songFilePaths = new ArrayList<String>();   // Path to all song files in the "Songs" folder
String currentSongName;              // The name of the audio file currently being used

FFT fft;                             // FFT object to analyze the frequency spectrum
LowPass lowPass;                     // LowPass object that will limit the frequencies we hear to only low frequencies
SoundFile song;                      // SoundFile object to load and play the MP3 file
float[] spectrum = new float[bands]; // Array to store the FFT spectrum data
int maxBandIndex = lowPassFrequency * bands / (samplingRate/2);    // The highest index of the band in the low pass range

float minValue;                      // The minimum average value of the spectrum we've seen so far
float maxValue;                      // The maximum average value of the spectrum we've seen so far


int startViewIndex;                  // The index of the wave values to start displaying on the left side of the screen
float scrollSpeed;                   // The speed at which we scroll through the wave
ArrayList<Float> averageValues = new ArrayList<Float>();                // Contains the average spectrum values of every frame of the song
ArrayList<Integer> beatIndices = new ArrayList<Integer>();     // Contains the indices of the average values that indicate a beat
boolean isRecording = true;          // Determines whether or not we add new average value calculations to the list
float cursorPosition;                // The location in the song to start playing music in seconds
int beatAnimationAlpha;              // Fade value of the pulsing circle indicating a recorded beat

void setup() {
    size(800, 600);

    // Load all song file paths and setup the program for the first song
    loadSongs();
    setupNextSong();
}

void draw() {
    background(255);

    // Display the name of the current song at the top center of the screen
    fill(0);
    noStroke();
    textSize(30);
    textAlign(CENTER,CENTER);
    text(currentSongName, width/2, 30);

    // Display the wave of average values over time
    stroke(0);
    strokeWeight(1);
    noFill();
    beginShape();
    for (int i=0; i < averageValues.size(); i++) {
        if(averageValues.get(i) == 0) continue;
        float x = i-startViewIndex;
        float y = getWaveY(averageValues.get(i));
        vertex(x, y);
    }
    endShape();


    if(isRecording) {
        recordSongValues();

        // Display a progress bar showing how much is left before the song finishes recording
        fill(0);
        noStroke();
        textSize(30);
        textAlign(CENTER,CENTER);
        text("Recording...", width/2, height*0.75);
        fill(0,200,50);
        noStroke();
        rectMode(CORNER);
        rect(width/2-200,height*0.75+40, song.position()/song.duration() * 400,60);
        noFill();
        stroke(0);
        strokeWeight(6);
        rectMode(CENTER);
        rect(width/2,height*0.75+70,400,60);

        return;
    }

    // Display the cursor on the wave
    float cursorX = cursorPosition/song.duration() * averageValues.size() - startViewIndex;
    stroke(50);
    strokeWeight(2);
    line(cursorX,height/2+10,cursorX,height/4-10);
    strokeWeight(10);
    point(cursorX,height/4-10);

    // Display the current position of the song on the wave
    int positionX = round(song.position()/song.duration() * averageValues.size()) - startViewIndex;
    stroke(100);
    strokeWeight(1);
    line(positionX,height/2+10,positionX,height/4-10);




    // Display a dot over the index that the mouse is hovering over
    int mouseIndex = mouseX+startViewIndex;
    float mouseBassY = getWaveY(averageValues.get(mouseIndex));
    strokeWeight(15);
    stroke(255,0,0);
    point(mouseX,mouseBassY);

    // Display dots over all recorded beat indices
    strokeWeight(10);
    stroke(0,50,200);
    for(Integer i : beatIndices) {
        float x = i-startViewIndex;
        float y = getWaveY(averageValues.get(i));
        point(x,y);

        if(abs(positionX-x) < 2) beatAnimationAlpha = 255;
    }

    // Display a pulsing fading circle whenever the song passes over a recorded beat
    stroke(200,beatAnimationAlpha);
    strokeWeight(100-float(255-beatAnimationAlpha)/255*50);
    point(width/2,height-height/4);
    beatAnimationAlpha = max(beatAnimationAlpha-10, 0);

    // Move the along the wave according to the scroll speed
    startViewIndex = int(constrain(startViewIndex + scrollSpeed*10, 0, averageValues.size()-width));
    scrollSpeed *= 0.9;
}

// Function to load the next song we have from the list of song file paths
void setupNextSong() {
    // Reset all recording values
    isRecording = true;
    averageValues.clear();
    beatIndices.clear();
    cursorPosition = 0;
    startViewIndex = 0;
    minValue = 1;
    maxValue = 0;

    // Stop playing the song if it's playing
    if(song != null) song.pause();

    // Load the song file, get the song name, and remove this song from the list of file paths
    song = new SoundFile(this, "./Songs/" + songFilePaths.get(0));
    currentSongName = split(songFilePaths.get(0), ".")[0];
    songFilePaths.remove(0);

    // Create the low pass filter and apply the threshold to the audio file
    lowPass = new LowPass(this);
    lowPass.process(song, lowPassFrequency);

    // Initialize the FFT object with the number of bands and set the audio input source to the sound file
    fft = new FFT(this, bands);
    fft.input(song);

    // Load all existing data. If no song data exists, play the song data to record it
    loadSongData();
    loadBeatData();
    if(isRecording) song.play();  
}

// Function that records the values of the wave as the song goes on
void recordSongValues() {
    // Analyze the song using FFT
    fft.analyze(spectrum);

    // Calculate the average value of the spectrum within the low pass range
    float sumOfValues = 0;
    for(int i=0; i<maxBandIndex; i++) sumOfValues += spectrum[i];
    float averageValue = sumOfValues / maxBandIndex;

    // Once the song stops playing, we don't need to record any more song values
    if(!song.isPlaying()) {
        isRecording = false;

        // Make sure to normalize all values to be between 0 and 1
        for(int i=0; i<averageValues.size(); i++)
            averageValues.set(i, map(averageValues.get(i), minValue, maxValue, 0,1));
        minValue = 0;
        maxValue = 1;

        startViewIndex = 0;
        saveSongData();
        return;
    }

    // Keep track of the minimum and maximum average value seen so far
    minValue = min(minValue, averageValue);
    maxValue = max(maxValue, averageValue);

    // Add this average value to the list of all average values to display the wave
    averageValues.add(averageValue);

    // During recording, move the startViewIndex to always keep the end of the wave in view
    startViewIndex = max(0,averageValues.size()-width);
}

// Function to convert an average spectrum value to a y position on the wave
float getWaveY(float value) {
    return map(value, minValue, maxValue, height/2, height/4);
}