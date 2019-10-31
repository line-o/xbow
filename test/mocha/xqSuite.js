'use strict'

const chai = require('chai')
const supertest = require('supertest')
const expect = require('chai').expect

// The client listening to the mock rest server
var client = supertest.agent('http://localhost:8080')

describe('xqSuite unit testing', function () {
  describe('rest api returns', function () {
    it('404 from random page', function (done) {
      this.timeout(10000)
      client
        .get('/random')
        .expect(404)
        .end(function (err, res) {
          expect(res.status).to.equal(404)
          if (err) return done(err)
          done()
        })
    })

    it('200 from default rest endpoint', function (done) {
      client
        .get('/exist/rest/db/')
        .expect(200)
        .end(function (err, res) {
          expect(res.status).to.equal(200)
          if (err) return done(err)
          done()
        })
    })

    it('200 from startpage (index.html)', function (done) {
      client
        .get('/exist/rest/db/no/xbow/index.html')
        .expect(200)
        .end(function (err, res) {
          expect(res.status).to.equal(200)
          if (err) return done(err)
          done()
        })
    })
  })

  // TODO: add authentication
  describe('running …', function () {
    this.timeout(1500)
    this.slow(500)

    const runner = '/exist/rest/db/no/xbow/content/test-runner.xq'

    it('returns 0 errors or failures', function (done) {
      client
        .get(runner)
        .set('Accept', 'application/json')
        .expect('content-type', 'application/json;charset=utf-8')
        .end(function (err, res) {
          try {
            console.group()
            console.group()
            console.group()
            console.info(res.body.testsuite.tests + ' xqsuite tests:')
            if (err) return done(err)
          } finally {
            console.group()
            res.body.testsuite.testcase.forEach(function (entry) {
              if (entry.failure) console.error([entry.name, entry.failure.message])
              else if (entry.error) console.error([entry.name, entry.error.message])
              else (console.log(entry.name))
            })
            console.groupEnd()
          }
          console.groupEnd()
          console.groupEnd()
          console.groupEnd()
          expect(res.body.testsuite.failures).to.equal('0')
          expect(res.body.testsuite.errors).to.equal('0')
          done()
        })
    })
  })
})
