# TRUEFAD, TRUE Fiber Atrophy Distinction

TRUEFAD is a composition of two FIJI/ImageJ macros designed for the analysis of two-dimensional images of muscle cells: TRUEFAD-Histo and TRUEFAD-Cells. TRUEFAD provides morpholigical metrics for phase contrast images of both myotubes (TRUEFAD-Cells) and laminin (TRUEFAD-Histo). TRUEFAD-Cells relies on a U-Net deep learning model trained with ZeroCostDL4Mic online [notebooks](https://github.com/HenriquesLab/ZeroCostDL4Mic/wiki). TRUEFAD-Histo is a non-deep learning tool with comparable results on laminin segmentation with state-of-the-art deep learning methods such as Cellpose.

## Installation

Requirements:
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
- Select *Apply Changes*, wait for the install to finish and restart FIJI/ImageJ.

## Usage

### TRUEFAD-Cells

To start TRUEFAD-Cells, do:
- Drag and drop the `TRUEFAD-Cells DL - 24.08.22.ijm` file into FIJI. The FIJI macro editor should appear. 
- Click on the "Run" button. 

### TRUEFAD-Histo

To start TRUEFAD-Histo, do:
- Drag and drop the `TRUEFAD-Histo V1.4 - 04.05.22.ijm` file into FIJI. The FIJI macro editor should appear. 
- Click on the "Run" button. 

## Reproduction - Deep learning model training

This section is adressed to researchers who intend to reproduce the results presented in our publication.

## Citation 

Writing in progress...

## Acknowledgments and Funding
