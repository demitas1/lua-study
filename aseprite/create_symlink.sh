#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/your/file"
    exit 1
fi

# Convert the provided file path to an absolute path
file_path=$(realpath "$1")

# Extract the filename from the provided file path
file_name=$(basename "$file_path")

# Variables
link_dir="$HOME/.config/aseprite/scripts"
link_path="$link_dir/$file_name"

# Check if the provided file path exists
if [ ! -e "$file_path" ]; then
    echo "Error: The file $file_path does not exist."
    exit 1
fi

# Check if the link directory exists and is a directory
if [ ! -d "$link_dir" ]; then
    echo "Error: The directory $link_dir does not exist."
    exit 1
fi

# Check if the link path exists and is not a symbolic link
if [ -e "$link_path" ] && [ ! -L "$link_path" ]; then
    echo "Error: A file or directory with the name $file_name already exists in $link_dir."
    exit 1
fi

# Check if the symbolic link exists
if [ -L "$link_path" ]; then
    # Check if the existing link points to the correct file
    if [ "$(readlink "$link_path")" != "$file_path" ]; then
        echo "Error: A symbolic link exists, but it does not point to $file_path."
        exit 1
    else
        echo "The symbolic link already exists and points to the correct file."
    fi
else
    # Create the symbolic link
    ln -s "$file_path" "$link_path"
    echo "Symbolic link created: $link_path -> $file_path"
fi

