# Detection vs. discrimination in ON and OFF parasol RGCs and human observers

This repository includes the analysis code for: Human retina trades single-photon detection for high-fidelity contrast encoding

```
@article {Kilpelainen2022human,
  author = {Markku Kilpel{\"a}inen and Johan West{\"o} and Anton Laihi and Daisuke Takeshita and Fred Rieke and Petri Ala-Laurila},
  title = {Human retina trades single-photon detection for high-fidelity contrast encoding},
  elocation-id = {2022.12.15.520020},
  year = {2022},
  doi = {10.1101/2022.12.15.520020},
  publisher = {Cold Spring Harbor Laboratory},
  URL = {https://www.biorxiv.org/content/early/2022/12/15/2022.12.15.520020},
  eprint = {https://www.biorxiv.org/content/early/2022/12/15/2022.12.15.520020.full.pdf},
  journal = {bioRxiv}
}
```

## Getting started:
1. Clone the repository.
1. Install the following software for full functionality:
   - MATLAB for analyses and figure panels (tested with 2017b and 2020b)
   - [export_fig](https://github.com/altmany/export_fig), required for saving publication ready panels and figures in pdf format. Install by cloning the export_fig repository to a directory under the root directory for this repository. **setPaths.m** (below) will then automatically add it to the MATLAB path. Figure panels are saved as png images instead of pdfs if export_fig is not found.
   - [ghostscript](https://www.ghostscript.com/), required for saving figures in pdf format with export_fig (gets installed automatically with LaTeX).
   - [LaTeX](https://www.latex-project.org), required for joining panels into the final manuscript figures.
   - [Make](https://www.gnu.org/software/make/), required for running all figure creating scripts automatically.
1. Download data.
   - Download data from: https://doi.org/10.6084/m9.figshare.21696686
   - Copy the following directories **RGC Data**, **RGC Data RF**, and **Psychophysics Data** to the root directory of this repository.
1. Run **setPaths.m**:
   - Resets Matlab's paths to default values so as to avoid conflicts wiht other projects.
   - Adds all folders and subfolders in this direcotry to the path.
   - Creates any missing project folders and adds then to the path.
1. Run **mainRGCAnalysis.m**:   
   - Extracts and groups spike counts in response to flashes of various intensities.  
   - Performs a 2AFC analyses in both a detection and a discrimination setting.    
   - Fits a hill function to the detection curve and to all discrimination curves.  
   - Determines the dipper function based on 75 % correct thresholds (the just noticeable difference).  
   - Plots and stores the results.
1. Run **plotRGCSummary.m** to see a dipper summary of all analyzed cells (optional).
1. Run **mainPsychophysicsAnalysis.m**:
   - Performs a 2AFC analyses on both the detection and the discrimination tasks.    
   - Fits a hill function to the detection curve and to all discrimination curves.  
   - Determines the dipper function based on 75 % correct thresholds (the just noticeable difference).  
   - Plots and stores the results.
1. Run **plotPsychophysicsSummary.m** to see a dipper summary of all subjects (optional).
1. Generate the final manuscript figures.
   - Run ./updateFigures.sh to create all Matlab panels and to compile all LaTeX files.
   - Alternatively, run **Figure Panels/plotPsychophysicsSummary.m** to only generate figure panels.

## Structure
__Figure panels:__ Functions for plotting figure panels in the manuscript.   
__Helper functions:__ General plotting and analysis functions.  
__Psychophysics analysis:__ Functions for analyzing psychophysics data.
__RGC analyses:__ Functions for analyzing RGC data.   
__Supplement figures:__ Functions for supplementary figures and and panels.   
__Theoretical model:__ Scripts and functions for fitting the pooling model to data and for understanding dips in general.  
__Tikz:__ LaTex (Tikz) code for compiling each figure in the manuscript.  
