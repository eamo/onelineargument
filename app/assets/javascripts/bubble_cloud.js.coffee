# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
class BubbleChart
  constructor: (data) ->
    @data = data
    @width = 900
    @height = 600

    @tooltip = CustomTooltip("gates_tooltip", 240)

    # locations the nodes will move towards
    # depending on which view is currently being
    # used
    @center = {x: @width / 2, y: @height / 2}
    @cyclist_centers = {
      "Froome":      {x: 1 * @width / 5, y: 1 * @height / 4},
      "Valverde":	{x: 2 * @width / 5, y: 1 * @height / 4},
      "Mollema":	{x: 3 * @width / 5, y: 1 * @height / 4},
      "Dam":      {x: 4 * @width / 5, y: 1 * @height / 4},
      "Kreuziger":	{x: 1.5 * @width / 5, y: 2 * @height / 4},
      "Contador":	{x: 3.5 * @width / 5, y: 2 * @height / 4},
      "Rojas":      {x: 1 * @width / 5, y: 3 * @height / 4},
      "Martin":      {x: 2 * @width / 5, y: 3 * @height / 4},
      "Rodriguez":      {x: 3 * @width / 5, y: 3 * @height / 4},
      "Costa":      {x: 4 * @width / 5, y: 3 * @height / 4},
      "None":      {x: @width / 2, y: @height / 2},
    }

    # used when setting up force and
    # moving around nodes
    @layout_gravity = -0.01
    @damper = 0.1

    # these will be set in create_nodes and create_vis
    @vis = null
    @nodes = []
    @force = null
    @circles = null

    # nice looking colors - no reason to buck the trend
    @fill_color = d3.scale.ordinal()
      .domain(["Froome", "Valverde", "Mollema","Dam","Kreuziger","Contador","Rojas","Martin","Rodriguez","Costa","None"])
      .range(["#3E88C7", "#92FF2D", "#73D44A", "#73D44A","#FFEB6E","#FFEB6E","#92FF2D","#008ECA","#D20C21","#92FF2D", "white"])

    @border_color = d3.scale.ordinal()
      .domain(["Froome", "Valverde", "Mollema","Dam","Kreuziger","Contador","Rojas","Martin","Rodriguez","Costa","None"])
      .range(["#15181F", "#032F48", "#010101", "#010101","#001950","#001950","#032F48","#EF1931","#FA8280","#032F48", "black"])

    # use the max total_amount in the data as the max in the scale's domain
    max_retweets = d3.max(@data, (d) -> parseInt(d.retweeted))
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, max_retweets]).range([2, 85])
    
    this.create_nodes()
    this.create_vis()

  # create node objects from original data
  # that will serve as the data behind each
  # bubble in the vis, then add each node
  # to @nodes to be used later
  create_nodes: () =>
    @data.forEach (d) =>
      node = {
        id: d.id
        radius: @radius_scale(parseInt(d.retweeted))
        retweeted: d.retweeted
        tweet_created_at: d.tweet_created_at
        screen_name: d.screen_name
        profile_image_url: d.profile_image_url
        group: d.group
        text: d.text
        cyclist: switch
          when d.text.search("Froome") > -1 then "Froome"
          when d.text.search("Valverde") > -1 then "Valverde"
          when d.text.search("Mollema") > -1 then "Mollema"
          when d.text.search("Dam") > -1 then "Dam"
          when d.text.search("Kreuziger") > -1 then "Kreuziger"
          when d.text.search("Contador") > -1 then "Contador"
          when d.text.search("Rojas") > -1 then "Rojas"
          when d.text.search("Martin") > -1 then "Martin"
          when d.text.search("Rodriguez") > -1 then "Rodriguez"
          when d.text.search("Costa") > -1 then "Costa"
          else 'None'
        x: Math.random() * 900
        y: Math.random() * 800
      }
      @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value


  # create svg at #vis and then 
  # create circle representation for each node
  create_vis: () =>
    @vis = d3.select("#vis").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("id", "svg_vis")

    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    # used because we need 'this' in the 
    # mouse callbacks
    that = this

    # radius will be set to 0 initially.
    # see transition below
    @circles.enter().append("circle")
      .attr("r", 0)
      .attr("fill", (d) => @fill_color(d.cyclist))
      .attr("stroke-width", 1)
      .attr("stroke", (d) => d3.rgb(@border_color(d.cyclist)))
      .attr("id", (d) -> "bubble_#{d.id}")
      .on("mouseover", (d,i) -> that.show_details(d,i,this))
      .on("mouseout", (d,i) -> that.hide_details(d,i,this))

    # Fancy transition to make bubbles appear, ending with the
    # correct radius
    @circles.transition().duration(2000).attr("r", (d) -> d.radius)


  # Charge function that is called for each node.
  # Charge is proportional to the diameter of the
  # circle (which is stored in the radius attribute
  # of the circle's associated data.
  # This is done to allow for accurate collision 
  # detection with nodes of different sizes.
  # Charge is negative because we want nodes to 
  # repel.
  # Dividing by 8 scales down the charge to be
  # appropriate for the visualization dimensions.
  charge: (d) ->
    -Math.pow(d.radius, 2.0) / 8

  # Starts up the force layout with
  # the default values
  start: () =>
    @force = d3.layout.force()
      .nodes(@nodes)
      .size([@width, @height])

  # Sets up force layout to display
  # all nodes in one circle.
  display_group_all: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_center(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

    this.hide_years()

  # Moves all circles towards the @center
  # of the visualization
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (@center.y - d.y) * (@damper + 0.02) * alpha

  # sets the display of bubbles to be separated
  # into each year. Does this by calling move_towards_year
  display_by_year: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_year(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

    this.display_years()

  # move all circles to their associated @cyclist_centers 
  move_towards_year: (alpha) =>
    (d) =>
      target = @cyclist_centers[d.cyclist]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

  # Method to display year titles
  display_years: () =>
    cyclist = @cyclist_centers
    cyclist_data = d3.keys(cyclist)
    cyclists = @vis.selectAll(".cyclists")
      .data(cyclist_data)
    console.log(@cyclist_centers)
    cyclists.enter().append("text")
      .attr("class", "cyclists")
      .attr("x", (d) => cyclist[d].x )
      .attr("y", (d) => cyclist[d].y )
      .attr("text-anchor", "middle")
      .text((d) -> d)

  # Method to hide year titiles
  hide_years: () =>
    years = @vis.selectAll(".years").remove()

  show_details: (data, i, element) =>
    d3.select(element).attr("stroke", "black").attr("stroke-width", 2)
    
    content = "<span class=\"name\">Tweeted by:</span><span class=\"value\"> #{data.screen_name}</span><br/>"
    content +="<span class=\"name\">Date:</span><span class=\"value\"> #{data.tweet_created_at}</span><br/>"
    content +="<span class=\"name\">Retweets:</span><span class=\"value\"> #{data.retweeted}</span><br/>"
    content +="<span class=\"name\">Tweet:</span><span class=\"value\"> #{data.text}</span><br/>"
    content +="<span class=\"name\">Rider:</span><span class=\"value\"> #{data.cyclist}</span>"
    @tooltip.showTooltip(content,d3.event)


  hide_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) => d3.rgb(@border_color(d.cyclist))).attr("stroke-width", 1)
    @tooltip.hideTooltip()


root = exports ? this

$ ->
  chart = null

  render_vis = (csv) ->
    chart = new BubbleChart csv
    chart.start()
    root.display_all()
  root.display_all = () =>
    chart.display_group_all()
  root.display_year = () =>
    chart.display_by_year()
  root.toggle_view = (view_type) =>
    if view_type == 'year'
      root.display_year()
    else
      root.display_all()

  d3.csv "view1.csv", render_vis