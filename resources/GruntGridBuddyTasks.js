/**
 *  Set of task definitions for Gridbuddy work.
 *  @author Paul Roth <proth@salesforce.com>
**/

//-- npm install -g grunt-cli
_ = require('underscore');

//-- module to help list files.
fs = require('fs');

/** function to add in the name of the file before each resource **/
var commonProcessHeader = function(src,filepath ){
	return( "/*\n//Filename:" + filepath + "\n//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#\n*/\n" + src);
};

/**
 *  Determines if there are any option overrides.
 *  @param definition (Object)
 *  @param taskName (String)
 *  @example:
 *  	getTaskOptions( { options: { concat: { footer: 'foot' } } }, 'concat' ); //- { footer: 'foot' }
**/
function getTaskOptions( definition, taskName ){
	if( definition &&
		typeof definition.options != 'undefined' &&
		typeof definition.options[ taskName ] != 'undefined' )
	{
		return( definition.options[ taskName ] );
	} else {
		return( {} );
	}
}

function deleteFolderRecursive(path) {
	if( !path || path.startsWith( "/" )){
		  return;
	}
	if( fs.existsSync(path) ) {
		fs.readdirSync(path).forEach(function(file,index){
			var curPath = path + "/" + file;
			if(fs.lstatSync(curPath).isDirectory()) { // recurse
				deleteFolderRecursive(curPath);
			} else { // delete file
				fs.unlinkSync(curPath);
			}
		});
		fs.rmdirSync(path);
	}
};

gridBuddyNameTemplates = {
	js: "gbc_<%= target %>_js.js",
	css: "gbc_<%= target %>_css.css"
};
gridBuddyNameWithoutExtensionTemplates = {
	js: "gbc_<%= target %>_js",
	css: "gbc_<%= target %>_css"
};

currentPathTemplate = _.template( './<%= file %>' );
resourcePathTemplate = _.template( '../src/staticresources/<%= fileWithoutExtension %>.resource' );
targetPathTemplate = _.template( './tmp/staticresources/<%= fileWithoutExtension %>.resource' );

gridBuddyDefinitions = {
	js: "\n\t\t<%= resourceName %>: {\n\t\t\tsrc: 'grunt_src/<%= resourceName %>.js',\n\t\t\tbeforeSrc: commonScripts\n\t\t},\n",
	css: "\n\t\t<%= resourceName %>: {\n\t\t\tsrc: 'grunt_src/<%= resourceName %>.css',\n\t\t\tbeforeSrc: commonCSS\n\t\t},\n"
};

META = '-meta.xml';

META_TEMPLATE = "" +
"<?xml version='1.0' encoding='UTF-8'?>\n" +
"<StaticResource xmlns='http://soap.sforce.com/2006/04/metadata'>\n" +
"    <cacheControl>Private</cacheControl>\n" +
"    <contentType>application/octet-stream</contentType>\n" +
"</StaticResource>";


