var gulp = require('gulp');
var argv = require('yargs').argv;
var shell = require('gulp-shell');
var path = require('path');

var basename = path.basename(argv.filename);
var filenameWithoutExtention = basename.split('.')[0] ;

gulp.task(
    'compile', 
    shell.task(
            [
                'vlog '+argv.filename
            ], {ignoreErrors : false, verbose :true}));


gulp.task(
    'compileAndRun', 
    shell.task(
            [
                'vlog '+argv.filename ,
                'vsim -c -do "run -all; exit" '+ filenameWithoutExtention
            ], {ignoreErrors : false, verbose : true}));
