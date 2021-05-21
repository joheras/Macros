batchMode=true;
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

	if(endsWith(files[i],".tif"))
	{
		showProgress(i, files.length);
		open(directory+File.separator+files[i]);
		title=getTitle();
		run("8-bit");
		run("Gray Morphology", "radius=2 type=circle operator=dilate");
		run("Gray Morphology", "radius=1 type=circle operator=erode");
		saveAs("Tif", dirOutput+File.separator+title+".tif");
		close();
		
		
	}
}
print("Done!");
