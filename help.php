<div class="section" style="text-align:left;margin-left:30px;">
	<h2>Help</h2>
	<div style="font-size:14px;">
		<style> 
			h3 {
				margin-top: 50px;
			}
		</style>
			</br>	
			<li>
			To start comet-assay analysis using HiComet, please do the following: 
            <ol>
                <li>The first thing you should do is to select the input image that contains comets. To this end, there are two options. (1) Click the "Upload an image" button to upload a local image file to our server, or 
		(2) select a sample image from the "choose a sample" drop-down list. In the list, we provide 20 test images (these were used to generate the results presented in the paper).</li>
                <img src="img/help/tutorial1.png" class="help_figures"/>
                
                
                <li>[Optional] Before starting your analysis, you can examine more advanced options by clicking the "show options" button. There are 5 options you can adjust, as described below: 
                <img src="img/help/tutorial2.png" class="help_figures"/>
                <ul>
                <li><strong>Weak Signal Adjusting:</strong>
		When the overall intensity level of your image is too low, the downstream analysis may not work properly due to the noise in your image. 
		To alleviate this issue, you can boost the overall intensity level by checking this option. By default this option is on. 
                </li>

                <li><strong>Noisy Signal Adjusting:</strong> 
		As preprocessing to filter noise, you can use either median filtering or moving average filtering. The default is median filtering.
                </li>
                
                <li><strong>Segmentation:</strong> 
		This is to set how many pixels to consider in the process of recognizing comets. For example, the 8-connected objects option means that 8 different directions (up and down, left and right, and two diagonal directions) are examined in the comet recognition process.
		If you choose the 4-connected objects option, only 4 directions (up and down, and left and right) will be considered. The default is to examine 8 directions.
                </li>

                <li><strong>Enhanced Segmentation:</strong> 
		Frequently, there exist overlaps between comets. HiComet provides a functionality to detect such overlaps and isolate the front comet automatically. By default, this option is on. 
                </li>
                <li><strong>Show Fail Type:</strong> 
		When it is not possible to process a comet properly, HiComet marks it as 'Fail.' When this option is on, 'Fail' mark is shown in the result. </li>
                </ul>
                </li>
		</br>
                <li> Now you are ready to start the analysis. Click the "Run" button.
                </li>
                <img src="img/help/tutorial3.png" class="help_figures"/>

		</br>
                <li> During your image is being processed, you can see a progress image on screen. After the analysis is over, you can see the result image on which the recognized comets are marked by boxes.
		Using this image, you can check the results HiComet has processed. Each box indicates a detected comet, and the color of a box represents whether the comet is normal, abnormal, or fail (green, yellow, or gray, respectively). 
                
                </li>
                <img src="img/help/tutorial4.png" class="help_figures"/>

		</br>
                <li>
                If you want to know more about each of the comets identified, you can move your mouse-cursor on the comet you want to investigate more.  You can save the intensity profile and parameters of comets as follows: 
			<ul>
			<li> To save the intesnsity profile of a comet into an image file: left-click the box surrounding the comet. 
			</li>
			<li> To save the parameters of all comets into a file: left-click anywhere on the result image.
			</li>
			</ul>
                </li>
                <img src="img/help/tutorial5.png" class="help_figures"/>
                
		</br>
                <li> In addition to the image showing identified comets and their types, HiComet reports more images to facilitate the analysis process. 
		On the "results" panel, there are four types of images. By clicking each, you can magnify it. 
		The first image shows the comets identified and their types. 
		In the second image, you can see the intermediate results produced during the HiComet procedure. 
		The third image shows the intensity profiles of all the identified comets on a single image. 
		The last image shows the histogram of three types of tail moment distributions: the extent moment, the Olive moment, and the moment of inertia (from top to bottom). 
		
                </li>
                <img src="img/help/tutorial6.png" class="help_figures"/>


            </ol>
	</div>
</div>
