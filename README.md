# vim-instant-preview

A vim plugin and Node.js server for instantly previewing file transformations in the browser (as you type).

Useful for:

* Markdown or LaTeX editing
* Literate programming

vim-instant-preview was 100% inspired by [suan's vim-instant-markdown](https://github.com/suan/vim-instant-markdown), with some key differences:

* Using new Vim 8 channels
* Filetype specific transformation
* Tabs to switch between buffers in the browser

![](https://i.imgur.com/N9VSztc.png)

## Dependencies

* Vim 8 for asynchronous channels
* Node.js and CoffeeScript
* ZeroMQ for Somata (see https://github.com/somata/somata-node#installation)

## Installation

* Install dependencies
* `npm install`
* Add the contents of [`vim-instant-preview.vim`](https://github.com/spro/vim-instant-preview/blob/master/vim-instant-preview.vim) to your Vim bundles or `vimrc`
* Optionally add a shortcut to start preview mode with the `PreviewStart` function:

```vim
nnoremap <leader>p :call PreviewStart()<CR>
```

## Usage

* `coffee service.coffee` to start the TCP server that Vim talks to, wrapped as a Somata service.
* `coffee server.coffee` to start the web server with Socket.io

Open a file in vim, `:call PreviewStart()`, and open http://localhost:8766/ to see your previews.
