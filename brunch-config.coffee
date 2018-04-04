module.exports =
  files:
    javascripts: {joinTo: 'site.js'}
  paths:
    public: '.tmp/dist'
    watched: ['source/javascripts']
  modules:
    autoRequire:
      'site.js': ['source/javascripts/site.js']
