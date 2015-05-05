/**
* A utility for managing the queries in the mongo database.
* This tool pulls down a version of the queries found in the queries repo
* 	which can be found at: https://github.com/PhysiciansDataCollaborative/queries
*
* The tool relies on the structure of the queries repo to know where to look for queries
*  and their associated helper functions. 
*
* @author: Simon Diemert
* @date: 2015-04-21
*/

var IMPORTER_DIR 	= "queryImporter/"; 
var TMP_DIR 	 	= IMPORTER_DIR+"tmp/"; 
var QUERIES_DIR  	= TMP_DIR+"queries/"; 

var global_vars = {
	host: 			null,
	user: 			null,
	pass: 			null,
	port: 			null, 
	database: 		null, 
	queries_repo:  "https://github.com/PhysiciansDataCollaborative/queries.git", 
	reclone: 		false, 
	pdc_user:		null
}; 


var parseArgs = require('minimist'); //provides argument processing. 
var fs 		  = require("fs");
var sys 	  = require("sys"); 
var execSync  = require("child_process").execSync;
//var util 	  = require("./mongoUtil.js"); 
var assert 	  = require("assert");
var async	  = require("async"); 
var mongoose  = require("mongoose"); 


//MODELS: 

var querySchema = mongoose.Schema(
	{
		title : String, 
		_type : {type: String, default: "Query"},
		description : String,
		map : String,
		reduce : String, 
		user_id :  mongoose.Schema.ObjectId
	}, {
		collection: 'queries'
	}
); 

var functionSchema = mongoose.Schema(
	{
		name : String,
		user_id :  mongoose.Schema.ObjectId, 
		definition : String
	}, {
		collection: "library_functions"
	}
);

var userSchema = mongoose.Schema(
	{
		first_name 	: String,
		last_name 	: String,
		username 	: String,
		admin		: Boolean 	
	}, {
		collection : "users"
	}
); 

var Query = mongoose.model("Query", querySchema); 
var Library_Function = mongoose.model("LibraryFunction", functionSchema); 
var User = mongoose.model("User", userSchema); 


/*
* THIS IS A BAD THING!!!!!!!!!!!! It should be fixed at some point 
* to acutally pull the reduce function from the queries repo. However,
* since all of the reduce are the same at this point (2015-05-22). 
*/ 
var reduceFunction = "function reduce(key, values){return Array.sum(values);}"; 

function helpMessage(){
	var s = "See the README.md file in the repo."; 
	return s;  
}

/**
* This function takes in the arguments and figures out
* how best to have the program proceed. It returns 
* an action (string) that can be used to inform how
* the rest of the program should behave. 
* 
* @param (object) args - the args (from minimist) object that contains the cmd 
*					arguments.
*
* @return a string indicating how the program should proceed. 
*/ 
function processArgs(args){
	//find the high level action:
	if(args._.length <= 1){// this did not give an explicit action
		return "no_action"; 
	}else if(args._[2] == "import"){
		//this corresponds to importing the queries into the database. 
		//if we get here, we need to populate the globa global_vars object. 

		//first check that the bear minimum of params are given:
		if((args["mongo-host"] == null || args["mongo-host"] == undefined) || 
			(args["mongo-port"] == null || args["mongo-port"] == undefined) ||
			(args["mongo-db"] == null || args["mongo-db"] == undefined)
		){
			//if they are here, we are missing an input parameter for the database. 
			return "missing_param"; 
		}

		//if we get here we know we have enough to connect to the database. 
 		global_vars.host = args["mongo-host"]; 
		global_vars.port = args["mongo-port"]; 
 		global_vars.database = args["mongo-db"]; 

		if(args["mongo-user"] != null && args["mongo-user"] != undefined){
			global_vars.user = args["mongo-user"]; 
		}

		if(args["mongo-pass"] != null && args["mongo-pass"] != undefined){
		 	global_vars.user = args["mongo-pass"]; 
		}

		if(args["mongo-pass"] != null && args["mongo-pass"] != undefined){
			global_vars.user = args["mongo-pass"]; 
		}

		if(args["reclone"] != null && args["reclone"] != undefined){
			global_vars.reclone = true; 
		}

		if(args["pdc-user"] != null && args["pdc-user"] != undefined){
			global_vars.pdc_user = args["pdc-user"]; 
		}else{
			global_vars.pdc_user = "pdcadmin"; 
		}

		return "import"; 
	}
}

