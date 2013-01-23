$ ->
	$('.trigger').on 'focus click', (e) ->
		$this = $(@)

		# Prevent any default actions
		do e.preventDefault

		# Fade out the current element
		$this.fadeOut 500, ->

			# Get the triggerable element
			$trig = $this.next '.triggerable'

			# Focus the first editable input
			do $trig.children('input, textarea').first.focus

			# Fade in the new element
			$trig.fadeIn 500

		# Additional action prevention
		return false;