name = getTitle();
H=getHeight();
W=getWidth();
BS = Math.round(W/5);
nBS = Math.round(W/50);
CLAHEvalue = 25;
block_radius = 2;
VARvalue = 1;
SPD = 3;
Tolerance = 80;
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
