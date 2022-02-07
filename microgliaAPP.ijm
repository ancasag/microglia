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

nucleos = newArray(files.length);
areasN = newArray(files.length);
mediasN = newArray(files.length);
stdN = newArray(files.length);
areasR = newArray(files.length);
mediasR = newArray(files.length);
stdR = newArray(files.length);

for (j=0; j<files.length; j++) {

	if(endsWith(files[j],".tif"))
	{
		showProgress(j, files.length);
		path = directory+File.separator+files[j];
		open(path);
		title=getTitle();
		getStatistics(area, meanI, min, max, std, histogram);
		//-----------------------------------------------------------------------------------------------------------
		//Aquí estamos detectando los nucleos
		//-----------------------------------------------------------------------------------------------------------
		selectWindow(title);	
		run("Duplicate...", " ");
		rename("dup_"+title);
		selectWindow("dup_"+title);
		run("8-bit");
		run("Median...", "radius=5");
		run("Find Maxima...", "noise=50 output=[Point Selection] light");
		//roiManager("Add");
		//roiManager("Select", 0); 
		s = selectionType();
		n = roiManager('count');
		badRois = newArray(n);
		
		if( s == -1 ) {
		    exit("There was no selection.");
		} else if( s != 10 ) {
		    exit("The selection wasn't a point selection.");
		} else {
		    getSelectionCoordinates(xPoints,yPoints);
			for (i = 0; i < xPoints.length; i++) {
				x = xPoints[i];
				y = yPoints[i];
				//print("Got coordinates ("+x+","+y+")");
				makePoint(x, y, "small yellow hybrid");
				roiManager("Add");
				//Roi.contains(xPoints[j], yPoints[j]
				
			}
		}
		close();
		selectWindow(title);
		
		selectWindow("ROI Manager");
		roiManager("Show All with labels");
		waitForUser("Añade/elimina los nucleos");
		setTool("point");
		roiNew = newArray(n);
		k=0;
		n1 = roiManager('count');
		xPointsNew = newArray(n1);
		yPointsNew = newArray(n1);
		for(i=0; i<n1;i++){
			roiManager('select', i);
			getSelectionCoordinates(xpunto, ypunto);
		
			x = xpunto[0];
			y = ypunto[0];
           	xPointsNew[i] = x;
			yPointsNew[i] = y;

			
			//roiNew.append
			//getSelectionCoordinates(xpoints, ypoints);
			
		}
		selectWindow(title);
		//roiManager("Deselect");
		//getSelectionCoordinates(xPoints,yPoints);
		//roiManager("get"
		n = roiManager('count');
		badRois = newArray(n);
		
		n = roiManager('count');
		//getSelectionCoordinates(xPoints,yPoints);
		roiManager("reset");

		
		for (l = 0; l < xPointsNew.length; l++) {
		    //roiManager('select', l);
		   
		    x = xPointsNew[l];
			y = yPointsNew[l];
		    // process roi here
			//print(x+','+y);
			makeRectangle(x-15, y-15,30, 30);
			roiManager("Add");
		}
		
		selectWindow(title);
		roiManager("Show None");
		roiManager("Deselect");
		run("Select All");
		run("Duplicate...", " ");
		rename("dup_"+title);
		run("8-bit");
		run("Invert");
		run("Duplicate...", " ");
		rename("dup2_"+title);
		selectWindow("dup_"+title);
		run("Gaussian Blur...", "sigma=2");
		selectWindow("dup2_"+title);
		run("Gaussian Blur...", "sigma=30");
		imageCalculator("Subtract create","dup_"+title,"dup2_"+title );
		selectWindow("Result of "+"dup_"+title);
		setAutoThreshold("Default dark");
		//run("Threshold...");
		//setThreshold(26, 255);
		setOption("BlackBackground", false);
		run("Convert to Mask");
		roiManager("Deselect");
		roiManager("Combine");
		run("Clear Outside");
		roiManager("reset");
		run("Erode");
		run("Erode");
		run("Dilate");
		run("Dilate");
		run("Analyze Particles...", "size=0.005-Infinity add");
		selectWindow(title);
		roiManager("Show All with labels");
		selectWindow("dup2_"+title);
		close();
		selectWindow("dup_"+title);
		close();
		selectWindow("Result of "+"dup_"+title);
		close();
		roiManager("Measure");
		selectWindow("ROI Manager");
		waitForUser("Añade/elimina los nucleos");
		//setTool("freehand");
		//------------------------------------------------------------------------------------------------------------------------------------
		// Aqui estamos calculando todos los excels de los nucleos
		//------------------------------------------------------------------------------------------------------------------------------------
		selectWindow(title);
		//saveAs("Tiff",dirOutput+File.separator+title);
		saveAs("Results", dirOutput+File.separator+title+"Nucleo.csv");
		roiManager("Save", dirOutput+File.separator+title+"Nucleo.zip");
		totalAreaN = 0.0;
		totalMediaN = 0.0;
		totalStdN = 0.0;
		for (k = 0; k < nResults();k++) {
		    v = getResult('Area', k);
    		totalAreaN = totalAreaN + v;
    		
		}
		nucleos[j] = nResults();
		
		areasN[j] = totalAreaN;
		mediasN[j] = totalAreaN/nResults();
		
		for (k = 0; k < nResults();k++) {
		    v = getResult('Area', k);
    		totalStdN = totalStdN + (v-mediasN[j])*(v-mediasN[j]);
		}


		
		stdN[j] = sqrt(totalStdN/nResults());

		roiManager("reset");
		//close();
		selectWindow("Results");
        run("Close" );

		//------------------------------------------------------------------------------------------------------------------------------------
		// Detectamos las ramificaciones
		//------------------------------------------------------------------------------------------------------------------------------------

		selectWindow(title);
		
		roiManager("Deselect");
		run("Select All");
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
			b = 0;
			while (b < xPointsNew.length && !contiene) {
				if(Roi.contains(xPointsNew[b], yPointsNew[b])){
					contiene=true;
				}
				b++;
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
		
		//------------------------------------------------------------------------------------------------------------------------------------
		// Aqui estamos calculando los excels
		//------------------------------------------------------------------------------------------------------------------------------------
		roiManager("Measure");
		selectWindow(title);
		saveAs("Tiff",dirOutput+File.separator+title);
		roiManager("Save", dirOutput+File.separator+title+"Ramificaciones.zip");
		saveAs("Results", dirOutput+File.separator+title+"Ramificaciones.csv");
		totalAreaR = 0.0;
		totalMediaR = 0.0;
		totalStdR = 0.0;
		for (k = 0; k < nResults();k++) {
		    v = getResult('Area', k);
    		totalAreaR = totalAreaR + v;
		}
		areasR[j] = totalAreaR;
		mediasR[j] = totalAreaR/nResults();


		for (k = 0; k < nResults();k++) {
		    v = getResult('Area', k);
    		totalStdR = totalStdR + (v-mediasR[j])*(v-mediasR[j]);
		}


		
		stdR[j] = sqrt(totalStdR/nResults());
		
		roiManager("reset");
		close();
		selectWindow("Results");
        run("Close" );

	}
}
for (i=0; i<files.length; i++) {
	setResult("File", i, files[i]);
	setResult("Nucleos", i, nucleos[i]);
	setResult("Areas Nucleos", i, areasN[i]); 
	setResult("Media Areas Nucleos", i, mediasN[i]); 
	setResult("Desviacion Areas Nucleos", i, stdN[i]); 
	setResult("Areas Ramificaciones", i, areasR[i]); 
	setResult("Media Areas Ramificaciones", i, mediasR[i]); 
	setResult("Desviacion Areas Ramificaciones", i, stdR[i]); 
}

saveAs("Results", dirOutput+File.separator+title+"General.csv");
if(isOpen("Results")){
			selectWindow("Results");
			run("Close");
}
