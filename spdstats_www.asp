<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>spdMerlin</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p {
  font-weight: bolder;
}

thead.collapsible-jquery {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

th.keystatsnumber {
  font-size: 20px !important;
  font-weight: bolder !important;
}

td.keystatsnumber {
  font-size: 20px !important;
  font-weight: bolder !important;
}

td.nodata {
  font-size: 48px !important;
  font-weight: bolder !important;
  height: 65px !important;
  font-family: Arial !important;
}

.StatsTable {
  table-layout: fixed !important;
  width: 747px !important;
  text-align: center !important;
}

.StatsTable th {
  background-color:#1F2D35 !important;
  background:#2F3A3E !important;
  border-bottom:none !important;
  border-top:none !important;
  color: white !important;
  padding: 4px !important;
  width: 740px !important;
  font-size: 11px !important;
}

.StatsTable td {
  padding: 2px !important;
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
  font-size: 12px !important;
}

.StatsTable a {
  font-weight: bolder !important;
  text-decoration: underline !important;
}

.StatsTable th:first-child,
.StatsTable td:first-child {
  border-left: none !important;
}

.StatsTable th:last-child ,
.StatsTable td:last-child {
  border-right: none !important;
}

.StatsTable tr.statsRow:nth-child(even) td {
  background-color: #2F3A3E !important;
}

.StatsTable tr.statsRow:nth-child(odd) td {
  background-color: #475A5F !important;
}

.SettingsTable {
  text-align: left;
}

.SettingsTable input {
  text-align: left;
  margin-left: 3px !important;
}

.SettingsTable input.savebutton {
  text-align: center;
  margin-top: 5px;
  margin-bottom: 5px;
  border-right: solid 1px black;
  border-left: solid 1px black;
  border-bottom: solid 1px black;
}

.SettingsTable td.savebutton {
  border-right: solid 1px black;
  border-left: solid 1px black;
  border-bottom: solid 1px black;
  background-color:rgb(77, 89, 93);
}

.SettingsTable .cronbutton {
  text-align: center;
  min-width: 50px;
  width: 50px;
  height: 23px;
  vertical-align: middle;
}

.SettingsTable select {
  margin-left: 3px !important;
}

.SettingsTable label {
  margin-right: 10px !important;
  vertical-align: top !important;
}

.SettingsTable th {
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  border-bottom: none !important;
  border-top: none !important;
  font-size: 12px !important;
  color: white !important;
  padding: 4px !important;
  font-weight: bolder !important;
  padding: 0px !important;
}

.SettingsTable th.sectionheader {
  padding-left: 10px !important;
  border-right: solid 1px black !important;
  border-left: solid 1px black !important;
}

.SettingsTable td {
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
  border-right: none;
  border-left: none;
}

.SettingsTable span.settingname {
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
}

.SettingsTable td.settingname {
  border-right: solid 1px black;
  border-left: solid 1px black;
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  width: 35% !important;
}

.SettingsTable td.settingvalue {
  text-align: left !important;
  border-right: solid 1px black;
}

.SettingsTable th:first-child{
  border-left: none;
}

.SettingsTable th:last-child {
  border-right: none;
}

.SettingsTable .invalid {
  background-color: darkred !important;
}

.SettingsTable .disabled {
  background-color: #CCCCCC !important;
  color: #888888 !important;
}

.removespacing {
  padding-left: 0px !important;
  margin-left: 0px !important;
  margin-bottom: 5px !important;
  text-align: center !important;
}

.schedulespan {
  display:inline-block !important;
  width:70px !important;
  color:#FFFFFF !important;
  font-weight: bold !important;
}

div.schedulesettings {
  margin-bottom: 5px;
}
</style>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chart.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/d3.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/detect.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdtitletext.js"></script>
<script>
var custom_settings;
function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for(var prop in custom_settings){
		if(Object.prototype.hasOwnProperty.call(custom_settings, prop)){
			if(prop.indexOf("spdmerlin") != -1 && prop.indexOf("spdmerlin_version") == -1){
				eval("delete custom_settings."+prop)
			}
		}
	}
}
var $j = jQuery.noConflict(); //avoid conflicts on John's fork (state.js)
var daysofweek = ["Mon","Tues","Wed","Thurs","Fri","Sat","Sun"];
var maxNoCharts = 0;
var currentNoCharts = 0;

var interfacelist = "";
var interfacescomplete = [];
var interfacesdisabled = [];

var ShowLines = GetCookie("ShowLines","string");
var ShowFill = GetCookie("ShowFill","string");
if(ShowFill == ""){
	ShowFill = "origin";
}

var DragZoom = true;
var ChartPan = false;

Chart.defaults.global.defaultFontColor = "#CCC";
Chart.Tooltip.positioners.cursor = function(chartElements, coordinates){
	return coordinates;
};

var chartlist = ["daily","weekly","monthly"];
var timeunitlist = ["hour","day","day"];
var intervallist = [24,7,30];
var bordercolourlist_Combined = ["#fc8500","#42ecf5"];
var backgroundcolourlist_Combined = ["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)"];
var bordercolourlist_Quality = ["#53047a","#07f242","#ffffff"];
var backgroundcolourlist_Quality = ["rgba(83,4,122,0.5)","rgba(7,242,66,0.5)","rgba(255,255,255,0.5)"];

var typelist = ["Combined","Quality"];

function keyHandler(e){
	if(e.keyCode == 27){
		$j(document).off("keydown");
		ResetZoom();
	}
}

$j(document).keydown(function(e){keyHandler(e);});
$j(document).keyup(function(e){
	$j(document).keydown(function(e){
		keyHandler(e);
	});
});

function Draw_Chart_NoData(txtchartname,txtcharttype){
	document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).width="730";
	document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).height="500";
	document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).style.width="730px";
	document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).style.height="500px";
	var ctx = document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).getContext("2d");
	ctx.save();
	ctx.textAlign = 'center';
	ctx.textBaseline = 'middle';
	ctx.font = "normal normal bolder 48px Arial";
	ctx.fillStyle = 'white';
	ctx.fillText('No data to display', 365, 250);
	ctx.restore();
}

function Draw_Chart(txtchartname,txtcharttype){
	var txtunity = "";
	var txtunity2 = "";
	var txttitle = "";
	var metric0 = "";
	var metric1 = "";
	var metric2 = "";
	var showyaxis2 = false;
	
	if(txtcharttype == "Combined"){
		txtunity = "Mbps";
		txttitle = "Bandwidth";
		metric0 = "Download";
		metric1 = "Upload";
	}
	else if(txtcharttype == "Quality"){
		txtunity = "ms";
		txtunity2 = "%";
		txttitle = "Quality";
		metric0 = "Latency";
		metric1 = "Jitter";
		metric2 = "PktLoss";
		showyaxis2 = true;
	}
	var chartperiod = getChartPeriod($j("#" + txtchartname + "_Period_" + txtcharttype + " option:selected").val());
	var txtunitx = timeunitlist[$j("#" + txtchartname + "_Period_" + txtcharttype + " option:selected").val()];
	var numunitx = intervallist[$j("#" + txtchartname + "_Period_" + txtcharttype + " option:selected").val()];
	var dataobject = window[chartperiod+"_"+txtchartname+"_"+txtcharttype];
	if(typeof dataobject === 'undefined' || dataobject === null){ Draw_Chart_NoData(txtchartname,txtcharttype); return; }
	if(dataobject.length == 0){ Draw_Chart_NoData(txtchartname,txtcharttype); return; }
	
	var chartData = dataobject.map(function(d){return {x: d.Time, y: d.Value}});
	
	var unique = [];
	var chartTrafficTypes = [];
	for( let i = 0; i < dataobject.length; i++){
		if(!unique[dataobject[i].Metric]){
			chartTrafficTypes.push(dataobject[i].Metric);
			unique[dataobject[i].Metric] = 1;
		}
	}
	
	var chartData0 = dataobject.filter(function(item){
		return item.Metric == metric0;
	}).map(function(d){return {x: d.Time, y: d.Value}});
	
	var chartData1 = dataobject.filter(function(item){
		return item.Metric == metric1;
	}).map(function(d){return {x: d.Time, y: d.Value}});
	
	var chartData2 = dataobject.filter(function(item){
		return item.Metric == metric2;
	}).map(function(d){return {x: d.Time, y: d.Value}});
	
	var objchartname=window["LineChart_"+txtchartname+"_"+txtcharttype];
	
	var timeaxisformat = getTimeFormat($j("#Time_Format option:selected").val(),"axis");
	var timetooltipformat = getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");
	
	factor=0;
	if(txtunitx=="hour"){
		factor=60*60*1000;
	}
	else if(txtunitx=="day"){
		factor=60*60*24*1000;
	}
	if(objchartname != undefined) objchartname.destroy();
	var ctx = document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).getContext("2d");
	var lineOptions = {
		segmentShowStroke : false,
		segmentStrokeColor : "#000",
		animationEasing : "easeOutQuart",
		animationSteps : 100,
		maintainAspectRatio: false,
		animateScale : true,
		hover: { mode: "point" },
		legend: {
			display: true,
			position: "top",
			reverse: true,
			onClick: function (e, legendItem){
				var index = legendItem.datasetIndex;
				var ci = this.chart;
				var meta = ci.getDatasetMeta(index);
				
				meta.hidden = meta.hidden === null ? !ci.data.datasets[index].hidden : null;
				
				if(ShowLines == "line"){
					var annotationline = ""
					if(meta.hidden != true){
						annotationline = "line";
					}
					
					if(ci.data.datasets[index].label == "Latency" || ci.data.datasets[index].label == "Download"){
						for(aindex = 0; aindex < 3; aindex++){
							ci.options.annotation.annotations[aindex].type=annotationline;
						}
					}
					else if(ci.data.datasets[index].label == "Jitter" || ci.data.datasets[index].label == "Upload"){
						for(aindex = 3; aindex < 6; aindex++){
							ci.options.annotation.annotations[aindex].type=annotationline;
						}
					}
					else if(ci.data.datasets[index].label == "Packet Loss"){
						for(aindex = 6; aindex < 9; aindex++){
							ci.options.annotation.annotations[aindex].type=annotationline;
						}
					}
				}
				
				if(ci.data.datasets[index].label == "Packet Loss"){
					var showaxis = false;
					if(meta.hidden != true){
						showaxis = true;
					}
					ci.scales["right-y-axis"].options.display = showaxis;
				}
				
				ci.update();
			}
		},
		title: { display: true, text: txttitle },
		tooltips: {
			callbacks: {
					title: function (tooltipItem, data){ return (moment(tooltipItem[0].xLabel,"X").format(timetooltipformat)); },
					label: function (tooltipItem, data){ var txtunitytip=txtunity; if(data.datasets[tooltipItem.datasetIndex].label == "Packet Loss"){txtunitytip=txtunity2}; return round(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y,2).toFixed(2) + ' ' + txtunitytip;}
				},
			itemSort: function(a, b){
				return b.datasetIndex - a.datasetIndex;
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
					min: moment().subtract(numunitx, txtunitx+"s"),
					display: true
				},
				time: {
					parser: "X",
					unit: txtunitx,
					stepSize: 1,
					displayFormats: timeaxisformat
				}
			}],
			yAxes: [{
				type: getChartScale($j("#" + txtchartname + "_Scale_" + txtcharttype + " option:selected").val()),
				gridLines: { display: false, color: "#282828" },
				scaleLabel: { display: false, labelString: txtunity },
				id: 'left-y-axis',
				position: 'left',
				ticks: {
					display: true,
					beginAtZero: true,
					labels: {
						index:  ['min', 'max'],
						removeEmptyLines: true,
					},
					userCallback: LogarithmicFormatter
				},
			},
			{
				type: getChartScale($j("#" + txtchartname + "_Scale_" + txtcharttype + " option:selected").val()),
				gridLines: { display: false, color: "#282828" },
				scaleLabel: { display: false, labelString: txtunity2 },
				id: 'right-y-axis',
				position: 'right',
				ticks: {
					display: showyaxis2,
					beginAtZero: true,
					labels: {
						index:  ['min', 'max'],
						removeEmptyLines: true,
					},
					userCallback: LogarithmicFormatter
				},
			}]
		},
		plugins: {
			zoom: {
				pan: {
					enabled: ChartPan,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: 0,
					},
					rangeMax: {
						x: new Date().getTime()//,
						//y: getLimit(chartData,"y","max",false) + getLimit(chartData,"y","max",false)*0.1,
					},
				},
				zoom: {
					enabled: true,
					drag: DragZoom,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: 0,
					},
					rangeMax: {
						x: new Date().getTime()//,
						//y: getLimit(chartData,"y","max",false) + getLimit(chartData,"y","max",false)*0.1,
					},
					speed: 0.1
				},
			},
		},
		annotation: {
			drawTime: 'afterDatasetsDraw',
			annotations: [{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getAverage(chartData0),
				borderColor: window["bordercolourlist_"+txtcharttype][0],
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
					content: "Avg. "+metric0+"=" + round(getAverage(chartData0),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData0,"y","max",true),
				borderColor: window["bordercolourlist_"+txtcharttype][0],
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
					position: "right",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Max. "+metric0+"=" + round(getLimit(chartData0,"y","max",true),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData0,"y","min",true),
				borderColor: window["bordercolourlist_"+txtcharttype][0],
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
					position: "left",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Min. "+metric0+"=" + round(getLimit(chartData0,"y","min",true),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getAverage(chartData1),
				borderColor: window["bordercolourlist_"+txtcharttype][1],
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
					content: "Avg. "+metric1+"=" + round(getAverage(chartData1),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData1,"y","max",true),
				borderColor: window["bordercolourlist_"+txtcharttype][1],
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
					position: "right",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Max. "+metric1+"=" + round(getLimit(chartData1,"y","max",true),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData1,"y","min",true),
				borderColor: window["bordercolourlist_"+txtcharttype][1],
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
					position: "left",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Min. "+metric1+"=" + round(getLimit(chartData1,"y","min",true),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'right-y-axis',
				value: getAverage(chartData2),
				borderColor: window["bordercolourlist_"+txtcharttype][2],
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
					content: "Avg. "+metric2+"=" + round(getAverage(chartData2),2).toFixed(2)+txtunity2,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'right-y-axis',
				value: getLimit(chartData2,"y","max",true),
				borderColor: window["bordercolourlist_"+txtcharttype][2],
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
					position: "right",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Max. "+metric2+"=" + round(getLimit(chartData2,"y","max",true),2).toFixed(2)+txtunity2,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'right-y-axis',
				value: getLimit(chartData2,"y","min",true),
				borderColor: window["bordercolourlist_"+txtcharttype][2],
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
					position: "left",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Min. "+metric2+"=" + round(getLimit(chartData2,"y","min",true),2).toFixed(2)+txtunity2,
				}
			}
			
		]}
	};
	var lineDataset = {
		datasets: getDataSets(txtcharttype, dataobject, chartTrafficTypes)
	};
	objchartname = new Chart(ctx, {
		type: 'line',
		options: lineOptions,
		data: lineDataset
	});
	window["LineChart_"+txtchartname+"_"+txtcharttype]=objchartname;
}

