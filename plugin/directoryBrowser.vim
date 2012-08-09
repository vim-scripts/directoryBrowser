" ------------------------------------------------------------------------------
" File: plugin/directoryBrowser.vim - Directory Browser - 
"			  Directory listing and file operation in vim
" Author: Alexandre Viau <alexandreviau@gmail.com>
" Maintainer: Alexandre Viau <alexandreviau@gmail.com>
"
" Licence: This program is free software; you can redistribute it and/or
"		modify it under the terms of the GNU General Public License.
"		See http://www.gnu.org/copyleft/gpl.txt
"		This program is distributed in the hope that it will be
"		useful, but WITHOUT ANY WARRANTY; without even the implied
"		warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
"
" Version: 1.0
"
" Files: plugin/directoryBrowser.vim	
"
" History:
" 1.0   2012-08-04
"		First release
"
" Overview
" --------
" The dir plugin allows fast directory browsing inside vim buffers, 
" split windows or tabs. It uses the windows dir command to list
" directories inside buffers and it provides several commands
" to be executed on the listed files or directories including
" dir listing, sorting, filtering, recursive file searching, 
" recursive file greping, file renaming, file deleting,
" file cloning, file executing and file opening/editing in buffer, 
" tab, window and external tools.
"
" The way it works is simple. It insert the output of the windows dir
" command at the end of a buffer and then after the user has moved
" the cursor to one of the lines of this directory listing and
" executes one of the pre-defined (or user defined) command mappings, 
" the path of the directory and the name of the file/directory are 
"copied to some registers and are used to execute the command on the 
" file or directory.
"
" For example if the command mapping \c is executed the directory of
" c:\ is listed at the end of a new tab (every drive may be accessed
" using \a, \b, \c, ..., \z).
"
"  Volume in drive C has no label.
"  Volume Serial Number is C0B2-2A46
" 
"  Directory of c:\
" 
" 2013-05-08  22:01       <DIR>          .vim-fuf-data
" 2012-07-10  23:22       <DIR>          clip
" 2012-07-23  06:36       <DIR>          cygwin
" 2012-07-31  12:29       <DIR>          Documents and Settings
" 2012-08-01  04:27       <DIR>          oraclexe
" 2012-07-31  12:27       <DIR>          Program Files
" 2012-08-02  10:32       <DIR>          repository
" 2012-08-02  01:58       <DIR>          temp
" 2012-07-08  23:24       <DIR>          test
" 2012-08-03  23:31       <DIR>          tmp
" 2012-08-02  08:01       <DIR>          WINNT
" 2012-08-04  09:11               27ÿ396 _viminfo
" 2012-07-07  00:46                  128 test.ctl
" 2012-07-07  00:45                   94 test.sql
" 2012-07-26  00:05                   74 test.txt
"               10 File(s)         95ÿ932 bytes
"               12 Dir(s)   2ÿ694ÿ692ÿ864 bytes free
"
" If the user moves the cursor on the "Program Files" for example,
" and presses <space>l, the content of the "Program Files"
" directory will be listed in this same buffer after this listing 
" of the c:\ directory. The listing of the "Program Files"
" directory will be positionned correctly at the top of the screen
" so the content of the c:\ will not be seed anymore unless the
" user moves the cursor upwards outside of the current screen. If
" The user presses then <space>h the directory will go one level
" up the directory tree back to the c:\ directory. 
"
" So all the commands are executed on the line where the cursor is 
" positionned to. Many commands are already available to be
" be executed on the directories or files where the cursor is 
" positionned to, and also the users may add some to their
" owned vimrc file like this user defined command for example here
" below which sends the current file where the cursor is positionned 
" to an external tool:
"
" nmap <space>u :call g:copyPath() \| silent exe '!start I:\data\AutoHotkey\repository_usb_only\repository.exe "' . @p . @f . '"'<cr>
"
" This mapping is in my vimrc and not in the plugin because it is
" a tool that is used only by myself. Here the g:copyPath() function
" will take care to copy the path of the current file to the registers
" @p, which contains the path, and @f which contains the filename, then
" then the external command is executed on this path. So many of the
" commands work this way.
"
" The movements between directories happen quite fast.
" The dir command was used because it performed faster on the test
" computer than the cygwin ls command. So portability was somehow
" sacrificed for performance. But it would be easy to adapt this
" plugin to make it work with the ls command on linux if the
" dir command is not available. 
"
" This plugin was not tested on another platform than windows 2000.
" The language of the operating system were it was tested is english.
" If another language is used the variable s:dirOfStr should be
" modify according to your language. 
"
" Note that when the g:dir or its variants g:dirTab, g:dirSplit etc
" are executed, the encoding is changed so that the dir command output
" is displayed correctly. The encoding is changed with the following command
" set encoding=cp850 " DOS 850: Western European
" You may change this encoding or remove/comment the command if you 
" don't want your encoding to be changed each time a dir command is issued.
"
" Installation
" ------------
" Copy the directoryBrowser.vim file to the vim plugin directory and restart vim,
" or open directoryBrowser.vim for editing and do :so %.
"
" Optionnaly install the utl.vim plugin developed by Stephan Bittner,
" which add text hyperlinking habilities. Used with this directoryBrowser.vim plugin, 
" it will allow to jump to the files hyperlinked in the results of
" the grep and find commands as well as the buffer listing commands. 
"
" Usage 
" -----
" Note that any mappings may be changed. If you don't like the usage of <space> or \ before some commands you may change this easily.
"
" \a to \z      list a:\ to z:\ root directories in a new tab
" \A to \Z      list a:\ to z:\ root directories in a split window
" <space><esc>  execute command on the vim command line (fast if escape remapped to capslock)
" <space><f3>   search files (including in subdirectories). Cygwin should be installed for this command to work.
" <space><f4>   grep files (including in subdirectories). Cygwin should be installed for this command to work. It will ask for keywords to search and a file filter by which by default is *.
" <space>1      sort directory by name ascending
" <space>2      sort directory by name descending
" <space>3      sort directory by type ascending
" <space>4      sort directory by type descending
" <space>5      sort directory by size ascending
" <space>6      sort directory by size descending
" <space>7      sort directory by date ascending
" <space>8      sort directory by date descending
" <space>.      reload directory
" <space>a      write manually a path to open (windows explorer address bar like)
" <space>b      list buffers to open (not related to directory browsing but useful. Requires utl.vim)
" <space>B      list buffers to delete (not related to directory browsing but useful. Requires utl.vim)
" <space>c      duplicate (clone) file
" <space>C      open current directory in command prompt
" <space>d      new directory
" <space>D      delete file or directory
" <space>e      open file in current buffer
" <space>f      Set filter to show only certain files example: *.txt or pic*.jpg
" <space>g      grep current file (file is opened inside vim and vimgrep is used. No need for cygwin here.)
" <space>h      go up a directory
" <space>i      go to previous dir listing (if many listings were done in the same buffer it allows to go directly back to a previous listing)
" <space>j      preview file (rapidly includes the file into the current buffer. Do <space>k to remove the file and go to next file in the dir listing. Doing successively <space>j and <space>k allows to preview quickly one file after another.) 
" <space>k      used with preview file to remove the preview and go down one line to next file to preview
" <space>l      list directory (go inside a directory)
" <space>m      go to next dir listing (if many listings were done in the same buffer it allows to go directly to the next listing)
" <space>n      open file in notepad
" <space>N      new file
" <space>o      open list dir pointed to by a windows .lnk file (dosen't work for all .lnk to directory files, to improve)
" <space>p      copy file path and name. The path is copied in several formats to different registers. Registers where chosen instead of variables because the path can then be pasted. Often the paths needs to be pasted to files for linking or documentation etc.
"                  1- in @p (directory only) with \
"                  2- in @* (directory and filename) with \ 
"                  3- in @z (directory only) with /
"                  4- in @x (directory and filename) with /
"                  5- in @f (filename only)
" <space>P      show current path
" <space>r      run file
" <space>R      rename file or directory
" <space>s      open file in split
" <space>S      list current directory in a split window (no need to have already a directory browser opened)
" <space>t      open file in tab
" <space>T      list current directory in a tab (no need to have already a directory browser opened) 
" <space>v      open file in vsplit
" <space>V      list current directory in a vsplit window (no need to have already a directory browser opened) 
" <space>w      write listing to disk
" <space>x      open current directory in windows explorer
"
" NOTE: To make quick bookmarks to files and directories, use vim usual marks with m and ' or ` (:help marks) to points to files and directories in a dir listing since these are buffers and files if written to disk. Use <space>w to write a listing to disk. Since the dir listings are files, they can be edited and annoted like any files.
"
" I added at the end of the plugin "Commands shortcuts" that can be used to assosiate words to commands using the dictionary g:cmdDict like so for example:
" let g:cmdDict = {
"     \ 'backup' : '!start z:/vifm/runtime/commands/Backup.bat',
"     \ 'bin' : 'call g:dirTab("c:/cygwin/bin")',
"     \ 'cv' : 'tabe Z:/data/travail/Alexandre_Viau_resume_en.html',
"     \ 'test' : 'echo "allo"',
"     \ 'cmdutils' : 'call g:dirTab("z:/apps/portable/cmdutils")',
"     \ 'commands' : 'call g:dirTab("z:/vifm/runtime/commands")',
"     \ 'menu' : 'tabe i:/data/Scripts/vim/m',
"     \ 'notes' : 'call g:dirTab("i:/data/notes")',
" \}
" If example the user does <space>; and enters the word "backup" the backup is started. This may be
" not directly related to directory browsing but I find it useful if one has many directories, he may associate words
" to these directories for example to do <space>; and write the word "notes" will run the command g:dirTab("i:/data/notes") to list the directory i:/data/notes using this plugin.
"
" The functions in this plugin may be used in other scripts, plugins or vimrc, especially the g:dirTab, g:dirSplit and other variants, or the g:copyPath function. The global variables g:dirSort or g:dirFilter may also be used in scripts. A example of the g:copyPath function was given in the overview section above. Another example here is with the use of the utl.vim plugin which I use. The function g:dirSplit is used inside a url to open a directory by clicking the link or doing the command :Utl ol (or the corresponding mapping):
" <url:vimscript:call g:dirSplit('I:/data/scripts/Vim/')>
" To see only the .vim files from that directory and sort the directory by date descending do:
" <url:vimscript:let g:dirFilter = '*.vim' \| let g:dirSort = '/o:g-d' \| call g:dirSplit('I:/data/scripts/Vim/')>
"
" Where ever the functions are used, in scripts, vimrc mappings, command line or utl urls, they will behave the same and list the directories or copy the paths or else depending on the functions.
"
" Configuration
" -------------
" By changing the following variables you can configure the behavior of this
" plugin. Set the following variables in your .vimrc file using the 'let'
" command.
"
" A needed search string in the dir listing, if the system is in another language, change this string, do a dir command to see the string that appears before the path of the directory listed and change the string here to that string.
" Example: Directory of C:\temp
" let g:dirOfStr = 'Directory of'

