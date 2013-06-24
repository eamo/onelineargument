/* Height & Width */

var width = 960,
    height = 600,
    radius = 6;

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
    .linkDistance(30)
    .size([width, height]);

/* Initialise SVG Element */
var svg = d3.select("body").select("#main-container").append("svg")
    .attr("width", width)
    .attr("height", height);

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
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
	
     node.attr("transform", function(d) { return "translate(" + Math.max(radius, Math.min(width - radius, d.x)) + "," + Math.max(radius, Math.min(height - radius, d.y)) + ")"; });
  });

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
				{return -36}
			else
				{return -(13* Math.floor(1+d.textWidth/150))/2}
			})
	    .attr("width", function(d) {
			if (d.type == "user-node") 
				{return 48}
			else
				{return Math.min(90, d.textWidth)}
			})
	    .attr("height", function(d) {
			if (d.type == "user-node") 
				{return 72}
			else
			{return  15 + 10 * Math.floor(d.textWidth/150)}
			})
	  .append("xhtml:p")
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

function addTweet(userText, tweetText, profile_image_url, retweets, tweetLink) {
  tweet = {};
  tweet.text = tweetText.replace("IF","if");
  tweet.text = tweet.text.replace("If","if");
  tweet.text = tweet.text.replace("Then","then");
  tweet.text = tweet.text.replace("THEN","then");
  tweet.text = tweet.text.substring(tweet.text.search("if ")+3,tweet.text.length)
  var n = [];
  n=tweet.text.split("then");
  node0 = {name: userText, type: "user-node", retweets: retweets, tweetLink: tweetLink, profile_image_url: profile_image_url};
  node1 = {name: "IF", type: "if-node"};
  node2 = {name: n[0], type: "text-node"};
  node3 = {name: "THEN", type: "then-node"};
  node4 = {name: n[1], type: "text-node"};
  nodes.push(node0);
  nodes.push(node1);
  nodes.push(node2);
  nodes.push(node3);
  nodes.push(node4);
  links.push({source: node0, target: node1});
  links.push({source: node1, target: node2});
  links.push({source: node2, target: node3});
  links.push({source: node3, target: node4});
  restart();
}

