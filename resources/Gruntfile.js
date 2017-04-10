
//-- to debug node run the following command from your commandline:
//-- node-debug $(which grunt) [[your task]]

//debugger;

//-- npm install -g grunt-cli
_ = require('underscore');
path = require('path');
npmRun = require('npm-run');
lightningLinter = require('./Grunt_LIGHTNING_LINTER');

//-- 

module.exports = function(grunt) {

	// Project configuration.
	grunt.initConfig({
		//_: require('underscore'),
		gridBuddyScripts: require('./Grunt_GRIDBUDDY_DEFINITIONS' ),
		pkg: grunt.file.readJSON('package.json'),
		
		lightningLint: {
			quiet:true
		},
		concat: {
		},
		watch: {
			src: {
				files: ['grunt_src/**/*.js','grunt_src/**/*.css'],
				tasks: ['gridBuddy']
			},
			lightning: {
				files: ['../src/aura/**/*.js']
			}
		},
		log: {
			foo: [1,2,3],
			bar: 'hello world',
			baz: false
		},
		antdeploy: {
			options: {
				root: '../src/'
			},
			testDeploy: {
				pkg: {
					staticresource: ['gbc_template_css.resource']
				}
			}
		}
	});
	
	//-- custom tasks
	/**
	 *  Custom task to log stuff.
	 *  @param message
	 *  @example: grunt log:'Some message'
	**/
	grunt.registerTask( 'log', 'Log stuff', function( message ){
		//debugger;
		if( !message ){
			message = '';
		}
		grunt.log.writeln( 'Log: ' + message );
	});
	
	//debugger;
	//-- load grid buddy tasks.
	require('./GruntGridBuddyTasks')(grunt);
	
	// Load the plugin that provides the "uglify" task.
	grunt.loadNpmTasks('grunt-contrib-concat');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-ant-sfdc');
	//grunt.loadNpmTasks('grunt-debug-task');
	
	// Default task(s).
	grunt.registerTask('default', ['gridBuddy']);
	
	grunt.event.on('watch', function( action, filepath, target ){
		//console.log( 'target:' + target + '|' + filepath + ' has ' + action );
		if( !filepath ){
			console.log( 'no file provided, should never get here' );
		} else if( filepath.indexOf('/aura/') !== -1 ){
			//-- only run the special linter if it is a lightning component.
			
			var isQuiet = grunt.config.get('lightningLint.quiety');
			console.log( 'isQuiet:' + isQuiet );
			var filePathObj = path.parse( filepath );
			
			lightningLinter.runLinter( filePathObj.dir, { quiet: isQuiet });
		}
	});
};