/**
* Clone's the queries repo down from github.
* If @param reclone is true, it will delete any old copy 
* and get a new one.
* 
* If @param reclone is false, then it will check for existance 
* 	of the repo, if it doesn't exist it will git clone, if it does
* 	exist it will proceed. 
* @param reclone - a boolean value, defaults to true. 
*/
function clone(reclone){
  	if (typeof(reclone)==='undefined') reclone = true;

	//make a directory to put the repo in:
	if(!fs.existsSync(TMP_DIR)){
		fs.mkdirSync(TMP_DIR); 
	}

	var child = null; 

	if(reclone){
		if(fs.existsSync(QUERIES_DIR)){
			//if the repo exists already, delete it and pull a fresh copy. 
			console.log("Removing old queries/ repo"); 
			child = execSync("rm -rf "+IMPORTER_DIR+"tmp/queries"); 
		}

		//clone a new copy of the the repo. 
		console.log("Cloning into: "+global_vars.queries_repo); 
		child = execSync("git clone "+global_vars.queries_repo+" "+QUERIES_DIR); 
	}else{
		if(!fs.existsSync(QUERIES_DIR)){
			//clone a new copy of the the repo. 
			console.log("Cloning into: "+global_vars.queries_repo); 
			child = execSync("git clone "+global_vars.queries_repo+" "+QUERIES_DIR); 
		}
	}
}


/*
* Checks the integrity of the queries repo to make sure the 
* file structure is compatible with this script. 
*
* Checks are based on the file tree given in the README.md of the
* 	queries repo. (https://github.com/PhysiciansDataCollaborative/queries)
* 
* return - true if the check passes, false otherwise. 
*/
function checkIntegrity(){
	if( !fs.existsSync(QUERIES_DIR+"queries") || 
		!fs.existsSync(QUERIES_DIR+"functions")
	){
		//if we get to here, then we are missing a directory. 
		throw {name:"DirectoryNotFound", message:"The queries and functions/ directories were not found in the queries repo."}
		return false; 
	}

	console.log(QUERIES_DIR+" repository integrity check PASSED."); 
	return true; 
}

function getTextBlobs(path, pattern){

	assert.notEqual(path, undefined, "Must pass getTextBlobs() a path"); 

	pattern = pattern || ".*"; 

	//check to make sure we have a / on the end of the directory path. 
	if(path[path.length-1] != "/"){
		path.push("/"); 
	}

	if(!fs.existsSync(path)){
		throw new {name : PathNotFoundException, message : "The path: "+path+" does not exist!"}; 
	}

	if(!fs.lstatSync(path).isDirectory()){
		throw new {name : DirectoryNotFoundException, message : "The path: "+path+" is not a directory!"}; 
	}

	var results = []; //put the text blobs in here. 

	var files = fs.readdirSync(path); //get all of the file names in an array
	var name = ""; 
	var tmp = ""; 

	for(i in files){
		// 1. filter out non-js files based on .js extension.
		// 2. open the file, check for valid map() function.
		// 3. push text blob from file into the results array with its associated query name.  

		// 1. Filter out non-js files
		if(!files[i].match(".*.js$")){
			//if we get here, then we know that this file is not a js file.
			continue; 
		}

		//drop off the last 3 chars to get the query name. 
		name = files[i].substring(0, files[i].length-3); 
		console.log(name); 

		tmp = fs.readFileSync(path+files[i], "utf8"); //path already has a / on it. 

		//could also change this to extract the description of the query. 
		//might also consider changing this approach. 

		var title = name.match(pattern); 
		if(title != null){
			title=title[0]; 
			tmp = {description:name, map:tmp, title:title, reduce:reduceFunction}; 
			results.push(tmp); 
		}else{
			console.log("WARNING: omitting "+name+" as it does not conform to naming convention enforced by: "+pattern)
		}
	}

	return results;    
}

