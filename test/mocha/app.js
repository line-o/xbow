'use strict'

const chai = require('chai')
const chaiXml = require('chai-xml')
const expect = require('chai').expect
const fs = require('fs-extra')
const glob = require('glob')
const xmldoc = require('xmldoc')
const assert = require('yeoman-assert')

// this is not equivalent ot using a real xml parser
describe('consistency checks', function () {
  describe('existing markup files are well-formed', function () {
    chai.use(chaiXml)
    it('*.html is xhtml', function (done) {
      glob('**/*.html', { ignore: 'node_modules/**' }, function (err, files) {
        if (err) throw err
        // console.log(files)
        files.forEach(function (html) {
          const xhtml = fs.readFileSync(html, 'utf8')
          var hParsed = new xmldoc.XmlDocument(xhtml).toString()
          expect(hParsed).xml.to.be.valid()
        })
      })
      done()
    })

    it('*.xml', function (done) {
      glob('**/*.xml', { ignore: 'node_modules/**' }, function (err, files) {
        if (err) throw err
        // console.log(files)
        files.forEach(function (xmls) {
          const xml = fs.readFileSync(xmls, 'utf8')
          var xParsed = new xmldoc.XmlDocument(xml).toString()
          expect(xParsed).xml.to.be.valid()
        })
      })
      done()
    })

    it('*.xconf', function (done) {
      glob('**/*.xconf', { ignore: 'node_modules/**' }, function (err, files) {
        if (err) throw err
        // console.log(files)
        files.forEach(function (xconfs) {
          const xconf = fs.readFileSync(xconfs, 'utf8')
          var cParsed = new xmldoc.XmlDocument(xconf).toString()
          expect(cParsed).xml.to.be.valid()
        })
      })
      done()
    })
    it('*.odd', function (done) {
      this.slow(1000)
      glob('**/*.odd', { ignore: 'node_modules/**' }, function (err, files) {
        if (err) throw err
        // console.log(files)
        files.forEach(function (odds) {
          const odd = fs.readFileSync(odds, 'utf8')
          var xParsed = new xmldoc.XmlDocument(odd).toString()
          expect(xParsed).xml.to.be.valid()
        })
      })
      done()
    })
  })

  describe('meta-data consistency', function () {
    it('description is consistent', function (done) {
      if (fs.existsSync('build.xml')) {
        const build = fs.readFileSync('build.xml', 'utf8')
        const parsed = new xmldoc.XmlDocument(build)
        var buildDesc = parsed.childNamed('description').val
      }

      if (fs.existsSync('package.json')) {
        const pkg = fs.readFileSync('package.json', 'utf8')
        const parsed = JSON.parse(pkg)
        var pkgDesc = parsed.description
      }

      if (fs.existsSync('repo.xml')) {
        const repo = fs.readFileSync('repo.xml', 'utf8')
        const parsed = new xmldoc.XmlDocument(repo)
        var repoDesc = parsed.childNamed('description').val
      }

      if (fs.existsSync('expath-pkg.xml')) {
        const exPkg = fs.readFileSync('expath-pkg.xml', 'utf8')
        const parsed = new xmldoc.XmlDocument(exPkg)
        var exPkgDesc = parsed.childNamed('title').val
      }

      var desc = [exPkgDesc, buildDesc, pkgDesc, repoDesc, buildDesc].filter(Boolean)
      var i = 0
      // console.log(desc)
      desc.forEach(function () {
        expect(desc[i]).to.equal(exPkgDesc)
        i++
      })
      done()
    })

    it('version string is consistent', function (done) {
      if (fs.existsSync('package.json')) {
        const pkg = fs.readFileSync('package.json', 'utf8')
        const parsed = JSON.parse(pkg)
        var pkgVer = parsed.version
      }

      if (fs.existsSync('expath-pkg.xml')) {
        const exPkg = fs.readFileSync('expath-pkg.xml', 'utf8')
        const parsed = new xmldoc.XmlDocument(exPkg)
        var exPkgVer = parsed.attr.version
      }

      var vers = [exPkgVer, pkgVer].filter(Boolean)
      var i = 0
      // console.log(vers)
      vers.forEach(function () {
        expect(vers[i]).to.equal(exPkgVer)
        i++
      })
      done()
    })

    it('title is consistent', function (done) {
      if (fs.existsSync('build.xml')) {
        const build = fs.readFileSync('build.xml', 'utf8')
        const parsed = new xmldoc.XmlDocument(build)
        var buildTit = parsed.attr.name.toLowerCase()
      }

      if (fs.existsSync('package.json')) {
        const pkg = fs.readFileSync('package.json', 'utf8')
        const parsed = JSON.parse(pkg)
        var pkgTitle = parsed.name
      }

      if (fs.existsSync('templates/page.html')) {
        const page = fs.readFileSync('templates/page.html', 'utf8')
        const parsed = new xmldoc.XmlDocument(page)
        var pageTitle = parsed.descendantWithPath('head.title').val
      }

      var titles = [buildTit, pkgTitle, pageTitle].filter(Boolean)
      var i = 0

      // console.log(titles)
      titles.forEach(function () {
        expect(titles[i]).to.equal(pkgTitle)
        i++
      })
      done()
    })

    it('Readme is consistent with meta-data', function (done) {
      const pkg = fs.readFileSync('package.json', 'utf8')
      const parsed = JSON.parse(pkg)

      if (fs.existsSync('README.md')) {
        assert.fileContent('README.md', '# ' + parsed.name)
        assert.fileContent('README.md', parsed.version)
        assert.fileContent('README.md', parsed.description)
      } else { this.skip() }
      done()
    })
  })
})
