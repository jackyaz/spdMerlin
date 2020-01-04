<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>Internet Speedtest</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p{
font-weight: bolder;
}
.collapsible {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

.collapsibleparent {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

.collapsiblecontent {
  padding: 0px;
  max-height: 0;
  overflow: hidden;
  border: none;
  transition: max-height 0.2s ease-out;
}
</style>
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/chart.min.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdstatsdata.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdstatstext.js"></script>
<script>

var ShowLines=GetCookie("ShowLines");
var ShowFill=GetCookie("ShowFill");
Chart.defaults.global.defaultFontColor = "#CCC";
Chart.Tooltip.positioners.cursor = function(chartElements, coordinates) {
  return coordinates;
};

function Draw_Chart_NoData(txtchartname){
	document.getElementById("divLineChart"+txtchartname).width="730";
	document.getElementById("divLineChart"+txtchartname).height="300";
	document.getElementById("divLineChart"+txtchartname).style.width="730px";
	document.getElementById("divLineChart"+txtchartname).style.height="300px";
	var ctx = document.getElementById("divLineChart"+txtchartname).getContext("2d");
	ctx.save();
	ctx.textAlign = 'center';
	ctx.textBaseline = 'middle';
	ctx.font = "normal normal bolder 48px Arial";
	ctx.fillStyle = 'white'
	ctx.fillText('No data to display', 365, 150);
	ctx.restore();
}

function Draw_Chart(txtchartname,txttitle,txtunity,txtunitx,numunitx,colourname){
	var objchartname=window["LineChart"+txtchartname];
	var txtdataname="Data"+txtchartname;
	var objdataname=window["Data"+txtchartname];
	if(typeof objdataname === 'undefined' || objdataname === null) { Draw_Chart_NoData(txtchartname); return; }
	if (objdataname.length == 0) { Draw_Chart_NoData(txtchartname); return; }
	factor=0;
	if (txtunitx=="hour"){
		factor=60*60*1000;
	}
	else if (txtunitx=="day"){
		factor=60*60*24*1000;
	}
	if (objchartname != undefined) objchartname.destroy();
	var ctx = document.getElementById("divLineChart"+txtchartname).getContext("2d");
	var lineOptions = {
		segmentShowStroke : false,
		segmentStrokeColor : "#000",
		animationEasing : "easeOutQuart",
		animationSteps : 100,
		maintainAspectRatio: false,
		animateScale : true,
		legend: { display: false, position: "bottom", onClick: null },
		title: { display: true, text: txttitle },
		tooltips: {
			callbacks: {
					title: function (tooltipItem, data) { return (moment(tooltipItem[0].xLabel).format('YYYY-MM-DD HH:mm:ss')); },
					label: function (tooltipItem, data) { return data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y.toString() + ' ' + txtunity;}
				},
				mode: 'point',
				position: 'cursor',
				intersect: true
		},
		scales: {
			xAxes: [{
				type: "time",
				gridLines: { display: true, color: "#282828" },
				ticks: {
					display: true
				},
				time: { min: moment().subtract(numunitx, txtunitx+"s"), unit: txtunitx, stepSize: 1 }
			}],
			yAxes: [{
				gridLines: { display: false, color: "#282828" },
				scaleLabel: { display: false, labelString: txttitle },
				ticks: {
					display: true,
					callback: function (value, index, values) {
						return round(value,3).toFixed(3) + ' ' + txtunity;
					}
				},
			}]
		},
		plugins: {
			zoom: {
				pan: {
					enabled: true,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: getLimit(txtdataname,"y","min") - Math.sqrt(Math.pow(getLimit(txtdataname,"y","min"),2))*0.1,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(txtdataname,"y","max") + getLimit(txtdataname,"y","max")*0.1,
					},
				},
				zoom: {
					enabled: true,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: getLimit(txtdataname,"y","min") - Math.sqrt(Math.pow(getLimit(txtdataname,"y","min"),2))*0.1,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(txtdataname,"y","max") + getLimit(txtdataname,"y","max")*0.1,
					},
					speed: 0.1
				},
			},
		},
		annotation: {
			drawTime: 'afterDatasetsDraw',
			annotations: [{
				id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getAverage(objdataname),
				borderColor: colourname,
				borderWidth: 1,
				borderDash: [5, 5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: "sans-serif",
					fontSize: 10,
					fontStyle: "bold",
					fontColor: "#fff",
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: "center",
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: "Avg=" + round(getAverage(objdataname),3).toFixed(3)+txtunity,
				}
			},
			{
				id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(txtdataname,"y","max"),
				borderColor: colourname,
				borderWidth: 1,
				borderDash: [5, 5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: "sans-serif",
					fontSize: 10,
					fontStyle: "bold",
					fontColor: "#fff",
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: "center",
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: "Max=" + round(getLimit(txtdataname,"y","max"),3).toFixed(3)+txtunity,
				}
			},
			{
				id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(txtdataname,"y","min"),
				borderColor: colourname,
				borderWidth: 1,
				borderDash: [5, 5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: "sans-serif",
					fontSize: 10,
					fontStyle: "bold",
					fontColor: "#fff",
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: "center",
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: "Min=" + round(getLimit(txtdataname,"y","min"),3).toFixed(3)+txtunity,
				}
			}]
		}
	};
	var lineDataset = {
		datasets: [{data: objdataname,
			label: txttitle,
			borderWidth: 1,
			pointRadius: 1,
			lineTension: 0,
			fill: ShowFill,
			backgroundColor: colourname,
			borderColor: colourname,
		}]
	};
	objchartname = new Chart(ctx, {
		type: 'line',
		options: lineOptions,
		data: lineDataset
	});
	window["LineChart"+txtchartname]=objchartname;
}

