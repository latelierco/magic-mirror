/* Config Sample
 *
 * For more information on how you can configure this file
 * see https://docs.magicmirror.builders/configuration/introduction.html
 * and https://docs.magicmirror.builders/modules/configuration.html
 *
 * You can use environment variables using a `config.js.template` file instead of `config.js`
 * which will be converted to `config.js` while starting. For more information
 * see https://docs.magicmirror.builders/configuration/introduction.html#enviromnent-variables
 */
let config = {
	address: "localhost",	// Address to listen on, can be:
							// - "localhost", "127.0.0.1", "::1" to listen on loopback interface
							// - another specific IPv4/6 to listen on a specific interface
							// - "0.0.0.0", "::" to listen on any interface
							// Default, when address config is left out or empty, is "localhost"
	port: 8080,
	basePath: "/",	// The URL path where MagicMirror² is hosted. If you are using a Reverse proxy
									// you must set the sub path here. basePath must end with a /
	ipWhitelist: ["127.0.0.1", "::ffff:127.0.0.1", "::1"],	// Set [] to allow all IP addresses
									// or add a specific IPv4 of 192.168.1.5 :
									// ["127.0.0.1", "::ffff:127.0.0.1", "::1", "::ffff:192.168.1.5"],
									// or IPv4 range of 192.168.3.0 --> 192.168.3.15 use CIDR format :
									// ["127.0.0.1", "::ffff:127.0.0.1", "::1", "::ffff:192.168.3.0/28"],

	useHttps: false,			// Support HTTPS or not, default "false" will use HTTP
	httpsPrivateKey: "",	// HTTPS private key path, only require when useHttps is true
	httpsCertificate: "",	// HTTPS Certificate path, only require when useHttps is true

	language: "en",
	locale: "en-US",
	logLevel: ["INFO", "LOG", "WARN", "ERROR"], // Add "DEBUG" for even more logging
	timeFormat: 24,
	units: "metric",

	modules: [
		/*
		{
			module: "alert",
		},
		{
			module: "updatenotification",
			position: "top_bar"
		},
		*/
		{
			module: "clock",
			classes: 'default everyone',
			position: "top_left"
		},
		{
			module: "calendar",
			classes: 'default everyone',
			header: "US Holidays",
			position: "top_left",
			config: {
				calendars: [
					{
						fetchInterval: 7 * 24 * 60 * 60 * 1000,
						symbol: "calendar-check",
						url: "https://ics.calendarlabs.com/76/mm3137/US_Holidays.ics"
					}
				]
			}
		},
		/*
		{
			module: "compliments",
			position: "lower_third"
		},
		*/
		{
			module: "weather",
			classes: 'default everyone',
			position: "top_right",
			config: {
				weatherProvider: "openmeteo",
				type: "current",
				lat: 48.856771939556204,
				lon: 2.3515402275243815
			}
		},
		{
			module: "weather",
			position: "top_right",
			header: "Weather Forecast",
			config: {
				weatherProvider: "openmeteo",
				type: "forecast",
				lat: 48.856771939556204,
				lon: 2.3515402275243815
			}
		},
		{
			module: 'helloworld',
			header: '',
			position: "lower_third",
			classes: 'unknown known',
			config: {
				user: "None",
			}
		},
		/*
		{
			module: "newsfeed",
			classes: 'default everyone',
			position: "bottom_bar",
			config: {
				feeds: [
					{
						title: "New York Times",
						url: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"
					}
				],
				showSourceTitle: true,
				showPublishDate: true,
				broadcastNewsFeeds: true,
				broadcastNewsUpdates: true
			}
		},
		*/
		{
			module: 'MMM-news-le-monde',
			classes: 'default everyone',
			position: 'bottom_bar',
			config: {
				fetchInterval: 15 * 60 * 1000,
				url: 'https://www.lemonde.fr/rss/en_continu.xml?refresh=' + Math.floor(Math.random() * 1000000),
				title: '',
				description: '',
				started: false,
			}
		},
		{
			module: 'MMM-Face-Reco-DNN',
			config: {
				// Logout 15 seconds after user was not detecte anymore, if they will be detected between this 15
				// Seconds, they delay will start again
				logoutDelay: 3000,
				// How many time the recognition starts, with a RasPi 3+ it would be good every 2 seconds
				checkInterval: 500,
				// Module set used for when there is no face detected ie no one is in front of the camera
				noFaceClass: 'noface',
				// Module set used for when there is an unknown/unrecognised face detected
				unknownClass: 'unknown',
				// Module set used for when there is a known/recognised face detected
				knownClass: 'known',
				// Module set used for strangers and if no user is detected
				defaultClass: 'default',
				// Set of modules which should be shown for any user ie when there is any face detected
				everyoneClass: 'everyone',
				// Set of modules that are always shown - show if there is a face or no face detected
				alwaysClass: 'always',
				// xml to recognize with haarcascae
				cascade: 'modules/MMM-Face-Reco-DNN/model/haarcascade_frontalface_default.xml',
				// pre encoded pickle with the faces
				encodings: 'modules/MMM-Face-Reco-DNN/model/encodings.pickle',
				// Brightness (0-100)
				brightness: 0,
				// Contrast (0-127)
				contrast: 0,
				// Rotate camera image (-1 = no rotation, 0 = 90°, 1 = 180°, 2 = 270°)
				rotateCamera: -1,
				// method of face recognition (dnn = deep neural network, haar = haarcascade)
				method: 'dnn',
				// which face detection model to use. "hog" is less accurate but faster on CPUs. "cnn" is a more accurate
				// deep-learning model which is GPU/CUDA accelerated (if available). The default is "hog".
				detectionMethod: 'hog',
				// how fast in ms should the modules hide and show (face effect)
				animationSpeed: 0,
				// Path to Python to run the face recognition (null / '' means default path)
				pythonPath: null,
				// Boolean to toggle welcomeMessage
				welcomeMessage: true,
				// Dictionary for person name mapping in welcome message
				// Allows for displaying name with complex character sets in welcome message
				// e.g. jerome => Jérôme, hideyuki => 英之, mourad => مراد
				usernameDisplayMapping: null,
				// Save some pictures from recognized people, if unknown we save it in folder "unknown"
				// So you can extend your dataset and retrain it afterwards for better recognitions
				extendDataset: false,
				// if extenDataset is set, you need to set the full path of the dataset
				dataset: 'modules/MMM-Face-Reco-DNN/dataset/',
				// How much distance between faces to consider it a match. Lower is more strict.
				tolerance: 0.6,
				// allow multiple concurrent user logins, 0=no, any other number is the maximum number of concurrent logins
				multiUser: 0,
				// resoltuion of the image
				resolution: [1920, 1080],
				// width of the image for processing
				processWidth: 500,
				// output image on mm
				outputmm: 0,
				// turn on extra debugging 0=no, 1=yes
				debug: 0,
			}
		},
	]
};

/*************** DO NOT EDIT THE LINE BELOW ***************/
if (typeof module !== "undefined") { module.exports = config; }
