
var DemoLesson;

(function($){

	/**
	 * Initialize some Foundation Elements we need.
	 */
	$(function(){
		$(document).foundationButtons();
		$(document).foundationCustomForms();
	});



	/**
	 * Setup the interactions.
	 */
	$(function(){

		/**
		 * Add and remove skills.
		 */
		$(".skill-select .columns span").on('click', function(){
			var item = $(this).parent();
			if(item.hasClass('selected')) {
				DemoLesson.removeSkill(item.data('skill'))
				item.removeClass('selected');
			}
			else {
				DemoLesson.addSkill(item.data('skill'))
				item.addClass('selected');
			}
			return false;
		})

		$(".badge").hover(function(){
			$(".highlight .row > div").hide()

			$("#skill-"+$(this).data('skillgroup')).show()
		},function(){
			$("#skill-"+$(this).data('skillgroup')).hide()
			$("#biography").show();
		})

		/**
		 * Mark selected skills as available.
		 */
		for(i=0;i<DemoLesson.hasSkills.length;i++) {
			$("div[data-skill="+DemoLesson.hasSkills[i]+"]").addClass('selected')
		}


		/**
		 * Process Forms.
		 */
		 $("form#add-school").submit(function() {
		 	DemoLesson.getPostResponse('addEducation', $(this).serialize(), function(data) {
		 		console.log(data)
		 	});
		 	return false;
		 })


		/**
		 * Process Forms.
		 */
		 $("form#add-work-experience").submit(function() {
		 	DemoLesson.getPostResponse('addWorkExperience', $(this).serialize(), function(data) {
		 		console.log(data)
		 	});
		 	return false;
		 })

		/**
		 * Process Forms.
		 */
		 $("form#add-certification").submit(function() {
		 	DemoLesson.getPostResponse('addCertification', $(this).serialize(), function(data) {
		 		console.log(data)
		 	});
		 	return false;
		 })
	});


	/**
	 * The DemoLesson AJAX interaction object.
	 * @author David Boskovic
	 * @since 08/05/2012
	 */
	DemoLesson = new function() {

		this.hasSkills = [];
		this.userID = false;

		/**
		 * Configure this with the specific handlers for each action.
		 */
		this.urls = {
			'addSkill' : '',
			'removeSkill' : '',
			'addEducation' : '/cardeducation',
			'addWorkExperience' : '',
			'addCertification' : '',
			'unlockCard' : '',
			'fetchBadges' : ''
		}

		/**
		 * Initialize the demolesson object.
		 */
		this.init = function() {
			if(this.userID)
				alert('UserID not loaded with page, nothing will work.')
		}

		/**
		 * Handle adding a skill for this user.
		 * @expects {'status':'success|failure'}
		 */
		this.addSkill = function (skill) {


			DemoLesson.hasSkills[DemoLesson.hasSkills.length] = skill;

			DemoLesson.getPostResponse('addSkill', {'skill_id':skill}, function(){
				alert('success')
			})
		}

		/**
		 * Handle removing a skill from this user.
		 * @expects {'status':'success|failure'}
		 */
		this.removeSkill = function (skill) {


			/**
			 * Remove the skill item from the hasSkills Array.
			 */
			for(i=0;i<DemoLesson.hasSkills.length;i++) {
				if(DemoLesson.hasSkills[i] == skill) {
					DemoLesson.hasSkills.splice(i,1)
					break;
				}
			}

			DemoLesson.getDeleteResponse('removeSkill', {'skill_id':skill}, function(){
				alert('success')
			})
		}



		/**
		 * Handle fetching a badge for this user.
		 * @expects ['badge-category','other-badge-category']
		 */
		this.fetchBadges = function () {

			DemoLesson.getResponse('fetchBadges', {}, function(){
				alert('success')
			})
		}

		/**
		 * A shortcut for getting the response for a GET action.
		 */
		this.getResponse = function(url, data, callback) {
			$.get(DemoLesson.urls[url], data, callback, 'json');
		}


		/**
		 * A shortcut for getting the response for a POST action.
		 */
		this.getPostResponse = function(url, data, callback) {
			$.post(DemoLesson.urls[url], data, callback, 'json');
		}

		/**
		 * A shortcut for getting the response for a DELETE action.
		 */
		this.getDeleteResponse = function(url, data, callback) {
			$.ajax({
			  url: DemoLesson.urls[url],
			  type:"DELETE",
			  data: data,
			  success: callback,
			  dataType: 'json'
			});
		}
	}

})(jQuery);


/**
 * Load any webfonts that we want around.
 */

WebFontConfig = {
	google: { families: [ 'Exo:200:latin' ] }
};
(function() {
	var wf = document.createElement('script');
	wf.src = ('https:' == document.location.protocol ? 'https' : 'http') +
	'://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
	wf.type = 'text/javascript';
	wf.async = 'true';
	var s = document.getElementsByTagName('script')[0];
	s.parentNode.insertBefore(wf, s);
})();
