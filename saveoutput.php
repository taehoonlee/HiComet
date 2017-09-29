<?php

header("Content-type: application/x-file-to-save");
header("Content-Disposition: attachment; filename=".basename($_REQUEST['file']));
readfile('output/'.$_REQUEST['file']);

?>