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

	# Load the tokenizer for subjects
	$('input[name="user[subjects]"]').tokenInput "/api/subjects", {
		hintText: "Subjects...",
		theme: "facebook",
		resultsLimit: 10
	}

	# Load the tokenizer for grades
	$('input[name="user[grades]"]').tokenInput "/api/grades", {
		hintText: "Grade Level...",
		theme: "facebook",
		resultsLimit: 10
	}

	# Load the tokenizer for grades
	$('input[name="user[skills]"]').tokenInput "/api/skills", {
		hintText: "Skills...",
		theme: "facebook",
		resultsLimit: 10
	}
