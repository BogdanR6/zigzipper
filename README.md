# ZigZipper

ZigZipper is a simple file compression and decompression tool written in Zig. It is a rewrite of my previous project, **Zipper**, which was originally implemented in C. This project serves as an exercise in learning Zig while improving upon the original design.

## Features
- Basic run-length encoding compression
- Efficient file handling using Zig's standard library
- Memory-safe design using Zig's allocator system

## Requierments
- zig >= 0.14.0 

## Compiling 
```sh
zig build-exe zipper.zig
```

## Usage
```sh
./zipper <zip/unzip> <input_file> <output_file>
```
- `zip` - Compresses the given input file and writes the compressed output to the specified file.
- `unzip` - Decompresses a previously compressed file and restores the original data.

### Example
```sh
./zipper zip input.txt compressed.zz
./zipper unzip compressed.zz output.txt
```

## Improvements That Can Be Made
- **Buffered I/O**: Instead of reading and writing byte-by-byte, using buffered reads and writes would enhance performance, especially for large files.
- **Command-line Argument Parsing**: A more robust argument parser could make handling user input cleaner and more flexible.
- **Error Handling Improvements**: Some parts of the error handling could be refined to give clearer error messages and avoid unnecessary allocations.
- **Benchmarking and Profiling**: Measuring performance and optimizing critical sections could make the tool faster.

## Author
**Bogdan Rares**

This project is a work-in-progress and an educational exercise in learning Zig. Feedback and suggestions are always welcome!

