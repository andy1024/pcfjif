/**
*
* Jiffy demo
* uses PCF8591 chip connected to FF32 dongle on B9 and B10 pins (i2c) 
*
* by Andrzej Maslowski (github.com/andy1024)
*
*/
import controlP5.*;

import org.warheim.interfacing.jiffy32.util.*;
import org.warheim.interfacing.jiffy32.exceptions.*;
import org.warheim.interfacing.jiffy32.hl.i2c.*;
import java.util.HashMap;
import java.util.Map;
import org.warheim.interfacing.jiffy32.model.Pin;

import com.codeminders.hidapi.ClassPathLibraryLoader;
import com.codeminders.hidapi.HIDDevice;
import com.codeminders.hidapi.HIDManager;

ControlP5 cp5;
int updateInterval = 1;

int potValue = 100;
int photoValue = 100;
int thermValue = 30;

Slider potSlider;
Slider photoSlider;
Slider thermSlider;
Slider intervalSlider;

Timer timer;

Map<String, Integer> ports = new HashMap<String, Integer>();
I2C_PCF8591 chip;

void setup() {
  size(500,300);
  background(0);
  noStroke();
  cp5 = new ControlP5(this);
  
  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  potSlider = cp5.addSlider("Pot")
     .setSize(256,20)
     .setPosition(100,50)
     .setRange(0,255)
     ;

  photoSlider = cp5.addSlider("Photoresistor")
     .setSize(256,20)
     .setPosition(100,100)
     .setRange(0,255)
     ;

  thermSlider = cp5.addSlider("Thermistor")
     .setSize(256,20)
     .setPosition(100,150)
     .setRange(0,255)
     ;

  intervalSlider = cp5.addSlider("Update interval")
     .setSize(256,20)
     .setRange(1,10)
     .setPosition(100,200)
     .setNumberOfTickMarks(10)
     ;
     intervalSlider.setValue(updateInterval);
     timer = new Timer(updateInterval*1000);
  initJiffy();
}

void initJiffy() {
  try {
    com.codeminders.hidapi.ClassPathLibraryLoader
          .loadNativeHIDLibrary();

    ports.put("empty", 0x00);
    ports.put("pot", 0x01);
    ports.put("photoresistor", 0x02);
    ports.put("thermistor", 0x03);

    chip = new I2C_PCF8591(Pin.B9, Pin.B10, ports);

    println("PCF8591 init ok");

  } catch (Exception e) {
    println("problem while initializing ff32");
    throw new RuntimeException(e);
  }    
}

void readChip() {
  println("reading chip");
  try {
    int nullValue = chip.readPort("empty");
    potValue = chip.readPort("pot");
    photoValue = chip.readPort("photoresistor");
    thermValue = chip.readPort("thermistor");
    println("pot=" + potValue);
    println("photo=" + photoValue);
    println("therm=" + thermValue);
  } catch (Exception e) {
    println("problem while using ff32");
  }
}

void draw() {
  if (timer.isFinished()) {
    timer.updateInterval(updateInterval*1000);
    timer.start();
    readChip();
    potSlider.setValue(potValue);
    photoSlider.setValue(photoValue);
    thermSlider.setValue(thermValue);
    updateInterval = (int) intervalSlider.getValue();
  }
}


void slider(float theColor) {
  //myColor = color(theColor);
  println("a slider event. setting background to "+theColor);
}