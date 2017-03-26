net = require 'net'
somata = require 'somata'

PORT = 8765
HOST = '127.0.0.1'

# Keep track of files for when a new client joins

files = {}
getFiles = (cb) ->
    cb null, files

service = new somata.Service 'vim-preview', {getFiles}

# Create TCP server for vim to communicate with

server = net.createServer (socket) ->
    socket_id = Math.floor(Math.random() * 1000) # Just for reference
    console.log "<#{socket_id}> Connected"

    socket.on 'close', ->
        console.log "<#{socket_id}> Closed"

    socket.on 'error', (err) ->
        console.log "<#{socket_id}> Error:", err

    data = ''

    socket.on 'data', (chunk) ->
        data += chunk.toString()

        if data.slice(-1)[0] == '\n'

            [n, message] = JSON.parse data
            # console.log "<#{socket_id}> Message (#{n})"

            if n >= 0 # Negative numbers are used for "expr" responses
                socket.write JSON.stringify [n, 'ok']
                lines = message.split('\n')
                filename = lines[0]
                contents = lines.slice(1).join('\n')
                files[filename] = contents
                service.publish 'update-contents', {filename, contents}

            data = ''

server.listen PORT, HOST
