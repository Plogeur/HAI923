#!/bin/bash

# This is a pipeline in bash that detect animal then crop it and increase the img size.
# He takes as argument a folder path which contains dataset classes containing images.
# He use a pre-trained YOLOv8x object detection model and moves the resulting
# crop images to a new dataset directory organized by class subdirectories.

# Prerequis object detection : 
    # pip3 install ultralytics

# Prerequis upscaler : 
    # git clone https://github.com/hollowaykeanho/Upscaler.git
    # brew install node
    # brew install ffmpeg
    # brew install ffprobe

# Exemple : ./pipeline.bash -i fox -o CropFox -S 128 -u 4

# Initialize variables with default values
Input_file=""
Output_file=""
MinScale=64
ScaleChange=false
Upscale=4
image_path=""

# Initialize counter variables with default values
DetectedObject=0
FailDetection=0
DeletedImage=0

# Define usage function to display usage instructions
usage() {
    echo "Usage: $0 -i <input_file>"
    echo "        -i or -I <input_file>    Input file"
    echo "        -o or -O <output_file>   Output file, default/no argument : Crop_dataset_<input_file>"
    echo "        -s or -S <minimum_scale> Minimun scale for detected animal in the object detection step 
                                 (minimum resolution = minimun scale * minimun scale). 
                                 default/no argument : the most higher resolution picture 
                                 in the detected animal picture"
    echo "        -u or -U <upscale_size>  Upscale size that will be applyed to the upscaling step, 
                                 if u=1 there will be no upscaling 
                                 (u∈[1;4]). default/no argument : u=4"
    echo "        -h or -H                 Display this help message"
    exit 1
}

# Parse command-line arguments
while getopts "i:I:o:O:s:S:u:U:hH" opt; do
  case $opt in
    i | I) # input dir
      Input_file="$OPTARG"
      ;;
    o | O) # output dir
      Output_file="$OPTARG"
      ;;
    s | S) # minimun scale picture
      MinScale="$OPTARG"
      ScaleChange=true
      ;;
    u | U) # upscale size
      Upscale="$OPTARG"
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

# Check if the file Upscaler/start.cmd is on the directory
if [ ! -e "./Upscaler/start.cmd" ]; then
  echo "File Upscaler/start.cmd does not exist in the directory."
  exit 1
fi

# Check Minimum scale arguments
if [ "$MinScale" -le 0 ] || [ "$MinScale" -gt 1081 ]; then
  echo "Error: MinScale must be between 1 and 1080"
  exit 1
fi

# Check if required arguments are provided
if [ "$Upscale" -le 0 ] || [ "$Upscale" -gt 5 ]; then
  echo "Error: Upscale must be between 1 and 4"
  exit 1
fi

# Check if the directory exists and no empty
if [[ ! -d "$Input_file" ]]; then
  echo "Error: Directory not found"
  exit 1
fi

if [ -z "$(ls -A "$Input_file")" ]; then
  echo "Error: Directory is empty"
  exit 1
fi

# Find the higher resolution animal pictures that is crop by yolo
function higher_resolution() {
    local max_resolution=0
    local highest_resolution_image=""
    local list_images=""

    # Use find to locate all image files in the source directory
    while IFS= read -r image; do
        DetectedObject=$((DetectedObject + 1))
        # Use identify from ImageMagick to get the resolution
        resolution=$(identify -format "%w:%h" "$image")

        # Split the resolution into width and height
        IFS=":" read -r width height <<< "$resolution"

        # Calculate the product of height and width
        resolution_product=$((width * height))

        if [[ $resolution_product -gt $((MinScale * MinScale)) ]]; then
          list_images+="$image"
          # Compare the resolution product with the current highest resolution
          if ((resolution_product > max_resolution)); then
              max_resolution=$resolution_product
              highest_resolution_image="$image"
          fi
        fi 
    done < <(find "$1" -type f -iname '*.jpg')

    if [ "$ScaleChange" = true ]; then
      image_path="$highest_resolution_image"
      else 
      image_path="$list_images"
    fi 
}

# Upscaled image size
function uspcaling() {
    mkdir -p "Upscaled_dataset_$Input_file"
    for picture in $Input_file/*; do
        if [ -f "$picture" ]; then
            Upscaler/start.cmd --model upscayl-ultrasharp-v2 --scale $Upscale --format jpg --input $picture #-update -frames:v 1
            picture_without_extension=$(basename "$picture" .jpg)
            mv "$Input_file/$picture_without_extension-upscaled.jpg" "Upscaled_dataset_$Input_file/"
            rm -r "$Input_file/$picture_without_extension-upscaled_workspace/"
        fi
    done
}

# Move crop or upscale picture to output dir
function move() {
    if [[ "$Output_file" == "" ]]; then
        mkdir -p "Crop_Dataset_$Input_file"
        for element in "$image_path"; do
            mv "$element" Crop_Dataset_$Input_file/Crop_$num.jpg
        done
    else
        mkdir -p "$Output_file"
        for element in "$image_path"; do
            mv "$element" $Output_file/Crop_$num.jpg
        done
    fi
}

# Crop animal object in picture
function croping() {
    local num=0
    for picture in "Upscaled_dataset_$Input_file"/*; do
        local SaveDetectionObject=$DetectedObject
        yolo predict model=yolov8x.pt source="$picture" save_crop
        source_directory="runs/detect/*/crops/*/*"
        higher_resolution $source_directory
        # Fail detection so move the Upscale picture
        if [[ $SaveDetectionObject -eq $DetectedObject ]]; then 
            FailDetection=$((FailDetection + 1))
            image_path=$picture
        fi
        DeletedImage=$((DeletedImage + DetectedObject - DeletedImage - $(echo "$image_path" | wc -w)))
        move 
        rm -r runs/detect/
        num=$((num + 1))
    done
}

main() {
  if [[ "$Upscale" != 1 ]]; then
    uspcaling
  fi
  croping

  echo "#######################################################################"
  echo "Number of object detected : $DetectedObject"
  echo "Number of fail detection (0 object detected in a picture) : $FailDetection"
  echo "Number of deleted picture in the resolution selection : $DeletedImage"
  echo "#######################################################################"
}

main
