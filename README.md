# TRUEFAD, TRUE Fiber Atrophy Distinction

TRUEFAD is a composition of two FIJI/ImageJ macros designed for the analysis of two-dimensional images of muscle cells: TRUEFAD-Histo and TRUEFAD-Cells. TRUEFAD provides morpholigical metrics for phase contrast images of both myotubes (TRUEFAD-Cells) and laminin (TRUEFAD-Histo). TRUEFAD-Cells relies on a U-Net deep learning model trained with ZeroCostDL4Mic online [notebooks](https://github.com/HenriquesLab/ZeroCostDL4Mic/wiki). TRUEFAD-Histo is a non-deep learning tool with comparable results on laminin segmentation with state-of-the-art deep learning methods such as Cellpose.

## Installation

Requirements:
- Windows 10 (we did not try other OS so we cannot guarantee that TRUEFAD apps are going to work on those)
- Up-to-date [FIJI/ImageJ2](https://imagej.net/software/fiji/downloads)
- The following FIJI plugins:
  - DeepImageJ
  - MorphoLibJ
  - ReadAndWriteExcel 
  
To install the previous FIJI plugins, do:
- Select *Help>Update...*.
- Select *Manage update sites*.
- Tick *DeepImageJ*, *IJPB-plugins* and *ResultsToExcel*.
- Select *Close*
- Select *Apply Changes*, wait for the install to finish and **restart FIJI/ImageJ**.

You can now download TRUEFAD by clicking on this [link](https://github.com/AurBrun/TRUEFAD/archive/refs/heads/main.zip) (or by clicking on the green button above *<> Code* and then on *Download ZIP* or by using git and the following command: `git clone https://github.com/AurBrun/TRUEFAD.git`). Unzip the .ZIP file to your favorite location.

To use TRUEFAD-Cells, the trained deep learning model must be installed in DeepImageJ. The deep learning model is named `TRUEFAD Myotube detection.zip` in the folder you just unziped. To install the deep learning model you must then:
- Open DeepImageJ installation plugin in FIJI/Imagej: select *Plugins > DeepImageJ > DeepImageJ Install Model*.
- In the DeepImageJ interface, select *Private Model* tab.
- Tick *From ZIP file* and fill the blanck with the path of the your `TRUEFAD Myotube detection.zip` model. For example: `D:\TRUEFAD\TRUEFAD Myotube detection.zip`.
- Tick the box stating that *I accept to install the model...* (we promise that our model is safe to install :blush:) and select *Install*.

## Usage

### TRUEFAD-Cells

To start TRUEFAD-Cells, do:
- Drag and drop the `TRUEFAD-Cells DL - 24.08.22.ijm` file into FIJI. The FIJI macro editor should appear. 
- Click on the "Run" button. 

You can try TRUEFAD-Cells on our example image located in the *TRUEFAD\example* folder. For this example you can use the default parameter values. After execution, you should find an Excel sheet on your Desktop storing the TRUEFAD-Cells metrics. 

### TRUEFAD-Histo

To start TRUEFAD-Histo, do:
- Drag and drop the `TRUEFAD-Histo V1.4 - 04.05.22.ijm` file into FIJI. The FIJI macro editor should appear. 
- Click on the "Run" button. 

## Deep learning model training

This section is adressed to researchers who would like to get more details about our deep learning model training or who intend to reproduce the results presented in our publication.

## Citation 

Writing in progress...

## Acknowledgments and Funding