function getLimit(datasetname,axis,maxmin) {
	limit=0;
	eval("limit=Math."+maxmin+".apply(Math, "+datasetname+".map(function(o) { return o."+axis+";} ))");
	return limit;
}

function getAverage(datasetname) {
	var total = 0;
	for(var i = 0; i < datasetname.length; i++) {
		total += datasetname[i].y;
	}
	var avg = total / datasetname.length;
	return avg;
}

function round(value, decimals) {
	return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function ToggleLines() {
	if(interfacelist != ""){
		if(ShowLines == ""){
			ShowLines = "line";
			SetCookie("ShowLines","line")
		}
		else {
			ShowLines = "";
			SetCookie("ShowLines","")
		}
		RedrawAllCharts();
	}
}

function ToggleFill() {
	if(interfacelist != ""){
		if(ShowFill == "origin"){
			ShowFill = false;
			SetCookie("ShowFill",false)
		}
		else {
			ShowFill = "origin";
			SetCookie("ShowFill","origin")
		}
		RedrawAllCharts();
	}
}

function RedrawAllCharts() {
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		var i;
		for (i = 0; i < interfacetextarray.length; i++) {
		Draw_Chart("DownloadDaily_"+interfacetextarray[i],"Download","Mbps","hour",24,"#fc8500");
		Draw_Chart("UploadDaily_"+interfacetextarray[i],"Upload","Mbps","hour",24,"#42ecf5");
		Draw_Chart("DownloadWeekly_"+interfacetextarray[i],"Download","Mbps","day",7,"#fc8500");
		Draw_Chart("UploadWeekly_"+interfacetextarray[i],"Upload","Mbps","day",7,"#42ecf5");
		Draw_Chart("DownloadMonthly_"+interfacetextarray[i],"Download","Mbps","day",30,"#fc8500");
		Draw_Chart("UploadMonthly_"+interfacetextarray[i],"Upload","Mbps","day",30,"#42ecf5");
		}
	}
}

function GetCookie(cookiename) {
	var s;
	if ((s = cookie.get("spd_"+cookiename)) != null) {
		return cookie.get("spd_"+cookiename);
	}
	else {
		return ""
	}
}

