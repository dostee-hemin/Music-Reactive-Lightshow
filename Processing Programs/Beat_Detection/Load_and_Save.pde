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