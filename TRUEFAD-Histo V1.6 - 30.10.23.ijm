requires("1.53f");
toolname = "ImageJ-TRUEFAD Histo";
version = "V1.6";
	
// Dialogs
//Dependancies
showMessage("TRUEFAD Histo requires up to date MORPHOLIBJ and ReadAndWriteExcel package");
//Macro starting choice
ChoiceTree = newArray("Import and work on label image", "Segmentation of laminin image", "Type atribution Laminin+Type1+Type2A", "Type atribution Laminin+Type1+Type2A+Type2X");
Dialog.create(toolname + "-" + version);
	Dialog.addChoice("What do you want to do ?", ChoiceTree);
	Dialog.show();
	UserChoice = Dialog.getChoice();
//Pipeline for "Import and work on label image" 
if (UserChoice == "Import and work on label image") {
	waitForUser(toolname + version + "Label_Edition_Pipeline", "Open or drag your image on FIJI, then click on OK");
	//Macro starting choice
	var i = 0;
	do {
		var temp = 0;
		ChoiceEdition = newArray("Label edition", "Remove a specific label or group of labels", "Looking for a label" , "Labels to ROI");
		Dialog.create(toolname + "-" + version + "-Label_Edition_Pipeline");
			Dialog.addChoice("What do you want to do ?", ChoiceEdition);
			Dialog.show();
			UserEdition = Dialog.getChoice();
			name = getTitle();
		if (UserEdition == "Label edition") {
			run("Label Edition");
			close(name);
		}
		if (UserEdition == "Remove a specific label or group of labels") {
			run("Replace/Remove Label(s)");
			DelAgain = 1;
			do{waitForUser;
			showMessageWithCancel("Remove other labels?");
			run("Replace/Remove Label(s)");
			} while (DelAgain == 1);
		}
		if (UserEdition == "Looking for a Label") {
			rename("A");
			run("Set Label Map", "colormap=Ice background=Black");
			run("Analyze Regions", "centroid");
			Table.rename("A-Morphometry", "Results");
			for (t = 0; t < Table.size; ++t) {
				selectWindow("Results");
				Label = Table.get( "Label", t );
				x = Table.get( "Centroid.X", t );
				y = Table.get( "Centroid.Y", t );
				toUnscaled(x, y);
				selectWindow("A");
				Overlay.drawString(t, x-5, y-5);
				Overlay.show();
			}
			run("Overlay Options...", "stroke=white width=5 fill=black set apply");
			//Asking for label number
			Dialog.create("Specify target");
			Dialog.addNumber("What label are you looking for?", 0);
			Dialog.show();
			UserLabel = Dialog.getNumber();
			//Looking for label number
			selectWindow("Results");
			Label = Table.get( "Label", UserLabel );
			x = Table.get( "Centroid.X", UserLabel );
			y = Table.get( "Centroid.Y", UserLabel );
			toUnscaled(x, y);
			selectWindow("A");
			doWand(x, y);
			Overlay.show();
			SearchAgain=1;
			do{waitForUser;
			showMessageWithCancel("Search again","Look for an other label?");
			Dialog.create("Specify target");
			Dialog.addNumber("What label are you looking for?", 0);
			Dialog.show();
			UserLabel = Dialog.getNumber();
			x = Table.get( "Centroid.X", UserLabel );
			y = Table.get( "Centroid.Y", UserLabel );
			toUnscaled(x, y);
			selectWindow("A");
			doWand(x, y);
			Overlay.show();
			} while (SearchAgain == 1);
		}
		if (UserEdition == "Labels to ROI") {
			roiManager("reset");
			rename("A");
			run("Analyze Regions", "centroid");
			Table.rename("A-Morphometry", "Results");
			for (t = 0; t < Table.size; ++t) {
				selectWindow("Results");
				Label = Table.get( "Label", t );
				x = Table.get( "Centroid.X", t );
				y = Table.get( "Centroid.Y", t );
				toUnscaled(x, y);
				selectWindow("A");
				doWand(x, y);
				roiManager("Add");
			}
			roiManager("Show All");
			roiManager("Save",getDir(name)+".zip");
		}
		waitForUser(toolname + version + "Label_Edition_Pipeline", "Click ok here when your job is done");
		SuplEdition = newArray("Save that image", "Edit another time this label image");
		Dialog.create(toolname + "-" + version + "-Label_Edition_Pipeline");
		Dialog.addChoice("Do you want to ", SuplEdition);
		Dialog.show();
		UserSuplEdition = Dialog.getChoice();
		if (UserSuplEdition == "Save that image") {
		saveAs("Tiff",getDir("file")+ name + "Edited");*
		run("Close All");
		i = 1;
		}
		if (UserSuplEdition == "Edit another time this image") {
		}
	} while (i == 0);
}
// Create a variable that allows the start of the main Pipeline for fiber type attribution T1vsT2A and T1vsT2AvsT2B/X
MainPipeline = 0;
Type4 = 0;
if (UserChoice == "Type atribution Laminin+Type1+Type2A") {
	MainPipeline = 1;
}
if (UserChoice == "Type atribution Laminin+Type1+Type2A+Type2X") {
	MainPipeline = 1;
	Type4 = 1;
}
if (MainPipeline == 1) {
	//Pipeline for "Segmentation of laminin image", "Type atribution Laminin+Type1+Type2A", "Type atribution Laminin+Type1+Type2A+Type2X"
	//Step1
	Dialog.create(toolname + "-" + version + "-Step1");
		Dialog.addMessage("Macro started, you will have to select path to your \"8-BIT\" raw fluorescence images folder");
		Dialog.show();
		dir1 = getDir("Choose your cell border directory (=Laminin/Dystrophin)");
		listBorder = getFileList(dir1);
		dir2 = getDir("Select your Type1 directory (=BAF8)");
		listType1 = getFileList(dir2);
		dir3 = getDir("Also your Type2A directory (=SC71)");
		listType2A = getFileList(dir3);
	if (Type4 == 1) {
		dir4 = getDir("Finally your Type2B/2X directory");
		listType2B = getFileList(dir4);
		};
	//Step2
	Dialog.create(toolname + "-" + version + "-Step2");
		Dialog.addMessage("Now select path to the directory for Composite/Label Map output.");
		Dialog.show();
		Output = getDir("Directory for Output");
	if (Type4 == 0) {
	//Step3.DeltaComparison
	Dialog.create(toolname + "-" + version + "-Step3");
		Dialog.addMessage("During the image processing, type 2a signal is substracted from type 1 signal");
		Dialog.addMessage("A positive sum means the cell might be type 1");
		Dialog.addMessage("A negative sum means the cell might be type 2a");
		Dialog.addMessage("When the result is close to 0 the plugin atribute the cell to 2b type"); 
		Dialog.addMessage("Select the minor threshold attributed to the Type 1");
		Dialog.addNumber("The Type1 range from [X to +1]", 0.2);
		Dialog.addMessage("Select the upper threshold attributed to the Type 2a");
		Dialog.addNumber("The Type2a range from [-1 to Y]", -0.2);
		Dialog.addMessage("Type 2b range between Y and X");
		Dialog.show();
		Type1THR = Dialog.getNumber();
		Type2aTHR = Dialog.getNumber();
	};
	if (Type4 == 1) {
	//Step3.ThreeFibers
	Dialog.create(toolname + "-" + version + "-Step3");
		Dialog.addMessage("During the image processing, type 1, 2A and 2B/X grey value signal is exported to excel");
		Dialog.addMessage("This let you attribuate the fiber type on your side as well as mixed fibers");
	};
	//Step4
	Dialog.create(toolname + "-" + version + "-Step4");
		Dialog.addMessage("The plugin try to automatically normalize the signal between each fluorescence image");
		Dialog.addMessage("If after some tries you can't adjust your threshold value to your images");
		Dialog.addMessage("you may want to amplify the normalization process to one type or the other");
		Dialog.addSlider("Boost Type 1 signal", 0, 10, 0);
		Dialog.addSlider("Boost Type 2A signal", 0, 10, 0);
		if (Type4 == 1) {
		Dialog.addSlider("Boost Type 2B/X signal", 0, 10, 0);
		}
		Dialog.addCheckbox("Artificially enhance laminin edges", false);
		Dialog.addNumber("Directional median filter power", 20);
		Dialog.addMessage("Tolerance for the segmentation process");
		Dialog.addSlider("Tolerance", 0, 100, 20);
		Dialog.addMessage("Min and Max pixel area of your fibers");
		Dialog.addNumber("Min label Area", 2000);
		Dialog.addNumber("Max label Area", 200000);
		Dialog.addNumber("Max label Ellongation", 4);
		Dialog.addNumber("Label Erosion", 3);
		Dialog.addCheckbox("Manually edit labels post filtering", false);
		Dialog.addCheckbox("Save automatically label map", false);
		Dialog.addCheckbox("Save automatically ROI", false);
		Dialog.addNumber("Set scale (number of pixels/µm)", 1);	
		Dialog.addMessage("Rate the performance of your machine. Plugin will take it in consideration for the processing speed");
		Dialog.addSlider("Slow (1) to Fast (5)", 1, 5, 2);
		Dialog.addCheckbox("Enable batch mode", true);
		Dialog.show();
		Type1Boost = Dialog.getNumber();
		Type2aBoost = Dialog.getNumber();
		if (Type4 == 1) {
		Type2bBoost = Dialog.getNumber();
		}
		FindEdges = Dialog.getCheckbox();	
		Median = Dialog.getNumber();
		Tolerance = Dialog.getNumber();
		MINsize = Dialog.getNumber();
		MAXsize = Dialog.getNumber();
		MAXell = Dialog.getNumber();
		Erosion = Dialog.getNumber();
		Manually = Dialog.getCheckbox();
		LabelSaving = Dialog.getCheckbox();
		ROISaving = Dialog.getCheckbox();
		umScale = Dialog.getNumber();
		SPEED  = Dialog.getNumber();
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
	//Step5
	Dialog.create(toolname + "-" + version + "-Step5");
		Dialog.addMessage("Wait for a textbox to appear when the job will be done");
		Dialog.show();	
	// Batch processing loop
	for (n=0; n<listBorder.length; n++) {
		showProgress(n+1, listBorder.length);
		// Treatment of the Laminin image
		if(BMchoice == 1){
			setBatchMode(true);
		}
		wait(SPD*300);
		open(dir1+listBorder[n]);
		wait(SPD*500);
		name = getTitle();
		rename("0");
		run("8-bit");
		if(FindEdges == 1)
		{
		run("Find Edges");
		}
		run("Directional Filtering", "type=Max operation=Median line=Median direction=15");
		run("8-bit");
		close("0");
		rename("1");
		H=getHeight();
		W=getWidth();
		makeRectangle(0, 0, W, H);
		run("Set Measurements...", "mean redirect=None decimal=3");
		run("Measure");
		selectWindow("Results");
		Greyvalue = Table.get("Mean",0);
		CLAHEvalue = (Greyvalue/60)/0.05;
		LamCLAHE = CLAHEvalue/2;
		BS = Math.round(W/5);
		selectWindow("1");
		run("Select None");
		if(Greyvalue <= 50){
		run("Enhance Local Contrast (CLAHE)", "blocksize=BS histogram=256 maximum=LamCLAHE mask=*None*");
		}
		run("Directional Filtering", "type=Max operation=Erosion line=Median direction=15");
		close("1");
		rename("1");
		wait(SPD*200);
		run("Clear Results");
		//Treatment of the Type 1 image
		open(dir2+listType1[n]);
		wait(SPD*500);
		rename("2");
		run("Median...", "radius=2");
		run("8-bit");
		makeRectangle(0, 0, W, H);
		run("Measure");
		selectWindow("Results");
		Greyvalue = Table.get("Mean",0);
		CLAHEvalue = ((Greyvalue/60)/0.07)+Type1Boost;
		selectWindow("2");
		run("Select None");
		if(Greyvalue <= 45){
		run("Enhance Local Contrast (CLAHE)", "blocksize=BS histogram=256 maximum=CLAHEvalue mask=*None*");
		}
		wait(SPD*200);
		run("Clear Results");
		//Treatment of the Type 2a image
		open(dir3+listType2A[n]);
		wait(SPD*500);
		rename("3");
		run("Median...", "radius=2");
		run("8-bit");
		makeRectangle(0, 0, W, H);
		run("Measure");
		selectWindow("Results");
		Greyvalue = Table.get("Mean",0);
		CLAHEvalue = ((Greyvalue/60)/0.07)+Type2aBoost;
		selectWindow("3");
		run("Select None");
		if(Greyvalue <= 45){
		run("Enhance Local Contrast (CLAHE)", "blocksize=BS histogram=256 maximum=CLAHEvalue mask=*None*");
		}
		wait(SPD*200);
		run("Clear Results");
		//Treatment of the Type 2b/x image
		if (Type4 == 1) {
		open(dir4+listType2B[n]);
		wait(SPD*500);
		rename("4");
		run("Median...", "radius=2");
		run("8-bit");
		makeRectangle(0, 0, W, H);
		run("Measure");
		selectWindow("Results");
		Greyvalue = Table.get("Mean",0);
		CLAHEvalue = ((Greyvalue/60)/0.07)+Type2bBoost;
		selectWindow("4");
		run("Select None");
		if(Greyvalue <= 45){
		run("Enhance Local Contrast (CLAHE)", "blocksize=BS histogram=256 maximum=CLAHEvalue mask=*None*");
		}
		wait(SPD*200);
		run("Clear Results");
		}
		//Images to stack
		run("Images to Stack", "name=Stack title=[] use");
		wait(SPD*500);
		rename("Stack");
		//Segmentation
		run("Duplicate...", "use");
		rename("mask");
		run("Extended Min & Max", "operation=[Extended Minima] dynamic=Tolerance connectivity=4");
		run("Connected Components Labeling", "connectivity=4 type=[float]");
		run("Impose Min & Max", "original=mask marker=mask-emin operation=[Impose Minima] connectivity=4");
		run("Marker-controlled Watershed", "input=mask-imp marker=mask-emin-lbl mask=None calculate use");
		run("Set Label Map", "colormap=Spectrum background=Black shuffle");
	// Trimming
		// Size filtering
		run("Set Scale...", "distance=umScale known=1 unit=µm");
		run("Label Size Filtering", "operation=Greater_Than size=MINsize");
		wait(SPD*100);
		run("Label Size Filtering", "operation=Lower_Than size=MAXsize");
		wait(SPD*100);
		rename("Labels");
		// Remove border labels
		run("Kill Borders");
		close("Labels");
		rename("Labels");
		//Close unnecessary IMGS
		close("mask-imp");
		close("mask-emin");
		close("mask-emin-lbl");
		close("mask-imp-watershed");
		close("mask-imp-watershed-sizeFilt");
		close("mask-imp-watershed-sizeFilt-sizeFilt");
		// Apply Geodesic Ellongation filtering
		run("Geodesic Diameter", "label=Labels distances=[Chessknight (5,7,11)] image=Labels");
		Table.rename("Labels-GeodDiameters", "Results");
		wait(SPD*100);
		run("Assign Measure to Label", "Results=Results column=GeodesicElongation min=1 max=MAXell");
		wait(SPD*100);
		setOption("ScaleConversions", true);
		// Create a mask
		run("8-bit");
		setAutoThreshold("Otsu dark");
		run("Threshold...");
		setThreshold(1, 254);
		run("Convert to Mask");
		rename("Temp");
		run("Morphological Filters", "operation=Erosion element=Disk radius=Erosion");
		rename("Temp-E");
		close("Labels");
		run("Connected Components Labeling", "connectivity=4 type=float");
		run("Set Label Map", "colormap=Spectrum background=Black shuffle");
		rename("Labels");
		close("Labels-GeodesicElongation");
		close("Temp");
		close("Temp-E");
		//If user wants to manually merge labels
		if(Manually == 1)
		{
		// Create an average to help visualize labels
			selectWindow("mask");
			run("Invert");
			run("RGB Color");
			imageCalculator("Average create", "mask","Labels");
			selectWindow("Labels");
			run("Label Boundaries");
			run("RGB Color");
			imageCalculator("Max create", "Result of mask","Labels-bnd");
			close("Labels-bnd");
			close("Result of mask");
			rename("MixLabel");
			if(BMchoice == 1)
			{
			setBatchMode("exit and display");
			}
			selectWindow("Labels");
			setTool("multipoint");
			run("Label Edition");		
		// Put windows side by side
			Xmix=screenWidth/2;
			selectWindow("MixLabel");
			setLocation(Xmix, 0);
			selectWindow("Label Edition");
			setLocation(0, 0);
		// Manual Edition message
			title2 = "Label editing step";
			msg2 = "Please, manually edit corresponding labels. Click on \"Done\" on the left window when finished and then click \"OK\" on this window.";
			beep();
			waitForUser(title2, msg2);
			selectWindow("Labels-edited");
			close("mask");
			close("MixLabel");
			close("Labels");
			if(BMchoice == 1)
			{
			setBatchMode(true);
			}
		}
		rename("Labels");
		if(LabelSaving == 1)
		{
		run("Set Scale...", "distance=umScale known=1 unit=µm");
		saveAs("Tiff",Output+name+"LabelMap");
		}
		setOption("ScaleConversions", true);
		// Create a mask
		run("8-bit");
		setAutoThreshold("Otsu dark");
		run("Threshold...");
		setThreshold(1, 254);
		run("Convert to Mask");
		// Import the mask to the ROI Manager and measure Area and perimeter
		run("Set Scale...", "distance=umScale known=1 unit=µm");
		run("Analyze Particles...", "size=0.01-Infinity circularity=0.20-1.00 clear add");
		rename("BinaryMask");
		run("Set Measurements...", "area perimeter shape feret's redirect=None decimal=3");
		roiManager("Measure");
		selectWindow("Results");
		Area = Table.getColumn("Area");
		Perimeter = Table.getColumn("Perim.");
		Circularity = Table.getColumn("Circ.");
		Roundness = Table.getColumn("Round");
		Feret = Table.getColumn("MinFeret");
		if(ROISaving == 1)
		{
		roiManager("Save",Output+name+".zip");
		}
		close("Results");
		// Measure mean gray intensity for each label on each slice
		run("Set Measurements...", "mean redirect=None decimal=3");
		// For type1
		selectWindow("Stack");
		run("Next Slice [>]");
		roiManager("Show All");
		roiManager("Measure");
		selectWindow("Results");
		Type1 = Table.getColumn("Mean");
		close("Results");
		// For type2a
		selectWindow("Stack");
		run("Next Slice [>]");
		roiManager("Show All");
		roiManager("Measure");
		selectWindow("Results");
		Type2A = Table.getColumn("Mean");
		if (Type4 == 1) {
			// For type2b
			selectWindow("Stack");
			run("Next Slice [>]");
			roiManager("Show All");
			roiManager("Measure");
			selectWindow("Results");
			Type2B = Table.getColumn("Mean");
			// Sum up everything and write an Excel Speadsheet for T1vsT2AvsT2B/X
			Table.showArrays("Measures", Area, Perimeter, Feret, Circularity, Roundness, Type1, Type2A, Type2B);
			Table.rename("Measures", "Results");
			run("Read and Write Excel", "dataset_label="+name);
			// Make the Composite with area of each cell and save it
			selectWindow("Stack");
			run("Make Composite", "display=Color");
			Stack.setChannel(2);
			run("Blue");
			Stack.setChannel(3);
			run("Green");
			Stack.setChannel(4);
			run("Magenta");
			run("Split Channels");
			run("Merge Channels...", "c1=C1-Stack c2=C2-Stack c3=C3-Stack c4=C4-Stack create");
			run("From ROI Manager");
			run("Flatten");
			wait(500*SPD);
			rename("TRUEFAD(B=T1-G=T2A-M=T2BX)-"+name);
			Fibers = getTitle();
			saveAs("Tiff",Output+Fibers);
			// Close everything
			run("Close All");
			close("Results");
			roiManager("reset");
			run("Collect Garbage");
		}
		if (Type4 == 0) {
			// Sum up everything and write an Excel Speadsheet
			Table.showArrays("Measures", Area, Perimeter, Feret, Circularity, Roundness, Type1, Type2A);
			Table.rename("Measures", "Results");
			// Establish the probability for typing
			for (i = 0; i < Type1.length; i++)
			{
				a = Table.get("Type1",i);
				b = Table.get("Type2A",i);
				Delta=(a/255)-(b/255);
				c = a/255;
				d = (b/255)*(-1);
				// Establish the type
				var LabelValue = -1;	
				if(Delta>Type1THR){
					LabelValue = 0;
					Type = "Type1";
				}
				if(Delta<Type2aTHR){
					LabelValue = 1;
					Type = "Type2A";		
				}
				if(LabelValue<-0.1){ 
					LabelValue = 2;
					Type = "Type2B/X";	
				}
				if((LabelValue==2) & (c>Type1THR) & (d<Type2aTHR)){ 
				LabelValue = 3;
				Type = "Hybrid";
				}
				Table.set("Probability", i, Delta);
				Table.set("Type", i, Type);
				Table.set("LabelValue", i, LabelValue);
				Table.update;
			}
			// Saving the spreadsheet
			run("Read and Write Excel", "dataset_label="+name);
			// Make the Composite with area of each cell and save it
			selectWindow("Stack");
			run("Make Composite", "display=Color");
			Stack.setChannel(2);
			run("Blue");
			Stack.setChannel(3);
			run("Green");
			run("Split Channels");
			run("Merge Channels...", "c1=C1-Stack c2=C2-Stack c3=C3-Stack create");
			run("From ROI Manager");
			run("Flatten");
			wait(500*SPD);
			rename("TRUEFAD(Blue=T1&Green=T2A)-"+name);
			Fibers = getTitle();
			saveAs("Tiff",Output+Fibers);
			// Close everything
			run("Close All");
			close("Results");
			roiManager("reset");
			run("Collect Garbage");
		}
	if(BMchoice == 1){
	setBatchMode("exit and display");
	}
	}
}
// Pipeline for rapid segmentation of laminin image
if (UserChoice == "Segmentation of laminin image") {
		// Dialogs
	Dialog.create(toolname + "-" + version + "-Step1");
	Dialog.addCheckbox("Artificially enhance laminin edges", false);
	Dialog.addNumber("Directional median filter power", 20);
	Dialog.addMessage("Tolerance for the segmentation process");
	Dialog.addSlider("Tolerance", 0, 100, 20);
	Dialog.addNumber("Min label Area", 2000);
	Dialog.addNumber("Max label Area", 200000);
	Dialog.addNumber("Max label Ellongation", 4);
	Dialog.addNumber("Label Erosion", 3);
	Dialog.addCheckbox("Save automatically label map", false);
	Dialog.addNumber("Set scale (number of pixels/µm)", 1);	
	Dialog.show();
	FindEdges = Dialog.getCheckbox();	
	Median = Dialog.getNumber();
	Tolerance = Dialog.getNumber();
	MINsize = Dialog.getNumber();
	MAXsize = Dialog.getNumber();
	MAXell = Dialog.getNumber();
	Erosion = Dialog.getNumber();
	LabelSaving = Dialog.getCheckbox();
	umScale = Dialog.getNumber();
	waitForUser(toolname + version + "Rapid_Segmentation_Pipeline", "Open or drag your 8-BIT image on FIJI, then click on OK");
	// Laminin preprocessing
	name = getTitle();
	rename("0");
	run("8-bit");
	if(FindEdges == 1)
	{
	run("Find Edges");
	}
	run("Directional Filtering", "type=Max operation=Median line=Median direction=15");
	run("8-bit");
	close("0");
	rename("A");
	H=getHeight();
	W=getWidth();
	makeRectangle(0, 0, W, H);
	run("Set Measurements...", "mean redirect=None decimal=3");
	run("Measure");
	selectWindow("Results");
	Greyvalue = Table.get("Mean",0);
	CLAHEvalue = (Greyvalue/60)/0.05;
	LamCLAHE = CLAHEvalue/2;
	BS = Math.round(W/5);
	selectWindow("A");
	run("Select None");
	if(Greyvalue <= 50)
	{
	run("Enhance Local Contrast (CLAHE)", "blocksize=BS histogram=256 maximum=LamCLAHE mask=*None*");
	}
	run("Directional Filtering", "type=Max operation=Erosion line=Median direction=15");
	close("A");
	rename("A");
	run("Clear Results");
	// Segmentation
	run("Extended Min & Max", "operation=[Extended Minima] dynamic=Tolerance connectivity=4");
	run("Connected Components Labeling", "connectivity=4 type=[float]");
	run("Impose Min & Max", "original=A marker=A-emin operation=[Impose Minima] connectivity=4");
	run("Marker-controlled Watershed", "input=A-imp marker=A-emin-lbl mask=None calculate use");
	run("Set Label Map", "colormap=Spectrum background=Black shuffle");
	// Size filtering
	run("Set Scale...", "distance=umScale known=1 unit=µm");
	run("Label Size Filtering", "operation=Greater_Than size=MINsize");
	run("Label Size Filtering", "operation=Lower_Than size=MAXsize");
	rename("Labels");
	// Remove border labels
	run("Kill Borders");
	close("Labels");
	//Close unnecessary IMGS
	close("A-imp");
	close("A-emin");
	close("*A-emin-lbl");
	close("A");	
	rename("Labels");
	// Apply Geodesic Ellongation filtering
	run("Geodesic Diameter", "label=Labels distances=[Chessknight (5,7,11)] image=Labels");
	Table.rename("Labels-GeodDiameters", "Results");
	run("Assign Measure to Label", "Results=Results column=GeodesicElongation min=1 max=MAXell");
	setOption("ScaleConversions", true);
	// Create a mask
	run("8-bit");
	setAutoThreshold("Otsu dark");
	run("Threshold...");
	setThreshold(1, 254);
	run("Convert to Mask");
	close("Labels");
	run("Connected Components Labeling", "connectivity=4 type=float");
	run("Set Label Map", "colormap=Spectrum background=Black shuffle");
	rename("Labels");
	run("Set Scale...", "distance=umScale known=1 unit=µm");
	close("Labels-GeodesicElongation");
	close("A-imp-watershed-sizeFilt");
	close("A-imp-watershed");
	run("Morphological Filters", "operation=Erosion element=Disk radius=Erosion");
	close("Labels");	
	rename("Labels");
	if(LabelSaving == 1)
		{
		Dialog.create(toolname + "-" + version + "-Step2");
		Dialog.addMessage("Select path to the directory for Label map output.");
		Dialog.show();
		Output = getDir("Directory for Output");
		saveAs("Tiff",Output+name+"LabelMap");
		}
}
// Final message
showMessage("TRUEFAD-histo has now finished the job!");
showMessage("Please find on your desktop and directories all the datas and IMGs obtained");
showMessage("Have a nice day! - Code written by Aurelien BRUN - ASMS Clermont-Ferrand");

