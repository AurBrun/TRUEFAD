Dialog.create("ImageJ-TRUEFAD-V0.8-Step1");
Dialog.addMessage("Macro started! What kind of images do you want to analyze?");
Dialog.addChoice("Type:", newArray("RGB phase contrast L6 or C2C12", "RGB MHC fluorescence of SKMDC cells"));
Dialog.addMessage("Rate the performance of your machine. Plugin will take it in consideration for the processing speed");
Dialog.addSlider("Slow (1) to Fast (5)", 1, 5, 2);
Dialog.addCheckbox("Enable batch mode", true);
Dialog.show();
IMGtype = Dialog.getChoice();
SPEED = Dialog.getNumber();
BMchoice = Dialog.getCheckbox();
SPD=3;
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
if (IMGtype == "RGB MHC fluorescence of SKMDC cells") {
	Dialog.create("ImageJ-TRUEFAD-V0.8-Fluorescence MHC Calibration");
	Dialog.addMessage("Select the apropriate parameters for your MHC IMGs");
	Dialog.addSlider("Local contrast adjustment", 1, 10, 3);
	Dialog.addSlider("Initial smoothness filter", 1, 10, 3);
	Dialog.addSlider("Segmentation tolerance", 1, 100, 25);
	Dialog.addNumber("Min label Area", 5000);
	Dialog.addNumber("Max label Area", 200000);
	Dialog.addNumber("Min label Ellongation", 7);
	Dialog.addNumber("Max label Ellongation", 15);
	Dialog.show();
	CLAHEvalue = Dialog.getNumber();
	KUWAvalue = Dialog.getNumber();
	Tolerance = Dialog.getNumber();
	MINsize = Dialog.getNumber();
	MAXsize = Dialog.getNumber();
	MINell = Dialog.getNumber();
	MAXell = Dialog.getNumber();
}
if (IMGtype == "RGB phase contrast L6 or C2C12") {
	Dialog.create("ImageJ-TRUEFAD-V0.8-Phase contrast Calibration");
	Dialog.addMessage("Select the apropriate parameters for your phase contrast IMGs");
	Dialog.addSlider("Local contrast adjustment", 1, 40, 25);
	Dialog.addSlider("Local variance filter block", 1, 30, 2);
	Dialog.addSlider("Local variance SD", 1, 10, 1);
	Dialog.addSlider("Segmentation tolerance", 1, 100, 80);
	Dialog.addNumber("Min label Area", 5000);
	Dialog.addNumber("Max label Area", 200000);
	Dialog.addCheckbox("Manually merge labels", false);
	Dialog.addNumber("Min label Ellongation", 7);
	Dialog.addNumber("Max label Ellongation", 15);
	Dialog.show();
	CLAHEvalue = Dialog.getNumber();
	block_radius = Dialog.getNumber();
	VARvalue = Dialog.getNumber();
	Tolerance = Dialog.getNumber();
	MINsize = Dialog.getNumber();
	MAXsize = Dialog.getNumber();
	Manually = Dialog.getCheckbox();
	MINell = Dialog.getNumber();
	MAXell = Dialog.getNumber();
}
Dialog.create("ImageJ-TRUEFAD-V0.8-Step2");
Dialog.addMessage("Macro started, you will have to select path to your raw images folder.");
Dialog.show();
dir = getDir("Choose the Directory for Input");
list = getFileList(dir);
Dialog.create("ImageJ-TRUEFAD-V0.8-Step3");
Dialog.addMessage("Now select path to the directory for myotubes extraction mask output.");
Dialog.show();
Output = getDir("Select the Directory for Output");
// Initialisation & folder oppening loop
run("Set Measurements...", "area mean min display redirect=None decimal=3");
	if(BMchoice == 1) {
	setBatchMode(true);
}
wait(SPD*500);
for (n=0; n<list.length; n++) {
	showProgress(n+1, list.length);
	open(dir+list[n]);
	//Image treatment and segmentation
	// Preprocessing for fluorescence
	if (IMGtype=="RGB MHC fluorescence of SKMDC cells") {
		name = getTitle();
		H=getHeight();
		W=getWidth();
		BS = Math.round(W/5);
		rename("A");
		//Channel spliting
		run("Split Channels");
		selectWindow("A (green)");
		close("A (blue)");
		close("A (red)");
		rename("B");
		run("Kuwahara Filter", "sampling=KUWAvalue");
		//CLAHE enhancement
		run("Duplicate...", " ");
		rename("B-1");
		run("Normalize Local Contrast", "block_radius_x=10 block_radius_y=10 standard_deviations=2 center stretch");
		selectWindow("B");
		run("Enhance Local Contrast (CLAHE)", "blocksize=BS histogram=256 maximum=CLAHEvalue mask=B-1");
		nCLAHEvalue = CLAHEvalue*2;
		nBS = BS/2;
		run("Enhance Local Contrast (CLAHE)", "blocksize=nBS histogram=256 maximum=nCLAHEvalue mask=B-1");
		close("B-1");
		run("32-bit");
		run("Morphological Filters", "operation=Dilation element=Disk radius=2");
		rename("mask");
		//Segmentation
		run("Extended Min & Max", "operation=[Extended Minima] dynamic=Tolerance connectivity=4");
		run("Connected Components Labeling", "connectivity=4 type=[float]");
		run("Impose Min & Max", "original=mask marker=mask-emin operation=[Impose Minima] connectivity=8");
		run("Marker-controlled Watershed", "input=mask-imp marker=mask-emin-lbl mask=None calculate use");
		run("Set Label Map", "colormap=Spectrum background=Black shuffle");
		//Closing unnecessary windows
		close("Morphological Segmentation");
		close("B");
		selectWindow("B");
		rename("Origin");
		selectWindow("B-Dilation-catchment-basins");
	}
	// Preprocessing for phase contrast
	if (IMGtype == "RGB phase contrast L6 or C2C12") {
		name = getTitle();
		H=getHeight();
		W=getWidth();
		BS = Math.round(W/5);
		nBS = Math.round(W/50);
		rename("A");
		// Saving the Inverted IMG
		run("Duplicate...", " ");
		wait(200*SPD);
		rename("Origin");
		run("Invert");
		wait(100*SPD);
		run("8-bit");
		run("RGB Color");
		// Directional Filtering
		selectWindow("A");
		run("Morphological Filters", "operation=[White Top Hat] element=Disk radius=20");
		run("16-bit");
		close("A");
		rename("A");
		// Enhance Local Contrast
		run("Duplicate...", " ");
		rename("A-1");
		run("Normalize Local Contrast", "block_radius_x=block_radius block_radius_y=block_radius standard_deviations=VARvalue center stretch");
		selectWindow("A");
		run("Enhance Local Contrast (CLAHE)", "blocksize=nBS histogram=256 maximum=CLAHEvalue mask=A-1");
		run("16-bit");
		// Hessian filter substraction
		run("FeatureJ Hessian", "largest absolute smoothing=2");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		imageCalculator("Difference create", "A","A largest Hessian eigenvalues");
		close("A largest Hessian eigenvalues");
		close("A");
		// Second directional filtering
		selectWindow("Result of A");
		rename("mask");
		// Segmentation
		run("Extended Min & Max", "operation=[Extended Minima] dynamic=Tolerance connectivity=4");
		run("Connected Components Labeling", "connectivity=4 type=[float]");
		run("Impose Min & Max", "original=mask marker=mask-emin operation=[Impose Minima] connectivity=8");
		run("Marker-controlled Watershed", "input=mask-imp marker=mask-emin-lbl mask=None calculate use");
		run("Set Label Map", "colormap=Spectrum background=Black shuffle");
		//Close unnecessary IMGS
		close("mask-imp");
		close("mask-emin-lbl");
		close("mask-emin");
		close("mask");
		close("A-1");
	}

	// Trimming
	// Size filtering
	run("Label Size Filtering", "operation=Greater_Than size=MINsize");
	wait(150*SPD);
	run("Label Size Filtering", "operation=Lower_Than size=MAXsize");
	wait(150*SPD);
	//If user wants to manually merge labels (Feat Dr. Lisa Guerrier)
	if(Manually == 1) {
		// Create an average to help visualize labels
		imageCalculator("Average create", "Origin","mask-imp-watershed-sizeFilt-sizeFilt");
		rename("MixLabel");
		close("mask-imp-watershed-sizeFilt");
		close("mask-imp-watershed");
		selectWindow("mask-imp-watershed-sizeFilt-sizeFilt");
		setTool("multipoint");
		run("Label Edition");		
		// Put windows side by side
		Xmix=screenWidth/2;
		selectWindow("MixLabel");
		setLocation(Xmix, 0);
		selectWindow("Label Edition");
		setLocation(0, 0);
		// Manual Edition message
		title = "Label merging step";
		msg = "Please, manually merge corresponding labels. Click on \"Done\" when finished and then click \"OK\" on this window.";
		waitForUser(title, msg);
		close("mask-imp-watershed-sizeFilt-sizeFilt");
		close("MixLabel");
		selectWindow("mask-imp-watershed-sizeFilt-sizeFilt-edited");
	}
	rename("Labels");
	// Removes potatoes particles
	run("Analyze Regions", "ellipse_elong.");
	Table.rename("Labels-Morphometry", "Results");
	run("Assign Measure to Label", "Results=Results column=Ellipse.Elong min=MINell max=MAXell");
	setOption("ScaleConversions", true);
	run("8-bit");
	setAutoThreshold("Default no-reset");
	run("Threshold...");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	selectWindow("Labels-Ellipse.Elong");
	// Process the image only if there is something to process
	Wo = getWidth();
	Ho = getHeight();
	makeRectangle(0, 0, Wo, Ho);
	run("Set Measurements...", "mean redirect=None decimal=3");
	run("Measure");
	Process = getValue("Mean");
	if(Process == 0) {
		abort = "No tubes found";
		Table.set("Mean", 1, abort);
		wait(100);
		run("Read and Write Excel", "no_count_column dataset_label="+name);
		run("Close All");
		run("Collect Garbage");
	} else {
		selectWindow("Labels-Ellipse.Elong");
		run("Select None");
		// Make a label map from binary image and isolate the center and orientation of each label
		run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
		run("Set Label Map", "colormap=Spectrum background=White");
		run("Label Size Filtering", "operation=Greater_Than size=MINsize");
		close("Labels-Ellipse-lbl");
		rename("Labels-Ellipse-lbl");
		//Preparing variables
		DiameterX = newArray();
		CorLabel = newArray();
		WidthC = getWidth() + BS;
		HeightC = getHeight() + BS;
		getPixelSize(unit, pw, ph);
		// preprocessing Lbl Image
		run("Oriented Bounding Box", "label=Labels-Ellipse-lbl image=Labels-Ellipse-lbl");
		Orient = Table.getColumn("Box.Orientation");
		run("Analyze Regions", "area");
		Area = Table.getColumn("Area");
		close("Labels-Ellipse-lbl-Morphometry");
		Table.rename("Labels-Ellipse-lbl-OBox", "LabelTable");
		selectWindow("Labels-Ellipse-lbl");
		run("Canvas Size...", "width=WidthC height=HeightC position=Center");
		selectWindow("LabelTable");
		Label = Table.getColumn("Label");
		// Measurement for each Label
		for (i = 0; i < Label.length; i++) {
			selectWindow("LabelTable");
			X = Table.get("Box.Center.X",i)/pw;
			Y = Table.get("Box.Center.Y",i)/pw;
			L = Table.get("Box.Length",i)/pw;
			W = Table.get("Box.Width",i)/pw;
			A = (Table.get("Box.Orientation",i)-90)*(PI/180);
			// Calculate the first center of the bounding box
			X1 = X-(sin(A)*(L/2))+(BS/2);
			Y1 = Y+(cos(A)*(L/2))+(BS/2);
			// Calculate the second center of the bounding box
			X2 = X+(sin(A)*(L/2))+(BS/2);
			Y2 = Y-(cos(A)*(L/2))+(BS/2);
			// Make the Oriented bounding box
			selectWindow("Labels-Ellipse-lbl");
			wait(50*SPD);
			makeRotatedRectangle(X1, Y1, X2, Y2, W);
			wait(50*SPD);
			// Extract the label
			run("Duplicate...", "title=Isolation"+i);
			wait(100*SPD);
			Wi = getWidth();
			Hi = getHeight();
			Areai = Wi*Hi;
			// Continue if this is not a noise
			if (Areai > 100) {
				run("Set Measurements...", "mean redirect=None decimal=3");
				run("8-bit");
				wait(50*SPD);
				run("Keep Largest Label");
				wait(50*SPD);
				run("Invert");
				wait(50*SPD);
				run("Fill Holes");
				wait(50*SPD);
				run("Invert");
				wait(50*SPD);
				rename("IsolationCor"+i);
				// Make the 9 measurements
				for (u = 1; u < 10; u++) {
					makeLine((u*L)/10, 0, (u*L)/10, W);
					run("Measure");
				}
				selectWindow("Results");
				Diameter = newArray();
				for (m = 0; m < 9; m++) {
					Diameter = (Table.get("Mean", m)/255)*W;
					Table.set("Diameter", m, Diameter);
					Table.update;
					// Save measurement of the label as an array
					DiameterX = Array.concat(DiameterX, Diameter);
				}
				for (k = 1; k < 10; k++) {
					CorLabel = Array.concat(CorLabel, i+1);
				}
			}
			close("Isolation"+i);
			close("IsolationCor"+i);
			run("Clear Results");
		}
		// Make the Result table for the current image
		Table.showArrays("Diameters", CorLabel, DiameterX, Orient, Area);
		Table.rename("Diameters", "Results");
		run("Read and Write Excel", "no_count_column dataset_label="+name);
		// Creating spectrum output
		close("LabelTable");
		close("Labels-Ellipse-lbl");
		close("Results");
		setBatchMode("exit and display");
		wait(200*SPD);
		selectWindow("Labels-Ellipse.Elong");
		// Make a label map from binary image and isolate the center and orientation of each label
		run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
		run("8-bit");
		wait(100);
		run("Set Label Map", "colormap=Spectrum background=White");
		// Overlay all Labels
		wait(200);
		setFont("SansSerif", 25, "bold");
		run("Analyze Regions", "centroid");
		wait(200*SPD);
		Table.rename("Labels-Ellipse-lbl-Morphometry", "Results");
		for (t = 0; t < Table.size; ++t) {
			selectWindow("Results");
			Label = Table.get( "Label", t );
			x = Table.get( "Centroid.X", t );
			y = Table.get( "Centroid.Y", t );
			toUnscaled(x, y);
			selectWindow("Labels-Ellipse-lbl");
			Overlay.drawString(t+1, x-5, y-5);
			Overlay.show();
			wait(25*SPD);
		}
		run("Overlay Options...", "stroke=white width=5 fill=black set apply");
		wait(100*SPD);
		run("Flatten");
		wait(150*SPD);
		rename("Labeled");
		// Saving average mask to the second directory
		imageCalculator("Average create", "Origin","Labeled");
		selectWindow("Result of Origin");
		rename("Myotubes-"+name);
		Myotubes = getTitle();
		run("Input/Output...", "jpeg=80 gif=-1 file=.csv use_file copy_row save_column save_row");
		saveAs("jpeg",Output+Myotubes);
		// Close everything
		run("Close All");
		run("Collect Garbage");
		run("Clear Results");
	}
}

if(BMchoice == 1) {
	setBatchMode("exit and display");
}

// Final message
showMessage("TRUEFAD has now finished the job");
showMessage("Please find on your desktop all the datas as an XLX spreadsheet");
showMessage("and in the second directory that you have chosen, all the myotubes found for each image.");
showMessage("Have a nice day! - Code written by Aurelien BRUN - ASMS Clermont-Ferrand");
