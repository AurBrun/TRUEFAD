requires("1.53f");
toolname = "TRUEFAD Cells";
version = "V220823";
// Liste des lettres utilisés pour les itérations : n, a, u, m, k

//    #############
//    ## Dialogs ##
//    #############

// Dependencies
title = "Requirements";
msg = "TRUEFAD Cells requires up to date MORPHOLIBJ, DeepImageJ with TRUEFAD myotube detection installed and ReadAndWriteExcel package";
waitForUser(title, msg);

// Dialogs - User defined properties
Dialog.create(toolname + "-" + version + "-Properties_Calibration");
Dialog.addMessage("Rate the performance of your machine. Plugin will take it in consideration for the processing speed");
Dialog.addSlider("Slow (1) to Fast (5)", 1, 5, 3);
Dialog.addMessage("Select the apropriate parameters for preprocessing and segmentation");
Dialog.addSlider("Border siding the DL prediction", 1, 30, 5); // Border radius in pixel siding the DL prediction used for subsequent processing
Dialog.addSlider("Remove noise on myotube prediction (less=more power)", 1, 30, 10); // TopHat strength
Dialog.addSlider("Make noise on other objects", 1, 100, 15); // Add salt that get smooth myotubes during segmentation
Dialog.addSlider("Segmentation tolerance", 1, 200, 35); // Compromise between under or oversegmentation
Dialog.addCheckbox("Test and stop just after after segmentation", false);
Dialog.addMessage("We recommand that you use your x10 objective with a 2000x2000 resolution");
Dialog.addMessage("Select the apropriate parameters for myotube retention");
Dialog.addNumber("Scale (pix/µm)", 1.86);
Dialog.addNumber("Min label Area (µm²)", 750); // Minimum Label size in µm²
Dialog.addNumber("Max label Area (µm²)", 120000); // Maximum Label size in µm²
Dialog.addNumber("Min Ellongation for myotube retention", 6);
Dialog.addNumber("Max Ellongation for myotube retention", 30);
Dialog.addCheckbox("Detailed measures exported as results", false);
Dialog.show();
SPEED = Dialog.getNumber();
SPD = 3;
// SPD is then inverted to become a multiplicative coefficient of wait time
if (SPEED == 1) {
	SPD = 5;
}
if (SPEED == 2) {
	SPD = 4;
}
if (SPEED == 4) {
	SPD = 2;
}
if (SPEED == 5) {
SPD = 1;
}
Border = Dialog.getNumber();
TopHatRadius = Dialog.getNumber();
NoisePower = Dialog.getNumber();
Tolerance = Dialog.getNumber();
STOPafterSEG = Dialog.getCheckbox();
Scale = Dialog.getNumber();
MINsize = Dialog.getNumber();
MAXsize = Dialog.getNumber();
MINell = Dialog.getNumber();
MAXell = Dialog.getNumber();
Detailed = Dialog.getCheckbox();

// Convert area in µm² to area in pixel²
MINsize = MINsize*(Scale*Scale);
MAXsize = MAXsize*(Scale*Scale);

// Dialogs - Directories
Dialog.create(toolname + "-" + version + "-Directories");
Dialog.addMessage("Macro started, you will have to select path of your input images folder.");
Dialog.show();
dir = getDir("Choose the Directory for Input : 8-bit TIFF phase contrast images with resolution > 2000x2000");
list = getFileList(dir);
Dialog.create(toolname + "-" + version + "-Directories");
Dialog.addMessage("Now select path to the output directory for ROI myotubes and final image export.");
Dialog.show();
Output = getDir("Select the Directory for Output");

//    ##################
//    ## Folder loops ##
//    ##################

