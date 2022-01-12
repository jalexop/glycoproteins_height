<h1>Measure Glycocalyx Sizes</h1>
     <b><u>Short Description</u></b><br>
     This macro can process xyz confocal stacks that contain at least one fluorescence channel of glycoprotein staining. 
     The user needs to select (at least for the first time) single lines (ROIs) over this channel. For each of these lines 
     the macro will reslice ("cut through") the original xyz image generating xz images, which show the hyaluronan molecules in xz (side view). 
     These xz images will be segmented (thresholded and binarized) and the segmented partciles will be analyzed. For each particle 
     the macro will measure the area and will fit an ellipse returning the length of the major and minor axis of this ellipse. The major axis 
     indicates the height of the hyaluronan molecules and the minor axis indicates the width.<br>
     <b><u>Parameters</u></b><br>
     <b>Analyse single image container file:</b> Uncheck this, only if you wish to analyze a folder with .tiff files. 
      In this case, make sure that all .tiff files are calibrated with known voxel size<br>
     <b>Select Channel with hyaluronan staining:</b> Indicated the number of the channel with the staining of interest.<br>
     <b>Load lines selection:</b> Check this if you want to run measurements on previously selected lines. The saved ROIs need to have an appropriate file name 
     for each of the selected images. In case this option is selected, you can already indicate the folder with the ROIs selections (see Browse button below).
     If the file path selection will be empty, then the macro will ask later for a source folder.<br>
     <b>Folder with lines selection </b> Browse for the folder with the lines selections of previously analyzed images. If this will be empty, the macro 
      will ask later for a source folder. If the file path given will not be the correct one (or if the file name of the saved ROIs will not be found) the macro 
     will return an error later.<br>
     <br>
     <b><u>Analysis Options</u></b><br>
     <b>Threshold Algorithm:</b> This is a list of the ImageJ / Fiji available threshold algorithms. Select the proper on (based on your data) that will be used 
     for particles segmentation.<br>
     <b>Smallest particle size (um^2):</b> It is the size of the smallest particle that will be analyzed.<br>
     <b>Biggest particle size (um^2):</b> It is the size of the biggest particle that will be analyzed.<br>
     <font color=red><b>Note:</b></font> It is assumed that all images are properly calibrated (correct voxel size). If not, the above values will be considered 
     as square pixels and the results will also be in pixels or square pixels.<br>
     <b><u>Saving Results Options</u></b><br>
     <b>Save XZ resliced images: </b>By default all resliced images (for each selected line) will be saved as .tiff files.<br>
     <b>Save XZ thresholded images: </b> By default the thresholded resliced images (for each selected line) will be saved as .tiff files.<br>
     <b>Name of saving folder:</b> This folder will also contain the file name of the file that will be processed together with the date and time of the analysis. 
      (YYYYMMDD_HHMMSS)<br>
     <font color=red><b>Note:</b></font> Inside the results folder, the ROIs of line selections (for each analyzed image) will be saved as .zip file. This will happen even if these ROIs have been loaded from a previous location. Additionally the particles ROIs (from the segmented thresholded images) for each line selection will be saved as .zip files.<br>
