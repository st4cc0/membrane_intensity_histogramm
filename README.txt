README  extract_histogram
Script Overview

This MATLAB script processes .tif image files in a specified directory to extract histogram data from the images and save the results in a structured format. It performs the following key tasks:

    Reads .tif files from a root directory.
    Processes each image to compute histograms of pixel intensities.
    Applies optional ROI (Region of Interest) selection and histogram filtering.
    Exports histogram data to CSV files for further analysis.

Prerequisites

    To run code: MATLAB installed on your system.
    The Image Processing Toolbox enabled.
    A folder containing .tif files (./01_max_intensity_input).

Directory Structure

    Input Folder: 01_max_intensity_input/
    Contains .tif image files for processing.

    Output Folder: 02_count_hist_output/
    Stores the histogram data for each processed image stack.

How It Works
Input

    All .tif files in the 01_max_intensity_input/ directory are read.
    Each .tif file is assumed to be a stack of images.

Processing

    Each image stack is processed slice by slice:
        Histogram Computation: Calculates a histogram of pixel intensities for the entire image or specific ROIs.
        Background Filtering: Applies a high-pass filter to remove background noise from the histogram data.
        Data Export: Saves histogram data as .csv files.

    Region of Interest (ROI) Options:
        "all": Processes all identified regions in the image.
        "max": Processes only the largest region.

Output

For each .tif file:

    Creates a folder in 02_count_hist_output/ with the same name as the input file.
    Exports CSV files for each slice in the stack containing:
        Histogram bins.
        Pixel counts per bin.
        Background-filtered histogram values.

Key Functions

Helper Function: get_rois_histogram

    Inputs:
        img: Image matrix.
        hist_bins_n: Number of histogram bins (default: 216216).
        roi_selection_case: ROI selection strategy ("all" or "max").

    Outputs:
        bins: Histogram bin centers.
        this_counts: Raw histogram counts.
        bg_filtered: Background-filtered histogram counts.

    Functionality:
        Binarizes the image and identifies regions.
        Computes histograms for selected ROIs.
        Applies background filtering to smooth histograms and reduce noise.

How to Use

    Place .tif files in the 01_max_intensity_input/ directory.
    Run the script in MATLAB/standalone .exe.
    Processed histogram data will be saved in the 02_count_hist_output/ directory.

Customization

    Adjust Evaluation Range: Modify evaluation_range in the script to process specific slices from the image stack.
    Change ROI Selection: Update roi_selection_case in get_rois_histogram to switch between "all" and "max".
    Tweak High-Pass Filter: Modify order and cut_off in get_rois_histogram for different background filtering behavior.

Example Output

For an input .tif file named sample.tif with 10 slices, the script will:

    Create a folder: 02_count_hist_output/sample/.
    Export CSV files: t_001.csv, t_002.csv, ..., t_010.csv.

Each CSV file contains:

    bins: Histogram bin centers.
    counts: Pixel intensity counts.
    smooth_counts: Filtered histogram counts.

Notes

    Ensure that input images are grayscale .tif files.
    Output directories are created automatically if they do not exist.

Troubleshooting

    Error: Missing 02_count_hist_output directory: Ensure you have write permissions in the working directory.
    Empty Output Files: Verify the input .tif files contain valid image data.
    Incorrect ROIs: Check the binarization and region detection parameters in get_rois_histogram.

License

CC-BY 4.0