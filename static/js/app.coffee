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

    render: ->
        <div>
            <div className='tabs'>
                {Object.keys(@state.files).map (filename) =>
                    className = 'filename tab'
                    if filename == @state.open
                        className += ' open'
                    open = @openFilename.bind(null, filename)
                    <a onClick=open className=className><span>{niceFilename filename}</span></a>
                }
            </div>

            {if filename = @state.open
                contents = @state.files[filename]
                if filename.match /\.md$/
                    html = md.render contents
                    <div className='markdown-body' dangerouslySetInnerHTML={__html: html}></div>
                else
                    <pre>{contents}</pre>
            }
        </div>

ReactDOM.render <App />, document.getElementById 'app'
