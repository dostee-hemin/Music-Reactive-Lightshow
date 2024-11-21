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
    
    switch(mouseButton) {
        // Add the index if the user clicks the left mouse button
        case LEFT:
            beatIndices.add(index);
            saveBeatData();
            break;
        
        // Remove the index if the user clicks the right mouse button
        case RIGHT:
            int indexInList = beatIndices.indexOf(index);
            if (indexInList != -1) {
                beatIndices.remove(indexInList);
                saveBeatData();
            }
            break;

        // Set the position of the cursor if the user clicks the middle mouse button
        case CENTER:
            cursorPosition = float(index)/averageValues.size() * song.duration();
            setCursor();
            break;
    }
}

// Pauses the song and sets the song position to the cursor position
void setCursor() {
    song.jump(cursorPosition);
    song.pause();
}

void keyPressed() {
    if(isRecording) return;

    switch(key) {
        // Toggle between playing and pausing the song if the user clicks the space bar
        case ' ':
            if(song.isPlaying()) setCursor();
            else song.play();
            break;
        
        // Move to the next song if the user clicks the 'N' key
        case 'n':
        case 'N':
            setupNextSong();
            break;
    }
}