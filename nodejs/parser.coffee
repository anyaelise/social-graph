data = require('./data.json')
http = require('http')

friends = {}
locations = {}

# Create nodes
for key, value of data
    friends[value.id] = value.friends
    delete value.friends

    val = JSON.stringify value

    headers = {
        'Content-Type': 'application/json',
        'Content-Length': val.length
    }

    options = {
      host: 'localhost',
      port: 7474,
      path: '/db/data/node',
      method: 'POST',
      headers: headers
    }

    req = http.request options, (res) ->
        console.log 'STATUS: ' + res.statusCode
        console.log 'HEADERS: ' + JSON.stringify res.headers

        body = ""
        res.setEncoding 'utf-8'

        res.on 'data', (chunk) ->
            body += chunk

        res.on 'end', ->
            ret_data = JSON.parse(body)
            locations[ret_data.data.id] = res.headers.location
            if Object.keys(locations).length == Object.keys(data).length
                process_rels()

    req.on 'error', (e) ->
        console.log "Error! " + e.message

    req.write val
    req.end

#Create relationships
process_rels = ->
    for key1, personObj of data
        for key2, friendID of friends[personObj.id]
            #console.log "current person: " + personObj.id
            #console.log "current friend: " + friendID
            rel = {
                "to": locations[friendID],
                "type": "FRIENDS"
            }
            val = JSON.stringify rel
            #console.log val

            headers = {
                'Content-Type': 'application/json',
                'Content-Length': val.length
            }
            loc = locations[personObj.id]
            path = loc.slice(21) + '/relationships'

            options = {
              host: 'localhost',
              port: 7474,
              path: path,
              method: 'POST',
              headers: headers
            }
            console.log options

            req = http.request options, (res) ->
                console.log 'STATUS: ' + res.statusCode
                console.log 'HEADERS: ' + JSON.stringify res.headers
                res.setEncoding 'utf-8'

                res.on 'data', (chunk) ->
                    console.log 'BODY:' + chunk

            req.on 'error', (e) ->
                console.log "Error! " + e.message

            req.write val
            req.end
        