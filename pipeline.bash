#!/bin/bash

# This is a pipeline in bash that detect animal then crop it and increase the img size.
# He takes as argument a folder path which contains dataset classes containing images.
# He use a pre-trained YOLOv8x object detection model and moves the resulting
# crop images to a new dataset directory organized by class subdirectories.

# Usage: ./yolo_pipeline.bash <path_directory>
# Prerequis object detection : 
    # pip3 install ultralytics
    
# Prerequis upscaler : 
    # git clone https://github.com/hollowaykeanho/Upscaler.git
    # brew install node
    # brew install ffmpeg
    # brew install ffprobe

# Initialize variables with default values
Input_file=""
Output_file=""
MinScale=64
Upscale=4
Change=false

# Define usage function to display usage instructions
usage() {
    echo "Usage: $0 -i <input_file>"
    echo "-i or -I <input_file>    Input file"
    echo "-o or -O <output_file>   Output file, default/no argument : Crop_dataset_<input_file>"
    echo "-s or -S <minimum_scale> Minimun scale for detected animal in the object detection step (minimum resolution = minimun scale * minimun scale). default/no argument : the most higher resolution picture in the detected animal picture"
    echo "-u or -U <upscale_size>  Upscale size that will be applyed to the upscaling step, if u=1 there will be no upscaling (u∈[1;4]). default/no argument : u=4"
    echo "-c or -C                 Change the order of the tools, default/no argument : uspcaling => croping "
    echo "-h or -H                 Display this help message"
    exit 1
}

# Parse command-line arguments
while getopts "iI:oO:sS:uU:hHcH" opt; do
  case $opt in
    i | I) # input dir
      Input_file="$OPTARG"
      ;;
    o | O) # output dir
      Output_file="$OPTARG"
      ;;
    s | S) # minimun scale picture
      MinScale="$OPTARG"
      ;;
    u | U) # upscale size
      Upscale="$OPTARG"
      ;;
    c | C) # upscale size
      Change=true
      ;;
    h | H)
      usage
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done

# Check if required arguments are provided
if [ -z "$Input_file" ]; then
  echo "Input file are required."
  usage
fi

# Check if the directory exists
if [[ ! -d "$Input_file" ]]; then
    echo "Error: directory not found"
    exit 1
fi

# Find the higher resolution animal pictures that is crop by yolo
function higher_resolution() {
    local source_directory="$Input_file"
    local max_resolution=0
    local highest_resolution_image=""

    # Use find to locate all image files in the source directory
    while IFS= read -r image; do
        # Use identify from ImageMagick to get the resolution
        resolution=$(identify -format "%w:%h" "$image")

        # Split the resolution into width and height
        IFS=":" read -r width height <<< "$resolution"

        # Calculate the product of height and width
        resolution_product=$((width * height))

        # Compare the resolution product with the current highest resolution
        if ((resolution_product > max_resolution)); then
            max_resolution=$resolution_product
            highest_resolution_image="$image"
        fi
    done < <(find "$source_directory" -type f -iname '*.jpg')

    echo "$highest_resolution_image"
}

function uspcaling() {
    # Create Increased_dataset directory
    mkdir -p "Upscaled_dataset_$Input_file"

    # Upscaled image size
    for picture in $Input_file/*; do
        Upscaler/start.cmd --model upscayl-ultrasharp-v2 --scale $Upscale --format jpg --input $picture
        picture_without_extension=$(basename "$picture" .jpg)
        mv "$Input_file/$picture_without_extension-upscaled.jpg" "Upscaled_dataset_$Input_file/$picture_without_extension-upscaled.jpg"
        rm -r "$Input_file/$picture_without_extension-upscaled_workspace"
    done
}

function croping() {
    # Create Crop_dataset directory
    if [[ "$Output_file" == "" ]]; then
        mkdir -p "Crop_dataset_$Input_file"
    else
        mkdir -p "$Output_file"
    fi
    
    # Crop animal object in picture
    for picture in "Upscaled_dataset_$Input_file"/*; do
        yolo predict model=yolov8x.pt source="$picture" save_crop
        source_directory="runs/detect/*/crops/*/*"
        image_path=$(higher_resolution $source_directory)
        mv "$image_path" Crop_dataset_$Input_file/
        rm -r runs/detect/
    done
}

main() {
    if [[ "$Change" == false]]; then
        uspcaling
        croping
    else
        croping
        uspcaling
    fi
}

main