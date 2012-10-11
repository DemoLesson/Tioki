if(typeof window.$ == 'undefined' || typeof window.$.fn == 'undefined')
	throw new Error("Fire requires jQuery or Zepto");

window.fire = {
	enabled: true,
	init: function() {
		$('body').on('click', 'a', fire.link);		
	},
	send: function(data, el) {
		var response = new Object;
		$.post('/_fire', data, fire.response(response, status, el))
			.error(fire.response(response, status, el));
	},
	response: function(response, data) {
		console.log(response);
		console.log(data);
	},
	link: function(e) {
		if(!fire.enabled) return true;

		var el = $(e.currentTarget);

		// Get all ATTRS
		var attrs = new Object;
		for(var i in el[0].attributes) {
			var attr = el[0].attributes[i];
			attrs[attr.nodeName] = attr.nodeValue;
		}

		if(el.attr('fire') != undefined) {
			var normal = fire.send(attrs, el);
			console.log(normal);
			return false;
			
			// Handle the various results
			if(normal.type == 'success')
				normal = true;
			else if(normal.type != 'success') {
				fire.alert(normal.message, normal.type);
				normal = false
			}

			return normal;
		} else return true;
	}
};

// Load Fire
$(fire.init);