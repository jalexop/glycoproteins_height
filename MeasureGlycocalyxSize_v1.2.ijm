/*****************************************************************************
 *  Author Dr. Ioannis K. Alexopoulos
 * The author of the macro reserve the copyrights of the original macro.
 * However, you are welcome to distribute, modify and use the program under 
 * the terms of the GNU General Public License as stated here: 
 * (http://www.gnu.org/licenses/gpl.txt) as long as you attribute proper 
 * acknowledgement to the author as mentioned above.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *****************************************************************************
 * Description of macro
 * --------------------
 * Press the Help button after running the macro or open the help files
 * 
 */
Help_html = "<html>"
     +"<h1>Measure Glycocalyx Sizes</h1>"
     +"<b><u>Short Description</u></b><br>"
     +"This macro can process xyz confocal stacks that contain at least one fluorescence channel of glycoprotein staining. "
     +"The user needs to select (at least for the first time) single lines (ROIs) over this channel. For each of these lines "
     +"the macro will reclice (\"cut through\") the original xyz image generating xz images which show the glycocalyxes in xz (side view). "
     +"These xz images will be segmented (thresholded and binarized) and the segmented partciles will be analyzed. For each particle "
     +"the macro will measure the area and will fit an ellipse returnign the length of the major and minor axis of this ellipse. The major axis "
     +"indicates the height of the glyococalyxes and the minor axis indicates the width.<br>"
     +"<b><u>Parameters</u></b><br>"
     +"<b>Analyse single image container file:</b> Uncheck this, only if you wish to analyze a folder with .tiff files. "
     +" In this case, make sure that all .tiff files are calibrated with known voxel size<br>"
     +"<b>Select Channel with hyaluronan staining:</b> Indicated the number of the channel with the staining of interest.<br>"
     +"<b>Load lines selection:</b> Check this if you want to run measurements on previously selected lines. The saved ROIs need to have an appropriate file name "
     +"for each of the selected images. In case this option is selected, you can already indicate the folder with the ROIs selections (see Browse button below)."
     +"If the file path selection will be empty, then the macro will ask later for a source folder.<br>"
     +"<b>Folder with lines selection </b> Browse for the folder with the lines selections of previously analyzed images. If this will be empty, the macro "
     +" will ask later for a source folder. If the file path given will not be the correct one (or if the file name of the saved ROIs will not be found) the macro "
     +"will return an error later.<br>"
     +"<br>"
     +"<b><u>Analysis Options</u></b><br>"
     +"<b>Threshold Algorithm:</b> This is a list of the ImageJ / Fiji available threshold algorithms. Select the proper on (based on your data) that will be used "
     +"for particles segmentation.<br>"
     +"<b>Smallest particle size (um^2):</b> It is the size of the smallest particle that will be analyzed.<br>"
     +"<b>Biggest particle size (um^2):</b> It is the size of the biggest particle that will be analyzed.<br>"
     +"<font color=red><b>Note:</b></font> It is assumed that all images are properly calibrated (correct voxel size). If not, the above values will be considered "
     +"as square pixels and the results will also be in pixels or square pixels.<br>"
     +"<b><u>Saving Results Options</u></b><br>"
     +"<b>Save XZ resliced images: </b>By default all resliced images (for each selected line) will be saved as .tiff files.<br>"
     +"<b>Save XZ thresholded images: </b> By default the thresholded resliced images (for each selected line) will be saved as .tiff files.<br>"
     +"<b>Name of saving folder:</b> This folder will also contain the file name of the file that will be processed together with the date and time of the analysis. "
     +" (YYYYMMDD_HHMMSS)<br>"
     +"<font color=red><b>Note:</b></font> Inside the results folder, the ROIs of line selections (for each analyzed image) will be saved as .zip file. This will happen "
     +"even if these ROIs have been loaded from a previous location. Additionally the particles ROIs (from the segmented thresholded images) for each line selection will "
     +"be saved as .zip files.<br>"
     +"";
/*********************************************************************************************************************************************************/

