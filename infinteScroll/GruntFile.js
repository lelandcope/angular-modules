module.exports = function(grunt) {

	// Config
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),

		coffee: {
			compile: {
				options: {
					bare: true
				},
				files: {
					'dist/infiniteScroll.js': 'src/infiniteScroll.coffee'
				}
			}
		},

		uglify: {
			options: {
				banner: "/*! \r\n <%= pkg.name %> v<%= pkg.version %> \r\n Author: <%= pkg.author %> \r\n URL: <%= pkg.url %> \r\n <%= grunt.template.today('yyyy-mm-dd') %> \r\n */\r\n\r\n"
			},

			normal: {
				options: {
					mangle: false,
					beautify: true,
					compress: false,
					wrap: false,
					preserveComments: true
				},

				files: {
					'dist/infiniteScroll.js': 'dist/infiniteScroll.js'
				}
			},

			min: {
				files: {
					'dist/infiniteScroll.min.js': 'dist/infiniteScroll.js'
				}
			}
		}
	});

	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-uglify');


	grunt.registerTask('build', ['coffee','uglify:normal','uglify:min']);
}