function SetCookie(cookiename,cookievalue) {
	cookie.set("spd_"+cookiename, cookievalue, 31);
}

function SetCurrentPage(){
	$("#next_page").val(window.location.pathname.substring(1));
	$("#current_page").val(window.location.pathname.substring(1));
}

function initial(){
	SetCurrentPage();
	show_menu();
	get_conf_file();
}

function reload() {
	location.reload(true);
}

function applyRule() {
	var action_script_tmp = "start_spdmerlin";
	document.form.action_script.value = action_script_tmp;
	var restart_time = document.form.action_wait.value*1;
	parent.showLoading(restart_time, "waiting");
	document.form.submit();
}

function get_conf_file(){
	$.ajax({
		url: '/ext/spdmerlin/interfaces.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout("get_conf_file();", 1000);
		},
		success: function(data){
			var interfaces=data.split("\n");
			interfaces.reverse();
			interfaces=interfaces.filter(Boolean);
			interfacelist="";
			var interfacecount=interfaces.length;
			for (var i = 0; i < interfacecount; i++) {
				var commentstart=interfaces[i].indexOf("#");
				if (commentstart != -1){
					continue
				}
				var interfacename=interfaces[i];
				$("#table_buttons").after(BuildInterfaceTable(interfacename));
				if(i == interfacecount-1){
					interfacelist+=interfacename;
				} else {
					interfacelist+=interfacename+',';
				}
			}
			
			if(interfacelist != ""){
				AddEventHandlers();
				RedrawAllCharts();
			}
		}
	});
}

function BuildInterfaceTable(name){
	var charthtml = '<div style="line-height:10px;">&nbsp;</div>'
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_interfaces_'+name+'">'
	charthtml+='<thead class="collapsibleparent" id="'+name+'">'
	charthtml+='<tr>'
	charthtml+='<td colspan="2">'+name+' (click to expand/collapse)</td>'
	charthtml+='</tr>'
	charthtml+='</thead>'
	charthtml+='<tr>'
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">'
	charthtml+='<div class="collapsiblecontent">'
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">'
	charthtml+='<tr>'
	charthtml+='<div style="line-height:10px;">&nbsp;</div>'
	charthtml+='</tr>'
	charthtml+='<thead class="collapsible" id="last24_'+name+'">'
	charthtml+='<tr>'
	charthtml+='<td colspan="2">Last 24 Hours (click to expand/collapse)</td>'
	charthtml+='</tr>'
	charthtml+='</thead>'
	charthtml+='<tr>'
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">'
	charthtml+='<div class="collapsiblecontent">'
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartDownloadDaily_'+name+'" height="300"></div>'
	charthtml+='<div style="line-height:10px;">&nbsp;</div>'
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartUploadDaily_'+name+'" height="300"></div>'
	charthtml+='</div>'
	charthtml+='</td>'
	charthtml+='</tr>'
	charthtml+='</table>'
	charthtml+='<div style="line-height:10px;">&nbsp;</div>'
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">'
	charthtml+='<thead class="collapsible" id="last7_'+name+'">'
	charthtml+='<tr>'
	charthtml+='<td colspan="2">Last 7 days (click to expand/collapse)</td>'
	charthtml+='</tr>'
	charthtml+='</thead>'
	charthtml+='<tr>'
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">'
	charthtml+='<div class="collapsiblecontent">'
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartDownloadWeekly_'+name+'" height="300"></div>'
	charthtml+='<div style="line-height:10px;">&nbsp;</div>'
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartUploadWeekly_'+name+'" height="300"></div>'
	charthtml+='</div>'
	charthtml+='</td>'
	charthtml+='</tr>'
	charthtml+='</table>'
	charthtml+='<div style="line-height:10px;">&nbsp;</div>'
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">'
	charthtml+='<thead class="collapsible" id="last30_'+name+'">'
	charthtml+='<tr>'
	charthtml+='<td colspan="2">Last 30 days (click to expand/collapse)</td>'
	charthtml+='</tr>'
	charthtml+='</thead>'
	charthtml+='<tr>'
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">'
	charthtml+='<div class="collapsiblecontent">'
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartDownloadMonthly_'+name+'" height="300"></div>'
	charthtml+='<div style="line-height:10px;">&nbsp;</div>'
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartUploadMonthly_'+name+'" height="300"></div>'
	charthtml+='</div>'
	charthtml+='</td>'
	charthtml+='</tr>'
	charthtml+='</table>'
	charthtml+='</div>'
	charthtml+='</td>'
	charthtml+='</tr>'
	charthtml+='</table>'
	charthtml+='<div style="line-height:10px;">&nbsp;</div>'
	return charthtml;
}

