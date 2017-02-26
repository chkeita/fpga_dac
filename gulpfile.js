var gulp = require('gulp');
var argv = require('yargs').argv;
var shell = require('gulp-shell');
var path = require('path');

var basename = path.basename(argv.filename);
var filenameWithoutExtention = basename.split('.')[0] ;
var dirname = path.dirname(argv.filename);

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

gulp.task('compileAndRunIcarus',
    shell.task(
        [
            'iverilog -g2012 -o '+ filenameWithoutExtention+ '.out '+ argv.filename,
            'vvp '+ filenameWithoutExtention+'.out'
        ], {ignoreErrors : false, verbose : true, cwd : dirname}));
