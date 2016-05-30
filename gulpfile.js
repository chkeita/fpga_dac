var gulp = require('gulp');
var argv = require('yargs').argv;
var shell = require('gulp-shell');

gulp.task('compile', shell.task(['vlog '+argv.filename], {ignoreErrors : false}));