" Default sorting
" let g:dirSort = '/o:gn'

" Default filter (all files)
" let dirFilter = '*.*'
" 
" Examples
" --------
"
" - If you write this on the command line it will list the "program files" directory in a new tab
" :call g:dirTab("c:/program files")
"
" - If you write this on the command line it will list the "program files" directory in a horizontal split window
" :call g:dirSplit("c:/program files")
"
" - If you write this on the command line it will list the "program files" directory in a vertical split window
" :call g:dirVSplit("c:/program files")
"
" - If you write this on the command line it will list the "program files" directory in a new buffer in the same tab
" :call g:dirBuf("c:/program files")
"
" - If you write this on the command line it will list the "program files" directory as appended text at the end of the current buffer
" :call g:dir("c:/program files")
"
" - All these commands may be used with mappings like for example:
" nmap \s :call g:dirVSplit("c:/program files")
" Then press \ and then s to execute the command.
"
" - Do \c to list the c:\ directory in a new buffer, or \D to list the d:\ etc. All alphabet letters are "pre-mapped" this way. You may change them to capital letters if they conflict with your current mappings.
"
" - Do \C to list the c:\ directory in a split window, or \D to list the d:\ etc.
"
" - Do <space>a write a path like c:/temp (or c:\temp). This mappings makes it possible to type in paths.
"
" - Do <space>f and write *.txt to see only the *.txt files and do again <space>f and write *.* to see all files.
"
" - Do <space>7 to sort by date
"
" Todo:
" - Maybe not have always paths copied to clipboard...use variables and copy to clipboard when needed only
" - Maybe to make is work with the ls command under linux.
" - peut-etre ajouter un hash table qui contiendrait des mots-cles/Paths et qui permettrait par exemple d'ecrire cmdutils et ca changerait vers le path z:\apps\portables\cmdutils
" - ajouter liste des volumes (disks) je ne sais pas la commande
" - peut-etre permettre d'entrer une partie seulement des commands dans le dictionnaire et que ca va trouver la commande quand meme
" - In another version of the plugin, do <space>m to mark the current file with an * (in copyfile add also the copy of the line number in the register @n), and in the function that will mark a file, will with the line number add the * and all the commands line delete, clone etc will be inside new functions. And when a mark * is done on a file with <space>m the file path will be added to an list (array) and all these commands (delete, run, clone, etc) will be executed in a loop on all the files in the list (array)
" - ajouter /A:H pour voir les hidden files, mais lorsque les hidden files sont affiches on voit pas les autres fichier...essayer de tout afficher en meme temps
" - ajouter copie d'un fichier: copypath et apres dans le rep dest mettre @f et @p dans variables temp f et p et faire un autre copy path et ensuite faire la commande de copie. Pour un move faire meme chose mais faire un delete des fichier source (variable p et f) apres.
" - conserver les repertoire recemment browser dans un tableau
" - put the encoding as a global variable
"
" ------------------------------------------------------------------------------

