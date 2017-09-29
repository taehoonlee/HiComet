<?php
/*
Uploadify
Copyright (c) 2012 Reactive Apps, Ronnie Garcia
Released under the MIT License <http://www.opensource.org/licenses/mit-license.php> 
*/

//$verifyToken = md5('unique_salt' . $_POST['timestamp']);

if (!empty($_FILES)) {// && $_POST['token'] == $verifyToken) {
	$tempFile = $_FILES['Filedata']['tmp_name'];
	//$targetPath = $_SERVER['DOCUMENT_ROOT'] . $targetFolder;
	
	// Validate the file type
	$fileTypes = array('jpg','jpeg','gif','png'); // File extensions
	$fileParts = pathinfo($_FILES['Filedata']['name']);

    if (in_array(strtolower($fileParts['extension']),$fileTypes)) {
		move_uploaded_file($tempFile,'/home/withdove/comet/input/uploads/'.$_FILES['Filedata']['name']);
		echo $_FILES['Filedata']['name'];
	} else {
		echo 'Invalid file type.';
	}
}
?>