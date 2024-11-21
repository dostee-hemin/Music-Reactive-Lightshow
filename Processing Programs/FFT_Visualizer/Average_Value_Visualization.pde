float previousValue;                 // The average value of the spectrum calculated on the previous frame 

void drawAverageValue() {
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