Module.register("helloworld", {
	// Default module config.
	defaults: {
		user: "None",
	},

	getTemplate () {
		return "helloworld.njk";
	},

	getTemplateData () {
		return this.config;
	},

	capitalize(str) {
		return str.split(' ')
			.map(word => str.trim())
			.filter(word => word.length !== 0)
			.map(word => {
				return word.split('')
					.map((char, idx) => idx === 0 && char.toUpperCase() || char.toLowerCase())
					.join('')
			})
			.join('')
	},

	getDom() {
		const helloDiv = document.createElement('DIV');
		if (this.user === 'None' || this.user === undefined) {
			helloDiv.textContent = '';
			helloDiv.classList.remove('bright');
			helloDiv.classList.remove('large');
			helloDiv.style.opacity = '0';
			return helloDiv;				
		}

		helloDiv.classList.add('bright')
		helloDiv.classList.add('large');
		helloDiv.style.opacity = '1';
		const content = `Bonjour ${ this.capitalize(this.user) } !!!`;
		helloDiv.textContent = content;
		return helloDiv;
	},

	notificationReceived: function(notification, payload, sender) {

		if (notification !== 'USERS_LOGIN')
			return;

		// console.log('helloworld - notification', notification)
		// console.log('helloworld - payload', payload)
		// console.log('helloworld - sender', sender)
		// console.log('helloworld - showing user', payload?.[0])

		if (payload?.[0] === undefined)
			return
		this.user = payload?.[0]

		this.updateDom( {
			options: {
				speed: 1500, // animation duration
				animate: {
					in: "backInDown", // animation when module shown (after update)
					out: "backOutUp" // animatation when module will hide (before update)
				}
			}
		})
	},
});
