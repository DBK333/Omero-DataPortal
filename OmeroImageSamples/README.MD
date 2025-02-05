# **Microscopy Image Processing Workflow**

This repository contains a complete pipeline for processing **microscopy images** (including **CZI** and **Zarr** formats) and simulating a basic image processing workflow. All data in this repository, including **CZI** files and clinical metadata, is **synthetically generated** or modified for **testing and educational purposes** only.

## **Purpose**

This repository demonstrates a basic image processing workflow involving the following steps:

1. **Preprocessing**:

   - **Deskewing**: Correcting any skew in the images that may have resulted during the image acquisition process.
   - **Deconvolution**: Improving the sharpness and quality of the microscopy images.
   - **Downsampling**: Reducing the resolution of the images for storage and processing optimization.
   - **Metadata Extraction**: Extracting metadata from **CZI** or **Zarr** files and associating it with clinical sample information (such as **patientID** and **sampleID**).

2. **Data Conversion**:

   - **CZI to Zarr**: Converting **CZI** files (Zeiss microscopy files) into the **Zarr** format for efficient storage and processing.

3. **Archiving**:

   - Compressing processed image files for storage or transfer.

This workflow serves as a foundational pipeline for more complex bioinformatics and image processing applications.

## **Repository Structure**

- `main.py`: The main Python script that includes all steps for converting **CZI** files to **Zarr** format, preprocessing the images (deskew, deconvolve, downsample), and visualizing the processed images.
- `ExternalMetadata_SampledClinicalData_Omero.csv`: A CSV file containing **synthetic clinical metadata** used for linking image data with sample and patient information.
- `README.md`: This file, providing documentation for the repository.

## **Usage**

### 1. **Clone the Repository**:

```bash
git clone <repository_url>
cd <repository_name>
```

### 2. **Running the Full Workflow**:

The full pipeline, including both the **conversion** of **CZI** files to **Zarr** format and **image preprocessing**, can be run with a single command from `main.py`:

```bash
python main.py
```

### 3. **How the Workflow Works**:

- **CZI to Zarr Conversion**: The script will load **CZI** files and convert them to **Zarr** format for easier processing and storage.
- **Preprocessing**: After converting to Zarr, the script will:
  - **Deskew** the images to correct any distortions.
  - **Deconvolve** the images to improve image clarity.
  - **Downsample** the images to reduce resolution for storage efficiency.
- **Output**: Processed images will be saved in the specified output directory.

### 4. **Viewing the Images**:

After preprocessing, you can visualize the processed **Zarr** images using the following code snippet:

```python
import napari
import zarr

# Path to the processed Zarr file
zarr_file_path = '/path/to/processed_image.zarr'
data = zarr.open(zarr_file_path, mode='r')

# Start the napari viewer and display the image
viewer = napari.view_image(data)
napari.run()
```

This will open the processed images in **napari**, where you can interactively explore them.

## **Data Management Recommendations**

1. **Raw Data Storage**:

   - It is recommended to store the raw data (e.g., CZI files) as a baseline for reproducibility. If raw data is too large (e.g., 500 GB), consider downsampling it for testing and archival purposes.

2. **Processing**:

   - Use the provided processing scripts to perform deskewing, deconvolution, and other preprocessing steps. Note that processed data can become significantly larger (e.g., a 500 GB raw dataset may expand to 700 GB after processing).

3. **Summarized Data**:

   - Instead of storing the full deskewed or deconvolved images, save summarized data to reduce storage requirements. Summarized data could include key metrics, visualizations, or compressed outputs.

4. **Access and Testing**:

   - The raw data, processing scripts, and summarized data are available on [Zenodo]\(link to Zenodo). Users are encouraged to download downsampled versions of the raw data for testing purposes.

### **Zenodo Repository Contents**

- **Raw Data**: Includes the original microscopy data (CZI files).
- **Processing Scripts**: Python scripts for deskewing, deconvolution, and summarization.
- **Summarized Data**: Compressed or reduced-resolution outputs of the processed images.

## **Important Notes on Data Privacy and Usage**

**All data in this repository is synthetic and does not represent any real biological or personal data. It is used solely for educational purposes and software development. No sensitive or personally identifiable data is involved in this project.**

---

## **Image Processing Details:**

1. **Deskewing**: This step corrects any skew or tilt in the images due to the imaging system.
2. **Deconvolution**: A process that improves the clarity and sharpness of the images, reducing blur and enhancing details.
3. **Downsampling**: Reduces the resolution of the images for quicker processing, especially for large datasets.

---

### **Summary of Key Steps**:

- **Run the workflow**: `python main.py` to convert **CZI** files to **Zarr** and preprocess the images (deskew, deconvolve, downsample).
- **View the images**: Visualize the processed images using **napari**.
- **No configuration needed**: All settings are handled within `main.py`.
