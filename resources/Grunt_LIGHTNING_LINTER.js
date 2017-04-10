/**
 *  Module to store salesforce credentials
**/

npmRun = require('npm-run');

/** argument for quiet **/
quietArg = ' --quiet';

/** cmd exec **/
lintCmd = 'heroku lightning:lint ';

/** config **/
lightningConfig = ' --config ./Grunt_LIGHTNING_LINTER_CONFIG.eslintrc';

module.exports = {
	
	/**
	 *  Function that executes the linter
	 *  @params targetDir (String) path to the directory to run the linter against
	 *  @params args (Object) - object with argument properties, such as the following:
	 *      # quiet (boolean) - the linter runs in quiet mode.
	 *  @return void
	 **/
	runLinter: function( targetDir, args ){
		
		args = args || {};
		
		var cmdArgs = "";
		if( (typeof args.quiet) !== 'undefined' && args.quiet ){
			cmdArgs += quietArg;
		}
		
		npmRun( lintCmd + targetDir + cmdArgs + lightningConfig, { cwd: __dirname }, function( err, stdout, stderr ){
			if( err ){
				console.log( ' there was an error' );
				console.log( stderr );
			} else {
				console.log( 'stdout:' );
				console.log( stdout );
			}
		});
	}
};