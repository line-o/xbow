/**
 * an example gulpfile to make ant-less existdb package builds a reality
 */
const { src, dest, watch, series, parallel } = require('gulp')
const { createClient } = require('@existdb/gulp-exist')
const rename = require('gulp-rename')
const zip = require("gulp-zip")
const replace = require('@existdb/gulp-replace-tmpl')
const del = require('delete')

// read metadata from package.json and .existdb.json
const { version, license } = require('./package.json')
const { package, servers } = require('./.existdb.json')

// .tmpl replacements to include 
// first value wins
const replacements = [package, {version, license}]

const serverInfo = servers.localhost
const { port, hostname } = new URL(serverInfo.server)
const connectionOptions = {
    basic_auth: {
        user: serverInfo.user, 
        pass: serverInfo.password
    },
    host: hostname,
    port
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
 * replace placeholders 
 * in src/*.xml.tmpl and 
 * output to build/*.xml
 */
function templates() {
    return src('src/*.tmpl')
        .pipe(replace(replacements, {}))
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
const packageName = () => `${package.target}-${version}.xar`

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
        .pipe(existClient.install({ packageUri: package.namespace }))
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
