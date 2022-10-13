// Macro to enhance contrast multiple raw images

// input path
#@ File (label = "Input image directory", style = "directory") input

// output path
#@ File (label = "Output image directory", style = "directory") output

// file suffix
#@ String (label = "File suffix", value = ".tif") suffix


processFolder(input);                     

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input); 
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {

	// print which file is being processed	
	print("Processing: " + input + File.separator + file);
	
	// open image
	open( input + File.separator + file );
	
	// run enhance contrast
	run("Enhance Contrast...", "saturated=0.3 process_all use");
	
	// 8 bit transformation
	run("8-bit");
	run("8-bit");

	// save image and print which file is being saved
	print("Saving to: " + output + File.separator + file);
	save(output + File.separator + file);
	
	// close img
	close();
}
