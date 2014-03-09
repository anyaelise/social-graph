fs = require('fs')

class Parser 
    constructor: (@filename) ->

    parse: ->
        stream = fs.createReadStream @filename
        stream.setEncoding 'utf-8'
    
        stream.on 'data', (chunk) ->
            console.log 'got %d bytes of data', chunk.length
            console.log 'first character as follows: '
            console.log chunk[0]

        stream.on 'end', ->
            console.log "Finished reading chunks!"

testParser = new Parser('data.json')
testParser.parse()