![CartoCell](https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/logoCartoCell_whiteBackground.png)

**Explore the Single-Cell Cartography tools featured in [CartoCell, a high-content pipeline for 3D image
analysis, unveils cell morphology
patterns in epithelia](https://doi.org/10.1016/j.crmeth.2023.100597) within this repository.** <br>
Documentation about CartoCell pipeline can be found clicking [here](https://biapy.readthedocs.io/en/latest/tutorials/cartocell.html).

---

![RepositoryPresentation](https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/repositoryPresentation.gif)

---

## Main features extraction

codes inside: 
NaturalVariation/Code/src/lib/featuresExtraction_20x/

### mainFeaturesExtraction_20xCysts

Code for extracting cyst features.
Result will be writen in a xls table.

Running the code will display some User Interface  so no coding is needed to extract features.

Global Features | Polygon Distributions | Mean Cell Features | Std Cell Features


![Demo mainFeaturesExtraction_20x](https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/mainFeatureExtraction_20x.gif)

### mainCellFeaturesExtraction_20xCysts

Code for extracting cyst Cell Features.
Result will be writen in a xls table.

Variables are the same as mainFeaturesExtraction_20xCysts/meanCellFeatures but raw
instead of averaged.

Running the code will display some User Interface  so no coding is needed to extract features.

---

## Some interesting user interfaces (_ui) for spatial distribution study:

Inside NaturalVariation/Code/src/lib/cartography/

### getCellSpatialData_ui
Function that joins cell's variable info with cell's Z and XY Position

![Demo getCellSpatialData_ui](https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/getCellSpatialData_ui.gif)
   
### getCellSpatialStatisticsBULKplot_ui [RETURNS TABLE AND TABLE FOR PLOTVIOLIN]
For each Variable Quartile, calculates mean ZPos of cells in that Quartile.
If scutoids just the mean of ZPos (no quartiles)
    
### plotSpatialDistribution_ui
Plotting 3D renders with feature information color-coded

![Demo plotSpatialDistribution_ui](https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/plotSpatialDistribution_ui.gif)

### plotSpatialDistributionBULK_ui
Plotting 3D renders with all features information color-coded

### plotGradientBoomerangs
For each quartile (or rank) of selected variable's distribution
a scatter plot and histogram plot is plotted and saved

![Demo plotGradientBoomerangs](https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/plotGradientBoomerangs.gif)

---

## Semiautomatic curation | proofreading tools

Some interesting tools can be found inside NaturalVariation/Code/src/lib/proofreading/

### checkingSegmentedCysts
Code for creating the warning table used by bulkCystProofReading.
This table contains info of potentially misslabeled cells.

![Demo checkingSegmentedCysts](https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/checkingSegmentedCysts.gif)

### saveForValidation
Code for creating the mat files needed for bulkCystProofreading tool

![Demo checkingSegmentedCysts](https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/saveForValidation.gif)

### bulkCystProofreading
Main code for semiautomatic curation GUI.
![Demo bulkCystProofreading](https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/bulkCystProofReading.gif)
