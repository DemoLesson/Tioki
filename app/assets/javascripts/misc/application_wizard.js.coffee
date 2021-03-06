$ ->
	# Date pickers / Current
	$dp1 = $('input[name="date[start_date]"]')
	$dp2 = $('input[name="date[end_date]"]')
	$current = $('input[name*="[current]"]')

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

	$accordian = $('div.accordian')
	$accordian.children('h2.bdata').click (e) ->
		$child = $(@).next('div.data')

		for child in $accordian.children('div.data')
			$(child).slideUp 500 if child != $child[0]
			$(child).slideDown 500 unless child != $child[0]

	$('form.new_video_uploader').submit (e) ->
		submit = $('form.new_video_uploader label input[type="submit"]')
		submit.prop('disabled', true).val("Uploading... This may take a while.")
