$ ->
	$('.trigger').on 'focus click', (e) ->
		$this = $(@)

		# Prevent any default actions
		do e.preventDefault

		# Fade out the current element
		$this.fadeOut 500, ->

			# Get the triggerable element
			$trig = $this.next '.triggerable'

			# Fade in the new element
			$trig.fadeIn 500, ->

				# Focus the first editable input
				do $trig.children('input, textarea').focus

		# Additional action prevention
		return false

	# Get file extension
	getExtension = (filename) ->
		parts = filename.split('.')
		parts[parts.length - 1]

	$('input[iconic]').each ->
		$this = $(@)

		# Get the style of the ele (before the hide)
		style = $this.attr 'style'

		tip = $this.attr 'tip'
		atip = $this.attr 'atip'

		# Hide the input
		$this.css
			visibility: 'hidden',
			position: 'absolute',
			left: '0px',
			top: '0px'

		# Create the icon tag
		iconic = $ '<span class="iconic ' + $this.attr('iconic') + '"></span>'

		# Add tooltip
		if tip
			iconic.addClass 'has-tip no-tip-dots tip-top'
			iconic.attr 'title', tip

		# Apply the style from the input
		iconic.attr 'style', style

		# Handle attachment coloring
		$this.on 'change', (e) ->
			val = do $this.val

			# Remove any old tooltips
			$('span.tooltip').each ->
				do $(@).remove

			# Determine whether or not to change the tip/color
			if val

				# If file verify the file is valid
				filetypes = $this.attr 'allowed-file-types'
				if filetypes && $this.is 'input[type="file"]'
					filetypes = filetypes.split ','

					# Check if the extension is in the allowed list
					if $.inArray(getExtension(val), filetypes) < 0
						alert 'Invalid file type must be one of the following: ' + filetypes.join(', ') + '.'
						$this.val ''
						$this.trigger 'change'
						return false

				if atip
					iconic.attr 'title', atip
				iconic.addClass 'salmon'
			else
				if tip
					iconic.attr 'title', tip
				iconic.removeClass 'salmon'

		# Go ahead and add the icon to the DOM and click track
		iconic.insertAfter($this).on 'click', (e) ->
			do e.preventDefault

			# Allow reseting of the file attached mode
			if do $this.val
				$this.val ''
				$this.trigger 'change'
			else
				do $this.click

			return false