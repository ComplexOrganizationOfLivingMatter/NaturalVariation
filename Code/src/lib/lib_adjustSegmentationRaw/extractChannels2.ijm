dir = getDirectory("Choose a Directory ");
count = 1;
print("\\Clear");

list = getFileList(dir);


//loop that extracts the number, code from Herbie
for (i=0; i<list.length; i++){
	
	fileName = list[i];
	subFileName = substring(fileName, fileName.length-4,fileName.length);
	
	if (subFileName==".nd2") {

		//subStringArray = split( fileName, “_” );
		
		open(dir + fileName);
		subFileName = substring(fileName, 0,fileName.length-4);
		run("Merge Channels...", fileName + " - C=1] c2=[" + fileName + " - C=2] create");
		run("RGB Color", "slices");
		run("32-bit");
		
		saveAs("Tiff", dir+ "/"+ subFileName + "_lateral+basal.tif");
		selectWindow(subFileName + "_lateral+basal.tif");
		run("Close");
		selectWindow(fileName + " - C=0");
		saveAs("Tiff", dir+ "/"+ subFileName + "_nuclei.tif");
		selectWindow(subFileName + "_nuclei.tif");
		run("Close");
		run("Close");
	

	}
}

