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
					'dist/lc-touch.js': 'src/lc-touch.coffee'
				}
			}
		},

		uglify: {
			options: {
				banner: "/*! \r\n <%= pkg.name %> v<%= pkg.version %> \r\n Author: <%= pkg.author %> \r\n <%= grunt.template.today('yyyy-mm-dd') %> \r\n */\r\n\r\n"
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
					'dist/lc-touch.js': 'dist/lc-touch.js'
				}
			},

			min: {
				options: {
					mangle: false,
					compress: true,
					wrap: true,
					preserveComments: false
				},

				files: {
					'dist/lc-touch.min.js': 'dist/lc-touch.js'
				}
			}
		},

		bump: {
		    options: {
        		files: ['package.json'],
        		updateConfigs: ['pkg'],
        		commit: false,
        		createTag: false,
        		push: false
            }
		}
	});

	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-uglify');
	grunt.loadNpmTasks('grunt-bump');


	grunt.registerTask('build', ['coffee','uglify:normal','uglify:min']);
}