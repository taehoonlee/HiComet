<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Comet Assay</title>
<link rel="stylesheet" type="text/css" media="all" href="css/style.css" />
<link rel="stylesheet" type="text/css" media="all" href="css/nyroModal.css" />
<link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Lato:100" />
<link rel="stylesheet" type="text/css" href="uploadify/uploadify.css" />
<!--<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>-->
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.8.9.custom.min.js"></script>
<script type="text/javascript" src="js/jquery.nyroModal.custom.min.js"></script>
<script type="text/javascript" src="uploadify/jquery.uploadify.min.js"></script>
<script type="text/javascript" src="js/myjquery.js"></script>
</head>
<body>

<div id="layout-top"><div class="wrapper">
	
    <div class="leftwrapper">

        <div id="logo"><font style="font-size:1.4em;">Comet</font><br /><font style="font-size:2em;">Assay</font></div>

    </div>

    <div class="rightwrapper">

        <div id="imgPreviewTag" class="tag border-radius10" style="margin-top:26px;">no image selected</div>
        <div id="imgPreviewFilename"></div><div id="imgPreviewOutname"></div>
        <div id="imgPreview0" class="imgPreview"></div>
        <div id="imgResultTag" class="tag border-radius10" style="margin-top:34px;">results</div>
        <div id="imgPreview1" class="imgPreview"></div>
        <div id="imgPreview2" class="imgPreview"></div>
        <div id="imgPreview3" class="imgPreview"></div>
        <div id="imgPreview4" class="imgPreview"></div>

    </div>
	
</div></div>

<div id="layout-middle"><div class="wrapper">

	<div class="leftwrapper">

		<div id="menu">

			<a href="#" id="btnMenu1" class="s1" url="home.php">Home</a><br />
			<a href="#" id="btnMenu2" class="s1" url="help.php">Help</a><br />
			<a href="#" id="btnMenu3" class="s1" url="about.php">About</a>

		</div>

	</div>
	
	<div class="centerwrapper">
	
		<div style="width:100%;text-align:center;color:#EEE;margin-top:15px;">select an image</div>
        <div class="samples"><select id="selFilename"><option value="none" />from samples</option>
		<?
			if ($dh = @opendir("input/samples")) {
				while (($file = readdir($dh)) !== false) {
					if ($file == "." || $file == "..") continue;
					echo '<option value="'.$file.'" />'.( (strlen($file) > 14) ? substr($file,0,14)."..." : $file ).'</option>';
				}
			}
		?>
		</select></div>
        <div style="width:100%;text-align:center;color:#EEE;">or</div>
		<div class="uploads"><input id="upFile" name="upFile" type="file" /></div>
        
		<div id="btnRun" class="border-radius14">Run</div>

		<div id="toggleOptions" class="border-radius10">show options</div>

		<div class="options"><div class="name">1. Weak Signal Adjusting</div><div><input type="checkbox" id="option1" checked="checked" /> Amplifying Signal</div></div>

		<div class="options"><div class="name">2. Noisy Signal Adjusting</div><div><input type="radio" name="option2" id="option2" value="1" checked="checked" /> Median Filtering</div><div><input type="radio" name="option2" id="option22" value="1" /> Moving Average Filtering</div></div>

		<div class="options"><div class="name">3. Segmentation</div><div><select id="option3"><option value="4" />4-connected objects</option><option value="8" selected="selected" />8-connected objects</option></select></div></div>

		<div class="options"><div class="name">4. Enhanced Segmentation</div><div><input type="checkbox" id="option2" checked="checked" /> Overlap Removal</div></div>

		<div class="options"><div class="name">5. Summary Figure</div><div><input type="checkbox" id="option2" checked="checked" /> Show Fail Type</div></div>

	</div>
		
	<div class="rightwrapper">
	</div>
	
</div>

<div id="layout-bottom"><div class="wrapper">
Copyright (c) 2017 Data Science Laboratory<br />Seoul National University</br>All Rights Reserved.
</div></div>

</body>
</html>