function AddEventHandlers(){
	var coll = document.getElementsByClassName("collapsible");
	var i;
	var height = 0;

	for (i = 0; i < coll.length; i++) {
		coll[i].addEventListener("click", function() {
			this.classList.toggle("active");
			var content = this.nextElementSibling.firstElementChild.firstElementChild.firstElementChild;
			if (content.style.maxHeight){
					content.style.maxHeight = null;
					SetCookie(this.id,"collapsed")
			} else {
					content.style.maxHeight = content.scrollHeight + "px";
					this.parentElement.parentElement.style.maxHeight = (this.parentElement.parentElement.style.maxHeight.substring(0,this.parentElement.parentElement.style.maxHeight.length-2)*1) + content.scrollHeight + "px";
					SetCookie(this.id,"expanded")
				}
		});
		
		if(GetCookie(coll[i].id) == "expanded" || GetCookie(coll[i].id) == ""){
			coll[i].click();
		}
		height=(coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight.substring(0,coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight.length-2)*1) + height + 21 + 10 + 10 + 10 + 10;
	}
	
	var coll = document.getElementsByClassName("collapsibleparent");
	var i;
	
	for (i = 0; i < coll.length; i++) {
		coll[i].addEventListener("click", function() {
			this.classList.toggle("active");
			var content = this.nextElementSibling.firstElementChild.firstElementChild.firstElementChild;
			if (content.style.maxHeight){
				content.style.maxHeight = null;
				SetCookie(this.id,"collapsed")
			} else {
				content.style.maxHeight = content.scrollHeight + "px";
				SetCookie(this.id,"expanded")
			}
		});
		if(GetCookie(coll[i].id) == "expanded" || GetCookie(coll[i].id) == ""){
			coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight = height + "px";
		} else {
			coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight = null;
		}
	}
}

</script>
</head>
<body onload="initial();" onunLoad="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="action_script" value="start_spdmerlin">
<input type="hidden" id="current_page" name="current_page" value="">
<input type="hidden" id="next_page" name="next_page" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_wait" value="90">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
<td width="17">&nbsp;</td>
<td valign="top" width="202">
<div id="mainMenu"></div>
<div id="subMenu"></div></td>
<td valign="top">
<div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
<tr>
<td valign="top">
<table width="760px" border="0" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
<tbody>
<tr bgcolor="#4D595D">
<td valign="top">
<div>&nbsp;</div>
<div class="formfonttitle" id="statstitle">Internet Speedtest Stats</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<tr class="apply_gen" valign="top" height="35px">
<td style="background-color:rgb(77, 89, 93);border:0px;">
<input type="button" onClick="applyRule();" value="Run speedtest now" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onClick="RedrawAllCharts();" value="Reset Zoom" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onClick="ToggleLines();" value="Toggle Lines" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onClick="ToggleFill();" value="Toggle Fill" class="button_gen" name="button">
</td>
</tr>
</table>

<!-- Charts inserted here -->

</td>
</tr>
</tbody>
</table>
</form>
</td>
</tr>
</table>
</td>
<td width="10" align="center" valign="top">&nbsp;</td>
</tr>
</table>
<script>
SetSPDStatsTitle();
</script>
<div id="footer">
</div>
</body>
</html>
