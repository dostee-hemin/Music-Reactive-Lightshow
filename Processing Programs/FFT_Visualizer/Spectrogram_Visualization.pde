void drawSpectrogram() {
    // When the spectrogram reaches the end of the screen width, reset the canvas
    if(frameCount % width == 0) background(255);

    loadPixels();
    // Loop through every band in the spectrum
    for(int i=0; i<bands; i++) {
        // Set the intensity of the spectrum value to a value between 0 and 1
        float intensity = map(spectrum[i],0,0.05,0,1);

        // Calculate the position of the current band pixel
        float x = frameCount%width;           // Moves to the right according to the frameCount
        float y = height-(height-bands)/2-i;  // Low-to-high frequencies go from the bottom to top
        // Get the index of the current pixel by converting the 2D-coordinates to a 1D-value
        int pixelIndex = int(x + y * width);
        // Set the pixel color to an orangish value based on the intensity of the current band
        pixels[pixelIndex] = color(intensity*255,intensity*100,0);
    }
    updatePixels();
}