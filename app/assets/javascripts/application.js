// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery.min
//= require jquery_ujs
//= require jquery-ui.min
//= require tinymce-jquery
//= require jquery.form
//= require jquery.remotipart
//= require_tree ./tioki
//= require_tree ./Jcrop
//= require_tree ./shadowbox
//= require_tree ./jquery-extensions
//= require_tree ./placeholder

$(document).ready(function() {
	$('input, textarea').each(function() {
		$(this).placeholder();
	});
});