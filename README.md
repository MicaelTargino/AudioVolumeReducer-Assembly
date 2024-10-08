# Audio Volume Reducer in Assembly

This project is the final submission for the Computer Architecture course at UFPB. It is an Assembly-based program designed to reduce the volume of mono-channel `.WAV` audio files by a user-defined constant.

## Features
- Reduces the volume of a mono-channel `.WAV` audio file by a constant between 1 and 10.
- Copies the header of the input file to the output file and processes the audio samples.
- Compatible with both MASM (Windows) and NASM (Linux) in 32-bit mode.

## Project Completion Checkpoints

1. ✅ **Basic Program Structure**: Create a 32-bit Assembly executable that runs without errors.
2. ✅ **Input Prompt**: Display prompts on screen for input (file names and volume constant).
3. ✅ **Input Handling**: Receive input from the user for the file names and volume reduction constant.
4. **File Handling**: Open the input file, read the 44-byte WAV header, and copy it to the output file.
5. **Audio Data Copy**: Read the audio data (in 16-byte chunks) and write it unaltered to the output file.
6. **Volume Reduction**: Implement volume reduction by dividing audio samples (2-byte WORD) by the user-defined constant.
7. **Function Refactoring**: Refactor the volume reduction logic into a separate function, as per the project requirements.
8. **Code Cleanliness**: Ensure the code is well-commented, organized, and efficient.

## How It Works
1. The program prompts the user for:
   - Input file name (WAV format, mono-channel)
   - Output file name
   - A constant for volume reduction (1-10)
2. It processes the audio data by dividing each audio sample by the constant, lowering the volume proportionally.
3. The output is saved in the specified file.
4. After processing, the user is asked whether to reduce the volume of another file.

## Usage
After running the program, provide:
1. The input file name (a `.WAV` file).
2. The output file name.
3. A volume reduction constant between 1 and 10.

The program will then process the file and save the modified audio.

## Notes
- The input and output files should be in the same directory as the executable.
- The program uses system calls for file handling and avoids external libraries.

## License
This project is for educational purposes and part of UFPB's Computer Architecture coursework.