function LogarithmicFormatter(tickValue, index, ticks){
	var unit = this.options.scaleLabel.labelString;
	if(this.type != "logarithmic"){
		if(! isNaN(tickValue)){
			return round(tickValue,2).toFixed(2) + ' ' + unit;
		}
		else{
			return tickValue + ' ' + unit;
		}
	}
	else{
		var labelOpts =  this.options.ticks.labels || {};
		var labelIndex = labelOpts.index || ['min', 'max'];
		var labelSignificand = labelOpts.significand || [1,2,5];
		var significand = tickValue / (Math.pow(10, Math.floor(Chart.helpers.log10(tickValue))));
		var emptyTick = labelOpts.removeEmptyLines === true ? undefined : '';
		var namedIndex = '';
		if(index === 0){
			namedIndex = 'min';
		}
		else if(index === ticks.length - 1){
			namedIndex = 'max';
		}
		if(labelOpts === 'all' || labelSignificand.indexOf(significand) !== -1 || labelIndex.indexOf(index) !== -1 || labelIndex.indexOf(namedIndex) !== -1){
			if(tickValue === 0){
				return '0' + ' ' + unit;
			}
			else{
				if(! isNaN(tickValue)){
					return round(tickValue,2).toFixed(2) + ' ' + unit;
				}
				else{
					return tickValue + ' ' + unit;
				}
			}
		}
		return emptyTick;
	}
};


function getDataSets(charttype, objdata, objTrafficTypes){
	var datasets = [];
	colourname="#fc8500";
	
	for(var i = 0; i < objTrafficTypes.length; i++){
		var traffictypedata = objdata.filter(function(item){
			return item.Metric == objTrafficTypes[i];
		}).map(function(d){return {x: d.Time, y: d.Value}});
		var axisid = "left-y-axis";
		if(objTrafficTypes[i] == "PktLoss"){
			axisid = "right-y-axis";
		}
		
		datasets.push({ label: objTrafficTypes[i].replace("PktLoss","Packet Loss"), data: traffictypedata, yAxisID: axisid, borderWidth: 1, pointRadius: 1, lineTension: 0, fill: ShowFill, backgroundColor: window["backgroundcolourlist_"+charttype][i], borderColor: window["bordercolourlist_"+charttype][i]});
	}
	datasets.reverse();
	return datasets;
}

function getLimit(datasetname,axis,maxmin,isannotation){
	var limit=0;
	var values;
	if(axis == "x"){
		values = datasetname.map(function(o){ return o.x } );
	}
	else{
		values = datasetname.map(function(o){ return o.y } );
	}
	
	if(maxmin == "max"){
		limit=Math.max.apply(Math, values);
	}
	else{
		limit=Math.min.apply(Math, values);
	}
	if(maxmin == "max" && limit == 0 && isannotation == false){
		limit = 1;
	}
	return limit;
}

function getAverage(datasetname){
	var total = 0;
	for(var i = 0; i < datasetname.length; i++){
		total += (datasetname[i].y*1);
	}
	var avg = total / datasetname.length;
	return avg;
}

