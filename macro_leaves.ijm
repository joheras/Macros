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
Dialog.show();
positColour = Dialog.getChoice();

areas = newArray(files.length);
for (i=0; i<files.length; i++) {

	if(endsWith(files[i],".jpg"))
	{
		
		showProgress(i, files.length);
		open(directory+File.separator+files[i]);
		run("Set Scale...", "distance=0 known=0 unit=pixel global");
		title=getTitle();
		run("Duplicate...", " ");
		rename("dup_"+title);
		selectWindow(title);
		run("Duplicate...", " ");


		// Measure posit
		rename("posit_"+title);
		selectWindow("posit_"+title);
		run("Colour Deconvolution", "vectors=[Methyl Green DAB]");
		selectWindow("posit_"+title+"-(Colour_3)");
		close();
		
		if(positColour=="yellow"){
			selectWindow("posit_"+title+"-(Colour_2)");
			close();
			selectWindow("posit_"+title+"-(Colour_1)");
		}

		if(positColour=="pink"){
			selectWindow("posit_"+title+"-(Colour_1)");
			close();
			selectWindow("posit_"+title+"-(Colour_2)");
		}
		
		setThreshold(255, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		

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
		roiManager("reset");
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

		print("Processing... "  + title);
		
		run("Set Scale...", "distance=" + maxwidthlengthScale +" known=" + maxWidthLengthP +" unit=" + unit + " global");


		selectWindow(title);
		run("Split Channels");
		selectWindow(title+" (blue)");
		close();
		selectWindow(title+" (green)");
		close();
		selectWindow(title+" (red)");
		setAutoThreshold("Default");
		setOption("BlackBackground", true);
		run("Convert to Mask");

		//run("Fill Holes");
		run("Erode");
		run("Erode");
		run("Dilate");
		run("Dilate");
		// Si sabemos que no toca los bordes, habría que incluir el exclude
		run("Analyze Particles...", "size=100-Infinity display add");//run("Analyze Particles...", "size=100-Infinity exclude add");
		selectWindow(title+" (red)");
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