// Create dialog, create save folders, and select file(s) to process
ThresholdMethods=getList("threshold.methods");
Dialog.create("Parameters");
Dialog.addMessage("********************************************************************************");
Dialog.addMessage("**************************       Measure Glycocalyx Sizes       ******************");
Dialog.addMessage("********************************************************************************");
Dialog.addMessage("");
Dialog.addCheckbox("Analyse single image container file", true);
Dialog.addNumber("Select Channel with hyaluronan staining", 2);
Dialog.addCheckbox("Load lines selection", false);
Dialog.addDirectory("Folder with lines selection ", "")
Dialog.addMessage("      ");
Dialog.addMessage("      ");
Dialog.addMessage("                                    Analysis Options                    ");
Dialog.addMessage("      ");
Dialog.addChoice("Threshold Algorithm", ThresholdMethods, "Huang");
Dialog.addNumber("Smallest particle size(um^2)", 0.350);
Dialog.addNumber("Biggest particle size(um^2)", 4.000);
Dialog.addMessage("      ");
Dialog.addMessage("      ");
Dialog.addMessage("                                    Saving Results Options                    ");
Dialog.addMessage("      ");
Dialog.addCheckbox("Save XZ resliced images", true);
Dialog.addCheckbox("Save XZ thresholded images", true);
Dialog.addString("Name of saving folder: ", "_Results");
Dialog.addHelp(Help_html);
Dialog.show();

// Variables of Dialog
single_file=Dialog.getCheckbox();
Hal_channel=Dialog.getNumber();
LOAD_ROI=Dialog.getCheckbox();
LINES_ROI_DIR= Dialog.getString();
Thres_Method=Dialog.getChoice();
small_particles=Dialog.getNumber();
big_particles=Dialog.getNumber();
saveXZ=Dialog.getCheckbox();
saveXZThresh=Dialog.getCheckbox();
save_folder=Dialog.getString();
sep = File.separator;
if (single_file)
{
	Filelist=newArray(1);
	Filelist[0] = File.openDialog("Select a file to proccess...");
	SourceDir=File.getParent(Filelist[0]);
	Filelist[0]=File.getName(Filelist[0]);
	save_folder_name_add=Filelist[0];
	SAVE_DIR=SourceDir;
	run("Bio-Formats Macro Extensions");
	Ext.setId(SourceDir+sep+Filelist[0]);
	Ext.getSeriesCount(SERIES_COUNT);
	// Create arrays...
	SERIES_NAMES=newArray(SERIES_COUNT);
	default_check_box_values=newArray(SERIES_COUNT);
	SERIES_2_OPEN=newArray(SERIES_COUNT);
	
	// Create the dialog
	rows=10;
	columns=(SERIES_COUNT/10)+1;
	Dialog.create("Select Series to Analyze");
	if(SERIES_COUNT == 1){default_check_box=true;}else{default_check_box=false;}
	for (i=0; i<SERIES_COUNT; i++) {
		// Get series names and channels count
		Ext.setSeries(i);
		SERIES_NAMES[i]="";
		Ext.getSeriesName(SERIES_NAMES[i]);
		default_check_box_values[i]=default_check_box;
	}
	Dialog.addCheckboxGroup(rows,columns,SERIES_NAMES,default_check_box_values);
	Dialog.addCheckbox("Select All", false);
	Dialog.show();
	for (i=0; i<SERIES_COUNT; i++)
	{
		SERIES_2_OPEN[i]=Dialog.getCheckbox();
	}
	select_all=Dialog.getCheckbox();
	if (select_all)
	{
		for (i=0; i<SERIES_COUNT; i++)
		{
			SERIES_2_OPEN[i]=select_all;
		}
	}
	// Check if user selected image
	ok_to_proc=0;
	for(i=0; i<SERIES_COUNT; i++){
		if(SERIES_2_OPEN[i]==1){
			ok_to_proc=1;
		}
	}
	if(ok_to_proc<1){
		exit("Please Select an image to open")
	}
}else
{
	SourceDir = getDirectory("Choose source directory");
	Filelist=getFileList(SourceDir);
	SAVE_DIR=SourceDir;
	save_folder_name_add=File.getName(SourceDir);
	SERIES_2_OPEN=newArray(1);
	SERIES_2_OPEN[0]=1;
}

save_folder=save_folder+"_"+save_folder_name_add;
// Remove Folders from Filelist array
tmp=newArray();
for(k=0;k<Filelist.length;k++)
{
	if (!File.isDirectory(SourceDir+"/"+Filelist[k]))
	{
		tmp = Array.concat(tmp,Filelist[k]); 
	}
}
Filelist=tmp;