function round(value, decimals){
	return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function ToggleLines(){
	var interfacetextarray = interfacelist.split(',');
	if(ShowLines == ""){
		ShowLines = "line";
		SetCookie("ShowLines","line");
	}
	else{
		ShowLines = "";
		SetCookie("ShowLines","");
	}
	for(var i = 0; i < interfacetextarray.length; i++){
		for(var i2 = 0; i2 < typelist.length; i2++){
			var chartobj = window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
			var maxlines = 6;
			if(typelist[i2] == "Quality"){
				maxlines = 9;
			}
			for(var i3 = 0; i3 < maxlines; i3++){
				chartobj.options.annotation.annotations[i3].type=ShowLines;
			}
			chartobj.update();
		}
	}
}

function ToggleFill(){
	var interfacetextarray = interfacelist.split(',');
	if(ShowFill == "origin"){
		ShowFill = "false";
		SetCookie("ShowFill","false");
	}
	else{
		ShowFill = "origin";
		SetCookie("ShowFill","origin");
	}
	
	for(var i = 0; i < interfacetextarray.length; i++){
		for(var i2 = 0; i2 < typelist.length; i2++){
			var chartobj = window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
			chartobj.data.datasets[0].fill=ShowFill;
			chartobj.data.datasets[1].fill=ShowFill;
			if(typelist[i2] == "Quality"){
				chartobj.data.datasets[2].fill=ShowFill;
			}
			chartobj.update();
		}
	}
}

function RedrawAllCharts(){
	var interfacetextarray = interfacelist.split(',');
	var i;
	for(var i2 = 0; i2 < chartlist.length; i2++){
		for(var i3 = 0; i3 < interfacetextarray.length; i3++){
			$j("#"+interfacetextarray[i3]+"_Period_Combined").val(GetCookie(interfacetextarray[i3]+"_Period_Combined","number"));
			$j("#"+interfacetextarray[i3]+"_Period_Quality").val(GetCookie(interfacetextarray[i3]+"_Period_Quality","number"));
			$j("#"+interfacetextarray[i3]+"_Scale_Combined").val(GetCookie(interfacetextarray[i3]+"_Scale_Combined","number"));
			$j("#"+interfacetextarray[i3]+"_Scale_Quality").val(GetCookie(interfacetextarray[i3]+"_Scale_Quality","number"));
			d3.csv('/ext/spdmerlin/csv/Combined'+chartlist[i2]+"_"+interfacetextarray[i3]+'.htm').then(SetGlobalDataset.bind(null,chartlist[i2]+"_"+interfacetextarray[i3]+"_Combined"));
			d3.csv('/ext/spdmerlin/csv/Quality'+chartlist[i2]+"_"+interfacetextarray[i3]+'.htm').then(SetGlobalDataset.bind(null,chartlist[i2]+"_"+interfacetextarray[i3]+"_Quality"));
		}
	}
}

function getTimeFormat(value,format){
	var timeformat;
	
	if(format == "axis"){
		if(value == 0){
			timeformat = {
				millisecond: 'HH:mm:ss.SSS',
				second: 'HH:mm:ss',
				minute: 'HH:mm',
				hour: 'HH:mm'
			}
		}
		else if(value == 1){
			timeformat = {
				millisecond: 'h:mm:ss.SSS A',
				second: 'h:mm:ss A',
				minute: 'h:mm A',
				hour: 'h A'
			}
		}
	}
	else if(format == "tooltip"){
		if(value == 0){
			timeformat = "YYYY-MM-DD HH:mm:ss";
		}
		else if(value == 1){
			timeformat = "YYYY-MM-DD h:mm:ss A";
		}
	}
	
	return timeformat;
}

function GetCookie(cookiename,returntype){
	var s;
	if((s = cookie.get("spd_"+cookiename)) != null){
		return cookie.get("spd_"+cookiename);
	}
	else{
		if(returntype == "string"){
			return "";
		}
		else if(returntype == "number"){
			return 0;
		}
	}
}

function SetCookie(cookiename,cookievalue){
	cookie.set("spd_"+cookiename, cookievalue, 10 * 365);
}

$j.fn.serializeObject = function(){
	var o = custom_settings;
	var a = this.serializeArray();
	$j.each(a, function(){
		if(o[this.name] !== undefined && this.name.indexOf("spdmerlin") != -1 && this.name.indexOf("version") == -1 && this.name.indexOf("spdmerlin_iface_enabled") == -1 && this.name.indexOf("spdmerlin_usepreferred") == -1 && this.name.indexOf("schdays") == -1){
			if(!o[this.name].push){
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if(this.name.indexOf("spdmerlin") != -1 && this.name.indexOf("version") == -1 && this.name.indexOf("spdmerlin_iface_enabled") == -1 && this.name.indexOf("spdmerlin_usepreferred") == -1 && this.name.indexOf("schdays") == -1){
			o[this.name] = this.value || '';
		}
	});
	var schdays = [];
	$j.each($j("input[name='spdmerlin_schdays']:checked"), function(){
		schdays.push($j(this).val());
	});
	var schdaysstring = schdays.join(",");
	if(schdaysstring == "Mon,Tues,Wed,Thurs,Fri,Sat,Sun"){
		schdaysstring = "*";
	}
	o["spdmerlin_schdays"] = schdaysstring;
	
	$j.each($j("input[name^='spdmerlin_usepreferred']"), function(){
		o[this.id] = this.checked.toString();
	});
	
	var ifacesenabled = [];
	$j.each($j("input[name='spdmerlin_iface_enabled']:checked"), function(){
		ifacesenabled.push(this.value);
	});
	var ifacesenabledstring = ifacesenabled.join(",");
	o["spdmerlin_ifaces_enabled"] = ifacesenabledstring;
	return o;
};

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	$j("#Time_Format").val(GetCookie("Time_Format","number"));
	ScriptUpdateLayout();
	SetSPDStatsTitle();
	get_interfaces_file();
}

function SetGlobalDataset(txtchartname,dataobject){
	window[txtchartname] = dataobject;
	currentNoCharts++;
	if(currentNoCharts == maxNoCharts){
		var interfacetextarray = interfacelist.split(',');
		for(var i = 0; i < interfacetextarray.length; i++){
			Draw_Chart(interfacetextarray[i],"Combined");
			Draw_Chart(interfacetextarray[i],"Quality");
		}
	}
}

function ScriptUpdateLayout(){
	var localver = GetVersionNumber("local");
	var serverver = GetVersionNumber("server");
	$j("#spdmerlin_version_local").text(localver);
	
	if(localver != serverver && serverver != "N/A"){
		$j("#spdmerlin_version_server").text("Updated version available: "+serverver);
		showhide("btnChkUpdate", false);
		showhide("spdmerlin_version_server", true);
		showhide("btnDoUpdate", true);
	}
}

function reload(){
	location.reload(true);
}

function getYAxisMax(chartname){
	if(chartname.indexOf("Quality") != -1){
		return 100;
	}
}

function getChartPeriod(period){
	var chartperiod = "daily";
	if(period == 0) chartperiod = "daily";
	else if(period == 1) chartperiod = "weekly";
	else if(period == 2) chartperiod = "monthly";
	return chartperiod;
}

function getChartScale(scale){
	var chartscale = "";
	if(scale == 0){
		chartscale = "linear";
	}
	else if(scale == 1){
		chartscale = "logarithmic";
	}
	return chartscale;
}

function ResetZoom(){
	var interfacetextarray = interfacelist.split(',');
	for(var i = 0; i < interfacetextarray.length; i++){
		for(var i2 = 0; i2 < typelist.length; i2++){
			var chartobj = window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
			chartobj.resetZoom();
		}
	}
}

function ToggleDragZoom(button){
	var drag = true;
	var pan = false;
	var buttonvalue = "";
	if(button.value.indexOf("On") != -1){
		drag = false;
		pan = true;
		DragZoom = false;
		ChartPan = true;
		buttonvalue = "Drag Zoom Off";
	}
	else{
		drag = true;
		pan = false;
		DragZoom = true;
		ChartPan = false;
		buttonvalue = "Drag Zoom On";
	}
	
	var interfacetextarray = interfacelist.split(',');
	for(var i = 0; i < interfacetextarray.length; i++){
		for(var i2 = 0; i2 < typelist.length; i2++){
			var chartobj = window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
			chartobj.options.plugins.zoom.zoom.drag = drag;
			chartobj.options.plugins.zoom.pan.enabled = pan;
			chartobj.update();
		}
		button.value = buttonvalue;
	}
}

function ExportCSV(){
	location.href = "/ext/spdmerlin/csv/spdmerlindata.zip";
	return 0;
}

function update_status(){
	$j.ajax({
		url: '/ext/spdmerlin/detect_update.js',
		dataType: 'script',
		timeout: 3000,
		error: function(xhr){
			setTimeout(update_status, 1000);
		},
		success: function(){
			if(updatestatus == "InProgress"){
				setTimeout(update_status, 1000);
			}
			else{
				document.getElementById("imgChkUpdate").style.display = "none";
				showhide("spdmerlin_version_server", true);
				if(updatestatus != "None"){
					$j("#spdmerlin_version_server").text("Updated version available: "+updatestatus);
					showhide("btnChkUpdate", false);
					showhide("btnDoUpdate", true);
				}
				else{
					$j("#spdmerlin_version_server").text("No update available");
					showhide("btnChkUpdate", true);
					showhide("btnDoUpdate", false);
				}
			}
		}
	});
}

function CheckUpdate(){
	showhide("btnChkUpdate", false);
	document.formScriptActions.action_script.value="start_spdmerlincheckupdate"
	document.formScriptActions.submit();
	document.getElementById("imgChkUpdate").style.display = "";
	setTimeout(update_status, 2000);
}

function DoUpdate(){
	document.form.action_script.value = "start_spdmerlindoupdate";
	document.form.action_wait.value = 10;
	showLoading();
	document.form.submit();
}

function getAllIndexes(arr, val){
	var indexes = [];
	for(var i = 0; i < arr.length; i++){
		if(arr[i].id == val){
			indexes.push(i);
		}
	}
	return indexes;
}

function get_spdtestservers_file(ifacename){
	$j.ajax({
		url: '/ext/spdmerlin/spdmerlin_serverlist_'+ifacename.toUpperCase()+'.htm?cachebuster='+ new Date().getTime(),
		dataType: 'text',
		timeout: 2000,
		error: function(xhr){
			setTimeout(get_spdtestservers_file, 1000, ifacename);
		},
		success: function(data){
			var servers = [];
			$j.each(data.split('\n').filter(Boolean), function (key, entry){
				var obj = {};
				obj["id"] = entry.split('|')[0];
				obj["name"] = entry.split('|')[1];
				servers.push(obj);
			});
			
			$j("#spdmerlin_preferredserver_"+ifacename).prop("disabled",false);
			$j("#spdmerlin_preferredserver_"+ifacename).removeClass("disabled");
			
			let dropdown = $j("#spdmerlin_preferredserver_"+ifacename);
			dropdown.empty();
			$j.each(servers, function (key, entry){
				dropdown.append($j('<option></option>').attr('value', entry.id+'|'+entry.name).text(entry.id+'|'+entry.name));
			});
			dropdown.prop('selectedIndex', 0);
			
			$j("#spdmerlin_preferredserver_"+ifacename)[0].style.display = "";
			showhide("imgServerList_"+ifacename, false);
		}
	});
}

function get_manualspdtestservers_file(){
	$j.ajax({
		url: '/ext/spdmerlin/spdmerlin_manual_serverlist.htm?cachebuster='+ new Date().getTime(),
		dataType: 'text',
		timeout: 2000,
		error: function(xhr){
			setTimeout(get_manualspdtestservers_file, 2000);
		},
		success: function(data){
			var servers = [];
			$j.each(data.split('\n').filter(Boolean), function (key, entry){
				var obj = {};
				obj["id"] = entry.split('|')[0];
				obj["name"] = entry.split('|')[1];
				servers.push(obj);
			});
			
			if(document.form.spdtest_enabled.value == "All"){
				var arrifaceindex = getAllIndexes(servers,"-----");
				for(var i = 0; i < arrifaceindex.length; i++){
					let dropdown = $j($j("select[name^=spdtest_serverprefselect]")[i]);
					dropdown.empty();
					var arrtmp = [];
					if(i == 0){
						arrtmp = servers.slice(0, arrifaceindex[i]);
					}
					else if(i == arrifaceindex.length-1){
						arrtmp = servers.slice(arrifaceindex[i-1]+1,servers.length-1);
					}
					else{
						arrtmp = servers.slice(arrifaceindex[i-1]+1, arrifaceindex[i]);
					}
					$j.each(arrtmp, function (key, entry){
						dropdown.append($j('<option></option>').attr('value', entry.id+'|'+entry.name).text(entry.id+'|'+entry.name));
					});
					dropdown.prop('selectedIndex', 0);
				}
				
				$j.each($j("select[name^=spdtest_serverprefselect]"), function(){
					this.style.display = "inline-block";
				});
				$j.each($j("span[id^=spdtest_serverprefselectspan]"), function(){
					this.style.display = "inline-block";
				});
				showhide("imgManualServerList",false);
			}
			else{
				let dropdown = $j('select[name=spdtest_serverprefselect]');
				dropdown.empty();
				$j.each(servers, function (key, entry){
					dropdown.append($j('<option></option>').attr('value', entry.id+'|'+entry.name).text(entry.id+'|'+entry.name));
				});
				dropdown.prop('selectedIndex', 0);
				showhide("spdtest_serverprefselect",true);
				showhide("imgManualServerList",false);
			}
			for(var i = 0; i < interfacescomplete.length; i++){
				if(interfacesdisabled.includes(interfacescomplete[i]) == false){
					$j('#spdtest_enabled_'+interfacescomplete[i].toLowerCase()).prop("disabled",false);
					$j('#spdtest_enabled_'+interfacescomplete[i].toLowerCase()).removeClass("disabled");
				}
			}
			$j.each($j("input[name=spdtest_serverpref]"), function(){
				$j(this).prop("disabled",false);
				$j(this).removeClass("disabled");
			});
		}
	});
}

function get_spdtestresult_file(){
	$j.ajax({
		url: '/ext/spdmerlin/spd-result.htm',
		dataType: 'text',
		timeout: 1000,
		error: function(xhr){
			setTimeout(get_spdtestresult_file, 500);
		},
		success: function(data){
			var lines = data.trim().split('\n');
			data = lines.join('\n');
			$j("#spdtest_output").html(data);
		}
	});
}

function get_spdtest_file(){
	$j.ajax({
		url: '/ext/spdmerlin/spd-stats.htm',
		dataType: 'text',
		timeout: 1000,
		error: function(xhr){
			//do nothing
		},
		success: function(data){
			var lines = data.trim().split('\n');
			var arrlastLine = lines.slice(-1)[0].split('%').filter(Boolean);
			
			if(lines.length > 5){
				$j("#spdtest_output").html(lines[0] + '\n' + lines[1] + '\n' + lines[2] + '\n' + lines[3] + '\n' + lines[4] + '\n' + arrlastLine[arrlastLine.length-1] + "%");
			}
			else{
				$j("#spdtest_output").html("");
			}
		}
	});
}

function update_spdtest(){
	$j.ajax({
		url: '/ext/spdmerlin/detect_spdtest.js',
		dataType: 'script',
		timeout: 1000,
		error: function(xhr){
			//do nothing
		},
		success: function(){
			if(spdteststatus.indexOf("InProgress") != -1){
				if(spdteststatus.indexOf("_") != -1){
					showhide("imgSpdTest", true);
					showhide("spdtest_text", true);
					document.getElementById("spdtest_text").innerHTML = "Speedtest in progress for " + spdteststatus.substring(spdteststatus.indexOf("_")+1);
					document.getElementById("spdtest_output").parentElement.parentElement.style.display = "";
					get_spdtest_file();
				}
			}
			else if(spdteststatus == "Done"){
				get_spdtestresult_file();
				document.getElementById("spdtest_text").innerHTML = "Refreshing tables and charts...";
				clearInterval(myinterval);
				PostSpeedTest();
			}
			else if(spdteststatus == "LOCKED"){
				showhide("imgSpdTest", false);
				document.getElementById("spdtest_text").innerHTML = "Scheduled speedtest already running!";
				showhide("spdtest_text", true);
				document.getElementById("spdtest_output").parentElement.parentElement.style.display = "none";
				showhide("btnRunSpeedtest", true);
				clearInterval(myinterval);
			}
			else if(spdteststatus == "NoLicense"){
				showhide("imgSpdTest", false);
				document.getElementById("spdtest_text").innerHTML = "Please accept Ookla license at command line via spdmerlin";
				showhide("spdtest_text", true);
				document.getElementById("spdtest_output").parentElement.parentElement.style.display = "none";
				showhide("btnRunSpeedtest", true);
				clearInterval(myinterval);
			}
			else if(spdteststatus == "Error"){
				showhide("imgSpdTest", false);
				document.getElementById("spdtest_text").innerHTML = "Error running speedtest";
				showhide("spdtest_text", true);
				document.getElementById("spdtest_output").parentElement.parentElement.style.display = "none";
				showhide("btnRunSpeedtest", true);
				clearInterval(myinterval);
			}
			else if(spdteststatus == "NoSwap"){
				showhide("imgSpdTest", false);
				document.getElementById("spdtest_text").innerHTML = "No Swap file configured/detected";
				showhide("spdtest_text", true);
				document.getElementById("spdtest_output").parentElement.parentElement.style.display = "none";
				showhide("btnRunSpeedtest", true);
				clearInterval(myinterval);
			}
		}
	});
}

function PostSpeedTest(){
	$j("#table_allinterfaces").remove();
	$j("#rowautomaticspdtest").remove();
	$j("#rowautospdprefserver").remove();
	$j("#rowautospdprefserverselect").remove();
	$j("#rowmanualspdtest").remove();
	currentNoCharts = 0;
	reload_js('/ext/spdmerlin/spdjs.js');
	reload_js('/ext/spdmerlin/spdtitletext.js');
	$j("#Time_Format").val(GetCookie("Time_Format","number"));
	SetSPDStatsTitle();
	setTimeout(get_interfaces_file, 3000);
}

function RunSpeedtest(){
	showhide("btnRunSpeedtest", false);
	$j("#spdtest_output").html("");
	
	var spdtestservers = "";
	if(document.form.spdtest_serverpref.value == "onetime"){
		if(document.form.spdtest_enabled.value == "All"){
			$j.each($j("select[name^=spdtest_serverprefselect]"), function(){
				spdtestservers += this.value.substring(0,this.value.indexOf('|')) + '+';
			});
			spdtestservers = spdtestservers.slice(0,-1);
		}
		else{
			spdtestservers = document.form.spdtest_serverprefselect.value.substring(0,document.form.spdtest_serverprefselect.value.indexOf('|'));
		}
	}
	document.formScriptActions.action_script.value="start_spdmerlinspdtest_" + document.form.spdtest_serverpref.value + "_" + document.form.spdtest_enabled.value + "_" + spdtestservers.replace(/ /g,'%');
	document.formScriptActions.submit();
	showhide("imgSpdTest", true);
	showhide("spdtest_text", false);
	setTimeout(StartSpeedTestInterval, 1500);
}

var myinterval;
function StartSpeedTestInterval(){
	myinterval = setInterval("update_spdtest();", 500);
}

function reload_js(src){
	$j('script[src="' + src + '"]').remove();
	$j('<script>').attr('src', src+'?cachebuster='+ new Date().getTime()).appendTo('head');
}

function SaveConfig(){
	if(Validate_All()){
		$j('[name*=spdmerlin_]').prop("disabled",false);
		for(var i = 0; i < interfacescomplete.length; i++){
			$j('#spdmerlin_iface_enabled_'+interfacescomplete[i].toLowerCase()).prop("disabled",false);
			$j('#spdmerlin_iface_enabled_'+interfacescomplete[i].toLowerCase()).removeClass("disabled");
			$j('#spdmerlin_usepreferred_'+interfacescomplete[i].toLowerCase()).prop("disabled",false);
			$j('#spdmerlin_usepreferred_'+interfacescomplete[i].toLowerCase()).removeClass("disabled");
			$j('#changepref_'+interfacescomplete[i].toLowerCase()).prop("disabled",false);
			$j('#changepref_'+interfacescomplete[i].toLowerCase()).removeClass("disabled");
		}
		if(document.form.schedulemode.value == "EveryX"){
			if(document.form.everyxselect.value == "hours"){
				var everyxvalue = document.form.everyxvalue.value*1;
				document.form.spdmerlin_schmins.value = 0;
				if(everyxvalue == 24){
					document.form.spdmerlin_schhours.value = 0;
				}
				else{
					document.form.spdmerlin_schhours.value = "*/"+everyxvalue;
				}
			}
			else if(document.form.everyxselect.value == "minutes"){
				document.form.spdmerlin_schhours.value = "*";
				var everyxvalue = document.form.everyxvalue.value*1;
				document.form.spdmerlin_schmins.value = "*/"+everyxvalue;
			}
		}
		document.getElementById('amng_custom').value = JSON.stringify($j('form').serializeObject());
		document.form.action_script.value = "start_spdmerlinconfig";
		showLoading();
		document.form.submit();
		document.form.action_wait.value = 10;
	}
	else{
		return false;
	}
}

function GetVersionNumber(versiontype){
	var versionprop;
	if(versiontype == "local"){
		versionprop = custom_settings.spdmerlin_version_local;
	}
	else if(versiontype == "server"){
		versionprop = custom_settings.spdmerlin_version_server;
	}
	
	if(typeof versionprop == 'undefined' || versionprop == null){
		return "N/A";
	}
	else{
		return versionprop;
	}
}

function get_conf_file(){
	$j.ajax({
		url: '/ext/spdmerlin/config.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_conf_file, 1000);
		},
		success: function(data){
			var configdata=data.split("\n");
			configdata = configdata.filter(Boolean);
			
			for(var i = 0; i < configdata.length; i++){
				let settingname = configdata[i].split("=")[0].toLowerCase();
				let settingvalue = configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");
				
				if(configdata[i].indexOf("SCHDAYS") != -1){
					if(settingvalue == "*"){
						for(var i2 = 0; i2 < daysofweek.length; i2++){
							$j("#spdmerlin_"+daysofweek[i2].toLowerCase()).prop("checked",true);
						}
					}
					else{
						var schdayarray = settingvalue.split(',');
						for(var i2 = 0; i2 < schdayarray.length; i2++){
							$j("#spdmerlin_"+schdayarray[i2].toLowerCase()).prop("checked",true);
						}
					}
				}
				else if(configdata[i].indexOf("USEPREFERRED") != -1){
					if(settingvalue == "true"){
						eval("document.form.spdmerlin_"+settingname).checked = true;
					}
				}
				else if(configdata[i].indexOf("PREFERREDSERVER") != -1){
					$j("#span_spdmerlin_"+settingname).html(configdata[i].split("=")[0].split("_")[1]+" - "+settingvalue);
				}
				else if(configdata[i].indexOf("PREFERRED") == -1){
					eval("document.form.spdmerlin_"+settingname).value = settingvalue;
				}
				
				if(configdata[i].indexOf("AUTOMATED") != -1){
					AutomaticInterfaceEnableDisable($j("#spdmerlin_auto_"+document.form.spdmerlin_automated.value)[0]);
				}
				
				if(configdata[i].indexOf("AUTOBW") != -1){
					AutoBWEnableDisable($j("#spdmerlin_autobw_"+document.form.spdmerlin_autobw_enabled.value)[0]);
				}
			}
			if($j('[name=spdmerlin_schhours]').val().indexOf('/') != -1 && $j('[name=spdmerlin_schmins]').val() == 0){
				document.form.schedulemode.value = "EveryX";
				document.form.everyxselect.value = "hours";
				document.form.everyxvalue.value = $j('[name=spdmerlin_schhours]').val().split('/')[1];
			}
			else if($j('[name=spdmerlin_schmins]').val().indexOf('/') != -1 && $j('[name=spdmerlin_schhours]').val() == "*"){
				document.form.schedulemode.value = "EveryX";
				document.form.everyxselect.value = "minutes";
				document.form.everyxvalue.value = $j('[name=spdmerlin_schmins]').val().split('/')[1];
			}
			else{
				document.form.schedulemode.value = "Custom";
			}
			ScheduleModeToggle($j('#schmode_'+$j('[name=schedulemode]:checked').val().toLowerCase())[0]);
		}
	});
}

function get_interfaces_file(){
	$j.ajax({
		url: '/ext/spdmerlin/interfaces_user.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_interfaces_file, 1000);
		},
		success: function(data){
			showhide("spdtest_text", false);
			showhide("imgSpdTest", false);
			showhide("btnRunSpeedtest", true);
			var interfaces=data.split("\n");
			interfaces=interfaces.filter(Boolean);
			interfacelist="";
			interfacescomplete = [];
			interfacesdisabled = [];

			var interfacecharttablehtml='<div style="line-height:10px;">&nbsp;</div>';
			interfacecharttablehtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_allinterfaces">';
			interfacecharttablehtml+='<thead class="collapsible-jquery" id="thead_allinterfaces">';
			interfacecharttablehtml+='<tr><td>Interfaces (click to expand/collapse)</td></tr>';
			interfacecharttablehtml+='</thead>';
			interfacecharttablehtml+='<tr><td align="center" style="padding: 0px;">';
			
			var interfaceconfigtablehtml='<tr id="rowautomaticspdtest"><td class="settingname">Interfaces to use for automatic speedtests</th><td class="settingvalue">';
			
			var prefserverconfigtablehtml='<tr id="rowautospdprefserver"><td class="settingname">Interfaces that use a preferred server</th><td class="settingvalue">';
			
			var prefserverselecttablehtml='<tr id="rowautospdprefserverselect"><td class="settingname">Preferred servers for interfaces</th><td class="settingvalue">';
			
			var speedtestifaceconfigtablehtml='<tr id="rowmanualspdtest"><td class="settingname">Interfaces to use for manual speedtest</th><td class="settingvalue">';
			speedtestifaceconfigtablehtml+='<input type="radio" name="spdtest_enabled" id="spdtest_enabled_all" onchange="Change_SpdTestInterface(this)" class="input" settingvalueradio" value="All" checked>';
			speedtestifaceconfigtablehtml+='<label for="spdtest_enabled_all">All</label>';
			
			var interfacecount=interfaces.length;
			for(var i = 0; i < interfacecount; i++){
				var interfacename = "";
				if(interfaces[i].indexOf("#") != -1){
					interfacename = interfaces[i].substring(0,interfaces[i].indexOf("#")).trim();
					interfacescomplete.push(interfacename);
					var interfacedisabled = "";
					var ifacelabel = interfacename.toUpperCase();
					var changelabel = "Change?";
					if(interfaces[i].indexOf("interface not up") != -1){
						interfacesdisabled.push(interfacename);
						interfacedisabled = "disabled";
						ifacelabel = '<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(1);">'+interfacename.toUpperCase()+'</a>';
						changelabel = '<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(1);">Change?</a>';
					}
					interfaceconfigtablehtml+='<input type="checkbox" name="spdmerlin_iface_enabled" id="spdmerlin_iface_enabled_'+ interfacename.toLowerCase() +'" class="input ' + interfacedisabled + ' settingvalue" value="'+interfacename.toUpperCase()+'" ' + interfacedisabled + '>';
					interfaceconfigtablehtml+='<label for="spdmerlin_iface_enabled_'+ interfacename.toLowerCase() +'">'+ifacelabel+'</label>';
					
					prefserverconfigtablehtml+='<input type="checkbox" name="spdmerlin_usepreferred_' + interfacename.toLowerCase() + '" id="spdmerlin_usepreferred_'+ interfacename.toLowerCase() +'" class="input ' + interfacedisabled + ' settingvalue" value="'+interfacename.toUpperCase()+'" ' + interfacedisabled + '>';
					prefserverconfigtablehtml+='<label for="spdmerlin_usepreferred_'+ interfacename.toLowerCase() +'">'+ifacelabel+'</label>';
					
					prefserverselecttablehtml+='<span style="margin-left:4px;vertical-align:top;max-width:465px;display:inline-block;" id="span_spdmerlin_preferredserver_'+interfacename.toLowerCase()+'">'+interfacename.toUpperCase()+':</span><br />';
					prefserverselecttablehtml+='<input type="checkbox" name="changepref_' + interfacename.toLowerCase() + '" id="changepref_'+ interfacename.toLowerCase() +'" class="input settingvalue ' + interfacedisabled + '" ' + interfacedisabled + ' onchange="Toggle_ChangePrefServer(this)">';
					prefserverselecttablehtml+='<label for="changepref_'+ interfacename.toLowerCase() +'">'+changelabel+'</label>';
					prefserverselecttablehtml+='<img id="imgServerList_'+ interfacename.toLowerCase() +'" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>';
					prefserverselecttablehtml+='<select class="disabled" name="spdmerlin_preferredserver_'+interfacename.toLowerCase()+'" id="spdmerlin_preferredserver_'+interfacename.toLowerCase()+'" style="min-width:100px;max-width:400px;display:none;vertical-align:top;" disabled></select><br />';
					
					speedtestifaceconfigtablehtml+='<input autocomplete="off" autocapitalize="off" type="radio" name="spdtest_enabled" id="spdtest_enabled_'+ interfacename.toLowerCase() +'" onchange="Change_SpdTestInterface(this)" class="input ' + interfacedisabled + ' settingvalueradio" value="'+interfacename.toUpperCase()+'" ' + interfacedisabled + '>';
					speedtestifaceconfigtablehtml+='<label for="spdtest_enabled_'+ interfacename.toLowerCase() +'">'+ifacelabel+'</label>';
				}
				else{
					interfacename = interfaces[i].trim();
					interfacescomplete.push(interfacename);
					
					interfaceconfigtablehtml+='<input type="checkbox" name="spdmerlin_iface_enabled" id="spdmerlin_iface_enabled_'+ interfacename.toLowerCase() +'" class="input settingvalue" value="'+interfacename.toUpperCase()+'" checked>';
					interfaceconfigtablehtml+='<label for="spdmerlin_iface_enabled_'+ interfacename.toLowerCase() +'">'+interfacename.toUpperCase()+'</label>';
					
					prefserverconfigtablehtml+='<input type="checkbox" name="spdmerlin_usepreferred_' + interfacename.toLowerCase() + '" id="spdmerlin_usepreferred_'+ interfacename.toLowerCase() +'" class="input settingvalue" value="'+interfacename.toUpperCase()+'" checked>';
					prefserverconfigtablehtml+='<label for="spdmerlin_usepreferred_'+ interfacename.toLowerCase() +'">'+interfacename.toUpperCase()+'</label>';
					
					prefserverselecttablehtml+='<span style="margin-left:4px;vertical-align:top;max-width:465px;display:inline-block;" id="span_spdmerlin_preferredserver_'+interfacename.toLowerCase()+'">'+interfacename.toUpperCase()+':</span><br />';
					prefserverselecttablehtml+='<input type="checkbox" name="changepref_' + interfacename.toLowerCase() + '" id="changepref_'+ interfacename.toLowerCase() +'" class="input settingvalue" onchange="Toggle_ChangePrefServer(this)">';
					prefserverselecttablehtml+='<label for="changepref_'+ interfacename.toLowerCase() +'">Change?</label>';
					prefserverselecttablehtml+='<img id="imgServerList_'+ interfacename.toLowerCase() +'" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>';
					prefserverselecttablehtml+='<select class="disabled" name="spdmerlin_preferredserver_'+interfacename.toLowerCase()+'" id="spdmerlin_preferredserver_'+interfacename.toLowerCase()+'" style="min-width:100px;max-width:400px;display:none;vertical-align:top;" disabled></select><br />';
					
					speedtestifaceconfigtablehtml+='<input type="radio" name="spdtest_enabled" id="spdtest_enabled_'+ interfacename.toLowerCase() +'" onchange="Change_SpdTestInterface(this)" class="input settingvalueradio" value="'+interfacename.toUpperCase()+'">';
					speedtestifaceconfigtablehtml+='<label for="spdtest_enabled_'+ interfacename.toLowerCase() +'">'+interfacename.toUpperCase()+'</label>';
				}
				
				interfacecharttablehtml += BuildInterfaceTable(interfacename);
				
				interfacelist+=interfacename+',';
			}
			
			interfacecharttablehtml+='</td></tr></table>';
			
			interfaceconfigtablehtml+='</td></tr>';
			
			prefserverconfigtablehtml+='</td></tr>';
			
			prefserverselecttablehtml+='</td></tr>';
			
			speedtestifaceconfigtablehtml+='</td></tr>';
			
			$j("#rowautomatedtests").after(prefserverselecttablehtml);
			$j("#rowautomatedtests").after(prefserverconfigtablehtml);
			$j("#rowautomatedtests").after(interfaceconfigtablehtml);
			$j("#thead_manualspeedtests").after(speedtestifaceconfigtablehtml);
			
			GenerateManualSpdTestServerPrefSelect();
			document.form.spdtest_serverpref.value = "auto";
			
			if(interfacelist.charAt(interfacelist.length-1) == ","){
				interfacelist = interfacelist.slice(0, -1);
			}
			
			$j("#table_buttons2").after(interfacecharttablehtml);
			maxNoCharts = interfacelist.split(',').length*3*2;
			RedrawAllCharts();
			
			AddEventHandlers();
			get_conf_file();
		}
	});
}

