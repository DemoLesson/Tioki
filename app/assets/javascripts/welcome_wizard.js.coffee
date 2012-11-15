$ ->
	# Step 1

	# Step 2
	$('input[name="current"]').change ->

		currentVal = do $(@).val
		classes = ['teacher', 'administrator', 'job_seeker', 'student']

		$('tr[data-who]').each ->
			who = $(@).attr('data-who').split(',')
			if currentVal in who
				$(@).fadeIn 500
			else $(@).fadeOut 500