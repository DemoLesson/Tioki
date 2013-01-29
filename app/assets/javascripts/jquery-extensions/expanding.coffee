(($, window) ->
	$.extend $.fn, autoexpand: (options) ->
		@defaultOptions =
			myOption: 'default-value'
			another:  'default'
		settings = $.extend({}, @defaultOptions, options)

		# Timer Functions
		setTimeout = (time, func) ->
			window.setTimeout(func, time);
		setInterval = (time, func) ->
			window.setInterval(func, time);

		# Get json from css sheets
		css2json = (css) ->
			s = {};
			return s if !css
			
			if css instanceof CSSStyleDeclaration
				for i in css
					if do i.toLowerCase
						s[do i.toLowerCase] = css[i]
			else if typeof css == "string"
				css = $.trim css.split(";")
				for i in css
					l = $.trim i.split(":")
					s[do l[0].toLowerCase] = l[1]
				
			return s

		# Get css for an element
		css = (sel) ->
			sel = $(sel)
			sheets = document.styleSheets
			o = {}
			
			# Loop through the styles and merge json sheets
			for sheet in sheets 
				rules = sheet.rules || sheet.cssRules
				for rule in rules
					if sel.is rule.selectorText
						console.log rule.style
						o = $.extend o, css2json(rule.style), css2json(sel.attr('style'))

			# If nothting matched run normal styles
			o = css2json(sel.attr('style')) if o.length == 0
					
			return o

		# Handle the items
		@each (i, el) =>
			$el = $(el)

			# Wrap in a expanding input tag
			$el.wrap '<div class="expanding-input" />'

			# Get the wrapper as an object
			$wrap = $el.closest 'div.expanding-input'

			# Get the value
			val = do $el.val
			name = $el.attr 'name'

			# Get the height and width
			theight = do $el.height
			height = do $el.outerHeight
			width = do $el.outerWidth

			# Get the padding and margin
			el_css = css $el

			# Create the textarea
			$ta = $ '<textarea />'

			# Add to wrapper
			$wrap.append ->

				# Set name and value
				$ta.attr 'name', name
				$ta.val val

				# Set width and height
				$ta.height height
				$ta.width width

				# Set some css values
				$ta.css $.extend({}, el_css, {display: 'none'})

			# Switcheroo
			$el.focus ->

				# Hide the input show the textarea
				do $el.hide
				do $ta.show
				do $ta.focus

			$ta.blur ->

				# If the input is not empty then dont hide
				return if $ta.val().length > 0

				# Otherwise switch back
				do $ta.hide
				do $el.show

			# Cache the line counts
			line_cache = {}
			timers = {}

			$ta.keyup ->
				
				# If we get the result twice in a row change height
				if line_cache[$ta] == $.countLines($ta).visual
					if timers[$ta] == null
						timers[$ta] = setTimeout 300, ->
							lines = line_cache[$ta]
							new_height = theight * lines if lines > 1
							new_height = (theight - 2) * lines if lines > 6
							new_height = height if lines == 1
							$ta.css height: new_height
							timers[$ta] = null
					return false

				# Cache lines and clear timers
				line_cache[$ta] = $.countLines($ta).visual
				clearTimeout timers[$ta]
				timers[$ta] = null


		# Code here will run once for each member of the jQuery collection on which your plugin was invoked

		# Careful - if the last executed statement in this "each" function evaluates to false,
		# you will stop iterating over the collection.

		@ # allow chaining
) this.jQuery or this.Zepto, this