module.exports = function( grunt ){
	
	//debugger;
	
	/**
	 *  Custom task to run all GridBuddy Tasks.
	 *  @param resourceName
	 *  @example: grunt gridBuddy
	 *  @example: grunt gridBuddy:ancillaryrevenues //-- compiles the ancillary revenues
	**/
	grunt.registerTask( 'gridBuddy', 'Runs all GridBuddy tasks.', function( resourceName ){
		if( resourceName ){
			grunt.task.run( ['gridBuddyCompile:js:' + resourceName, 'gridBuddyCompile:css:' + resourceName, 'applyResources:' + resourceName, "log:'finishedCompiling'" ] );
		} else {
			grunt.task.run( ['gridBuddyCompile:js', 'gridBuddyCompile:css', 'applyResources', "log:'Finished Compiling'" ] );
		}
	});
	
	/**
	 *  Inner task to compile a type of gridBuddy asset (js/css/etc)
	 *  @param resourceType [js/css]
	 *  @param resourceName (string) - an individual resource or all resources of that type if blank
	 *  @example: grunt gridBuddyCompile:js
	 *  @example: grunt gridBuddyCompile:js:ancillaryrevenues
	**/
	grunt.registerTask( 'gridBuddyCompile', 'Compiles all GridBuddy assets.', function( resourceType, resourceName ){
		//debugger;
		grunt.log.writeln( 'starting to compile Gridbuddy files[' + resourceType + ':' + resourceName + ']' );
		
		var gbDefinitions = null;
		var nameTemplate = null;
		var nameTemplateWithoutExtension = null;
		try {
			gbDefinitions = require('./Grunt_GRIDBUDDY_DEFINITIONS.js' );
			if( resourceType && gbDefinitions.hasOwnProperty( resourceType )){
				gbDefinitions = gbDefinitions[ resourceType ];
			} else {
				grunt.log.error( 'No Gridbuddy Definition for:' + resourceType);
				return( false );
			}
			nameTemplate = _.template( gridBuddyNameTemplates[ resourceType ] );
			nameTemplateWithoutExtension = _.template( gridBuddyNameWithoutExtensionTemplates[ resourceType ]);
		} catch( err ){
			grunt.log.error( 'unable to find definition. contact paul' );
			return( false );
		}
		
		var customConfig = null, catConfig = null;
		var jsSrc = null, beforeSrc = null, afterSrc = null;
		var nameWithoutExtension = null;
		
		var runGB_Definition = function( gbDefinitions, nameTemplate, prop ){
			if( gbDefinitions.hasOwnProperty( prop )){
				//grunt.log.writeln( 'found a javascript config:' + prop );
				//grunt.log.writeln( JSON.stringify( gbDefinitions[prop] ));
				var jsConfig = gbDefinitions[prop];
				
				if( jsConfig &&
					jsConfig.src )
				{
					customConfig = {};
					jsSrc = jsConfig.src;
					if( !jsConfig.beforeSrc ){
						jsConfig.beforeSrc = [];
					}
					if( !jsConfig.afterSrc ){
						jsConfig.afterSrc = [];
					}
					nameWithoutExtension = nameTemplateWithoutExtension({ target: prop });
					customConfig.src = _.union( jsConfig.beforeSrc, [ jsSrc ], jsConfig.afterSrc );
					customConfig.dest = nameTemplate({ target: prop });
					customConfig.options = { process: commonProcessHeader };
					
					//-- generate the config 
					catConfig = getTaskOptions( gbDefinitions, 'concat' );
					catConfig[nameWithoutExtension] = customConfig;
					grunt.config.merge( { concat: catConfig } );
					
					//-- actually run the grunt task
					grunt.task.run( 'concat:' + nameWithoutExtension );
				}
			}
		};
		
		if( resourceName ){
			runGB_Definition( gbDefinitions, nameTemplate, resourceName );
		} else {
			for( var prop in gbDefinitions ){
				if( gbDefinitions.hasOwnProperty( prop )){
					runGB_Definition( gbDefinitions, nameTemplate, prop );
				}
			}
		}
		
		//-- task will complete when all sub-tasks have completed.
	});
	
	/**
	 *  Task to compile all gridbuddy JS files.
	 *  @param resourceName (String) - resource to compile, or all resources if blank.
	 *  @example: grunt gridBuddyJS
	 *  @example: grunt gridBuddyJS:ancillaryrevenues // compiles gb_ancillaryrevenues_js.js
	**/
	grunt.registerTask( 'gridBuddyJS', 'Compiles GridBuddy JavaScript files', function( resourceName ){
		if( resourceName ){
			grunt.task.run( 'gridBuddyCompile:js:' + resourceName );
		} else {
			grunt.task.run( 'gridBuddyCompile:js' );
		}
	});
	
	/**
	 *  Task to compile all gridbuddy CSS files.
	 *  @param resourceName (String) - resource to compile, or all resources if blank.
	 *  @example: grunt gridBuddyCSS
	 *  @example: grunt gridBuddyCSS:ancillaryrevenues // compiles gb_ancillaryrevenues_css.css
	**/
	grunt.registerTask( 'gridBuddyCSS', 'Compiles GridBuddy CSS files', function( resourceName ){
		if( resourceName ){
			grunt.task.run( 'gridBuddyCompile:css:' + resourceName );
		} else {
			grunt.task.run( 'gridBuddyCompile:css' );
		}
	});
	
	/**
	 *  Compies all resources to the static resource folder.
	 *  @param resourceName
	 *  @example: grunt applyResources
	 *  @example: grunt applyResources: ancillaryrevenues
	**/
	grunt.registerTask( 'applyResources', 'Copies the resources down to the src/resources folder', function( resourceName ){
		
		//debugger;
		
		var applyResource = function( resourceName, verifiedFile ){
			var path = currentPathTemplate({ file: resourceName });
			var path2 = null;
			if( !verifiedFile ){
				try {
					stats = fs.lstatSync( path );
				} catch( err ){
					grunt.log.error( 'could not find file:' + path );
					return( false );
				}
			}
			
			var extensionMatch = resourceName.match( /\w(\.(js|css))$/i );
			if( !extensionMatch ){
				grunt.log.error( 'Cannot apply resource:' + resourceName );
				return( false );
			}
			
			var fileWithoutExtension = resourceName.replace( extensionMatch[1], '' );
			path2 = resourcePathTemplate( { fileWithoutExtension: fileWithoutExtension } );
			
			var staticResourceStats = null;
			try {
				staticResourceStats = fs.lstatSync( path2 );
			} catch( err2 ){}
			
			if( !staticResourceStats ){
				if( !verifiedFile ){
					grunt.log.error( 'No such static resource:' + path2 );
				}
				return;
			}
			grunt.log.writeln( 'Updating:' + path2 + ' from ' + path );
			//var results = fs.createReadStream(path,{autoClose:true}).pipe(fs.createWriteStream(path2,{autoClose:true}));
			fs.writeFileSync( path2, fs.readFileSync( path ));
		};
		
		if( resourceName ){
			applyResource( resourceName, false );
		} else {
			var resourceFiles = fs.readdirSync( '.' );
			var file = null, fileWithoutExtension = null, file2 = null;
			var extensionMatch = null;
			
			for( var i = 0; i < resourceFiles.length; i++ ){
				file = resourceFiles[i];
				extensionMatch = file.match( /\w(\.(js|css))$/i );
				if( extensionMatch ){
					applyResource( file, true );
				}
			}
		}
	});
	
	grunt.registerTask( 'createCredentials', 'Creates a Salesforce credentials file', function(){
		//-- @TODO:
		/*
		prompt.get( { properties: { password: { message:'Your Salesforce Password (token may be required)', hidden:true }}}, function( err, result ){
			if( err ){
				//-- @TODO: not sure what would cause this or how to handle this...
				throw( new Exception('Error: unknown issue occurred when prompting for password' ));
			} else {
				program.pass = result.password;
				//console.log( 'password prompt completed' ); console.log( arguments );
				appReady.resolve();
			}
		});
		*/
		
		var exampleCredentials = "" +
			"/**\n" +
			" *  Module to store salesforce credentials\n" +
			"**/\n" +
			"module.exports = {\n" +
			"	username: '',\n" +
			"	password: '',\n" +
			"	token: '',\n" +
			"	serverurl: 'https://test.salesforce.com',\n" +
			"	apiVersion: '37.0'\n" +
			"};";
		
		fs.writeFileSync( './Grunt_SALESFORCE_CREDENTIALS.js', exampleCredentials);
	});
	
	grunt.registerTask( 'createGridBuddyResource', 'Creates a GridBuddyResource', function( resourceType, resourceName ){
		var exampleCommand = 'grunt createGridBuddyResource:js:template to create gbc_template_js';
		if( !resourceType ){
			grunt.log.error( 'You must specify a resource type to create a resource' );
			grunt.log.error( exampleCommand );
			return( false );
		}
		
		if( !resourceName ){
			grunt.log.error( 'You must specify a resource name to create a resource' );
			grunt.log.error( exampleCommand );
			return( false );
		}
		
		if( !gridBuddyDefinitions.hasOwnProperty( resourceType )){
			grunt.log.error( 'Resource type should be either: js or css' );
			grunt.log.error( exampleCommand );
			return( false );
		}
		
		var gbSourceFileTemplate = _.template( './grunt_src/<%= resourceName %>.<%= resourceType %>' );
		var gridBuddyDefinitionTemplate = _.template( gridBuddyDefinitions[resourceType] );
		var gridBuddyDefinition = gridBuddyDefinitionTemplate({ resourceName: resourceName });
		
		//debugger;
		var GRID_BUDDY_DEFINITION = './Grunt_GRIDBUDDY_DEFINITIONS.js';
		var scriptDefinition = fs.readFileSync( GRID_BUDDY_DEFINITION ).toString();
		var scriptDefinition2 = null;
		
		var definitionRegEx = new RegExp( "\\n\\s+" + resourceType + ":\\s*\\{","i" );
		scriptDefinition2 = scriptDefinition.replace( definitionRegEx, "$&" + gridBuddyDefinition );
		
		fs.writeFileSync( GRID_BUDDY_DEFINITION, scriptDefinition2 );
		
		var gbSourceFilePath = gbSourceFileTemplate({ resourceName: resourceName, resourceType:resourceType });
		fs.writeFileSync( gbSourceFilePath, '//-- your info goes here:' + resourceName + "\n//-- to deploy run: grunt deployGridBuddyResource:" + resourceName );
		
		var resourceNameTemplate = _.template( gridBuddyNameWithoutExtensionTemplates[ resourceType ] );
		var gbResourceName = resourceNameTemplate({ target:resourceName });
		
		grunt.task.run( 'createResource:' + gbResourceName );
	});
	
	grunt.registerTask( 'createResource', 'Creates a resource', function( resourceName ){
		if( !resourceName ){
			grunt.log.error( 'You must specify a resource name to create one' );
		}
		
		resourceName = resourceName.replace( /\.resource$/i, '' );
		
		var targetPath2 = resourcePathTemplate({ fileWithoutExtension: resourceName });
		
		fs.writeFileSync( targetPath2, '//-- your file goes here' );
		fs.writeFileSync( targetPath2 + META, META_TEMPLATE );
		
		grunt.log.writeln( 'new resource created:' + targetPath2 );
	});
	
	grunt.registerTask( 'deployGridBuddyResource', 'Deploys a gridbuddy resource', function( resourceName ){
		var exampleCommand = "run the command of:\ngrunt deployGridBuddyResource:template\n to deploy any resources for template.\n both gbc_template_js and gbc_template_css (if applicable)";
		
		if( !resourceName ){
			grunt.log.error( 'You must specify a resource name to deploy a resource' );
			grunt.log.error( exampleCommand );
			return( false );
		}
		
		var credentials = null;
		try {
			credentials = require('./Grunt_SALESFORCE_CREDENTIALS.js');
		} catch(err6){
			grunt.log.writeln( 'Such file: ./Grunt_SALESFORCE_CREDENTIALS.js' );
			grunt.log.writeln( 'Kicking off Template.' );
			grunt.task.run( 'createCredentials' );
			grunt.log.writeln( 'Please fill out credentials before attempting to deploy again.' );
			return;
		}
		
		credentials = _.defaults({
			apiVersion: '37.0',
			cuca: 'monga',
			serverurl: 'https://test.salesforce.com'
		}, credentials );
		
		if( !credentials.username ){
			grunt.log.error( 'Grunt_SALESFORCE_CREDENTIALS.username not provided. please fill it in.' );
		}
		if( !credentials.password ){
			grunt.log.error( 'Grunt_SALESFORCE_CREDENTIALS.password not provided. please fill it in.' );
		}
		
		var gruntDefinitions = require('./Grunt_GRIDBUDDY_DEFINITIONS.js' );
		if( !gruntDefinitions ){
			grunt.log.error( 'Grunt definitions not found. Talk to Paul.' );
			return( false );
		}
		
		var resourcesToDeploy = [];
		
		var jsNameTemplate = _.template( gridBuddyNameWithoutExtensionTemplates.js );
		var cssNameTemplate = _.template( gridBuddyNameWithoutExtensionTemplates.css );
		
		var fileWithoutExtension = null;
		var resourcePath = null;
		var targetPath = null;
		
		try {
			deleteFolderRecursive( './tmp' );
		} catch( err8 ){}
		
		try {
			fs.mkdirSync( './tmp' );
			fs.mkdirSync( './tmp/staticresources' );
		} catch( err7 ){}
		
		if( gruntDefinitions.hasOwnProperty('js') &&
			gruntDefinitions.js.hasOwnProperty( resourceName ) )
		{
			fileWithoutExtension = jsNameTemplate({ target: resourceName });
			resourcePath = resourcePathTemplate({ fileWithoutExtension: fileWithoutExtension });
			try {
				fs.lstatSync( resourcePath );
				
				targetPath = targetPathTemplate({ fileWithoutExtension: fileWithoutExtension });
				fs.writeFileSync( targetPath, fs.readFileSync( resourcePath ));
				fs.writeFileSync( targetPath + META, fs.readFileSync( resourcePath + META ));
				
				//-- only get here if the file exists
				resourcesToDeploy.push( fileWithoutExtension );
			} catch( err3 ){
				grunt.log.writeln( 'could not find:' );
			}
		}
		
		if( gruntDefinitions.hasOwnProperty('css') &&
			gruntDefinitions.css.hasOwnProperty( resourceName ) )
		{
			fileWithoutExtension = cssNameTemplate({ target: resourceName });
			resourcePath = resourcePathTemplate({ fileWithoutExtension: fileWithoutExtension });
			try {
				fs.lstatSync( resourcePath );
				
				targetPath = targetPathTemplate({ fileWithoutExtension: fileWithoutExtension });
				fs.writeFileSync( targetPath, fs.readFileSync( resourcePath ));
				fs.writeFileSync( targetPath + META, fs.readFileSync( resourcePath + META ));
				
				//-- only get here if the file exists
				resourcesToDeploy.push( fileWithoutExtension );
			} catch( err4 ){
				grunt.log.writeln( 'could not find:' );
			}
		}
		
		//debugger;
		grunt.log.writeln( 'resourcesToDeploy:' + resourcesToDeploy );
		
		if( !resourcesToDeploy || resourcesToDeploy.length < 1 ){
			grunt.log.error( 'Could not find [' + resourceName + '] within the list of grunt definitions' );
			return( false );
		}
		
		var antRetrieveOptions = {
			root: './tmp/',
			version: credentials.apiVersion,
			user: credentials.username,
			pass: credentials.password,
			serverurl: credentials.serverurl
		};
		
		if( credentials.hasOwnProperty('token') ){
			antRetrieveOptions.token = credentials.token;
		}
		
		var antRetrievePkg = {
			staticresource: resourcesToDeploy
		};
		
		var antDeployConfig = {
			antdeploy: {
				options: antRetrieveOptions,
				generated: {
					pkg: antRetrievePkg
				}
			}
		};
		
		grunt.config.merge(antDeployConfig);
		
		grunt.task.run( 'antdeploy:generated' );
	});
};