function sendQueriesToMongo(data, db, doneCallback){
	
	db.once("open", function(callback){
		console.log("Beginning to write queries....")

		var pushQueries = function(userinfo){

			async.each(
				data, 
				function(d, callback){
					//called for each item in data, executed async
					var q = new Query({
						title: d.title, 
						map: d.map,
						reduce:d.reduce, 
						description:d.description,
						user_id: mongoose.Types.ObjectId(userinfo._id) 
					});

					var upsertData = q.toObject();
					delete upsertData._id;  //delete the ID field so mongo doesn't get confused

					Query.findOneAndUpdate(
						{title: q.title}, 
						upsertData,
						{upsert : true},
						function(err){
							if(err){
								console.log(err); 
							}else{
								console.log(d.title+" was updated in MongoDB"); 
							}
							callback(); 
						}
					);
				}, 
				function(err){
					//this gets called when we are done. 
					if(err){
						console.log(err); 
					}else{
						console.log("Done writing queries to MongoDB."); 
					}
					doneCallback(); 
				}
			);
		}

		User.find(
			{username : global_vars.pdc_user},
			function(err, val){
				if(err){
					console.log("Could not fetch user "+global_vars.pdc_user+" from MongoDB: "+err); 
					db.close(); 
				}else{
					if(val.length < 1){
						console.log("WARNING: Could not find user: "+global_vars.pdc_user+" in MongoDB"); 
						return; 
					}else if(val.length > 1){
						console.log("WARNING: Found to many users with username: "+global_vars.pdc_user+" in MongoDB"); 
						return; 
					}else{
						pushQueries(val[0]); 
					}
				}
			}
		);	


	}); 

	db.on("error", function(err){
		console.log("Mongoose could not connect to MongoDB");  
		console.log(err); 
	}); 
}

function sendFunctionsToMongo(data, db, doneCallback){
	db.once("open", function(){
		console.log("Beginning to write functions...."); 

		var pushFunctions = function(userinfo){
			async.each(
				data,
				function(d, callback){
					var f = new Library_Function({
						name : d.title,
						definition : d.map, //this is d.map even though it isn't actually a map() function.
						user_id : mongoose.Types.ObjectId(userinfo._id) 
					}); 

					var upsertData = f.toObject();
					delete upsertData._id;  //delete the ID field so mongo doesn't get confused

					Library_Function.findOneAndUpdate(
						{title: f.title}, 
						upsertData,
						{upsert : true},
						function(err){
							if(err){
								console.log(err); 
							}else{
								console.log(d.title+" was updated in MongoDB"); 
							}
							callback(); 
						}
					);
				}, 
				function(err){
					if(err){
						console.log(err); 
					}else{
						console.log("Done writing functions to MongoDB."); 
					}
					doneCallback(); 
				}
			);
		}
		
		User.find(
			{username : global_vars.pdc_user},
			function(err, val){
				if(err){
					console.log("Could not fetch user "+global_vars.pdc_user+" from MongoDB: "+err); 
					db.close(); 
				}else{
					if(val.length < 1){
						console.log("WARNING: Could not find user: "+global_vars.pdc_user+" in MongoDB"); 
						return; 
					}else if(val.length > 1){
						console.log("WARNING: Found to many users with username: "+global_vars.pdc_user+" in MongoDB"); 
						return; 
					}else{
						pushFunctions(val[0]); 
					}
				}
			}
		);
	}); 
}

function runImport(){
	//1. Load queries and functions in an array of text blobs.
	//2. For each item in each array push into the database

	var queries =  getTextBlobs(QUERIES_DIR+"queries/", "PDC-[0-9]*"); 
	var funcs   = getTextBlobs(QUERIES_DIR+"functions/", ".*"); 

	var db = mongoose.connection;

	async.each(
		[{action:"function", data:funcs}, {action:"queries", data:queries}],
		function(item, callback){
			console.log(item.action);  
			if(item.action == "function"){
				sendFunctionsToMongo(item.data, db, callback); 
			}else if(item.action == "queries"){
				sendQueriesToMongo(item.data, db, callback); 
			}
		},
		function(err){
			if(err) console.log(err); 
			db.close(); 
		}
	);
}

//Everything starts here....
function main(){

	console.log("==========================="); 
	console.log("Starting queryImporter tool");
	console.log("==========================="); 

	//take in arguments and process with minimist tool. 
	var argv = parseArgs(process.argv); 

	var action = processArgs(argv); 

	var url = "mongodb://"+global_vars.host+":"+global_vars.port+"/"+global_vars.database; 

	mongoose.connect(url)	

	switch(action){
		case "no_action":
			break;
		case "missing_param":
			break; 
		case "import":
			clone(global_vars.reclone);
			checkIntegrity(); 
			runImport(); 
			break;
		default:
			break;  
	}
}


//call the main function of tool. 
main(); 