" Variables

" A needed search string in the dir listing, if the system is in another language, change this string, do a dir command to see the string that appears before the path of the directory listed and change the string here to that string.
" Example: Directory of C:\temp
let g:dirOfStr = 'Directory of'

" Default sorting
let g:dirSort = '/o:gn'

" Default filter (all files)
let dirFilter = '*.*'

" Command shortcuts (Optional. This dictionnary g:cmdDict may be moved to your vimrc and may contain the commands you want. It is used with the g:cmdExe function and the mapping <space>; and it is not absolutly part of this plugin. I put it inside the plugin because it may be a fast way to open directories)
let g:cmdDict = {
    \ 'backup' : '!start z:/vifm/runtime/commands/Backup.bat',
    \ 'bin' : 'call g:dirTab("c:/cygwin/bin")',
    \ 'cv' : 'tabe Z:/data/travail/Alexandre_Viau_resume_en.html',
    \ 'test' : 'echo "allo"',
    \ 'cmdutils' : 'call g:dirTab("z:/apps/portable/cmdutils")',
    \ 'commands' : 'call g:dirTab("z:/vifm/runtime/commands")',
    \ 'menu' : 'tabe i:/data/Scripts/vim/m',
    \ 'notes' : 'call g:dirTab("i:/data/notes")',
\}

