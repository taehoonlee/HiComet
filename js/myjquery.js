$(document).ready( function() {

	var imgPreviewNum = 4;
	var currentData;
	var currentPage = 0;

	for (var i=0; i<3; i++) {
		$("#btnMenu" + (i+1)).click( function () {
			$.ajax({
				type: "get",
				url: $(this).attr("url"),
				dataType: "text",
				success: function (data) {
					currentPage = 0;
					$("#layout-middle .rightwrapper").html(data);
				}
			});
		});
	}

/*
	for (var i=1; i<=3; i++) {
		$("#btnChkResult" + i).click( function () {
			if ( $("#chkResult" + i).attr("checked") == true ) {
				$("#chkResult" + i).attr("checked", false);
			} else {
				$("#chkResult" + i).attr("checked", true);
			}
		});
	}
*/	
	$("#btnRun").click( function () {

		if ( $("#imgPreviewFilename").html() != "" ) {

			$("#imgResultTag").css({"visibility":"hidden"});
            for (var i=1; i<=imgPreviewNum; i++) {
                $("#imgPreview"+i).css({"visibility":"hidden"});
            }

			$.ajax({
				type: "get",
				url: "core/run.php",
				dataType: "text",
				data: {filename: $("#imgPreviewFilename").html()},
				beforeSend: function () {
					$("#layout-middle .leftwrapper").css({"visibility":"hidden"});
					$("#layout-middle .centerwrapper").css({"visibility":"hidden"});
					$("#layout-middle .rightwrapper").html("<img src=\"img/ajax-loader.gif\" style=\"margin-top:300px;\" />");
				},
				success: function (d) {
					currentData = d;
					$("#layout-middle .leftwrapper").css({"visibility":"visible"});
					$("#layout-middle .centerwrapper").css({"visibility":"visible"});
					showResult();
				},
				error: function () {
					alert("error");
				}
			});

		} else {
			alert("please select a file");
			$("#selFilename").focus();
		}
	});

	function showResult() {

		currentPage = 1;

		var data = eval("(" + currentData + ")");
		var info = data.cometinfo;
		if (data.filename == "fail")
		{
			alert(data.reason);
			$("#layout-middle .rightwrapper").html("");
			return;
		}
		var str = "<div id=\"imgResult1\" class=\"imgResult\"" +
			" url=\"saveoutput.php?file=" + data.filename + "-1.png\">" +
			"<div style=\"position:absolute;width:100%;top:-40px;border:0;text-align:center;\">To save the intensity profile of a comet, left-click the comet number.<br />To save the parameters of all comets, left-click anywhere in the background.</div>" +
			"<img src=\"input/" + $("#imgPreviewFilename").html() + "\" width=\"" + (data.width/data.scale) + "\" height=\"" + (data.height/data.scale) + "\" />";

		$("#imgResultTag").css({"visibility":"visible"});
		for (var i=1; i<=imgPreviewNum; i++) {
			$("#imgPreview"+i).html("<img src=\"output/" + data.filename + "-" + i + ".png\" />");
			$("#imgPreview"+i).css({"visibility":"visible"});
		}

		for (var i=0; i<data.n; i++) {
		
			var tooltipheight = 190;
			if (info[i].type != "fail") {
				tooltipheight = 390;
			}
			
			var tooltiptop = ((info[i].y + info[i].h) / data.scale + 10);
			if (tooltiptop*1.6 > data.height/data.scale) {
				tooltiptop = tooltiptop - tooltipheight - 3 - (info[i].h/data.scale);
			}
			
			var tooltipleft = (info[i].x/data.scale);
			if (tooltipleft*1.8 > data.width/data.scale) {
				tooltipleft = tooltipleft - 120;
			}

			var cometclass;
			if ( info[i].type == "normal" ) {
				cometclass = "normal";
			} else if ( info[i].type == "apoptosis" ) {
				cometclass = "abnormal";
			} else if ( info[i].type == "necrosis" ) {
				cometclass = "abnormal";
			} else {
				cometclass = "fail";
			}
			
			str += "<div id=\"comet"+i+"\" no=\""+i+"\" class=\"comet "+cometclass+"\""
				+" url=\"saveoutput.php?file=" + data.filename + "-comet" + (i+1) + ".png\""
				+"style=\"left:"+(info[i].x/data.scale)+"px;top:"+(info[i].y/data.scale+10)+"px;width:"+(info[i].w/data.scale)+"px;height:"+(info[i].h/data.scale)+"px;\">"+(i+1)+"</div>";
			
			str += "<div id=\"tooltip"+i+"\" class=\"tooltip\" style=\"left:"+tooltipleft+"px;top:"+tooltiptop+"px;height:"+tooltipheight+"px;\"><table>"
				+"<tr><td class=\"1\">Type</td><td class=\""+cometclass+"\">"+cometclass+"</td></tr>";
			
			if ( info[i].type != "fail" ) {
				str += "<tr><td class=\"1\">Head per DNA</td><td class=\"2\">"+info[i].p1+"</td></tr>"
					+"<tr><td class=\"1\">Tail per DNA</td><td class=\"2\">"+info[i].p2+"</td></tr>"
					+"<tr><td class=\"1\">Tail Extent Moment</td><td class=\"2\">"+info[i].p3+"</td></tr>"
					+"<tr><td class=\"1\">Olive Tail Moment</td><td class=\"2\">"+info[i].p4+"</td></tr>"
					+"<tr><td class=\"1\">Tail Inertia</td><td class=\"2\">"+info[i].p5+"</td></tr>"
					+"<tr><td class=\"1\">Tail Length</td><td class=\"2\">"+info[i].p6+"</td></tr>"
					+"<tr><td class=\"1\">Tail Distance</td><td class=\"2\">"+info[i].p7+"</td></tr>";
			}

			str += "<tr><td colspan=\"2\" style=\"text-align:center;vertical-align:middle;\"><img src=\"output/" + data.filename + "-comet" + (i+1) + ".png\" /></td></tr></table></div>";
			
		}
		str += "</div>";

		str += "<div id=\"imgResult2\" class=\"imgResult\"><img src=\"output/" + data.filename + "-2.png\" /></div>";
		str += "<div id=\"imgResult3\" class=\"imgResult\"><img src=\"output/" + data.filename + "-3.png\" /></div>";
		str += "<div id=\"imgResult4\" class=\"imgResult\"><img src=\"output/" + data.filename + "-4.png\" /></div>";

		$("#layout-middle .rightwrapper").html(str);
		for (var i=0; i<data.n; i++) {
			$("#comet"+i).mouseover( function() {
				$("#tooltip" + $(this).attr("no")).css({"visibility":"visible"});
			}).mouseout( function() {
				$("#tooltip" + $(this).attr("no")).css({"visibility":"hidden"});
			});
		}

		for (var i=1; i<=imgPreviewNum; i++) {
			$("#imgPreview" + i).click( function() {
				if (currentPage < 1) {
					showResult();
				}
				$(".imgPreview img").removeClass("selected");
				$("#imgPreview" + $(this).attr("id").substring(10) + " img").addClass("selected");
				$(".imgResult").css({"visibility":"hidden"});
				$("#imgResult" + $(this).attr("id").substring(10)).css({"visibility":"visible"});
			});
		}

		if (currentPage > 0) {
			$("#imgPreview1").click();
		}
		
		$("#imgResult1 img").click( function() {
			window.open("saveoutput.php?file=" + data.filename + ".csv", "new");
			//window.open("saveoutput.php?file=" + data.filename + "-1.png", "new");
			
		});

		$("#imgResult2 img").click( function() {
			window.open("saveoutput.php?file=" + data.filename + "-2.png", "new");
		});

		$("#imgResult3 img").click( function() {
			window.open("saveoutput.php?file=" + data.filename + "-3.png", "new");
		});

		$("#imgResult4 img").click( function() {
			window.open("saveoutput.php?file=" + data.filename + "-4.png", "new");
		});
		
		$("#imgResult1 .comet").click( function() {
			window.open($(this).attr("url"), "new");
		});
	}

	function strlen(str) {
		return utf8_encode(str).length;
	}
	
	function utf8_encode(str) {
		str = str.replace(/\r\n/g,"\n");
		var output = "";
		for (var n = 0; n < str.length; n++) {
			var c = str.charCodeAt(n);
			if (c < 128) {
				output += String.fromCharCode(c);
			} else if ((c > 127) && (c < 2048)) {
				output += String.fromCharCode((c >> 6) | 192);
				output += String.fromCharCode((c & 63) | 128);
			} else {
				output += String.fromCharCode((c >> 12) | 224);
				output += String.fromCharCode(((c >> 6) & 63) | 128);
				output += String.fromCharCode((c & 63) | 128);
			}
		}
		return output;
	}

	function setCurrentFile(path, file) {
		if (file != "none") {
			$("#imgPreview0").html("<a href=\"input/" + path + "s/" + file + "\"><img src=\"input/" + path + "s/" + file + " \"/></a>");
			$("#imgPreview0 a").nyroModal();
			$("#imgPreviewFilename").html(path + "s/" + file);
			
			if (strlen(file) > 16) {
				$("#imgPreviewTag").html(path + "<br />" + file.substr(0,14) + "...");
			} else {
				$("#imgPreviewTag").html(path + "<br />" + file);
			}
		} else {
			$("#imgPreview0").html("");
			$("#imgPreviewFilename").html("");
			$("#imgPreviewTag").html("no image selected");
		}
	}

	$("#selFilename").change( function() {
		setCurrentFile("sample", $("#selFilename option:selected").val());
	});

	$("#upFile").uploadify( {
		width: 140,
		height: 22,
		swf: "uploadify.swf",
		uploader: "uploadify.php",
		folder: "input/uploads",
		buttonText: "Upload an image",
		auto: true,
		onUploadSuccess: function (file, data, response) {
			setCurrentFile("upload", data);
		}
	});

	$("#toggleOptions").click( function() {
		if ($(".options").css("display") != "none") {
			$(".options").css({"display":"none"});
			$("#toggleOptions").html("show options");
		} else {
			$(".options").css({"display":"block"});
			$("#toggleOptions").html("hide options");
		}
	});

	$("#btnMenu1").click();

});