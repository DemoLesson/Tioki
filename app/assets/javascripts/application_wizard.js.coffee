$ ->
	# Date pickers / Current
	$dp1 = $('input[name="date[start_date]"]')
	$dp2 = $('input[name="date[end_date]"]')
	$current = $('input[name*="[current]"]')

	$dp1.datepicker
		changeMonth: true
		changeYear: true
		onClose: (selectedDate) ->
			$dp2.datepicker "option", "minDate", selectedDate

	$dp2.datepicker
		changeMonth: true
		changeYear: true
		onClose: (selectedDate) ->
			$dp1.datepicker "option", "maxDate", selectedDate

	$current.change (e) ->
		do e.preventDefault

		if $(@).prop "checked"
			today = new Date
			m = today.getMonth() + 1
			d = do today.getDate
			y = do today.getFullYear

			d = '0' + d if d < 10
			m = '0' + m if m < 10

			today = "#{m}/#{d}/#{y}"
			$dp2.val today