" Mappings

" execute command on the vim command line (fast if escape remapped to capslock)
nmap <space><esc> :exe 'normal G' \| :r! 

" search files
nmap <space><f3> :call g:dirFind()<cr>

" grep files
nmap <space><f4> :call g:dirGrep()<cr>

" reload directory
nmap <space>. :call g:copyPath() \| call g:dir(@p)<cr>

" write path to open (windows explorer address bar like)
nmap <space>a :unlet! p \| let p = input('path: ', '') \| call g:dirTab(p)<cr>

 " list buffers to open (not related to directory browsing but useful. Requires utl.vim)
nmap <space>b :call g:listBuffers('b!')<cr>

 " list buffers to delete (not related to directory browsing but useful. Requires utl.vim)
nmap <space>B :call g:listBuffers('bd!')<cr>

" duplicate (clone) file
nmap <space>c :call g:copyPath() \| exe '!copy ' @p . @f . ' ' @p . @f . '_' . substitute(strftime('%x_%X'), ':', '-', 'g') \| call g:dir(@p)<cr>

" open directory in command prompt
nmap <space>C :call g:copyPath() \| silent exe '!start cmd /k "dir /o:g ' . @p . '"'<cr>

" new directory
nmap <space>d :unlet! t \| let t = input('Directory name: ') \| :call g:copyPath() \| call mkdir(t) \| call g:dir(@p)<cr>

