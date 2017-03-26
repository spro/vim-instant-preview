polar = require 'somata-socketio'
app = polar port: 8766
app.get '/', (req, res) -> res.render 'index'
app.start()