// Initialisation
for (n=0; n<list.length; n++) {
	showProgress(n+1, list.length);
	open(dir+list[n]);
	wait(SPD*200);
	// Image dependant variable declaration
	name = getTitle();
	Hnativ = getHeight();
	Wnativ = getWidth();
	// Reset default parameters
	roiManager("reset");
	run("Set Measurements...", "area mean min display redirect=None decimal=3");

//    ############################
//    ##  Segmentation Pipeline ##
//    ############################
	
	
	// Get the Origin Image
	run("RGB Color");
	run("8-bit");
	run("Duplicate...", "title=Origin");
	close(name);
	
	// Scale down the image to 512x512Pix
	if (Wnativ > Hnativ){
		makeRectangle(0, 0, Hnativ, Hnativ);
	}
	else {
		makeRectangle(0, 0, Wnativ, Wnativ);
	}
	run("Crop");
	// Cropped dependant variable
	Onativ = getWidth();
	ClosingRadius = Math.round(Onativ/80);
	BS = Math.round(Onativ/5);
	WidthC = getWidth()+BS;
	HeightC = getHeight()+BS;
	run("Scale...", "x=- y=- width=512 height=512 interpolation=Bicubic average create");
	rename("A");
	
	// Run DeepImageJ with TRUEFAD myotube detection model on this 512x512Pix, and make directional filters
	run("DeepImageJ Run", "model=[TRUEFAD Myotube detection] format=Tensorflow preprocessing=[per_sample_scale_range.ijm] postprocessing=[no postprocessing] axes=X,Y,C tile=512,512,1 logging=normal");
	rename("B");
	close("A");
	run("Directional Filtering", "type=Min operation=Closing line=10 direction=15");
	close("B");
	run("Directional Filtering", "type=Min operation=Median line=5 direction=15");
	rename("B");
	close("B-directional");
	
	// Scale up this probability map to the original size
	run("Scale...", "x=- y=- width=Onativ height=Onativ interpolation=Bicubic average create");
	close("B");
	rename("B");
	
	// Threshold the probability image to get a single ROI corresponding to all putative myotubes on the image
	run("16-bit");
	roiManager("reset");
	setAutoThreshold("Otsu");
	setThreshold(0, 30000, "raw");
	run("Create Selection");
	roiManager("Add");
	
	// Goes back to the original image, make a TopHat filter only on ROI + Noise filter on everything else
	selectWindow("Origin");
	run("Duplicate...", "title=A");
	roiManager("Select", 0);
	run("Enlarge...", "enlarge=Border pixel");
	run("Top Hat...", "radius=TopHatRadius");
	roiManager("Deselect");
	roiManager("Show All");
	roiManager("Show None");
	selectWindow("B");
	run("Create Selection");
	run("Enlarge...", "enlarge=Border pixel");
	run("Make Inverse");
	roiManager("Add");
	selectWindow("A");
	roiManager("Select", 1);
	run("Add Specified Noise...", "standard=NoisePower");
	roiManager("reset");
	roiManager("Show All");
	roiManager("Show None");
	close("B");
	
	// Watershed segmentation
	run("Extended Min & Max", "operation=[Extended Minima] dynamic=Tolerance connectivity=4");
	run("Connected Components Labeling", "connectivity=4 type=[float]");
	run("Impose Min & Max", "original=A marker=A-emin operation=[Impose Minima] connectivity=4");
	run("Marker-controlled Watershed", "input=A-imp marker=A-emin-lbl mask=None calculate use");
	run("Set Label Map", "colormap=Spectrum background=Black shuffle");
	close("A-imp");
	close("A-emin-lbl");
	close("A-emin");
	close("A");
	rename("A");
	
	if(STOPafterSEG == 1){
		break
		break
	}

//    ####################
//    ## Label trimming ##
//    ####################

	// Size and border filtering
	run("Set Scale...", "distance=Scale known=1 unit=µm");
	getPixelSize(unit, pw, ph);
	run("Label Size Filtering", "operation=Greater_Than size=MINsize");
	run("Label Size Filtering", "operation=Lower_Than size=MAXsize");
	run("Kill Borders");
	
	// Close unnecessary IMGS
	close("A");
	close("A-sizeFilt");
	close("A-sizeFilt-sizeFilt");
	rename("CleanLabelMap");
	run("Label Size Filtering", "operation=Greater_Than size=MINsize");
	close("CleanLabelMap");
	rename("CleanLabelMap");
	
	// Verify if there is at least one putative myotube on the image and keep labels with correct ellongation profile
	run("Duplicate...", "title=Verification");
	run("8-bit");
	setThreshold(1, 255);
	run("Convert to Mask");
	makeRectangle(0, 0, Onativ, Onativ);
	run("Set Measurements...", "mean redirect=None decimal=1");
	run("Measure");
	GV = Table.get("Mean", 0);
	close("Verification");
	if (GV > 0) {
		run("Remap Labels");
		close("Results");
		run("Analyze Regions", "ellipse_elong.");
		wait(SPD*400);
		Table.rename("CleanLabelMap-Morphometry", "EllongationTable");
		
		//Create new "master arrays" and usefull variables that get erased each image
		NumberOfLabel = Table.getColumn("Label"); // Array that contains all putative myotubes
		LabelNbr = newArray(); // Array that contains the number of measures made for each myotubes
		Measures = newArray(); // Array that contains all measures made on all myotubes per image
		MeanDiameter = newArray(); // Array that contains all mean diameters for all myotubes of the image
		Orient = newArray(); // Array that contains all angles for all myotubes of the image
		Area = newArray(); // Array that contains all areas for all myotubes of the image
		ROI = 0; // Identification number of the correct myotube
		
		// Proceed to identify labels over MINEll and under MAXell
		for (a = 0; a < NumberOfLabel.length ; a++) {
			selectWindow("EllongationTable");
			LabelEll = Table.get("Ellipse.Elong", a);
			run("Clear Results");
			if ((LabelEll > MINell)&(LabelEll < MAXell)) {
				// Smoothify each myotube, save it as a ROI and get morphometry
				selectWindow("CleanLabelMap");
				run("Duplicate...", "title=Myotube"+a+1);
				setThreshold(a+1, a+1, "raw");
				run("Convert to Mask");
				run("Morphological Filters", "operation=Closing element=Disk radius=ClosingRadius");
				run("Morphological Filters", "operation=Erosion element=Disk radius=1");
				rename("TEMP-BIN");
				setThreshold(255, 255);
				run("Analyze Particles...", "add");
				roiManager("Show None");
				run("Select None");
				resetThreshold();
				run("Connected Components Labeling", "connectivity=4 type=[8 bits]");
				rename("TEMP");
				run("Oriented Bounding Box", "label=TEMP image=TEMP");
				selectWindow("TEMP-OBox");
				OrientTEMP = newArray();
				OrientTEMP = Table.get("Box.Orientation",0);
				run("Analyze Regions", "area");
				AreaTEMP = newArray();
				AreaTEMP = Table.get("Area", 0);
				Orient = Array.concat(Orient, OrientTEMP); // Concatenate OrientTEMP in Orient Array
				Area = Array.concat(Area, AreaTEMP); // Concatenate AreaTEMP in Area Array
				close("TEMP-Morphometry");
				selectWindow("TEMP");
				run("Canvas Size...", "width=WidthC height=HeightC position=Center");
				// get Oriented Bounding box properties
				getPixelSize(unit, pw, ph);
				selectWindow("TEMP-OBox");
				X = Table.get("Box.Center.X",0)/pw;
				Y = Table.get("Box.Center.Y",0)/pw;
				L = Table.get("Box.Length",0)/pw;
				W = Table.get("Box.Width",0)/pw;
				A = (Table.get("Box.Orientation",0)-90)*(PI/180);
				// Calculate the first center of the bounding box
				X1 = X-(sin(A)*(L/2))+(BS/2);
				Y1 = Y+(cos(A)*(L/2))+(BS/2);
				// Calculate the second center of the bounding box
				X2 = X+(sin(A)*(L/2))+(BS/2);
				Y2 = Y-(cos(A)*(L/2))+(BS/2);
				selectWindow("TEMP-BIN");
				run("Canvas Size...", "width=WidthC height=HeightC position=Center");
				makeRotatedRectangle(X1, Y1, X2, Y2, W);
				// Extract the label
				run("Duplicate...", "title=Isolation");
				run("Set Measurements...", "mean redirect=None decimal=1");
				// Make the 9 measurements
				for (u = 1; u < 10; u++) {
					makeLine((u*L)/10, 0, (u*L)/10, W);
					run("Measure");
				}
				selectWindow("Results");
				Diameter = newArray(); //  Array that is a variable that contain the diameter of one measure 
				Diam9 = newArray(); // Temporrary Array that contain all diameters measures of one myotube
				for (m = 0; m < 9; m++) {
					Diameter = ((Table.get("Mean", m)/255)*W)/Scale;
					Table.set("Diameter", m, Diameter);
					Table.update;
					// Save in Measures all of the 9 measures per myotube for all labels
					Measures = Array.concat(Measures, Diameter);
					// Concatenate in Diam9 all of the 9 measures per myotube
					Diam9 = Array.concat(Diam9, Diameter);
				}
				Array.getStatistics(Diam9, min, max, MyotubeMean, stdDev); // Get statistics of Diam9
				MeanDiameter = Array.concat(MeanDiameter, MyotubeMean); // Save the mean of the measures for each myotube in "MeanDiameter"
				// Create an array that iterate the 9 measures per label
				for (k = 1; k < 10; k++) {
					LabelNbr = Array.concat(LabelNbr, ROI+1);
				}
				ROI ++;
				selectWindow("TEMP");		
				run("Clear Results");
				close("Isolation");
				close("TEMP");	
				close("TEMP-OBox");
				close("Myotube"+(a+1));
				close("Myotube"+(a+1)+"-Closing");
				close("TEMP-BIN");
			}
		}
		close("CleanLabelMap");
	
//    #####################################
//    ## Results and ROI map exportation ##
//    #####################################

		if (ROI > 0) {
			// Export results to Excel
			close("EllongationTable");
			if (Detailed == 1) {
				Table.showArrays("Diameters", LabelNbr, Measures, MeanDiameter, Orient, Area);
			} else {
				Table.showArrays("Diameters", MeanDiameter, Orient, Area);
			}
			
			Table.rename("Diameters", "Results");
			run("Read and Write Excel", "no_count_column dataset_label="+name+"_Export");
			close("Results");
					
			// Create ROI map
			selectWindow("Origin");
			roiManager("Show All");
			roiManager("Set Color", "green");
			roiManager("Set Line Width", 3);
			run("Labels...", "color=red font=18 show draw bold");
			roiManager("Save", Output+name+".zip");
			run("Set Scale...", "distance=Scale known=1 unit=µm");
			saveAs("Tiff", Output+name+".tif");
		} else {
		Table.rename("EllongationTable", "Results");
		Table.set("Mean", 0, "No True tubes found");
		Table.update;
		run("Read and Write Excel", "no_count_column dataset_label="+name+"_Export");
		}
	} else {
		Table.set("Mean", 0, "No tubes found");
		Table.update;
		run("Read and Write Excel", "no_count_column dataset_label="+name+"_Export");
	}
	run("Collect Garbage");
	roiManager("reset");
	run("Clear Results");
	run("Close All");
	wait(SPD*300);
}
// Final message
showMessage("TRUEFAD Cells has now finished the job");
showMessage("Please find on your desktop the XLX spreadsheet");
showMessage("and in the Output directory, ROIs myotubes and final images produced");
showMessage("Have a nice day! - Aurelien BRUN - UNH UMR1019 Clermont-Ferrand");