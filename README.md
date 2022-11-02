# NaturalVariation

## Main features extraction

codes inside: 
NaturalVariation/Code/src/lib/featuresExtraction_20x/

### mainFeaturesExtraction_20xCysts

Code for extracting cyst features.
Result will be writen in a xls table.

Running the code will display some User Interface  so no coding is needed to extract features.

Global Features | Polygon Distributions | Mean Cell Features | Std Cell Features

Tutorial: https://github.com/ComplexOrganizationOfLivingMatter/NaturalVariation/blob/main/Code/src/lib/tutorials/mainFeatureExtraction_20x.mp4

### mainCellFeaturesExtraction_20xCysts

Code for extracting cyst Cell Features.
Result will be writen in a xls table.

Variables are the same as mainFeaturesExtraction_20xCysts/meanCellFeatures but raw
instead of averaged.

Running the code will display some User Interface  so no coding is needed to extract features.

## Some interesting user interfaces (_ui) for spatial distribution study:

Inside NaturalVariation/Code/src/lib/cartography/

### correlateVariableWithScutoids_ui
Function that divide cyst in 4 quartiles 
using the chosen variable
then gives the percentage of cells in each quartile
that are scutoids.

### getCellSpatialData_ui
Function that joins cell's variable info with cell's Z and XY Position
   
### getCellSpatialStatisticsBULKplot_ui [RETURNS TABLE AND TABLE FOR PLOTVIOLIN]
For each Variable Quartile, calculates mean ZPos of cells in that Quartile.
If scutoids just the mean of ZPos (no quartiles)
    
### plotSpatialDistribution_ui
Plotting "stamps" of single variables

### plotSpatialDistributionBULK_ui
Plotting "stamps" of all variables

### plotGradientBoomerangs
For each quartile of selected variable's distribution
a scatter plot and histogram plot is plotted and saved

## Semiautomatic curation | proofreading tools

Some interesting tools can be found inside NaturalVariation/Code/src/lib/proofreading/

### bulkCystProofreading
Main code for semiautomatic curation GUI.

### checkingSegmentedCysts
Code for creating the warning table used by bulkCystProofReading.
This table contains info of potentially misslabeled cells.

