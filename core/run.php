<?

	$descSpec = array(
			0 => array("pipe", "r"),
			1 => array("file", "/dev/null", "w")
			);
	
	$filename = $_GET['filename'];
	$tmp = explode('/', $filename);
	$tmp = explode('.j', $tmp[1]);
	$outname = $tmp[0].' '.date('Y-m-d-H-i-s');

	//$outname = '2-0.2mM-SYBR 4o-10X-50-1 2012-12-27-13-38-18';
	//echo file_get_contents("/var/www/comet/output/".$outname.".txt");
	//return;
	
	$proc = proc_open("/usr/local/MATLAB/R2011b/bin/matlab -nodisplay -r \"run '$filename' '$outname'\"", $descSpec, $pipes);
	
	if (is_resource($proc)) {
		$return_value = proc_close($proc);
		echo file_get_contents("/var/www/comet/output/".$outname.".txt");
		//echo "{filename:'$outname',width:1360,height:1024,scale:2}";
	} else {
		echo 'filename:\'fail\'';
	}
?>