function changeAllCharts(e){
	value = e.value * 1;
	name = e.id.substring(0, e.id.indexOf("_"));
	SetCookie(e.id,value);
	var interfacetextarray = interfacelist.split(',');
	for(var i = 0; i < interfacetextarray.length; i++){
		Draw_Chart(interfacetextarray[i],"Combined");
		Draw_Chart(interfacetextarray[i],"Quality");
	}
}

function changeChart(e){
	value = e.value * 1;
	name = e.id.substring(0, e.id.indexOf("_"));
	SetCookie(e.id,value);
	if(e.id.indexOf("Combined") != -1){
		Draw_Chart(name,"Combined");
	}
	else if(e.id.indexOf("Quality") != -1){
		Draw_Chart(name,"Quality");
	}
}

function SettingHint(hintid){
	var tag_name = document.getElementsByTagName('a');
	for(var i=0;i<tag_name.length;i++){
		tag_name[i].onmouseout=nd;
	}
	hinttext="My text goes here";
	if(hintid == 1) hinttext="Interface not enabled";
	if(hintid == 2) hinttext="Hour(s) of day to run speedtest<br />* for all<br />Valid numbers between 0 and 23<br />comma (,) separate for multiple<br />dash (-) separate for a range";
	if(hintid == 3) hinttext="Minute(s) of day to run speedtest<br />(* for all<br />Valid numbers between 0 and 59<br />comma (,) separate for multiple<br />dash (-) separate for a range";
	
	return overlib(hinttext, 0, 0);
}

