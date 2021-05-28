batchMode=true;
outputFolder="_Output";

// Set measurements
run("Set Measurements...", "area shape display redirect=None decimal=3");
//PROCESS 
setBatchMode(batchMode);
directory = getDirectory("Choose folder with the images"); 
dirParent = File.getParent(directory);
dirName = File.getName(directory);
dirOutput = dirParent+File.separator+dirName+outputFolder;
if (File.exists(dirOutput)==false) {
  	File.makeDirectory(dirOutput); // new output folder
}
files=getFileList(directory);

// Length and width of posit
lengthP = -1;
widthP = -1;

Dialog.create("Posit colour");
types = newArray("pink", "yellow");
Dialog.addChoice("Units:", types);
typesThreshold = newArray("Default", "Minimum");
Dialog.addChoice("Threshold:", typesThreshold);
Dialog.addCheckbox("Objects in border:", false);
Dialog.show();
positColour = Dialog.getChoice();
threshold = Dialog.getChoice();
border = Dialog.getCheckbox();

areas = newArray(files.length);
for (i=0; i<files.length; i++) {

	if(endsWith(files[i],".jpg") || endsWith(files[i],".JPG"))
	{

		showProgress(i, files.length);
		open(directory+File.separator+files[i]);
		run("Set Scale...", "distance=0 known=0 unit=pixel global");
		title=getTitle();
		print("Processing... "  + title);
		run("Duplicate...", " ");
		rename("dup_"+title);
		selectWindow(title);
		run("Duplicate...", " ");


		// Measure posit
		rename("posit_"+title);
		selectWindow("posit_"+title);
		run("Colour Deconvolution", "vectors=[Methyl Green DAB]");
		
		
		if(positColour=="yellow"){
			selectWindow("posit_"+title+"-(Colour_3)");
			close();
			selectWindow("posit_"+title+"-(Colour_2)");
			close();
			selectWindow("posit_"+title+"-(Colour_1)");
			setThreshold(255, 255);
			setOption("BlackBackground", true);
			run("Convert to Mask");
		}

		if(positColour=="pink"){
			selectWindow("posit_"+title+"-(Colour_1)");
			close();
			selectWindow("posit_"+title+"-(Colour_2)");
			close();
			selectWindow("posit_"+title+"-(Colour_3)");
			setAutoThreshold("Default");
			setOption("BlackBackground", true);
			run("Convert to Mask");
		}
		
		
		

		// Select biggest roi
		run("Analyze Particles...", "size=1000-Infinity exclude add");
		roiManager("Show All without labels");
		roiManager("Select", 0); 

		

		//waitForUser("","check the segmentation");
		run("Fit Rectangle");
		run("Measure");
		rrlength = getResult("RRLength", 0);
		rrwidth = getResult("RRWidth", 0);
		
		//selectWindow("ROI Manager");
		
		if(isOpen("Results")){
			selectWindow("Results");
			run("Close");
		}
		
		if(lengthP<0){

			  Dialog.create("Posit size");
			  types = newArray("mm", "cm");

			  if(positColour=="yellow"){
					Dialog.addNumber("Width:", 51);
			        Dialog.addNumber("Height:", 38);
				}

			 if(positColour=="pink"){
				Dialog.addNumber("Width:", 40);
			    Dialog.addNumber("Height:", 40);
			 }
			  
			  
			  Dialog.addChoice("Units:", types);
			  Dialog.show();
			  unit = Dialog.getChoice();
			  widthP = Dialog.getNumber();
			  lengthP = Dialog.getNumber();;

			  
			
		}

		if(widthP>lengthP){
			maxWidthLengthP = widthP;
		}else{
			maxWidthLengthP = lengthP;
		}

		if(widthP>lengthP){
			maxWidthLengthP = widthP;
		}else{
			maxWidthLengthP = lengthP;
		}

		if(rrlength>rrwidth){
			maxwidthlengthScale = rrlength;
		}else{
			maxwidthlengthScale = rrwidth;	
		}

		
		
		run("Set Scale...", "distance=" + maxwidthlengthScale +" known=" + maxWidthLengthP +" unit=" + unit + " global");

		
		selectWindow(title);

		 if(positColour=="yellow"){
		 	roiManager("Select", 0); 
			setBackgroundColor(255, 255, 255);
			run("Clear", "slice");
		}
		roiManager("reset");

		/*run("HSB Stack");
		run("Stack to Images");
		selectWindow("Hue");
		close();
		selectWindow("Brightness");
		close();

		selectWindow("Saturation");
		setAutoThreshold("MaxEntropy dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");*/


		run("Colour Deconvolution", "vectors=[Methyl Green DAB]");
		
		
		
		selectWindow(title+"-(Colour_1)");
		close();
		selectWindow(title+"-(Colour_3)");
		close();
		selectWindow(title+"-(Colour_2)");
		setAutoThreshold(threshold);//Minimum
		setOption("BlackBackground", true);
		run("Convert to Mask");

		
		/*
		run("Split Channels");
		selectWindow(title+" (blue)");
		close();
		selectWindow(title+" (green)");
		close();
		selectWindow(title+" (red)");
		setAutoThreshold("Default");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		*/

		//run("Fill Holes");
		run("Erode");
		run("Erode");
		run("Dilate");
		run("Dilate");
		// Si sabemos que no toca los bordes, habría que incluir el exclude
		if(border){
			run("Analyze Particles...", "size=10-Infinity display add");
		}else{
			run("Analyze Particles...", "size=10-Infinity display exclude add");
		}
		c = roiManager("count");

		if(c==0){
			run("Analyze Particles...", "size=10-Infinity display add");
		}


		
		selectWindow(title+"-(Colour_2)");
		close();
		selectWindow("dup_"+title);


		

		
		roiManager("Set Color", "red");
		roiManager("Set Line Width", 10);
		roiManager("Show All without labels");
		roiManager("Draw");
		selectWindow("dup_"+title);
		saveAs("Jpeg",dirOutput+File.separator+title);
		//close();
		
		//waitForUser("","check the segmentation");
		//roiManager("Measure");

		
		saveAs("Results", dirOutput+File.separator+title+".csv");

		totalArea = 0.0;
		for (j = 0; j < nResults();j++) {
		    v = getResult('Area', j);
    		totalArea = totalArea + v;
		}

		
		areas[i] = totalArea;

		
		roiManager("Save", dirOutput+File.separator+title+".zip");
		run("Close All");
		//selectWindow("ROI Manager");
		roiManager("reset");
		if(isOpen("Results")){
			selectWindow("Results");
			run("Close");
		}
		

	}
}

for (i=0; i<files.length; i++) {
	setResult("File", i, files[i]);
	setResult("Area", i, areas[i]); 
}
saveAs("Results", dirOutput+File.separator+"results.csv");
if(isOpen("Results")){
			selectWindow("Results");
			run("Close");
		}

print("Done!");
