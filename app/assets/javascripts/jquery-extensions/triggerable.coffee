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

	$('input[iconic]').each ->
		$this = $(@)

		# Get the style of the ele (before the hide)
		style = $this.attr 'style'

		tip = $this.attr 'tip'

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

		# Go ahead and add the icon to the DOM and click track
		iconic.insertAfter($this).on 'click', (e) ->
			do e.preventDefault
			do $this.click
			return false