function BuildInterfaceTable(name){
	var charthtml = '<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_interfaces_'+name+'">';
	charthtml+='<thead class="collapsible-jquery" id="'+name+'">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">'+name+' (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible-jquery" id="resulttable_'+name+'">';
	charthtml+='<tr><td colspan="2">Last 10 speedtest results (click to expand/collapse)</td></tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable StatsTable">';
	var nodata="";
	var objdataname = window["DataTimestamp_"+name];
	if(typeof objdataname === 'undefined' || objdataname === null){nodata="true"}
	else if(objdataname.length == 0){nodata="true"}
	else if(objdataname.length == 1 && objdataname[0] == ""){nodata="true"}
	
	if(nodata == "true"){
		charthtml+='<tr>';
		charthtml+='<td colspan="6" class="nodata">';
		charthtml+='No data to display';
		charthtml+='</td>';
		charthtml+='</tr>';
	}
	else{
		charthtml+='<col style="width:120px;">';
		charthtml+='<col style="width:75px;">';
		charthtml+='<col style="width:65px;">';
		charthtml+='<col style="width:65px;">';
		charthtml+='<col style="width:65px;">';
		charthtml+='<col style="width:65px;">';
		charthtml+='<col style="width:80px;">';
		charthtml+='<col style="width:80px;">';
		charthtml+='<col style="width:135px;">';
		charthtml+='<thead>';
		charthtml+='<tr>';
		charthtml+='<th class="keystatsnumber">Time</th>';
		charthtml+='<th class="keystatsnumber">Download<br />(Mbps)</th>';
		charthtml+='<th class="keystatsnumber">Upload<br />(Mbps)</th>';
		charthtml+='<th class="keystatsnumber">Latency<br />(ms)</th>';
		charthtml+='<th class="keystatsnumber">Jitter<br />(ms)</th>';
		charthtml+='<th class="keystatsnumber">Packet<br />Loss (%)</th>';
		charthtml+='<th class="keystatsnumber">Download<br />Data (MB)</th>';
		charthtml+='<th class="keystatsnumber">Upload<br />Data (MB)</th>';
		charthtml+='<th class="keystatsnumber">Result URL</th>';
		charthtml+='</tr>';
		charthtml+='</thead>';
		
		for(var i = 0; i < objdataname.length; i++){
			charthtml+='<tr class="statsRow">';
			charthtml+='<td>'+moment.unix(window["DataTimestamp_"+name][i]).format('YYYY-MM-DD HH:mm:ss')+'</td>';
			charthtml+='<td>'+window["DataDownload_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataUpload_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataLatency_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataJitter_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataPktLoss_"+name][i].replace("null","N/A")+'</td>';
			charthtml+='<td>'+window["DataDataDownload_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataDataUpload_"+name][i]+'</td>';
			if(window["DataResultURL_"+name][i] != ""){
				charthtml+='<td><a href="'+window["DataResultURL_"+name][i]+'" target="_blank">Speedtest result URL</a></td>';
			}
			else{
				charthtml+='<td>No result URL</td>';
			}
			charthtml+='</tr>';
		};
	}
	charthtml+='</table>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible-jquery" id="table_charts">';
	charthtml+='<tr>';
	charthtml+='<td>Tables and Charts (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr><td align="center" style="padding: 0px;">';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible-jquery" id="'+name+'_ChartCombined">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">Bandwidth (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr class="even">';
	charthtml+='<th width="40%">Period to display</th>';
	charthtml+='<td>';
	charthtml+='<select style="width:150px" class="input_option" onchange="changeChart(this)" id="' + name + '_Period_Combined">';
	charthtml+='<option value=0>Last 24 hours</option>';
	charthtml+='<option value=1>Last 7 days</option>';
	charthtml+='<option value=2>Last 30 days</option>';
	charthtml+='</select>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='<tr class="even">';
	charthtml+='<th width="40%">Scale type</th>';
	charthtml+='<td>';
	charthtml+='<select style="width:150px" class="input_option" onchange="changeChart(this)" id="' + name + '_Scale_Combined">';
	charthtml+='<option value="0">Linear</option>';
	charthtml+='<option value="1">Logarithmic</option>';
	charthtml+='</select>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_'+name+'_Combined" height="500" /></div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible-jquery" id="'+name+'_ChartQuality">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">Quality (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr class="even">';
	charthtml+='<th width="40%">Period to display</th>';
	charthtml+='<td>';
	charthtml+='<select style="width:150px" class="input_option" onchange="changeChart(this)" id="' + name + '_Period_Quality">';
	charthtml+='<option value=0>Last 24 hours</option>';
	charthtml+='<option value=1>Last 7 days</option>';
	charthtml+='<option value=2>Last 30 days</option>';
	charthtml+='</select>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='<tr class="even">';
	charthtml+='<th width="40%">Scale type</th>';
	charthtml+='<td>';
	charthtml+='<select style="width:150px" class="input_option" onchange="changeChart(this)" id="' + name + '_Scale_Quality">';
	charthtml+='<option value="0">Linear</option>';
	charthtml+='<option value="1">Logarithmic</option>';
	charthtml+='</select>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_'+name+'_Quality" height="500" /></div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	return charthtml;
}

function AutomaticInterfaceEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));
	
	var fieldnames = ["schhours","schmins"];
	var fieldnames2 = ["schedulemode","everyxselect","everyxvalue"];
	
	if(inputvalue == "false"){
		for(var i = 0; i < interfacescomplete.length; i++){
			$j('#'+prefix+'_iface_enabled_'+interfacescomplete[i].toLowerCase()).prop("disabled",true);
			$j('#'+prefix+'_iface_enabled_'+interfacescomplete[i].toLowerCase()).addClass("disabled");
			$j('#'+prefix+'_usepreferred_'+interfacescomplete[i].toLowerCase()).prop("disabled",true);
			$j('#'+prefix+'_usepreferred_'+interfacescomplete[i].toLowerCase()).addClass("disabled");
			$j('#changepref_'+interfacescomplete[i].toLowerCase()).prop("disabled",true);
			$j('#changepref_'+interfacescomplete[i].toLowerCase()).addClass("disabled");
		}
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name='+prefix+'_'+fieldnames[i]+']').addClass("disabled");
			$j('input[name='+prefix+'_'+fieldnames[i]+']').prop("disabled",true);
		}
		for (var i = 0; i < daysofweek.length; i++){
			$j('#'+prefix+'_'+daysofweek[i].toLowerCase()).prop("disabled",true);
		}
		for (var i = 0; i < fieldnames2.length; i++){
			$j('[name='+fieldnames2[i]+']').addClass("disabled");
			$j('[name='+fieldnames2[i]+']').prop("disabled",true);
		}
	}
	else if(inputvalue == "true"){
		for(var i = 0; i < interfacescomplete.length; i++){
			if(interfacesdisabled.includes(interfacescomplete[i]) == false){
				$j('#'+prefix+'_iface_enabled_'+interfacescomplete[i].toLowerCase()).prop("disabled",false);
				$j('#'+prefix+'_iface_enabled_'+interfacescomplete[i].toLowerCase()).removeClass("disabled");
				$j('#'+prefix+'_usepreferred_'+interfacescomplete[i].toLowerCase()).prop("disabled",false);
				$j('#'+prefix+'_usepreferred_'+interfacescomplete[i].toLowerCase()).removeClass("disabled");
				$j('#changepref_'+interfacescomplete[i].toLowerCase()).prop("disabled",false);
				$j('#changepref_'+interfacescomplete[i].toLowerCase()).removeClass("disabled");
			}
		}
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name='+prefix+'_'+fieldnames[i]+']').removeClass("disabled");
			$j('input[name='+prefix+'_'+fieldnames[i]+']').prop("disabled",false);
		}
		for (var i = 0; i < daysofweek.length; i++){
			$j('#'+prefix+'_'+daysofweek[i].toLowerCase()).prop("disabled",false);
		}
		for (var i = 0; i < fieldnames2.length; i++){
			$j('[name='+fieldnames2[i]+']').removeClass("disabled");
			$j('[name='+fieldnames2[i]+']').prop("disabled",false);
		}
	}
}

