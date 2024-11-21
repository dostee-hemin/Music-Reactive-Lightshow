import processing.sound.*;
import java.time.format.DateTimeFormatter;  
import java.time.LocalDateTime; 

int bands = 512;                     // Number of frequency bands for the FFT
int samplingRate = 44100;            // Sampling rate of audio file
int lowPassFrequency = 200;          // The maximum frequency we will hear (in Hertz)

String songName = "8 bit hero - intro sequence";   // The name of the audio file
String fileExtension = ".mp3";                     // The type of the audio file

FFT fft;                             // FFT object to analyze the frequency spectrum
LowPass lowPass;                     // LowPass object that will limit the frequencies we hear to only low frequencies
SoundFile song;                      // SoundFile object to load and play the MP3 file
float[] spectrum = new float[bands]; // Array to store the FFT spectrum data
int maxBandIndex;                    // The highest index of the band in the low pass range

float previousValue;                 // The average value of the spectrum calculated on the previous frame 
float minValue;                      // The minimum average value of the spectrum we've seen so far
float maxValue;                      // The maximum average value of the spectrum we've seen so far


int startViewIndex;                  // The index of the wave values to start displaying on the left side of the screen
float scrollSpeed;                   // The speed at which we scroll through the wave
ArrayList<Float> averageValues = new ArrayList<Float>();                // Contains the average spectrum values of every frame of the song
ArrayList<Integer> beatIndices = new ArrayList<Integer>();     // Contains the indices of the average values that indicate a beat
boolean isRecording = true;          // Determines whether or not we add new average value calculations to the list

void setup() {
    size(800, 600);

    // Load the MP3 file and start playing it
    song = new SoundFile(this, songName+fileExtension);

    // Create the low pass filter and apply the threshold to the audio file
    lowPass = new LowPass(this);
    lowPass.process(song, lowPassFrequency);

    // Initialize the FFT object with the number of bands and set the audio input source to the sound file
    fft = new FFT(this, bands);
    fft.input(song);

    // Calculate the last band in the array that is within the low pass range
    maxBandIndex = lowPassFrequency * bands / (samplingRate/2);

    // Load all existing data. If no song data exists, record the song data
    loadSongData();
    loadBeatData();
    if(isRecording) song.play();  
}

void draw() {
    background(255);

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
        return;
    }

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
    }

    // Move the along the wave according to the scroll speed
    startViewIndex = int(constrain(startViewIndex + scrollSpeed*10, 0, averageValues.size()-width));
    scrollSpeed *= 0.9;
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



/*      Load and Save Data Code      */

// Add all saved values of the wave to the list of averageValues. We don't need to record if the song data file exists 
void loadSongData() {
    try {
        String[] txt = loadStrings("./Song Data/"+songName+"_song_data.txt");
        for(int i=0; i<txt.length; i++) {
            float currentValue = float(txt[i]);
            minValue = min(minValue, currentValue);
            maxValue = max(maxValue, currentValue);
            averageValues.add(currentValue);
        }
        isRecording = false;
    } catch (Exception e) {
        println("Error: Song data for \""+songName+"\" doesn't exist");
    }
}


// Add all saved beat indices to the list
void loadBeatData() {
    try {
        String[] txt = loadStrings("./Beat Data/"+songName+"_beat_data.txt");
        for(int i=0; i<txt.length; i++) {
            beatIndices.add(int(txt[i]));
        }
    } catch (Exception e) {
        println("Error: Beat data for \""+songName+"\" doesn't exist");
    }
}

// Save all values of the wave to a text file
void saveSongData() {
    String fileName = "./Song Data/"+songName+"_song_data.txt";
    PrintWriter output = createWriter(fileName); 
    for (Float f : averageValues) output.println(f);
    output.close(); 
    println("File saved: " + fileName);
}

// Save all beat indices to a text file
void saveBeatData() {
    String fileName = "./Beat Data/"+songName+"_beat_data.txt";
    PrintWriter output = createWriter(fileName); 
    for (int i = 0; i < beatIndices.size(); i++) {
        output.println(beatIndices.get(i));
    } 
    output.close(); 
}







/*      User Interaction Code      */

// Move along the wave according to the direction of the scroll wheel
void mouseWheel(MouseEvent event) {
    if(isRecording) return;

    float e = event.getCount();
    scrollSpeed -= e;
}

// Mark the index at the mouse as a beat index
void mousePressed() {
    if(isRecording) return;

    int index = mouseX + startViewIndex;

    // Add the index if the user clicks the left mouse button
    if(mouseButton == LEFT && !beatIndices.contains(index)) beatIndices.add(index);
    // Remove the index if the user clicks the right mouse button
    else if(mouseButton == RIGHT && beatIndices.contains(index)) beatIndices.remove(beatIndices.indexOf(index));

    saveBeatData();
}