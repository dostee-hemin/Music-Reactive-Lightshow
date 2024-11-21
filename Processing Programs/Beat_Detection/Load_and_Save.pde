// Loads all song file paths to an array list of strings 
void loadSongs() {
    // Get the list of files from the "Songs" folder
    File folder = new File(sketchPath() + "/Songs");
    File[] files = folder.listFiles();

    // Make sure the "Songs" folder exists
    if(files == null) {
        print("Whoops, it seems the 'Songs' folder is not there. Are you sure you haven't deleted it or renamed it?");
        exit();
        return;
    }

    // Only consider the files with a .mp3 or .wav extension
    for (File file : files) {
        println(file.getName());
        if (file.isFile() && (file.getName().endsWith(".mp3") || file.getName().endsWith(".wav")))
            songFilePaths.add(file.getName());
    }
}


// Add all saved values of the wave to the list of averageValues. We don't need to record if the song data file exists 
void loadSongData() {
    try {
        String[] txt = loadStrings("./Song Data/"+currentSongName+"_song_data.txt");
        for(int i=0; i<txt.length; i++) {
            float currentValue = float(txt[i]);
            minValue = min(minValue, currentValue);
            maxValue = max(maxValue, currentValue);
            averageValues.add(currentValue);
        }
        isRecording = false;
    } catch (Exception e) {
        println("Error: Song data for \""+currentSongName+"\" doesn't exist");
    }
}


// Add all saved beat indices to the list
void loadBeatData() {
    try {
        String[] txt = loadStrings("./Beat Data/"+currentSongName+"_beat_data.txt");
        for(int i=0; i<txt.length; i++) {
            beatIndices.add(int(txt[i]));
        }
    } catch (Exception e) {
        println("Error: Beat data for \""+currentSongName+"\" doesn't exist");
    }
}

// Save all values of the wave to a text file
void saveSongData() {
    String fileName = "./Song Data/"+currentSongName+"_song_data.txt";
    PrintWriter output = createWriter(fileName); 
    for (Float f : averageValues) output.println(map(f,minValue,maxValue,0,1));
    output.close(); 
    println("File saved: " + fileName);
}

// Save all beat indices to a text file
void saveBeatData() {
    String fileName = "./Beat Data/"+currentSongName+"_beat_data.txt";
    PrintWriter output = createWriter(fileName); 
    for (int i = 0; i < beatIndices.size(); i++) {
        output.println(beatIndices.get(i));
    } 
    output.close(); 
}