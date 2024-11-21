void drawBarGraph() {
    background(255);

    // Loop through each frequency band to draw the spectrum
    stroke(0);
    strokeWeight(1);
    for(int i = 0; i < bands; i++) {
        // Draw a vertical line for each band, where the line height is proportional to the spectrum value
        line(i, height, i, height - spectrum[i] * height * 5);
    }
}