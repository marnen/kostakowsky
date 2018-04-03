module.exports =
  files:
    javascripts: {}
  paths:
    public: '.tmp/dist'
    watched: ['source/javascripts']
  plugins:
    copycat:
      'abcjs': 'node_modules/abcjs/bin/abcjs_plugin_4.0.1-min.js'
