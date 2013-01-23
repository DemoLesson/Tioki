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
		return false;