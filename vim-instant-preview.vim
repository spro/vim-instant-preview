" Vim Instant Preview
" https://github.com/spro/vim-instant-preview
" ----------------------------------------------------------------------------------------

function PreviewOpenChannel()
    let g:preview_ch_handle = ch_open('localhost:8765')
endfunction

function PreviewMaybeOpenChannel()
    if !exists("g:preview_ch_handle")
        call PreviewOpenChannel()
    elseif ch_status(g:preview_ch_handle) != "open"
        call PreviewOpenChannel()
    endif
endfunction

function PreviewSendContents()
    call PreviewMaybeOpenChannel()
    let filename = expand('%:p')
    let contents = join(getline(1, '$'), "\n")
    let response = ch_sendexpr(g:preview_ch_handle, filename . "\n" . contents)
endfunction

function PreviewStart()
    autocmd! * <buffer>
    autocmd BufEnter <buffer> call PreviewSendContents()
    autocmd TextChanged <buffer> call PreviewSendContents()
    autocmd TextChangedI <buffer> call PreviewSendContents()
    call PreviewSendContents()
endfunction

