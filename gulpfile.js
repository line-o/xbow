/**
 * an example gulpfile to make ant-less existdb package builds a reality
 */
const { src, dest, watch, series, parallel, lastRun } = require('gulp')
const { createClient } = require('@existdb/gulp-exist')
const zip = require("gulp-zip")
const replace = require('gulp-replace')
const rename = require('gulp-rename')
const del = require('delete')

const pkg = require('./package.json')

// read metadata from .existdb.json
const existJSON = require('./.existdb.json')
const packageUri = existJSON.package.namespace
const serverInfo = existJSON.servers.localhost

const connectionOptions = {
    basic_auth: {
        user: serverInfo.user, 
        pass: serverInfo.password
    }
}
const existClient = createClient(connectionOptions);

/**
 * Use the `delete` module directly, instead of using gulp-rimraf
 */
function clean (cb) {
    del(['build'], cb);
}
exports.clean = clean

/**
 * report problems in replacements in .tmpl files
 * replaces the problematic values with an empty string
 * 
 * @param {String} match
 * @param {Number} offset 
 * @param {String} string 
 * @param {String} path
 * @param {String} message
 * @returns {String} empty string
 */
function handleReplacementIssue (match, offset, string, path, message) {
    const line = string.substring(0, offset).match(/\n/g).length + 1
    const startIndex = Math.max(0, offset - 30)
    const startEllipsis = Boolean(startIndex)
    const start = string.substring(startIndex, offset)
    const endIndex = (offset + match.length + Math.min(string.length, 30)) 
    const endEllipsis = endIndex === string.length
    const end = string.substr(offset + match.length, Math.min(string.length, 30))
    console.warn(`\n\x1b[31m${match}\x1b[39m ${message}`)
    console.warn(`Found at line ${line} in ${path}`)
    console.warn(`${ellipsis(startEllipsis)}${start}\x1b[31m${match}\x1b[39m${end}${ellipsis(endEllipsis)}`)
    return ""
}

/**
 * replace placeholders in the form @package.something@
 * similar to your normal .tmpl substitutions
 * 
 * @param {String} match 
 * @param {String} p1 
 * @param {String} p2
 * @param {Number} offset 
 * @param {String} string 
 * @returns {String} replacement or empty string
 */
function tmplReplacement (match, p1, p2, offset, string) {
    const path = this.file.relative
    if (!p1) {
        return handleReplacementIssue(match, offset, string, path, "replacement must start with 'package.'")
    }
    // search for replacement in .existdb.json "package"
    if (existJSON.package && p2 in existJSON.package) {
        return existJSON.package[p2]
    }
    // search for replacement in package.json
    if (p2 in pkg) {
        return pkg[p2]
    }
    // missing substitution handling
    return handleReplacementIssue(match, offset, string, path, "is not set in package.json!")
}

/**
 * show that the file contents were shortened
 * 
 * @param {Boolean} display 
 * @returns {String} '...' if display is true, '' otherwise
 */
function ellipsis (display) {
    if (display) { return '...' }
    return ''
}

/**
 * replace placeholders 
 * in src/repo.xml.tmpl and 
 * output to build/repo.xml
 */
function templates () {
  return src('src/*.tmpl')
    .pipe(replace(/@(package\.)?([^@]+)@/g, tmplReplacement))
    .pipe(rename(path => { path.extname = "" }))
    .pipe(dest('build/'))
}
exports.templates = templates

function watchTemplates () {
    watch('src/*.tmpl', series(templates))
}
exports["watch:tmpl"] = watchTemplates

const static = [
    "src/examples/*",
    "src/content/*",
    "src/test/*.*",
    "src/icon.svg"
]

/**
 * copy html templates, XSL stylesheet, XMLs and XQueries to 'build'
 */
function copyStatic () {
    return src(static, {base: 'src'}).pipe(dest('build'))
}
exports.copy = copyStatic

function watchStatic () {
    watch(static, series(copyStatic));
}
exports["watch:static"] = watchStatic

/**
 * since this is a pure library package uploading
 * the library itself will not update the compiled
 * version in the cache.
 * This is why the xar will be installed instead
 */
function watchBuild () {
    watch('build/**/*', series(xar, installXar))
}

// construct the current xar name from available data
const packageName = () => `${existJSON.package.target}-${pkg.version}.xar`

/**
 * create XAR package in repo root
 */
function xar () {
    return src('build/**/*', {base: 'build'})
        .pipe(zip(packageName()))
        .pipe(dest('.'))
}

/**
 * upload and install the latest built XAR
 */
function installXar () {
    return src(packageName())
        .pipe(existClient.install({ packageUri }))
}

// composed tasks
const build = series(
    clean,
    templates,
    copyStatic,
    xar
)
const watchAll = parallel(
    watchStatic,
    watchTemplates,
    watchBuild
)

exports.build = build
exports.watch = watchAll

exports.xar = build
exports.install = series(build, installXar)

// main task for day to day development
exports.default = series(build, installXar, watchAll)
