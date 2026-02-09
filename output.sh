#!/usr/bin/env python3
"""
Hex Dump Display Tool
Displays hex dump of a file line by line at high speed for testing OCR capture tools.
"""

import sys
import time
import argparse
import os


def clear_screen():
    """Clear the terminal screen"""
    os.system('cls' if os.name == 'nt' else 'clear')


def format_hex_line(offset, data, bytes_per_line=16):
    """
    Format a single line of hex dump in the style: 00000000: 7F D6 E4 E4 14 16 E9 19 ...
    
    Args:
        offset: Starting byte offset for this line
        data: Bytes to display on this line
        bytes_per_line: Number of bytes per line (default 16)
    
    Returns:
        Formatted hex dump line
    """
    # Format offset
    offset_str = f"{offset:08X}"
    
    # Format each byte as separate hex pair with spaces
    hex_bytes = [f"{byte:02X}" for byte in data]
    
    # Pad if necessary to reach 16 bytes
    while len(hex_bytes) < bytes_per_line:
        hex_bytes.append("  ")
    
    hex_part = " ".join(hex_bytes)
    
    return f"{offset_str}: {hex_part}"


def display_hex_dump(filepath, lines_per_second=4, bytes_per_line=16, clear_each_line=False, loop=False):
    """
    Display hex dump of a file line by line at specified speed.
    
    Args:
        filepath: Path to the file to dump
        lines_per_second: Number of lines to display per second
        bytes_per_line: Number of bytes per line
        clear_each_line: Whether to clear screen before each line (unused, always clears now)
        loop: Whether to loop the display indefinitely
    """
    try:
        with open(filepath, 'rb') as f:
            file_data = f.read()
    except FileNotFoundError:
        print(f"Error: File '{filepath}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)
    
    if len(file_data) == 0:
        print("Error: File is empty.")
        sys.exit(1)
    
    file_size = len(file_data)
    delay = 1.0 / lines_per_second
    
    # Brief info message before starting
    clear_screen()
    print(f"\nFile: {filepath}")
    print(f"Size: {file_size} bytes ({file_size / 1024:.2f} KB)")
    print(f"Speed: {lines_per_second} lines/second")
    print("\nStarting in 2 seconds...\n")
    time.sleep(2)
    
    while True:
        offset = 0
        
        while offset < file_size:
            clear_screen()
            
            # Add empty lines to center the hex line vertically
            print("\n" * 10)
            
            # Get the bytes for this line
            end_offset = min(offset + bytes_per_line, file_size)
            line_data = file_data[offset:end_offset]
            
            # Format and display the line (centered horizontally with spacing)
            hex_line = format_hex_line(offset, line_data, bytes_per_line)
            
            # Calculate centering (terminal width assumed ~80-120 chars, center around 60)
            spaces = " " * 20
            print(f"{spaces}{hex_line}")
            
            offset += bytes_per_line
            
            # Wait before next line
            time.sleep(delay)
        
        if not loop:
            break
        
        # Brief pause between loops
        time.sleep(0.5)


def main():
    parser = argparse.ArgumentParser(
        description='Display hex dump of a file line by line for OCR testing',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Display 4 lines per second (default)
  python hex_dump_display.py file.bin
  
  # Display 10 lines per second (faster)
  python hex_dump_display.py file.bin -s 10
  
  # Display 2 lines per second (slower, easier for testing)
  python hex_dump_display.py file.bin -s 2
  
  # Clear screen before each line (easier to capture single lines)
  python hex_dump_display.py file.bin -c
  
  # Loop indefinitely for continuous testing
  python hex_dump_display.py file.bin -l
  
  # Fast capture test: 20 lines per second
  python hex_dump_display.py file.bin -s 20
        """
    )
    
    parser.add_argument('file', help='File to display as hex dump')
    parser.add_argument('-s', '--speed', type=float, default=4.0,
                        help='Lines per second (default: 4.0)')
    parser.add_argument('-b', '--bytes-per-line', type=int, default=16,
                        help='Bytes per line (default: 16)')
    parser.add_argument('-c', '--clear', action='store_true',
                        help='Clear screen before each line')
    parser.add_argument('-l', '--loop', action='store_true',
                        help='Loop indefinitely')
    
    args = parser.parse_args()
    
    if args.speed <= 0:
        print("Error: Speed must be greater than 0")
        sys.exit(1)
    
    if args.bytes_per_line not in [8, 16, 32]:
        print("Warning: Recommended bytes-per-line values are 8, 16, or 32")
    
    try:
        display_hex_dump(
            args.file,
            lines_per_second=args.speed,
            bytes_per_line=args.bytes_per_line,
            clear_each_line=args.clear,
            loop=args.loop
        )
    except KeyboardInterrupt:
        print("\n\nInterrupted by user.")
        sys.exit(0)


if __name__ == '__main__':
    main()
