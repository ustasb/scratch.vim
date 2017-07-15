" File: scratch.vim
" Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
" Version: 1.1.1
" Last Modified: March 13, 2013
"
" Overview
" --------
" You can use the scratch plugin to create a temporary scratch buffer to store
" and edit text that will be discarded when you quit/exit vim. The contents
" of the scratch buffer are not saved/stored in a file.
"
" Installation
" ------------
" 1. Copy the scratch.vim plugin to the $HOME/.vim/plugin directory. Refer to
"    the following Vim help topics for more information about Vim plugins:
"
"       :help add-plugin
"       :help add-global-plugin
"       :help runtimepath
"
" 2. Restart Vim.
"
" Usage
" -----
" You can use the following command to open/edit the scratch buffer:
"
"       :Scratch
"
"To open the scratch buffer in a new horizontal split window, use the following command:
"
"      :Sscratch
"
"To open the scratch buffer in a new vertical split window, use the following command:
"
"      :Vscratch
"
"You can toggle the Scratch window using
"
"      :ScratchToggle
" When you close the scratch buffer window, the buffer will retain the
" contents. You can again edit the scratch buffer by openeing it using one of
" the above commands. There is no need to save the scatch buffer.
"
" When you quit/exit Vim, the contents of the scratch buffer will be lost.
" You will not be prompted to save the contents of the modified scratch
" buffer.
"
" You can have only one scratch buffer open in a single Vim instance. If the
" current buffer has unsaved modifications, then the scratch buffer will be
" opened in a new window
"
" ****************** Do not modify after this line ************************

if exists('loaded_scratch') || &cp
    finish
endif
let loaded_scratch=1

" Scratch buffer name
if !exists("g:ScratchFileName")
    let g:ScratchFileName = "~/scratch_file.txt"
endif

" Stolen from Steve Losh's Gundo source code:
" https://github.com/sjl/gundo.vim/blob/master/plugin/gundo.vim#L405
function! s:ScratchGoToWindowForBufferName(name)"{{{
    if bufwinnr(bufnr(a:name)) != -1
        exe bufwinnr(bufnr(a:name)) . "wincmd w"
        return 1
    else
        return 0
    endif
endfunction"}}}

" https://github.com/sjl/gundo.vim/blob/master/plugin/gundo.vim#L414
function! s:ScratchIsVisible()"{{{
    if bufwinnr(bufnr(g:ScratchFileName)) != -1
        return 1
    else
        return 0
    endif
endfunction"}}}

" https://github.com/sjl/gundo.vim/blob/master/plugin/gundo.vim#L605
function! s:ScratchToggle()"{{{
    if s:ScratchIsVisible()
        call s:ScratchClose()
    else
        call s:ScratchBufferOpen(1, 0)
    endif
endfunction"}}}

" https://github.com/sjl/gundo.vim/blob/master/plugin/gundo.vim#L585
function! s:ScratchClose()"{{{
    if s:ScratchGoToWindowForBufferName(g:ScratchFileName)
        execute ':w ' . g:ScratchFileName
        quit
    endif
endfunction"}}}

" ScratchBufferOpen
" Open the scratch buffer
function! s:ScratchBufferOpen(new_win,vertical_split)
    let split_win = a:new_win
    let vertical_split = a:vertical_split

    " If the current buffer is modified then open the scratch buffer in a new
    " window
    if !split_win && &modified
        let split_win = 1
    endif

    " Check whether the scratch buffer is already created
    let scr_bufnum = bufnr(g:ScratchFileName)
    if scr_bufnum == -1
        " open a new scratch buffer
        if split_win
            if vertical_split
                exe "vnew " . g:ScratchFileName
            else
                exe "new " . g:ScratchFileName
            endif
        else
            exe "edit " . g:ScratchFileName
        endif
    else
        " Scratch buffer is already created. Check whether it is open
        " in one of the windows
        let scr_winnum = bufwinnr(scr_bufnum)
        if scr_winnum != -1
            " Jump to the window which has the scratch buffer if we are not
            " already in that window
            if winnr() != scr_winnum
                exe scr_winnum . "wincmd w"
            endif
        else
            " Create a new scratch buffer
            if split_win
                if vertical_split
                    exe "vsplit +buffer" . scr_bufnum
                else
                    exe "split +buffer" . scr_bufnum
                endif
            else
                exe "buffer " . scr_bufnum
            endif
        endif
    endif
endfunction

" Command to edit the scratch buffer in the current window
command! -nargs=0 Scratch call s:ScratchBufferOpen(0,0)
" Command to open the scratch buffer in a new horizontal split window
command! -nargs=0 Sscratch call s:ScratchBufferOpen(1,0)
" Command to open the scratch buffer in a new vertical split window
command! -nargs=0 Vscratch call s:ScratchBufferOpen(1,1)
command! -nargs=0 ScratchToggle call s:ScratchToggle()