" delete file or directory
nmap <space>D :call g:dirDelete()<cr>

" open file in buffer
nmap <space>e :call g:copyPath() \| exe 'e! ' . @p . @f<cr>

" Set filter to show only certain files
nmap <space>f :call g:copyPath() \| let dirFilter = input('filter: ', '*.') \| call g:dir(@p)<cr>

" grep file
nmap <space>g :call g:copyPath() \| exe 'tabe ' . @p . @f \| exe 'vimgrep ' . input('grep current file keywords: ') . ' %' \| exe 'copen'<cr>

" up directory
nmap <space>h :call g:copyPath() \| call g:dir(@p . '..')<cr>

" go to previous dir listing 
nmap <space>i :exe 'normal k' \| call search(g:dirOfStr, 'b')<cr> 

" preview file (include the file and undo "u" (or <space>k to remove it) (useful also to view content of lnk files and copy their target)
nmap <space>j :call g:copyPath() \| exe 'normal zt' \| exe 'r ' . @p . @f<cr>

" used with preview file to remove the preview and go down one line to next file to preview
nmap <space>k :exe 'normal uj'<cr>

" list directory (go inside subdir)
nmap <space>l :call g:copyPath() \| call g:dir(@p . @f)<cr>

" go to next dir listing 
nmap <space>m :call search(g:dirOfStr)<cr> 

" open file in notepad
nmap <space>n :call g:copyPath() \| silent exe '!start notepad "' . @p . @f . '"'<cr>

" new file
nmap <space>N :enew!<cr>

" open list dir using a lnk file (dosen't work for all lnk to directory files, to improve)
nmap <space>o :call g:copyPathLnk() \| call g:dir(@*)<cr>

" copy file path
nmap <space>p :call g:copyPath()<cr> 

" show path
nmap <space>P :pwd<cr> 

" run file
nmap <space>r :call g:copyPath() \| silent exe '!start cmd /c "' . @p . @f . '"'<cr>

" rename file or directory
nmap <space>R :call g:copyPath() \| exe 'call rename("' . @f . '","' . input('rename to: ', @f) . '")' \| call g:dir(@p)<cr>

" open file in split
nmap <space>s :call g:copyPath() \| exe 'split \| enew \| e ' . @p . @f<cr>

" list directory in a split window
nmap <space>S :call g:copyPath() \| exe 'split \| enew' \| call g:dir(@p)<cr>

" open file in tab
nmap <space>t :call g:copyPath() \| exe 'tabe ' . @p . @f<cr>

" open file in vsplit
nmap <space>v :call g:copyPath() \| exe 'vsplit \| enew \| e ' . @p . @f<cr>

" list current directory in a vsplit window
nmap <space>V :call g:copyPath() \| exe 'vsplit \| enew' \| call g:dir(@p)<cr>

" write listing to disk
nmap <space>w :exe 'w! ' . input('directory listing name: ', 'c:/dirlist_')<cr>

" open current directory in windows explorer
nmap <space>x :call g:copyPath() \| silent exe '!start explorer "' . @p . '"'<cr>

" to copy a path (4 paths format) 
" 1- in @p (directory only) with \
" 2- in @* (directory and filename) with \ 
" 3- in @z (directory only) with /
" 4- in @x (directory and filename) with /
" 5- in @f (filename only)
function! g:copyPath()
    exe 'normal mf039l"fy$' 
    call search(g:dirOfStr, 'b') 
    exe 'normal 2w"py$`f' 
    " with \
    let @p = @p . '\'
    let @p = substitute(@p, '\\\\', '\\', '')
    let @* = @p . @f 
    " with \\
    let @c = substitute(@p, '\\', '\\\\', 'g')
    let @v = @c . @f
    " with /
    let @z = substitute(@p, '\\', '/', 'g')
    let @x = @z . @f
endfunction

