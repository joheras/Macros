batchMode=false;
outputFolder="_Output";
maxWidthLengthP =  5.1
unit = "cm"


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

	if(endsWith(files[i],".jpg"))
	{
		showProgress(i, files.length);
		open(directory+File.separator+files[i]);
		title=getTitle();
		run("Set Scale...", "distance=0 known=0 unit=pixel");
		setTool("rectangle");
		waitForUser("","select the region of the posit");

		
		run("Duplicate...", " ");
		rename("dup_"+title);
		run("8-bit");
		setAutoThreshold("Default dark");
		//run("Threshold...");
		//setThreshold(171, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Analyze Particles...", "size=0-Infinity exclude add");
		roiManager("Select", 0);
		run("Fit Rectangle");
		run("Measure");
		rrlength = getResult("RRLength", 0);
		rrwidth = getResult("RRWidth", 0);

		if(rrlength>rrwidth){
			maxwidthlengthScale = rrlength;
		}else{
			maxwidthlengthScale = rrwidth;	
		}
		if(isOpen("Results")){
				selectWindow("Results");
				run("Close");
		}

		run("Set Scale...", "distance=" + maxwidthlengthScale +" known=" + maxWidthLengthP +" unit=" + unit + " global");
		close();

		
		run("Close All");
		selectWindow("ROI Manager");
		roiManager("reset");
		
		open(directory+File.separator+files[i]);
		title=getTitle();
		run("Duplicate...", " ");
		rename("res_"+title);
		reply = true;
		j = 0;
		while(reply){

			selectWindow(title);
			run("Duplicate...", " ");
			rename("dup_"+title);
			waitForUser("","select the region of the roots");

			run("Subtract Background...", "rolling=50");
			setBackgroundColor(0, 0, 0);
			run("Clear Outside");
			run("8-bit");
			setAutoThreshold("Triangle dark");
			run("Convert to Mask");
			run("Analyze Particles...", "size=2-Infinity display add");


			saveAs("Results", dirOutput+File.separator+j+'_'+title+".csv");

			selectWindow("res_"+title);
			roiManager("Set Color", "red");
			roiManager("Set Line Width", 10);
			roiManager("Show All without labels");
			roiManager("Draw");
			roiManager("Save", dirOutput+File.separator+j+'_'+title+".zip");
			j = j+1;


			roiManager("reset");
			if(isOpen("Results")){
				selectWindow("Results");
				run("Close");
			}
			selectWindow("dup_"+title);
			close();
			reply = getBoolean("Any more roots?", "Yes", "No");
		}

		selectWindow("res_"+title);
		saveAs("Jpeg",dirOutput+File.separator+title);

		run("Close All");

		
		
		
	}
}
print("Done!");
