// Macro to downsample multiple raw images and labels


// paths for raw images and labels
#@ File (label = "Input image directory", style = "directory") input
#@ File (label = "Input label directory", style = "directory") inputDirLabels

// paths for downsampled raw images and labels
#@ File (label = "Output image directory", style = "directory") output
#@ File (label = "Output label directory", style = "directory") outputDirLabels

// suffix
#@ String (label = "File suffix", value = ".tif") suffix

// Desired Z pixel size and XY pixel size
#@ Float (label = "Desired Z size", value=0.7) zSize
#@ Float (label = "Desired XY size", value=0.6151658) xySize


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
	
	// get dimensions and pixel/voxel size
	getDimensions(width, height, channels, slices, frames);
	getPixelSize(unit, pixelWidth, pixelHeight);
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
	
	// calculate correction factor (for xy and for z)
	correctionFactor = pixelWidth / xySize;
	correctionFactor_Z = voxelDepth / zSize;
	newWidth = round( width * correctionFactor );
	newHeight = round( height * correctionFactor );
	newSlices = round( slices * correctionFactor_Z );
	
	// run resize
	run("Size...", "width="+newWidth+" height="+newHeight+" depth="+newSlices+" constrain average interpolation=Bilinear");
	
	// edit name
	fileName = substring(file, 0,file.length-4);
	
	// print fileName of file being saved
	print("Saving to: " + output + File.separator + fileName+".tif");
	
	// save
	save(output + File.separator + fileName+".tif");
	
	// close image
	close();
	file = substring(file, 0,file.length-4);
	
	labelFile = file + ".tif";
	
	// open labeled image
	open( inputDirLabels + File.separator + labelFile);
	
    // resize
	run("Size...", "width="+newWidth+" height="+newHeight+" depth="+newSlices+" constrain interpolation=None");
	
	// print fileName of file being saved
	print("Saving to: " + outputDirLabels + File.separator + labelFile);
	
	// save labeled image
	save(outputDirLabels + File.separator + labelFile);
	
	// close
	close();
	
}
