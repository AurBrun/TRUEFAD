# TRUEFAD, TRUE Fiber Atrophy Distinction
## 17MAR25 note about recent DeepImageJ update > TRUEFAD 2.0 is now in construction with more features, better built in functionnalities and adpatability. In waiting here is a fix for TRUEFAD Cells DeepImageJ call once you unzipped and installed the model:
`Go to Plugin > DeepImageJ > Create Macro, then tick "Display Output", copy the call underneath and paste it inplace to the line 123 of your TRUEFAD macro code.`

# | Youtube video presentation & tutorial |
[![](https://github.com/AurBrun/TRUEFAD/blob/main/dev/Thumbnail.png?raw=true)](https://youtu.be/4vMrz28spzo)

## Description
TRUEFAD is a composition of two FIJI/ImageJ macros designed to analyze two-dimensional images of muscle cells: TRUEFAD-Histo and TRUEFAD-Cells. TRUEFAD allows the automatization of morphological measurements from phase contrast images of C2C12 as well as human myotubes (TRUEFAD-Cells), and fluorescent laminin-dystrophin images of muscle cross sections (TRUEFAD-Histo). 

TRUEFAD-Cells relies on a U-Net deep learning model trained with ZeroCostDL4Mic online [notebooks](https://github.com/HenriquesLab/ZeroCostDL4Mic/wiki). 

![Figure 1 - TRUEFAD Cells workflow 14 12 22](https://github.com/AurBrun/TRUEFAD/assets/97951288/626bdd34-407c-485c-8d3e-4c356e98e946)

TRUEFAD-Histo is a non-deep learning tool with comparable results on laminin segmentation with state-of-the-art deep learning methods such as Cellpose.

![Figure 4 - TRUEFAD Histo workflow 25 01 23](https://github.com/AurBrun/TRUEFAD/assets/97951288/65ad8919-23a3-4c84-a6a9-a7cbe53308ce)

## Installation

Requirements:
- Windows 10 (Linux interoperability seems to be failing due to latency issues)
- Up-to-date [FIJI/ImageJ2](https://imagej.net/software/fiji/downloads)
- The following FIJI plugins:
  - CSBDeep
  - DeepImageJ
  - IJPB plugins
  - ReadAndWriteExcel
  - Tensorflow 
  
To install the previous FIJI plugins, do the following:
- Select *Help>Update...*.
- Select *Manage update sites*.
- Tick *CSBDeep*, *DeepImageJ*, *IJPB-plugins*, *ResultsToExcel*, and *TensorFlow*.
- Select *Close*
- Select *Apply Changes*, wait for the install to finish
- Go to Edit > Options > TensorFlow and install the CPU version that is equal or above 1.15
- **Restart FIJI/ImageJ**.

You can now download TRUEFAD by clicking on this [link](https://github.com/AurBrun/TRUEFAD/archive/refs/heads/main.zip) (or by clicking on the green button above named "*<> Code*" and then on *Download ZIP* or by using git and the following command: `git clone https://github.com/AurBrun/TRUEFAD.git`). Unzip the .ZIP file to your favorite location.

To use TRUEFAD-Cells, the trained deep learning model must be installed in DeepImageJ. The deep learning model is named `TRUEFAD Myotube detection.zip` in the folder you just unziped. To install the deep learning model you must then:
- Open DeepImageJ installation plugin in FIJI/Imagej: select *Plugins > DeepImageJ > DeepImageJ Install Model*.
- In the DeepImageJ interface, select *Private Model* tab.
- Tick *From ZIP file* and fill the blank with the path of your `TRUEFAD Myotube detection.zip` model. For example: `D:\JeanPignon\TRUEFAD Myotube detection.zip`.
- Tick the box stating that *I accept to install the model...* (we promise that our model is safe to install :blush:) and select *Install*.

## Usage
### TRUEFAD-Cells 

Input image                |  TRUEFAD-Cells output
:-------------------------:|:-------------------------:
![](dev/illustration.png)  |  ![](dev/illustration_output.png)

To start TRUEFAD-Cells, do:
- Drag and drop the `TRUEFAD-Cells DL - 06.09.23.ijm` file into FIJI. The FIJI macro editor should appear. 
- Click on the "Run" button.
- After the "Requirement" window, select your properties for the image preprocessing and segmentation as well as the myotube retention parameters:
  - "Rate the performance of your machine": This highly subjective parameter creates artificial delays inversely proportionate to the grading of your machine's performance to let the time for Java and some plugins load correctly in FIJI.
  - "Border siding the DL prediction": This is the number of pixels that the thresholded prediction will be enlarged to run the subsequent filters
  - "Remove noise on myotube prediction": Decrease this parameter to increase the noise on the rest of the image that is not a prediction (noise prevents watershed from creating false myotubes in a non-prediction area).
  - "Segmentation tolerance": Parameter used for watershed extended minima-based segmentation (see Morphological segmentation https://imagej.net/plugins/morpholibj).
  - "Set scale (pix/µm)": Needs to be adapted to the image resolution to allow label filtering.
  - "Min/Max label area" and "Label maximum elongation": These criteria define the label retention to obtain definitive myotubes.
  - "Detailed measures": Export each of the nine diameter measurements for each myotube detected in the Excel file instead of the mean diameter
- Select your first directory corresponding to your batch of images (you can go up to 1000 images)
- Select another directory for results export
### Macro should be starting ###
- At the end of the analysis, a few windows open, please click on « ok » for each.
- Results (Label JPG image, ROI zip folder) could be found in the "Result" path previously selected by the user. A detailed quantified output could be found as an Excel file "rename me after writing is done" saved on the computer desktop according to the Read&WriteExcel plugin.
-We recommend checking all images for consistency in segmentation. If not, rerun TRUEFAD with different settings.
You can try TRUEFAD-Cells on our example image located in the *TRUEFAD\example* folder. For this example, you can use the default parameter values. After execution, you should find an Excel sheet on your Desktop storing the TRUEFAD-Cells metrics. 

Be aware that TRUEFAD-Cells has been made for square images only so all input images will be automatically cropped to a square before treatment and the rest of the image will be ignored.

We recommend using grey scale 8-BIT images captured on positive phase contrast with x10 magnification of around 2000x2000 pixel resolution

### TRUEFAD-Histo

To start TRUEFAD-Histo, do:
- The first step is to create on your computer one folder for each fluorescence channel, depending on the type of analysis to be carried out (see choices below). For example, if laminin, BAF8, and SC71 fluorescence are going to be analyzed, you need 3 distinct folders containing the corresponding 8-BIT single channel image with the same filename per original field (ex « sample1.tif » in folder laminin/dystrophin, « sample1.tif » in folder BAF8, and « sample1.tif » in folder SC71). Only 8-BIT image files to be analyzed should be found in folders. An additional empty folder must be created for result files. In the following procedure and current version of TRUEFAD, the default fluorescence is laminin for fiber segmentation, BAF8 for type I, and SC71 for type IIA labeling respectively (other labeling depending on your protocol should be tested, and could be used instead). 
- Drag and drop the `TRUEFAD-Histo V1.6 - 30.10.23.ijm` file into FIJI. The FIJI macro editor should appear. 
- Click on the "Run" button. 
- Four options are available, depending on the objective of the analysis (see the main manuscript for further details) :
  - « Work on a label image » 
  - « Segmentation of laminin image » to segment fibers using laminin (or other). In this case, only one folder is necessary. 
  - « Type attribution Laminin+Type1+Type2A ». Includes segmentation + labeling of type I and type IIA fibers (as explained in the manuscript).
  - « Type attribution Laminin+Type1+Type2A(+Type2X). Includes segmentation + intensity measurement of each fluorescence 3 different channels in the same pipeline.
- You will get several windows to select the paths for the folders corresponding to each labeling (laminin, BAF8, and SC71 following the order specified in the name of the windows).
- Step 3: It is here possible to adjust the probability threshold to assign fiber to type I or IIA. We recommend that you keep the default parameter but adjustments may be necessary depending on the quality of the image acquisition. A few images from a batch may be firstly checked manually using a different threshold and rerun TRUEFAD.
- Step 4: Different parameters can be adapted here to adjust the resulting segmentation, fiber retention, and results export
  - "Boost Type I" or "Boost Type IIA": To increase artificially the signal contrast of the respective fluorescence channel
  - "Artificially enhance edges": To use systematically the "Find edges" FIJI filter to artificially enhance laminin/dystrophin contrast
  - "Directional median filter": Use MorpholibJ directional median filters to close laminin gaps and heterogeneity of fiber borders signal (more = more corrections and more artifacts)
  - "Tolerance": Parameter used for watershed extended minima-based segmentation (see Morphological segmentation https://imagej.net/plugins/morpholibj)
  - "Min/Max label area" "Label maximum elongation" and "Label Erosion": These criteria define the label retention to obtain definitive muscle fiber
  - "Manually edit label post-filtering": This tickbox allows the user to switch from a fully automatic analysis to a semi-auto analysis with a GUI designed to help the user remove non-desired labels
  - "Save automatically label map / ROIs"
  - "Set scale (pix/µm)": Needs to be adapted to the image resolution to allow label filtering
  - "Rate the performance of your machine": This highly subjective parameter creates artificial delays inversely proportionate to the grading of your machine's performance to let the time for Java and some plugins load correctly in FIJI.
  - "Enable batch mode": Tick to let the plugin run in silent mode (not recommended) or untick to show each step of the image processing
### Macro should be starting ###
- At the end of the analysis, a few windows open, please click on « ok » for each.
- Results (TIF label map, Composite JPG image, ROI zip folder) could be found in the "Result" path previously selected by the user. A detailed quantified output could be found as an Excel file "rename me after writing is done" saved on the computer desktop according to the Read&WriteExcel plugin.
-We recommend checking all images for consistency in segmentation and fiber type identification. If not, rerun TRUEFAD with different settings.

### TRUEFAD Histo K-mean Clustering ###
After your file is exported, we recommend you clean your raw data by removing lanes of falsely discovered fibres while keeping the file structure identic (sort by count for each block of data once done)
- You can now start using the TRUEFAD Histo Clusterization program we developed for both pipeline 3 (Type I and Type IIA) and pipeline 4 (Type I, Type IIA and Type IIB or X)
 - Option1: Download directly the portable executable version for [Pipeline_3.exe](https://drive.uca.fr/f/4fad7ce193c04396b520/?dl=1) or for [Pipeline_4.exe](https://drive.uca.fr/f/38d94170dc3f49a0b38a/?dl=1)
 - Option2: Download and install Python 3.10, OpenPyXL, Tkinter, Pandas, SKlearn, and Numpy as well as an interpreter. Open and run the corresponding Python script that is found in the main branch [Pipeline_3.py](https://github.com/AurBrun/TRUEFAD/blob/main/TRUEFAD-Histo-Pipeline3-K_mean_Clustering_V1.3.py) or [Pipeline_4.py](https://github.com/AurBrun/TRUEFAD/blob/main/TRUEFAD-Histo-Pipeline4-K_mean_Clustering_V1.3.py)
- Once executed, the program will start. You may have to wait for a minute until it finishes to load all the imports.
- A window will appear and ask you what size and roundness filter you want to apply to the data.
- You should give the number of clusters (fiber classes) you want the K-mean clustering to find on your dataset.
- Once the Excel file is selected, you should press "read" and wait.
- The program should by itself identify the number of data blocks and process it block by block, it should print the name of the image (and block of data) that was successfully clusterized
- Once all images have been clusterized, the program will export the metrics and format a new Excel file that will also be exported

Whenever the program is done, it should print "JOB DONE" in the log and you should find your resulting Excel file on your desktop
- The first sheet of the resulting Excel presents all the clusterization metrics for each image block (Silhouette score, Davies Bouldin, Calinski Harabasz, Inertia)
- The second sheet will export the raw entry data as a backup
- The third sheet will show you the filtered dataset that was clusterized. Each of the blocks was appended with one column containing as header the name of the image and then the clusterization that was made.

K-Mean clustering is a random clusterization method initiated for each image block. The label assigned to each of the fiber will have to be associated with your fiber type of interest based on image matching.
To reformulate it, as the clusterization process is random, the Type I fibers on your image_1 might be assigned as "0" while Type I fibers on your image_2 might be assigned as "2". The clusterization method will still offer the most robust way to get automatically supervised fiber type attribution, whenever your image has a high background or low signal. It will classify your fibers by groups based on best inner-cluster cohesion and inter-cluster separation.

## Deep learning model training

This section is addressed to developers who would like to get more details about our deep learning model training or who intend to reproduce the results presented in our publication. This section is thus not needed for users only.

The deep learning model has been trained using ZeroCostDL4Mic [notebooks](https://github.com/HenriquesLab/ZeroCostDL4Mic/wiki). We provide a copy of both our training/validation datasets and our deep learning model obtained with ZeroCostDL4Mic in our [release tagged 'data&model'](https://github.com/AurBrun/TRUEFAD/releases/tag/data%26model). As the notebooks may change on the ZeroCostDL4Mic website, we also provide in the `dev` folder the original `.ipynb` notebook we used to train our deep learning model. 

## Citation - Please cite our work if it contributed to your research
The original TRUEFAD publication is accessible on : https://www.nature.com/articles/s41598-024-53658-0 
Brun, A., Mougeot, G., Denis, P. et al. A new bio imagery user-friendly tool for automatic morphometry measurement on muscle cell cultures and histological sections. Sci Rep 14, 3108 (2024). https://doi.org/10.1038/s41598-024-53658-0

## Acknowledgments and Funding
### Authors and Affiliations
- UMR1019 Unité de Nutrition Humaine (UNH), INRAE, Université Clermont Auvergne, Clermont-Ferrand, France
Aurélien Brun, Philippe Denis, Marie Laure Collin, Christophe Montaurier, Stéphane Walrand, Frédéric Capel & Marine Gueugneau
- iGReD CNRS, INSERM Université Clermont Auvergne, Clermont-Ferrand, France
Guillaume Mougeot & Pierre Pouchin

We thank J.P. Rigaudière, J. Salles, A. Pinel, O. Le Bacquer, M. Rambeau, P. Sanchez, L. Guerrier, J. Touron, C. Barbé for their contribution to manually measured C2C12 myotube diameter for the training step of the deep learning model. we thank also C. Coudy-Gandhilon for giving sample images. Aurélien Brun was supported by a funding from Clermont-Auvergne Metropole. The work was supported by a grant from the Société Française de Nutrition Clinique et Métabolisme and Promega (Prix jeunes chercheurs 2022).

## Next updates ...
- Migration from IJM to Python/Jython for better support
- TRUEFAD histo will directly implement K-mean clusterization algorithm
- More task will be done by TRUEFAD histo related to other common muscle staining
- TRUEFAD cells model should be moving from Semantic to Instance segmentation with new training capacities and myoblast detection  
- TRUEFAD cells diameter measurement algorithms will be simplified and more robust