function ScheduleModeToggle(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	if(inputvalue == "EveryX"){
		showhide("schfrequency",true);
		showhide("schcustom",false);
		if($j("#everyxselect").val() == "hours"){
			showhide("spanxhours",true);
			showhide("spanxminutes",false);
		}
		else if($j("#everyxselect").val() == "minutes"){
			showhide("spanxhours",false);
			showhide("spanxminutes",true);
		}
	}
	else if(inputvalue == "Custom"){
		showhide("schfrequency",false);
		showhide("schcustom",true);
	}
}

function EveryXToggle(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	if(inputvalue == "hours"){
		showhide("spanxhours",true);
		showhide("spanxminutes",false);
	}
	else if(inputvalue == "minutes"){
		showhide("spanxhours",false);
		showhide("spanxminutes",true);
	}
	
	Validate_ScheduleValue($j("[name=everyxvalue]")[0]);
}

function AutoBWEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.indexOf('_'));
	
	var fieldnames = ["autobw_ulimit","autobw_llimit","autobw_sf","autobw_threshold","autobw_average"];
	
	if(inputvalue == "false"){
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name^='+prefix+'_'+fieldnames[i]+']').addClass("disabled");
			$j('input[name^='+prefix+'_'+fieldnames[i]+']').prop("disabled",true);
		}
		
		$j('input[name^='+prefix+'_excludefromqos]').removeClass("disabled");
		$j('input[name^='+prefix+'_excludefromqos]').prop("disabled",false);
	}
	else if(inputvalue == "true"){
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name^='+prefix+'_'+fieldnames[i]+']').removeClass("disabled");
			$j('input[name^='+prefix+'_'+fieldnames[i]+']').prop("disabled",false);
		}
		
		document.form.spdmerlin_excludefromqos.value = true;
		$j('input[name^='+prefix+'_excludefromqos]').addClass("disabled");
		$j('input[name^='+prefix+'_excludefromqos]').prop("disabled",true);
	}
}

function Toggle_ChangePrefServer(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.checked;
	
	var ifacename = inputname.split("_")[1];
	
	if(inputvalue == true){
		document.formScriptActions.action_script.value="start_spdmerlinserverlist_"+ifacename;
		document.formScriptActions.submit();
		showhide("imgServerList_"+ifacename, true);
		setTimeout(get_spdtestservers_file, 2000, ifacename);
	}
	else{
		$j("#spdmerlin_preferredserver_"+ifacename)[0].style.display = "none";
		$j("#spdmerlin_preferredserver_"+ifacename).prop("disabled",true);
		$j("#spdmerlin_preferredserver_"+ifacename).addClass("disabled");
	}
}

function Change_SpdTestInterface(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	GenerateManualSpdTestServerPrefSelect();
	Toggle_SpdTestServerPref(document.form.spdtest_serverpref);
}

function Toggle_SpdTestServerPref(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	if(inputvalue == "onetime"){
		document.formScriptActions.action_script.value="start_spdmerlinserverlistmanual_" + document.form.spdtest_enabled.value;
		document.formScriptActions.submit();
		for(var i = 0; i < interfacescomplete.length; i++){
			$j('#spdtest_enabled_'+interfacescomplete[i].toLowerCase()).prop("disabled",true);
			$j('#spdtest_enabled_'+interfacescomplete[i].toLowerCase()).addClass("disabled");
		}
		$j.each($j("input[name=spdtest_serverpref]"), function(){
			$j(this).prop("disabled",true);
			$j(this).addClass("disabled");
		});
		showhide("rowmanualserverprefselect", true);
		showhide("imgManualServerList", true);
		
		if(document.form.spdtest_enabled.value == "All"){
			$j.each($j("select[name^=spdtest_serverprefselect]"), function(){
				$j(this).empty();
			});
		}
		else{
			$j('select[name=spdtest_serverprefselect]').empty();
		}
		setTimeout(get_manualspdtestservers_file, 2000);
	}
	else{
		showhide("rowmanualserverprefselect", false);
		if(document.form.spdtest_enabled.value == "All"){
			$j.each($j("select[name^=spdtest_serverprefselect]"), function(){
				showhide(this.id,false);
			});
			$j.each($j("span[id^=spdtest_serverprefselectspan]"), function(){
				showhide(this.id,false);
			});
		}
		else{
			showhide("spdtest_serverprefselect",false);
		}
		showhide("imgManualServerList", false);
	}
}

