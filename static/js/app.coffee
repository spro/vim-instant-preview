React = require 'react'
ReactDOM = require 'react-dom'
somata = require 'somata-socketio-client'
MarkdownIt = require 'markdown-it'
hljs = require 'highlight.js'

md = new MarkdownIt
    html: true
    linkify: true
    highlight: (str, lang) ->
        if lang and hljs.getLanguage(lang)
            try
                return hljs.highlight(lang, str).value
            catch err
                # Do nothing
        else
            return str
        return

getLitExtension = (filename) ->
    if match = filename.match /\.(\w+)\.lit$/
        return match[1]
    else if match = filename.match /\.lit\.(\w+)$/
        return match[1]
    else if match = filename.match /\.lit(\w+)/
        return match[1]

extensionToFiletype = (ext) ->
    switch ext
        when 'coffee'
            'coffeescript'
        else ext

transformLiterate = (ext, body) ->
    lines = body.split('\n')
    fixed_lines = []
    in_block = false
    li = 0
    while li < lines.length
        line = lines[li]
        if line.slice(0, 4) == '    '
            if !in_block
                in_block = true
                fixed_lines.push '```' + extensionToFiletype ext
            fixed_lines.push line.slice(4)
        else
            if in_block and line.length > 0
                in_block = false
                while fixed_lines.slice(-1)[0].length == 0
                    fixed_lines.pop()
                fixed_lines.push '```'
            fixed_lines.push line
        li++
    fixed_lines.join '\n'

niceFilename = (filename) ->
    filename = filename.replace /^\/home\/\w+/, '~'
    filename = filename.replace /^\/Users\/\w+/, '~'
    filename = filename.replace /^~\/Projects\//, ''
    return filename

App = React.createClass
    getInitialState: ->
        open: null
        files: {}

    componentDidMount: ->
        somata.remote$('vim-preview', 'getFiles')
            .onValue @gotFiles
        somata.subscribe$('vim-preview', 'update-contents')
            .onValue @gotContents

    gotFiles: (files) ->
        @setState {files}
        if !@state.open?
            open = Object.keys(files)[0]
            @setState {open}

    gotContents: ({filename, contents}) ->
        {files} = @state
        files[filename] = contents
        @gotFiles files

    openFilename: (open) ->
        @setState {open}

    closeFilename: (filename) ->
        {files} = @state
        delete files[filename]
        @setState {files}

    render: ->
        <div>
            <div className='tabs'>
                {Object.keys(@state.files).map (filename) =>
                    className = 'tab'
                    if filename == @state.open
                        className += ' open'
                    open = @openFilename.bind(null, filename)
                    close = @closeFilename.bind(null, filename)
                    <div className=className>
                        <a onClick=open className='filename'>{niceFilename filename}</a>
                        <a onClick=close className='close'>&times;</a>
                    </div>
                }
            </div>

            {if filename = @state.open
                contents = @state.files[filename]
                if filename.match /\.md$/
                    html = md.render contents
                    <div className='markdown-body' dangerouslySetInnerHTML={__html: html}></div>
                else if ext = getLitExtension filename
                    html = md.render transformLiterate ext, contents
                    <div className='markdown-body' dangerouslySetInnerHTML={__html: html}></div>
                else
                    <pre>{contents}</pre>
            }
        </div>

ReactDOM.render <App />, document.getElementById 'app'