" to copy the path from a lnk (shortcut) file to a directory (the lnk path is copied to the @* register)
function! g:copyPathLnk()
    call g:copyPath()
    exe 'r ' . @p . @f
    exe 'normal V'
    " remove null characters
    exe 's/\%x00//g'
    exe 'normal V$'
    call search('\.\\', 'b')
    call search('\.\.\\', 'b')
    exe 'normal hDF:h"*y$u'
    "NOTE: seach how to remove this message other than to write the file to disk
        "write! c:/t " write to remove message of line less after undo of r! type
        "use autocmd maybe to remove this message
endfunction

" to list directories (in tab or not)
function! g:dirTab(path)
    tabe!
    call g:dir(a:path)
endfunction

function! g:dirSplit(path)
    split
    enew
    call g:dir(a:path)
endfunction

function! g:dirVSplit(path)
    vsplit
    enew
    call g:dir(a:path)
endfunction

function! g:dirBuf(path)
    enew!
    call g:dir(a:path)
endfunction

function! g:dir(path)
    set encoding=cp850 " DOS 850: Western European (not to have strange caracters in the dir listing)
    "set encoding=utf-8 " To display russian text (dosen't work on russian computer...)
    let temp = substitute(a:path, '/', '\\', 'g')
    " Add trailing backslash in case there is no
    let temp = temp . '\'
    " Remove extra trailing backslashes if any
    let temp = substitute(temp, '\\\\', '\\', 'g')
    normal G
    exe 'r! dir ' . g:dirSort . ' "' . temp . g:dirFilter . '"'
    call search(g:dirOfStr, 'b')
    normal ztjj
    exe 'cd ' . temp
endfunction

" Recursive files find 
function! g:dirFind()
    call g:copyPath()
    let s = input('find files keywords: ', '*')
    tabe
    let c = 'c:\\cygwin\\bin\\find.exe ' . @p . ' -name "' . s . '"'
    let r = system(c)
    let r = substitute(r, '\\', '/', 'g')
    let r = substitute(r, '//', '/', 'g')
    let t = split(r, '\n')
    tabe
    call append(0, t)
    " Delete empty lines
    g/^$/d
    " Delete first 6 lines saying that the path is not something line /cygwin/c etc but a ms-dos path...
	0d 6
    %s/^/<url:vimscript:tabe /
    %s/$/>/
    normal gg
endfunction

" Recursive files grep
function! g:dirGrep()
    call g:copyPath()
    let s = input('grep files keywords: ')
    let i = input('include files: ', '*')
    tabe
    let c = 'c:\\cygwin\\bin\\grep -n -r -i --include=' . i . ' ' . s . ' ' . @p
    let r = system(c)
    let t = split(r, '\n') 
    tabe 
    call append(0, t) 
    " Delete first 6 lines saying that the path is not something line /cygwin/c etc but a ms-dos path...
	0d 6
    %s/^\(.*\):\([0-9]*\):/<url:vimscript:tabe \+\2 \1>/
    %s/\\/\//g
    normal gg
endfunction

function! g:dirDelete()
    if input("Delete this directory/file [(y)es/(n)o]? ", "") == "y"
        call g:copyPath()
        silent exe '!del /S/Q "' . @p . @f . '"'
        silent exe '!rmdir /S/Q "' . @p . @f . '"'
        call g:dir(@p)
    endif
endfunction

" Mappings to change sorting
nmap <space>1 :call g:copyPath() \| let g:dirSort = '/o:gn' \| call g:dir(@p) \| echo 'sorted by name ascending'<cr>
nmap <space>2 :call g:copyPath() \| let g:dirSort = '/o:g-n' \| call g:dir(@p) \| echo 'sorted by name descending'<cr>
nmap <space>3 :call g:copyPath() \| let g:dirSort = '/o:ge' \| call g:dir(@p) \| echo 'sorted by type ascending'<cr>
nmap <space>4 :call g:copyPath() \| let g:dirSort = '/o:g-e' \| call g:dir(@p) \| echo 'sorted by type descending'<cr>
nmap <space>5 :call g:copyPath() \| let g:dirSort = '/o:gs' \| call g:dir(@p) \| echo 'sorted by size ascending'<cr>
nmap <space>6 :call g:copyPath() \| let g:dirSort = '/o:g-s' \| call g:dir(@p) \| echo 'sorted by size descending'<cr>
nmap <space>7 :call g:copyPath() \| let g:dirSort = '/o:gd' \| call g:dir(@p) \| echo 'sorted by date ascending'<cr>
nmap <space>8 :call g:copyPath() \| let g:dirSort = '/o:g-d' \| call g:dir(@p) \| echo 'sorted by date descending'<cr>

" Mappings to some root directories
nmap \A :call g:dirBuf('a:/')<cr>
nmap \B :call g:dirBuf('b:/')<cr>
nmap \C :call g:dirBuf('c:/')<cr>
nmap \D :call g:dirBuf('d:/')<cr>
nmap \E :call g:dirBuf('e:/')<cr>
nmap \F :call g:dirBuf('f:/')<cr>
nmap \G :call g:dirBuf('g:/')<cr> 
nmap \H :call g:dirBuf('h:/')<cr>
nmap \I :call g:dirBuf('i:/')<cr>
nmap \J :call g:dirBuf('j:/')<cr>
nmap \K :call g:dirBuf('k:/')<cr>
nmap \L :call g:dirBuf('l:/')<cr>
nmap \M :call g:dirBuf('m:/')<cr>
nmap \O :call g:dirBuf('o:/')<cr>
nmap \P :call g:dirBuf('p:/')<cr>
nmap \Q :call g:dirBuf('q:/')<cr>
nmap \R :call g:dirBuf('r:/')<cr>
nmap \S :call g:dirBuf('s:/')<cr>
nmap \T :call g:dirBuf('t:/')<cr>
nmap \U :call g:dirBuf('u:/')<cr>
nmap \V :call g:dirBuf('v:/')<cr>
nmap \W :call g:dirBuf('w:/')<cr>
nmap \X :call g:dirBuf('x:/')<cr>
nmap \Y :call g:dirBuf('y:/')<cr>
nmap \Z :call g:dirBuf('z:/')<cr>
nmap \a :call g:dirSplit('a:/')<cr>
nmap \b :call g:dirSplit('b:/')<cr>
nmap \c :call g:dirSplit('c:/')<cr>
nmap \d :call g:dirSplit('d:/')<cr>
nmap \e :call g:dirSplit('e:/')<cr>
nmap \f :call g:dirSplit('f:/')<cr>
nmap \g :call g:dirSplit('g:/')<cr> 
nmap \h :call g:dirSplit('h:/')<cr>
nmap \i :call g:dirSplit('i:/')<cr>
nmap \j :call g:dirSplit('j:/')<cr>
nmap \k :call g:dirSplit('k:/')<cr>
nmap \l :call g:dirSplit('l:/')<cr>
nmap \m :call g:dirSplit('m:/')<cr>
nmap \o :call g:dirSplit('o:/')<cr>
nmap \p :call g:dirSplit('p:/')<cr>
nmap \q :call g:dirSplit('q:/')<cr>
nmap \r :call g:dirSplit('r:/')<cr>
nmap \s :call g:dirSplit('s:/')<cr>
nmap \t :call g:dirSplit('t:/')<cr>
nmap \u :call g:dirSplit('u:/')<cr>
nmap \v :call g:dirSplit('v:/')<cr>
nmap \w :call g:dirSplit('w:/')<cr>
nmap \x :call g:dirSplit('x:/')<cr>
nmap \y :call g:dirSplit('y:/')<cr>
nmap \z :call g:dirSplit('z:/')<cr>

" Commands shortcuts
function! g:cmdExe(c)
    exe g:cmdDict[a:c]
endfunction
nmap <space>; :exe 'call g:cmdExe("' . input('command shortcut: ') . '")'<cr>

" Buffer listing
function! g:listBuffers(action)
    redir! => b
    silent buffers
    redir end
    let t = split(b, '\n')
    enew!
    call append(0, t)
    execute 'g/^$/d'
    execute '%s/^ *\([0-9]*\)\( \|u\)/\1>\2/g'
    execute '%s/^ */<url:vimscript:' . a:action . '/g'
    execute 'normal gg'
endfunction
