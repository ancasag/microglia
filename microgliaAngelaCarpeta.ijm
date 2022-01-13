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
		path = directory+File.separator+files[i];
		print(path);
		open(path);
		title=getTitle();

		selectWindow(title);
		
		
		getStatistics(area, meanI, min, max, std, histogram);
		
		
		run("Duplicate...", " ");
		rename("dup_"+title);
		selectWindow("dup_"+title);
		run("8-bit");
		run("Median...", "radius=5");
		run("Find Maxima...", "noise=50 output=[Point Selection] light");
		//roiManager("Add");
		//roiManager("Select", 0); 
		s = selectionType();
		
		if( s == -1 ) {
		    exit("There was no selection.");
		} else if( s != 10 ) {
		    exit("The selection wasn't a point selection.");
		} else {
		    getSelectionCoordinates(xPoints,yPoints);
			/*for (i = 0; i < xPoints.length; i++) {
				x = xPoints[i];
				y = yPoints[i];
				print("Got coordinates ("+x+","+y+")");
			}*/
		}
		close();
		
		
		// Regiones
		selectWindow(title);
		run("Duplicate...", " ");
		rename("dup_"+title);
		selectWindow("dup_"+title);
		run("8-bit");
		run("Median...", "radius=5");
		run("Find Maxima...", "prominence=50 light output=[Segmented Particles]");
		
		
		
		
		selectWindow(title);
		run("Duplicate...", " ");
		rename("dup1_"+title);
		selectWindow("dup1_"+title);
		run("8-bit");
		run("Enhance Contrast...", "saturated=0.9");
		run("Variance...", "radius=2");
		setAutoThreshold("Default dark");
		run("Convert to Mask");
		imageCalculator("Min create", "dup_"+title+" Segmented","dup1_"+title);
		
		selectWindow("Result of "+"dup_"+title+" Segmented");
		run("Fill Holes");
		run("Analyze Particles...", "size=0.01-Infinity add");
		
		
		n = roiManager('count');
		badRois = newArray(n);
		k=0;
		selectWindow(title);
		for (m = 0; m < n; m++) {
		    roiManager('select', m);
		    getStatistics(area, mean, min, max, std, histogram);
		
			contiene = false;
			j = 0;
			while (j < xPoints.length && !contiene) {
				if(Roi.contains(xPoints[j], yPoints[j])){
					contiene=true;
				}
				j++;
			}
		    if(meanI>200){
		    	t =120;
		    }else{
		    	t = 110;
		    }
		    if(!contiene|| min>t ){
		    	badRois[k]=m;
		    	k++;
		    }
		}
		selectWindow("Result of "+"dup_"+title+" Segmented");
		close();
		selectWindow("dup_"+title);
		close();
		selectWindow("dup_"+title+" Segmented");
		close();
		selectWindow("dup1_"+title);
		close();
		
		for(l=k-1;l>=0;l--){
			roiManager('select', badRois[l]);
			roiManager("delete");
		}
		
		selectWindow(title);
		roiManager("Show All without labels");
		
		roiManager("Draw");
		saveAs("Tiff",dirOutput+File.separator+title);
		roiManager("Save", dirOutput+File.separator+title+".zip");
		

		roiManager("reset");
		close();
		
	}
	
}
print("Done!");
