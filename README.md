# ROMDUMP81 - TI-81 ROM Preservation using an ESP32

## Introduction

The TI-81 was the first foray into graphing calculator by Texas Instruments all the way back in 1990. Though there are several revisions of the TI-81, they all have 1 thing in common; the lack of a link-port.

This means that transferring data to/from the TI-81 is not supported natively, so activities like transferring programs and backing up calculator contents, such as your ROM (the focus of this project), were not supported.

Considering the age of the TI-81 it has become important to some in the community to backup their calculators for historical and archival purposes. Since there was no ablity to link to the TI-81, some creativity is required in order to achieve this.

All efforts in this space build off the great work by Randy 'Zeroko' Compton who discovered an exploit that enabled execution of user-entered machine code on the TI-81. Additionally Benjamin 'FloppusMaximus' Moody built upon this by releasing Unity, an assembly program loader for the TI-81.

There are 2 current methods for dumping your TI-81 ROM as far as I'm aware:
- Printing characters to the LCD, capturing with a video camera and using OCR to decode the data (Developed by FloppusMaximus, instructions here: https://tiplanet.org/modules/archives/downloads/dump81.pdf)
- Running an ASM program to generate a signal that can bepicked up by an AM radio connected to your PC. (Developed by Zeroko, not publicly available?)

The issue with the OCR method (and the main reason for this project) is that due to the age of the TI-81, the LCD's are starting to deteriorate and become unreliable with missing rows or columns. Plus it is EXTREMELY tedious and time-consuming. I don't believe at the time of writing that the AM Radio dumper is publicly available, though that would also be a very nifty and viable alternative to OCR.

This project proposes taking advantage of the populatrity of cheap Arduino compatible microcontrollers such as the ESP32 (though you can likely use an actual Arduino, an ESP8266 or other similar board) and the GPIO pins on the TI-81 ASIC itself to transfer data over serial to your PC.

By running an extremely simple ASM program and an equally simple Arduino program, I was able to dump the ROM's of my TI-81 in around 10 minutes - inclusive of disassembly, soldering, typing in the programs and running the code. The actual dumping of the ROM contents once the program is running takes less than 15 seconds.

The biggest difficulty with this project is soldering wires to the ASIC pins for TI-81 ROM versions V1.0 - V1.8K. Some experience with soldering is definitely recommended and checking afterwards with a multimetere to ensure there are no shorts is a must. A magnifying glass or microscope would make life easier if you have one. I recommend soldering to the bottom of 1 pin and the top of the other as it seemed to be easier that way for me.

TI-81 versions V2.00 and later are based on the early TI-82 PCB and have nicely broken out pads for you to solder to, which makes things much simpler.

Although not necessary, I recommend powering your calc off the ESP32 +5v & GND pins (as I've included in the images below, I just used aligator clips as opposed to soldering) so you don't have to keep messing around with batteries. This is how I did it and I'm fairly certain you will need GND in any case to ensure the serial connection functions correctly.

**IMPORTANT - The GPIO pins on the TI-81 are 5V and could damage your microcontroller if it is not 5V tolerant. There is a lot of conflicting information online regarding 5V tolerance on the ESP32 so a logic-level converter may be necessary.**

## What you will need:
- A working TI-81 Calculator
- An ESP32 board (I used an ESP32-WROOM-32 board which cost less than $10 on ebay) + USB cable
- A solder iron with solder (flux is also recommended)
- Small gauge wire
- Breadbord and jumper wires (optional but recommended)
- A multimeter
- PC with Aruino IDE and drivers for your board installed

## Hardware Instructions

To obtain the ROM version of your TI-81 press: [2nd] [MATH] [ALPHA] [S] and you will be presented with the self-test screen which displays your ROM version similar to the below:

![](/res/V1.0_selftest.png)

Follow the instructions specific to your ROM version:

#### ROM Version V1.0

Carefully solder 2 wires to the below pins GPIO2 & GPIO3 of the ASIC. I recommend using small gauge wire and double checking for shorts with a multimeter afterwards. GPIO3 is 8 pins from the bottom left of the ASIC, likewise GPIO2 is 9 pins from the bottom left. It may be possible to utilise IC pin clips to avoid soldering if you have them. Pins assignments are shown for reference:

![](/res/V1.0_full.png) ![](/res/V1.0_asic.png)

Connect GPIO3 to pin G4 of your ESP32 and GPIO2 to pin G5. Additionally connect your calculators + battery to the ESP32's 5V pin and your calculators - battery to your ESP32's GND pin.

#### ROM Version V1.1 - V1.8K

Carefully solder 2 wires to the below pins GPIO2 & GPIO3 of the ASIC. I recommend using small gauge wire and double checking for shorts with a multimeter afterwards. GPIO3 is 8 pins from the bottom left of the ASIC, likewise GPIO2 is 9 pins from the bottom left. It may be possible to utilise IC pin clips to avoid soldering if you have them. Pins assignments are shown for reference:

![](/res/V1.1-V1.8K_full.png) ![](/res/V1.1-V1.8K_asic.png)

Connect GPIO3 to pin G4 of your ESP32 and GPIO2 to pin G5. Additionally connect your calculators + battery to the ESP32's 5V pin and your calculators - battery to your ESP32's GND pin.

#### ROM Version V2.00 - V2.0V

Carefully solder 2 wires to the below pads on the calculator mainboard labelled R10 & R7. It should be a lot easier than other versions due to the pads being easily accessible. Still if your prefer solderless GPIO3 is the 1st pin from the bottom right of the ASIC, likewise GPIO2 is the 2nd pin from the bottom right, so it may be possible to utilise IC pin clips to avoid soldering if you have them. Pins assignments are shown for reference:

![](/res/V2.00-V2.0V_full.png) ![](/res/V2.00-V2.0V_asic.png)

Connect GPIO3(R10) to pin G4 of your ESP32 and GPIO2(R7) to pin G5. Additionally connect your calculators + battery to the ESP32's 5V pin and your calculators - battery to your ESP32's GND pin.

## Software Instructions:

### Preparing your ESP32

- Connect your ESP32 to your PC and start up your Arduino IDE. It may be necessary to install drivers for your board for both your Operating System and for Arduino via the Boards Manager (under Tools->Board:).
- Open *src\arduino\ROMDUMP81.ino* and Upload it to your ESP32.
- Open the Serial Monitor from Tools->Serial Monitor and ensure it is set to 115200 baud.
- Press the physical RST button on your ESP32 (if it has one) to reset your board.
- The Serial Monitor should read: "TI-81 ROM Dumper ready - awaiting calculator."

Keep the Serial Monitor open as this is where the ESP32 will write the ROM data to.

### Preparing your TI-81

Follow the instructions specific to your ROM version:

#### ROM Version V1.0

Enter the below code into Prgm1 (Optionally name it ROMDUMP if you wish):
![](/res/V1.0_ROMDUMP.png)

#### ROM Version V1.1 - V1.8K

Enter the below code into Prgm1 (Optionally name it ROMDUMP if you wish):
![](/res/V1.1-V1.8K_ROMDUMP.png)

#### ROM Version V2.00 - V2.0V

Enter the below code into Prgm1 (Optionally name it ROMDUMP if you wish):
![](/res/V2.00-V2.0V_ROMDUMP.png)

### Preparing the ROM Dumper

Enter the below code into Prgm2 (Optionally name it LAUNCH if you wish):
![](/res/all_launch.png)

### Launching the ROM Dumper

Once you've entered the programs above (and double-checked them to be sure they are correct), do the following:

1. Turn the calculator off and back on.
2. Be sure the calculator is in Function mode.
3. Run Prgm1.
4. Run Prgm2. It will run for a little while and then display a question mark (?). Press 2nd CLEAR to exit the program.
5. Press Y= to open the equation editor. Press ENTER twice to move down to Y3.
6. Type lots and lots of garbage into Y3, until the calculator won't let you type any more. It's important that the equations be completely full.
7. Return to the home screen and run Prgm2 again. This time, when it displays a ?, type Y1 (2nd VARS 1 ENTER.)
8. The calculator will display an error message. Press ENTER again ("Goto Error") which should take you to the equation editor. Press 2nd CLEAR to return to the home screen. (Note: if you accidentally press CLEAR before pressing 2nd, thus deleting the contents of Y1, then immediately turn the calculator off, and start over with step 1.)
9. Repeat steps 7 and 8 four more times. The fifth time you run Prgm2, rather than displaying a ?, it will launch the ROM Dumper.

Once the ROM Dumper executes it will send data to the ESP32 which will be printed out in the Serial Monitor, this should take less than 15 seconds and should look similar to the following:  
TODO: [Image of ROM data in Serial Monitor]

If nothing happened or the Serial Monitor output looks corrupted I suggest:
- Double checking your solder connections for shorts
- Unplugging yor ESp32 to power down your TI-81
- Retyping in the Programs and trying again

To generate a ROM binary simply copy the data from the Serial Monitor and paste into a text file, then assemble as a raw binary with your favourite assembler.

If all went to plan then congratulations you have successfully backed up the ROM from your TI-81 calculator!

## BUGS!
This was a very quick hack-job of a project so there is the potential for bugs. Please be careful and let me know if you find anything ...

## Thanks
Special thanks goes to the amazing work by the pioneers of the 81 scene and those who helped me along the way:
Randy 'Zeroko' Compton  
Benjamin 'FloppusMaximus' Moody  
Adrien 'Adriweb' Bertrand  
Fred 'mr womp womp' Desautels  
Xavier 'critor' Andreani  
The creators of TilEm  
Everyone at Cemetech  
Everyone at TIPlanet  
And anyone else I forgot (please remind me)

## License
This project is licensed under the The Unlicense, see LICENSE for more details.