if(LOAD_ROI)
{
	if (LINES_ROI_DIR == "" || LINES_ROI_DIR == " ")
	{
		LINES_ROI_PATH = getDirectory("Select the folder containing the lines selection ROIs");
	}else
	{
		LINES_ROI_PATH = LINES_ROI_DIR;
	}
}

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
//month=month+1;
save_folder=save_folder+"_"+year+""+month+""+dayOfMonth+"_"+hour+""+minute+""+second;
new_folder=SAVE_DIR + sep + save_folder;
File.makeDirectory(new_folder);
run("Input/Output...", "jpeg=85 gif=-1 file=.xls copy_row save_column save_row");
roiManager("reset");
setBatchMode(true);
for (k=0;k<Filelist.length;k++)
{
	if(!endsWith(Filelist[k], sep))
	{
		run("Bio-Formats Macro Extensions");
		Ext.setId(SourceDir+sep+Filelist[k]);
		Ext.getSeriesCount(SERIES_COUNT);
		FILE_PATH=SourceDir + sep + Filelist[k];
		for (i=0;i<SERIES_COUNT; i++) 
		{
		 showProgress(-i/SERIES_COUNT);
		 if(SERIES_2_OPEN[i]==1){
			options="open=["+ FILE_PATH + "] " + "autoscale color_mode=Default view=Hyperstack stack_order=XYCZT " + "series_"+d2s(i+1,0) + " use_virtual_stack";
			run("Bio-Formats Importer", options);
			FILE_NAME=File.nameWithoutExtension;
			Ext.setSeries(i);
			Ext.getSeriesName(SERIES_NAMES2);
			SERIES_NAMES2=replace(SERIES_NAMES2, " ", "_");
			SERIES_NAMES2=replace(SERIES_NAMES2, "/", "_");
			SERIES_NAMES2=replace(SERIES_NAMES2, "\\(", "");
			SERIES_NAMES2=replace(SERIES_NAMES2, "\\)", "_");
			SAVE_NAME=FILE_NAME+"_"+SERIES_NAMES2;
			rename(SAVE_NAME);
			run("Set Measurements...", "area fit redirect=None decimal=3");
			run("Duplicate...", "title=analysis_img duplicate channels="+Hal_channel+"");
			selectWindow(SAVE_NAME);
			close();
//			Draw lines (preferably horizontal) over the glycoproteins staining
//			For each of the lines a resliced image will be generated and will be 
//			analysed.
			if(LOAD_ROI)
			{
				roiManager("Open", LINES_ROI_PATH + sep + SAVE_NAME+"_Lines_ROIs"+".zip" );
			}else
			{
				selectWindow("analysis_img");
				setBatchMode("show");
				setTool("line");
				waitForUser("Draw lines and for each line press \"t\" on the keyboard. When you are done, press ok on this message");
				setBatchMode("hide");
			}
			
			for (lines=0;lines<roiManager("count");lines++)
			{
				selectWindow("analysis_img");
				roiManager("Select", lines);
				roiManager("Rename", "line"+lines+"");
				//run("Dynamic Reslice", " ");
				run("Reslice [/]...", " ");
				rename("Reslice_"+lines+"");
			}
			NO_Selections=roiManager("count");
			roiManager("save", new_folder+ sep + SAVE_NAME+"_Lines_ROIs"+".zip");
			roiManager("reset");
			selectWindow("analysis_img");
			close();
			for (lines=0;lines<NO_Selections;lines++)
			{
				selectWindow("Reslice_"+lines+"");
				run("Duplicate...", " ");
				if (saveXZ){
					saveAs("tif", new_folder+ sep +SAVE_NAME+"_XY_"+lines);
				}
				close();
				selectWindow("Reslice_"+lines+"");
				setAutoThreshold(Thres_Method+" dark");
				setOption("BlackBackground", true);
				run("Convert to Mask");
				run("Watershed");
				run("Analyze Particles...", "size="+small_particles+"-"+big_particles+" circularity=0.00-0.8 display exclude add");
				if(roiManager("count") > 0)
				{
					roiManager("save", new_folder+ sep + SAVE_NAME+"_Particles_ROIs_"+lines+".zip");
				}
				
				selectWindow("Reslice_"+lines+"");
				if (saveXZThresh){
					saveAs("tif", new_folder+ sep +SAVE_NAME+"_XY_Thresh_"+lines);
				}
				close();
				roiManager("reset");
			}
		 }
		}
		selectWindow("Results");
		saveAs("Results", new_folder+ sep +FILE_NAME+"_Results.txt");
		run("Clear Results");
		roiManager("reset");
	}
}
setBatchMode(false);
run("Close");
close("Roi Manager");