function GenerateManualSpdTestServerPrefSelect(){
	$j("#rowmanualserverprefselect").remove();
	var serverprefhtml = '<tr class="even" id="rowmanualserverprefselect" style="display:none;">';
	serverprefhtml += '<td class="settingname">Choose a server</th><td class="settingvalue"><img id="imgManualServerList" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>';
	
	if(document.form.spdtest_enabled.value == "All"){
		for(var i = 0; i < interfacescomplete.length; i++){
			if(interfacesdisabled.includes(interfacescomplete[i]) == false){
				var interfacename = interfacescomplete[i].toLowerCase();
				serverprefhtml += '<span style="width:50px;display:none;" id="spdtest_serverprefselectspan_'+interfacename+'">'+interfacescomplete[i]+':</span><select name="spdtest_serverprefselect_'+interfacename+'" id="spdtest_serverprefselect_'+interfacename+'" style="display:none;max-width:415px;"></select><br />';
			}
		}
	}
	else{
		serverprefhtml += '<select name="spdtest_serverprefselect" id="spdtest_serverprefselect" style="display:none;"></select>';
	}
	
	serverprefhtml += '</td></tr>';
	$j("#rowmanualserverpref").after(serverprefhtml);
}

function Validate_All(){
	var validationfailed = false;
	
	if(! Validate_PercentRange(document.form.spdmerlin_autobw_sf_down)) validationfailed=true;
	if(! Validate_PercentRange(document.form.spdmerlin_autobw_sf_up)) validationfailed=true;
	if(! Validate_PercentRange(document.form.spdmerlin_autobw_threshold_down)) validationfailed=true;
	if(! Validate_PercentRange(document.form.spdmerlin_autobw_threshold_up)) validationfailed=true;
	
	if(document.form.schedulemode.value == "EveryX"){
		if(! Validate_ScheduleValue(document.form.everyxvalue)) validationfailed=true;
	}
	else if(document.form.schedulemode.value == "Custom"){
		if(! Validate_Schedule(document.form.spdmerlin_schhours,"hours")) validationfailed=true;
		if(! Validate_Schedule(document.form.spdmerlin_schmins,"mins")) validationfailed=true;
	}
	
	if(validationfailed){
		alert("Validation for some fields failed. Please correct invalid values and try again.");
		return false;
	}
	else{
		return true;
	}
}

function Validate_Schedule(forminput,hoursmins){
	var inputname = forminput.name;
	var inputvalues = forminput.value.split(',');
	var upperlimit = 0;
	
	if(hoursmins == "hours"){
		upperlimit = 23;
	}
	else if (hoursmins == "mins"){
		upperlimit = 59;
	}
	
	showhide("btnfixhours",false);
	showhide("btnfixmins",false);
	
	var validationfailed = "false";
	for(var i=0; i < inputvalues.length; i++){
		if(inputvalues[i] == "*" && i == 0){
			validationfailed = "false";
		}
		else if(inputvalues[i] == "*" && i != 0){
			validationfailed = "true";
		}
		else if(inputvalues[0] == "*" && i > 0){
			validationfailed = "true";
		}
		else if(inputvalues[i] == ""){
			validationfailed = "true";
		}
		else if(inputvalues[i].startsWith("*/")){
			if(! isNaN(inputvalues[i].replace("*/","")*1)){
				if((inputvalues[i].replace("*/","")*1) > upperlimit || (inputvalues[i].replace("*/","")*1) < 0){
					validationfailed = "true";
				}
			}
			else{
				validationfailed = "true";
			}
		}
		else if(inputvalues[i].indexOf("-") != -1){
			if(inputvalues[i].startsWith("-")){
				validationfailed = "true";
			}
			else{
				var inputvalues2 = inputvalues[i].split('-');
				for(var i2=0; i2 < inputvalues2.length; i2++){
					if(inputvalues2[i2] == ""){
						validationfailed = "true";
					}
					else if(! isNaN(inputvalues2[i2]*1)){
						if((inputvalues2[i2]*1) > upperlimit || (inputvalues2[i2]*1) < 0){
							validationfailed = "true";
						}
						else if((inputvalues2[i2+1]*1) < (inputvalues2[i2]*1)){
							validationfailed = "true";
							if(hoursmins == "hours"){
								showhide("btnfixhours",true)
							}
							else if (hoursmins == "mins"){
								showhide("btnfixmins",true)
							}
						}
					}
					else{
						validationfailed = "true";
					}
				}
			}
		}
		else if(! isNaN(inputvalues[i]*1)){
			if((inputvalues[i]*1) > upperlimit || (inputvalues[i]*1) < 0){
				validationfailed = "true";
			}
		}
		else{
			validationfailed = "true";
		}
	}
	
	if(validationfailed == "true"){
		$j(forminput).addClass("invalid");
		return false;
	}
	else{
		$j(forminput).removeClass("invalid");
		return true;
	}
}

function Validate_ScheduleValue(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	var upperlimit = 0;
	var lowerlimit = 1;
	
	var unittype = $j("#everyxselect").val();
	
	if(unittype == "hours"){
		upperlimit = 24;
	}
	else if(unittype == "minutes"){
		upperlimit = 30;
	}
	
	if(inputvalue > upperlimit || inputvalue < lowerlimit || forminput.value.length < 1){
		$j(forminput).addClass("invalid");
		return false;
	}
	else{
		$j(forminput).removeClass("invalid");
		return true;
	}
}

function Validate_PercentRange(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	if(inputvalue > 100 || inputvalue < 0 || forminput.value.length < 1){
		$j(forminput).addClass("invalid");
		return false;
	}
	else{
		$j(forminput).removeClass("invalid");
		return true;
	}
}

function Validate_AverageCalc(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	if(inputvalue > 30 || inputvalue < 1 || forminput.value.length < 1){
		$j(forminput).addClass("invalid");
		return false;
	}
	else{
		$j(forminput).removeClass("invalid");
		return true;
	}
}

function FixCron(hoursmins){
	if(hoursmins == "hours"){
		var origvalue = document.form.spdmerlin_schhours.value;
		document.form.spdmerlin_schhours.value = origvalue.split("-")[0]+"-23,0-"+origvalue.split("-")[1];
		Validate_Schedule(document.form.spdmerlin_schhours,"hours");
	}
	else if(hoursmins == "mins"){
		var origvalue = document.form.spdmerlin_schmins.value;
		document.form.spdmerlin_schmins.value = origvalue.split("-")[0]+"-59,0-"+origvalue.split("-")[1];
		Validate_Schedule(document.form.spdmerlin_schmins,"mins");
	}
}

