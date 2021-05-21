
//VARIABLES
minSize=3000;
thresh="Default";

batchMode=false;
outputFolder="_Output";


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
for (i=0; i<files.length; i++) {

	if(endsWith(files[i],".JPG"))
	{
		open(directory+File.separator+files[i]);
		title=getTitle();
		run("Duplicate...", " ");
		rename("dup_"+title);
		selectWindow(title);
		run("Split Channels");
		selectWindow(title+" (red)");
		close();
		selectWindow(title+" (green)");
		close();
		selectWindow(title+" (blue)");
		//run("Threshold...");
		setAutoThreshold(thresh);
		run("Analyze Particles...", "size="+minSize+"-Infinity show=Nothing  exclude clear add");
		selectWindow(title+" (blue)");
		close();
		selectWindow("dup_"+title);
		roiManager("Show All without labels");
		waitForUser("","check the segmentation");
		roiManager("Measure");
		saveAs("Results", dirOutput+File.separator+title+".csv");
		roiManager("Save", dirOutput+File.separator+title+".zip");
		run("Close All");
		selectWindow("ROI Manager");
		roiManager("reset");
		if(isOpen("Results")){
			selectWindow("Results");
			run("Close");
		}
	}
}
print("Done!");
