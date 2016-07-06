helpers = null

module.exports =
  config:
    stanzaExecutablePath:
      type: 'string'
      default: 'stanza'

  activate: ->
    require('atom-package-deps').install('linter-stanza')

  provideLinter: ->
    provider =
      name: 'stanza'
      grammarScopes: ['source.stanza']
      scope: 'file'
      lintOnFly: true
      lint: (textEditor) ->
        helpers ?= require('atom-linter')
        fpath = textEditor.getPath()
        stzExec = atom.config.get('linter-stanza.stanzaExecutablePath')
        return helpers.exec(stzExec, ["check", fpath], {ignoreExitCode: true})
          .then (result) ->
            toReturn = []
            regex = /([\w\/\.\-]+):(\d+)\.(\d+):(.+)(?: Possibilities are:)?/g
            while (match = regex.exec(result)) isnt null
              file = match[1] or fpath
              line = parseInt(match[2]) or 0
              col = parseInt(match[3]) or 0
              toReturn.push({
                type: 'Error'
                text: match[4]
                filePath: file
                range: [[line - 1, col], [line - 1, col + 1]]
              })
            return toReturn