function AddEventHandlers(){
	$j(".collapsible-jquery").off('click').on('click', function(){
		$j(this).siblings().toggle("fast",function(){
			if($j(this).css("display") == "none"){
				SetCookie($j(this).siblings()[0].id,"collapsed");
			}
			else{
				SetCookie($j(this).siblings()[0].id,"expanded");
			}
		})
	});
	
	$j(".collapsible-jquery").each(function(index,element){
		if(GetCookie($j(this)[0].id,"string") == "collapsed"){
			$j(this).siblings().toggle(false);
		}
		else{
			$j(this).siblings().toggle(true);
		}
	});
}
</script>
</head>
<body onload="initial();" onunload="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="about:blank" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="action_script" value="start_spdmerlin">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_wait" value="90">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="amng_custom" id="amng_custom" value="">
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
<div class="formfonttitle" id="scripttitle" style="text-align:center;">spdMerlin</div>
<div id="statstitle" style="text-align:center;">Stats last updated:</div>
<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
<div class="formfontdesc">spdMerlin is an internet speedtest and monitoring tool for AsusWRT Merlin with charts for daily, weekly and monthly summaries. It tracks download/upload bandwidth as well as latency, jitter and packet loss.</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<thead class="collapsible-jquery" id="scripttools">
<tr><td colspan="2">Utilities (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%">Version information</th>
<td>
<span id="spdmerlin_version_local" style="color:#FFFFFF;"></span>
&nbsp;&nbsp;&nbsp;
<span id="spdmerlin_version_server" style="display:none;">Update version</span>
&nbsp;&nbsp;&nbsp;
<input type="button" class="button_gen" onclick="CheckUpdate();" value="Check" id="btnChkUpdate">
<img id="imgChkUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
<input type="button" class="button_gen" onclick="DoUpdate();" value="Update" id="btnDoUpdate" style="display:none;">
&nbsp;&nbsp;&nbsp;
</td>
</tr>
<tr>
<th width="20%">Export</th>
<td>
<input type="button" onclick="ExportCSV();" value="Export to CSV" class="button_gen" name="btnExport">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable" style="border:0px;" id="table_manualspeedtests">
<thead class="collapsible-jquery" id="thead_manualspeedtests">
<tr><td colspan="2">Manual Speedtest (click to expand/collapse)</td></tr>
</thead>
<tr class="even" id="rowmanualserverpref">
<td class="settingname">Mode for speedtest</td>
<td class="settingvalue">
<input type="radio" name="spdtest_serverpref" id="spdtest_serverpref_auto" class="input" value="auto" onchange="Toggle_SpdTestServerPref(this)" checked>
<label for="spdtest_serverpref_auto">Auto-select server</label>
<input type="radio" name="spdtest_serverpref" id="spdtest_serverpref_user" class="input" value="user" onchange="Toggle_SpdTestServerPref(this)">
<label for="spdtest_serverpref_user">Preferred server</label>
<input type="radio" name="spdtest_serverpref" id="spdtest_serverpref_onetime" class="input" value="onetime" onchange="Toggle_SpdTestServerPref(this)">
<label for="spdtest_serverpref_onetime">Choose a server</label>
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" class="savebutton">
<input type="button" onclick="RunSpeedtest();" value="Run speedtest" class="button_gen savebutton" name="btnRunSpeedtest" id="btnRunSpeedtest">
<img id="imgSpdTest" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
&nbsp;&nbsp;&nbsp;
<span id="spdtest_text" style="display:none;"></span>
</td>
</tr>
<tr style="display:none;"><td colspan="2" style="padding: 0px;">
<textarea cols="63" rows="8" wrap="off" readonly="readonly" id="spdtest_output" class="textarea_log_table" style="border:0px;font-family:Courier New, Courier, mono; font-size:11px;overflow-y:auto;overflow-x:hidden;">Speedtest output</textarea>
</td></tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable" style="border:0px;" id="table_config">
<thead class="collapsible-jquery" id="scriptconfig">
<tr><td colspan="2">General Configuration (click to expand/collapse)</td></tr>
</thead>
<tr class="even" valign="middle">
<th colspan="2" class="sectionheader">Automatic speedtest configuration</th>
</tr>
<tr class="even" id="rowautomatedtests">
<td class="settingname">Enable automatic speedtests</td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_automated" id="spdmerlin_auto_true" onchange="AutomaticInterfaceEnableDisable(this)" class="input" value="true" checked>
<label for="spdmerlin_auto_true">Yes</label>
<input type="radio" name="spdmerlin_automated" id="spdmerlin_auto_false" onchange="AutomaticInterfaceEnableDisable(this)" class="input" value="false">
<label for="spdmerlin_auto_false">No</label>
</td>
</tr>
<tr class="even" id="rowschedule">
<td class="settingname">Schedule for automatic speedtests</td>
<td class="settingvalue">
<div class="schedulesettings" id="schdays">
<span class="schedulespan" style="vertical-align:top;">Day(s)</span>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_mon" class="input" value="Mon" style="margin-left:0px;"><label for="spdmerlin_mon">Mon</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_tues" class="input" value="Tues"><label for="spdmerlin_tues">Tues</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_wed" class="input" value="Wed"><label for="spdmerlin_wed">Wed</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_thurs" class="input" value="Thurs"><label for="spdmerlin_thurs">Thurs</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_fri" class="input" value="Fri"><label for="spdmerlin_fri">Fri</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_sat" class="input" value="Sat"><label for="spdmerlin_sat">Sat</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_sun" class="input" value="Sun"><label for="spdmerlin_sun">Sun</label>
</div>
<div class="schedulesettings" id="schmode">
<span class="schedulespan" style="vertical-align:top;">Mode</span>
<input type="radio" onchange="ScheduleModeToggle(this)" name="schedulemode" id="schmode_everyx" class="input" value="EveryX"><label for="schmode_everyx">Every X hours/minutes</label>
<input type="radio" onchange="ScheduleModeToggle(this)" name="schedulemode" id="schmode_custom" class="input" value="Custom" checked><label for="schmode_custom">Custom</label>
</div>
<div style="margin-bottom:0px;" class="schedulesettings" id="schfrequency">
<span class="schedulespan">Frequency</span>
<span style="color:#FFFFFF;margin-left:3px;">Every </span>
<input autocomplete="off" style="text-align:center;padding-left:2px;" type="text" maxlength="2" class="input_3_table removespacing" name="everyxvalue" id="everyxvalue" value="30" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_ScheduleValue(this)" onblur="Validate_ScheduleValue(this)" />
&nbsp;<select name="everyxselect" id="everyxselect" class="input_option" onchange="EveryXToggle(this)">
<option value="hours">hours</option><option value="minutes" selected>minutes</option></select>
<span id="spanxhours" style="color:#FFCC00;"> (between 1 and 24)</span>
<span id="spanxminutes" style="color:#FFCC00;"> (between 1 and 30, default: 30)</span>
</div>
<div id="schcustom">
<div class="schedulesettings">
<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(2);">
<span class="schedulespan">Hours</span>
</a>
<input data-lpignore="true" autocomplete="off" autocapitalize="off" type="text" class="input_25_table" name="spdmerlin_schhours" value="*" onkeyup="Validate_Schedule(this,'hours')" onblur="Validate_Schedule(this,'hours')" />
<input id="btnfixhours" type="button" onclick="FixCron('hours');" value="Fix?" class="button_gen cronbutton" name="button" style="display:none;">
</div>
<div class="schedulesettings">
<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(3);">
<span class="schedulespan">Minutes</span>
</a>
<input data-lpignore="true" autocomplete="off" autocapitalize="off" type="text" class="input_25_table" name="spdmerlin_schmins" value="*" onkeyup="Validate_Schedule(this,'mins')" onblur="Validate_Schedule(this,'mins')" />
<input id="btnfixmins" type="button" onclick="FixCron('mins');" value="Fix?" class="button_gen cronbutton" name="button" style="display:none;">
</div>
</div>
</td>
</tr>
<tr class="even" valign="middle">
<th colspan="2" class="sectionheader">AutoBW configuration</th>
</tr>
<tr class="even" id="rowautobwenabled">
<td class="settingname">Enable AutoBW?<br/><span style="color:#FFCC00;background:#2F3A3E;">Automatically adjust QoS bandwidth limits using automatic speedtest data</span></td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_autobw_enabled" id="spdmerlin_autobw_true" onchange="AutoBWEnableDisable(this)" class="input" value="true">
<label for="spdmerlin_autobw_true">Yes</label>
<input type="radio" name="spdmerlin_autobw_enabled" id="spdmerlin_autobw_false" onchange="AutoBWEnableDisable(this)" class="input" value="false" checked>
<label for="spdmerlin_autobw_false">No</label>
</td>
</tr>
<tr class="even" id="rowautobwavgcalc">
<td class="settingname">Number of speedtests to use to calculate average bandwidth</td>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="2" class="input_3_table removespacing" name="spdmerlin_autobw_average_calc" value="10" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_AverageCalc(this)" onblur="Validate_AverageCalc(this)" /><span style="color:#FFFFFF;">&nbsp;&nbsp;speedtest(s)&nbsp;&nbsp;</span><span style="color:#FFCC00;">(between 1 and 30, default: 10)</span>
</td>
</tr>
<tr class="even" id="rowautobwsf">
<td class="settingname">Scale factor to use for speedtest results</td>
<td class="settingvalue">
<span class="schedulespan">Download</span><input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="spdmerlin_autobw_sf_down" value="100" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_PercentRange(this)" onblur="Validate_PercentRange(this)" /><span style="color:#FFFFFF;"> %</span>
&nbsp;&nbsp;&nbsp;&nbsp;
<span class="schedulespan">Upload</span><input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="spdmerlin_autobw_sf_up" value="100" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_PercentRange(this)" onblur="Validate_PercentRange(this)" /><span style="color:#FFFFFF;"> %</span>
</td>
</tr>
<tr class="even" id="rowautobwlimits">
<td class="settingname">Bandwidth limits for AutoBW calculations<br/><span style="color:#FFCC00;background:#2F3A3E;">(for Upper Limit 0 = Unlimited)</span></td>
<td class="settingvalue"><span style="font-weight:bolder;color:#FFFFFF;">Upper Limit:&nbsp;&nbsp;&nbsp;&nbsp;</span>
<span class="schedulespan">Download</span><input autocomplete="off" type="text" maxlength="4" class="input_6_table removespacing" name="spdmerlin_autobw_ulimit_down" value="100" onkeypress="return validator.isNumber(this, event)" /><span style="color:#FFFFFF;"> Mbps</span>
&nbsp;&nbsp;&nbsp;&nbsp;
<span class="schedulespan">Upload</span><input autocomplete="off" type="text" maxlength="4" class="input_6_table removespacing" name="spdmerlin_autobw_ulimit_up" value="20" onkeypress="return validator.isNumber(this, event)" /><span style="color:#FFFFFF;"> Mbps</span><br />
<span style="font-weight:bolder;color:#FFFFFF;">Lower Limit:&nbsp;&nbsp;&nbsp;&nbsp;</span>
<span class="schedulespan">Download</span><input autocomplete="off" type="text" maxlength="4" class="input_6_table removespacing" name="spdmerlin_autobw_llimit_down" value="50" onkeypress="return validator.isNumber(this, event)" /><span style="color:#FFFFFF;"> Mbps</span>
&nbsp;&nbsp;&nbsp;&nbsp;
<span class="schedulespan">Upload</span><input autocomplete="off" type="text" maxlength="4" class="input_6_table removespacing" name="spdmerlin_autobw_llimit_up" value="10" onkeypress="return validator.isNumber(this, event)" /><span style="color:#FFFFFF;"> Mbps</span><br />
</td>
</tr>
<tr class="even" id="rowautobwth">
<td class="settingname">Threshold for updating QoS bandwidth values</td>
<td class="settingvalue">
<span class="schedulespan">Download</span><input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="spdmerlin_autobw_threshold_down" value="10" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_PercentRange(this)" onblur="Validate_PercentRange(this)" /><span style="color:#FFFFFF;"> %</span>
&nbsp;&nbsp;&nbsp;&nbsp;
<span class="schedulespan">Upload</span><input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="spdmerlin_autobw_threshold_up" value="10" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_PercentRange(this)" onblur="Validate_PercentRange(this)" /><span style="color:#FFFFFF;"> %</span>
</td>
</tr>
<tr class="even" valign="middle">
<th colspan="2" class="sectionheader">Script configuration</th>
</tr>
<tr class="even" id="rowdataoutput">
<td class="settingname">Data Output Mode<br/><span style="color:#FFCC00;background:#2F3A3E;">(for weekly and monthly charts)</span></td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_outputdatamode" id="spdmerlin_dataoutput_average" class="input" value="average" checked>
<label for="spdmerlin_dataoutput_average">Average</label>
<input type="radio" name="spdmerlin_outputdatamode" id="spdmerlin_dataoutput_raw" class="input" value="raw">
<label for="spdmerlin_dataoutput_raw">Raw</label>
</td>
</tr>
<tr class="even" id="rowtimeoutput">
<td class="settingname">Time Output Mode<br/><span style="color:#FFCC00;background:#2F3A3E;">(for CSV export)</span></td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_outputtimemode" id="spdmerlin_timeoutput_non-unix" class="input" value="non-unix" checked>
<label for="spdmerlin_timeoutput_non-unix">Non-Unix</label>
<input type="radio" name="spdmerlin_outputtimemode" id="spdmerlin_timeoutput_unix" class="input" value="unix">
<label for="spdmerlin_timeoutput_unix">Unix</label>
</td>
</tr>
<tr class="even" id="rowstorageloc">
<td class="settingname">Data Storage Location</td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_storagelocation" id="spdmerlin_storageloc_jffs" class="input" value="jffs" checked>
<label for="spdmerlin_storageloc_jffs">JFFS</label>
<input type="radio" name="spdmerlin_storagelocation" id="spdmerlin_storageloc_usb" class="input" value="usb">
<label for="spdmerlin_storageloc_usb">USB</label>
</td>
</tr>
<tr class="even" id="rowstoreresulturl">
<td class="settingname">Save speedtest URLs to database</td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_storeresulturl" id="spdmerlin_store_true" class="input" value="true">
<label for="spdmerlin_store_true">Yes</label>
<input type="radio" name="spdmerlin_storeresulturl" id="spdmerlin_store_false" class="input" value="false" checked>
<label for="spdmerlin_store_false">No</label>
</td>
</tr>
<tr class="even" id="rowexcludefromqos">
<td class="settingname">Exclude speedtests from QoS</td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_excludefromqos" id="spdmerlin_exclude_true" class="input" value="true" checked>
<label for="spdmerlin_exclude_true">Yes</label>
<input type="radio" name="spdmerlin_excludefromqos" id="spdmerlin_exclude_false" class="input" value="false">
<label for="spdmerlin_exclude_false">No</label>
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" class="savebutton">
<input type="button" onclick="SaveConfig();" value="Save" class="button_gen savebutton" name="button">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons2">
<thead class="collapsible-jquery" id="charttools">
<tr><td colspan="2">Chart Display Options (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%"><span style="color:#FFFFFF;background:#2F3A3E;">Time format</span><br /><span style="color:#FFCC00;background:#2F3A3E;">(for tooltips and Last 24h chart axis)</span></th>
<td>
<select style="width:100px" class="input_option" onchange="changeAllCharts(this)" id="Time_Format">
<option value="0">24h</option>
<option value="1">12h</option>
</select>
</td>
</tr>
<tr class="apply_gen" valign="top">
<td colspan="2" style="background-color:rgb(77, 89, 93);">
<input type="button" onclick="ToggleDragZoom(this);" value="Drag Zoom On" class="button_gen" name="btnDragZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ResetZoom();" value="Reset Zoom" class="button_gen" name="btnResetZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleLines();" value="Toggle Lines" class="button_gen" name="btnToggleLines">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleFill();" value="Toggle Fill" class="button_gen" name="btnToggleFill">
</td>
</tr>
</table>

<!-- Charts inserted here -->

</td>
</tr>
</tbody>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</form>
<form method="post" name="formScriptActions" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="">
</form>
<div id="footer">
</div>
</body>
</html>
