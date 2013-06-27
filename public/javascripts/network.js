/* Height & Width */

var width = 940,
    height = 600,
    aspect = width/height
    radius = 6;

$(window).on("resize", function() {
	chart = $("#main-container");
    var targetWidth = chart.width();
    width = targetWidth
    height = $(window).height();
    svg.attr("width", width);
    svg.attr("height", height-30-70);
	force.resume();
});

$(window).on("load", function() {
	chart = $("#main-container");
    var targetWidth = chart.width();
    width = targetWidth
    height = $(window).height();
    svg.attr("width", width);
    svg.attr("height", height-30-70);
	force.resume();
});

function replaceURLWithHTMLLinks(text) {
	if(text != undefined) {
    	var exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
    	return text.replace(exp,"<a href='$1' target='_blank'>$1</a>"); 
	}
}
	
/* Colour Scale */
var color = d3.scale.category10();

/* Force Directed Parameters */
var force = d3.layout.force()
    .charge(-400)
    .linkDistance(60)
    .size([width, height]);

/* Initialise SVG Element */
var svg = d3.select("body").select("#main-container").append("svg")
    .attr("class","chart")
    .attr("width", width)
    .attr("height", height)
	//.attr("viewBox","0 0 960 500")
	.attr("preserveAspectRatio","xMidYMid");

/* Load File and begin to generate chart */
graph = {
	"nodes":[],
	"links":[]
	}

  force.nodes(graph.nodes)
      .links(graph.links)
	  .start();
      
  /*******
  * Links
  *******/
  var link = svg.selectAll(".link")
      .data(graph.links)
  /*******
  * Node
  *******/
  var node = svg.selectAll(".node")
      .data(graph.nodes);

  var nodes = force.nodes(),
      links = force.links();

	svg.append("svg:defs")
	   .append("svg:marker")
	    .attr("id", "head")
	    .attr("viewBox", "0 -5 10 10")
	    .attr("refX", 25.5)
	    .attr("refY", 0)
	    .attr("markerWidth", 12)
	    .attr("markerHeight", 12)
	    .attr("orient", "auto")
	  .append("svg:path")
	    .attr("d", "M0,-5L10,0L0,5");


  force.on("tick", function() {
	node.attr("transform", function(d) { return "translate(" + Math.max(radius, Math.min(width - radius, d.x)) + "," + Math.max(radius+41, Math.min(height - radius, d.y)) + ")"; });
    link.attr("x1", function(d) { return Math.min(Math.max(0,d.source.x),width); })
        .attr("y1", function(d) { return Math.min(Math.max(41,d.source.y),height); })
        .attr("x2", function(d) { return Math.min(Math.max(0,d.target.x),width); })
        .attr("y2", function(d) { return Math.min(Math.max(41,d.target.y),height); });
  });

	function mouseover() {
		group = d3.select(this).select("p").attr("group")

	me = d3.selectAll("g").filter(function(d){return d.group == group}).selectAll("p");

	me.transition()
      .duration(300)
	  .style("border-color", "black");
	
	my_link = d3.selectAll("line").filter(function(d){return d.group == group});
	my_link.transition()
		.duration(300)
		.style("opacity", 1);
		
	force.start();
	
	}

	function mouseout() {
			group = d3.select(this).select("p").attr("group")

		me = d3.selectAll("g").filter(function(d){return d.group == group}).selectAll("p");
		me.transition()
	      .duration(300)
		  .style("border-color", "white");
		
		my_link = d3.selectAll("line").filter(function(d){return d.group == group});
		my_link.transition()
			.duration(300)
			.style("opacity", 0.4);
			
		force.start();
	}
	
	function restart() {	  
	  link = link.data(links);
	
	  var newLink = link.enter().insert("line")
	    .attr("class", "link")
	    .attr("marker-end",'url(#head)');

	  node = node.data(nodes);
	
	  var newNode = node.enter().insert("g")
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
      .attr("group", function(d) { return newGroup = d.group})
      .call(force.drag);

    newNode.append("text")
      .attr("class", "invisible-text-node")
      .text(function(d) { return d.name });
	
	newNode.each(function(d){d.textWidth = (this.getBBox().width)});
	newNode.append("foreignObject")
	    .attr("x",function(d) {return -Math.min(90, d.textWidth)/2})
	    .attr("y", function(d) {
			if (d.type == "user-node") 
				{return -45}
			else
				{return -(15 + 17 * Math.floor(d.textWidth/120) + 4)/2}
			})
	    .attr("width", function(d) {
			if (d.type == "user-node") 
				{return 60}
			else
				{return Math.min(120, d.textWidth+10)}
			})
	    .attr("height", function(d) {
			if (d.type == "user-node") 
				{return 72 + 10}
			else
			{return  15 + 17 * Math.floor(d.textWidth/120) + 10}
			})
	  .on("mouseover", mouseover)
	  .on("mouseout", mouseout)
	  .append("xhtml:p")
 	    .attr("group", function(d) {return d.group})
		.attr("class", function(d) {return d.type})
	    .html(function(d) {
			if(d.type == "text-node") 
				{return replaceURLWithHTMLLinks(d.name) }
			else if (d.type == "user-node") 
				{return "<a href='http://www.twitter.com/" + d.name +"' target='_blank'><img src='" + d.profile_image_url + "' alt='" + d.name + "'></a><a href='" + d.tweetLink + "' target='_blank'>" + String(d.retweets) + "<br>retweets</a>"}
			else
				{return d.name}
		});
	
	force.start();

	}

function addTweet(userText, tweetText, profile_image_url, retweets, tweetLink, id_str) {
  tweet = {};
  tweet.text = tweetText.replace("IF","if");
  tweet.text = tweet.text.replace("If","if");
  tweet.text = tweet.text.replace("Then","then");
  tweet.text = tweet.text.replace("THEN","then");
  tweet.text = tweet.text.substring(tweet.text.search("if ")+3,tweet.text.length)
  var n = [];
  n=tweet.text.split("then");
  node0 = {name: userText, type: "user-node", retweets: retweets, tweetLink: tweetLink, profile_image_url: profile_image_url, group: id_str};
  node1 = {name: "IF", type: "if-node", group: id_str};
  node2 = {name: n[0], type: "text-node", group: id_str};
  node3 = {name: "THEN", type: "then-node", group: id_str};
  node4 = {name: n[1], type: "text-node", group: id_str};
  nodes.push(node0);
  nodes.push(node1);
  nodes.push(node2);
  nodes.push(node3);
  nodes.push(node4);
  links.push({source: node0, target: node1, group: id_str});
  links.push({source: node1, target: node2, group: id_str});
  links.push({source: node2, target: node3, group: id_str});
  links.push({source: node3, target: node4, group: id_str});
  restart();
}

