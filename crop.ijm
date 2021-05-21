batchMode=false;

setBatchMode(batchMode);

directory = getDirectory("Choose folder with the images"); 
files=getFileList(directory);

for (i=0; i<files.length; i++) {

	if(endsWith(files[i],".jpg"))
		{
			
			showProgress(i, files.length);
			open(directory+File.separator+files[i]);
			waitForUser("","select region to crop");
			
			run("Crop");
			saveAs("Jpeg",directory+File.separator+files[i]);
			run("Close");
			

		}

}