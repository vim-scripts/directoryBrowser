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
" Version: 3.1
"
" Files: plugin/directoryBrowser.vim	
"
" History:
" 1.0   2012-08-04
"		    - First release
" 2.0   2012-08-09
"           - Put 36 caracters instead of 39 between beginning of line and filename in cPath
"           - Added \. to \a to \z and \A to \Z
" 3.0   2012-08-23
"           - \a to \z list a:\ to z:\ root directories in current buffer (appended)
"           - \A to \Z list a:\ to z:\ root directories in new buffer
"           - -a to -z list a:\ to z:\ root directories in split window
"           - -A to -Z list a:\ to z:\ root directories in vertical split window
"           - =a to =z list a:\ to z:\ root directories in new tab
"           - f/ Change backslash to forwardslash on the current line
"           - f<Bslash> Change forwardslash to backslash on the current line
"           - ff<Bslash> Change backslash to double backslash on the current line
"           - fff<Bslash> Change forwardslash to double backslash on the current line
"           - ffff<Bslash> Change doublebackslash to backslash the current line
"           - <space><f5> copy current file's path+filename relative to current directory with backslash
"           - <space><f6> copy current file's path+filename relative to current directory with forward slash
"           - <space><f7> copy current file's path only (with backslash)
"           - <space><f8> copy current file's path only (with forward slash)
"           - <space><f9> copy current file's filename only (without path)
"           - <space><f10> copy current file's path+filename relative to current directory with the line number (in utl format)
"           - <space>! Layout 1 (2 vertical panes)
"           - <space>@ Layout 2 (2 horizontal panes)
"           - <space># Layout 3 (3 panes: 2 vertical, 1 horizontal)
"           - <space>$ Layout 4 (4 panes)
"           - <space>^ Layout 6 (6 panes)
"           - <space>* Layout 8 (8 panes)
"           - <space>) Layout 10 (10 panes)
"           - <space>- toggle show file owner
"           - <space>0 to change directory attributes
"           - <space>9 to change directory time display and sorting
"           - <space>a interchanged with <space>A
"           - <space>b changed list buffers to open in new tab instead of opening in current tab (not related to directory browsing but useful. Requires utl.vim)
"           - <space>I open file in internet explorer
"           - <space>L to list current directory and its subdirectories recursively
"           - <space>M open a "contextual menu" to run operations on files (requires the utl plugin)
"           - <space>n new file in new tab
"           - <space>N new file in current tab
"           - <space>O open file in notepad
"           - <space>q show available volumes
"           - <space>Q show available volumes with names and details about shares and computers
"           - <space>T open directory in new tab
"           - <space>u open filename in clipboard current tab
"           - <space>U open filename in clipboard in new tab
"           - <space>w to save (append) directory listing to disk (useful for shorcuts)
"           - <space>W to save (overwrite) directory listing to disk
"           - <space>X to show directory and subdirectories structure of current directory using the "tree" command
"           - <space>y list the directory of the path in clipboard (with or without filename) in a new split window
"           - <space>Y list the directory of the path in clipboard (with or without filename) in the current buffer
"           - <space>z open utl link under cursor in a split window (utl plugin required)
"           - <space>Z open utl link under cursor in tab (utl plugin required)
"           - Remove dirOfStr language requirement. Searching for a language specific string was not needed. 
"           - Changes with cursor position and listing position specially using <space>i and <space>m. 
"           - Set g:dir instead of g:dirBuf as defaut when doing \A..\Z (listing drives using capital letters) with is more convenient because this way one my list content of another drive in the same buffer using the \ shortcut key so one may have all his directory browsing inside the same buffer, with is nice if saved to file using <space>w for later viewing and continuation. 
"           - Added <space>F to list the directory of the current file
"           - Changed behavior of <space>i "go to previous dir listing", now it will go to top of current dir then to previous dir if <space>i is typed a second time. 
"           - Modified search string to find current directory (not to conflict with the directory showned by the tree command)
"           - uu, uuu, uuuu, uuuuu, UU, UUU, UUUU, uur abbreviations used with the utl plugin to insert links and references
" 
" 3.1
"           - Don't use version 3.0, use version 3.1 instead.
"           - <space><tab> open default 'browsing history' file called 'dirlist_', useful for fast browsing
"
" Overview
" --------
" This plugin is currently only for Windows but could be easily ported for another OS. Some optional features require cygwin and/or the utl plugin.
"
" The dir plugin allows fast directory browsing inside vim buffers, 
" split windows or tabs. It uses the windows dir command to list
" directories inside buffers and it provides several commands
" to be executed on the listed files or directories including
" dir listing, sorting, filtering, recursive file searching, 
" recursive file greping, file renaming, file deleting,
" file cloning, file executing and file opening/editing in buffer, 
" tab, window and external tools and changing listing options.
"
" The way it works is simple. It insert the output of the windows dir
" command at the end of a buffer and then after the user has moved
" the cursor to one of the lines of this directory listing and
" executes one of the pre-defined (or user defined) command mappings, 
" the path of the directory and the name of the file/directory are 
" copied to some registers and are used to execute the command on the 
" file or directory.
"
" For example if the command mapping \C is executed the directory of
" c:\ is listed at the end of a new split window (every drive may be 
" accessed using \A, \B, \C, ..., \Z or \a..\z to append a listing to current buffer).
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
" nmap <space>y :call g:cPath() \| silent exe '!start I:\data\AutoHotkey\repository_usb_only\repository.exe "' . @p . @f . '"'<cr>
"
" This mapping is in my vimrc and not in the plugin because it is
" a tool that is used only by myself. Here the g:cPath() function
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
" Note that when the g:dir or its variants g:dir, g:dirTab, g:dirSplit etc
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
" Note that any mappings may be changed. If you don't like the usage of <space> or \ before some commands you may change this easily. <space> may be changed by <tab> for example.
"
" \a to \z      list a:\ to z:\ root directories in current buffer (appended)
" \A to \Z      list a:\ to z:\ root directories in new buffer
" -a to -z      list a:\ to z:\ root directories in split window
" -A to -Z      list a:\ to z:\ root directories in vertical split window
" =a to =z      list a:\ to z:\ root directories in new tab
" f/            Change backslash to forwardslash on the current line
" f<Bslash>     Change forwardslash to backslash on the current line
" ff<Bslash>    Change backslash to double backslash on the current line
" fff<Bslash>   Change forwardslash to double backslash on the current line
" ffff<Bslash>  Change doublebackslash to backslash the current line
" <space>;      Command shortcuts (Optional. This dictionnary g:cmdDict may be moved to your vimrc and may contain the commands you want. It is used with the g:cmdExe function and the mapping <space>; and it is not absolutly part of this plugin. I put it inside the plugin because it may be a fast way to open directories). If commands were previously entered, you may use the up/down or ctrl+p/ctrl+n on the command line after doing <space>;
" <space>:      Show list of command shortcuts
" <space><esc>  execute command on the vim command line (fast if escape remapped to capslock)
" <space><tab>  open default 'browsing history' file called 'dirlist_', useful for fast browsing
" <space><f3>   search files (including in subdirectories). Cygwin should be installed for this command to work.
" <space><f4>   grep files (including in subdirectories). Cygwin should be installed for this command to work. It will ask for keywords to search and a file filter by which by default is *.
" <space><f5>   copy current file's path+filename relative to current directory with backslash
" <space><f6>   copy current file's path+filename relative to current directory with forward slash
" <space><f7>   copy current file's path only (with backslash)
" <space><f8>   copy current file's path only (with forward slash)
" <space><f9>   copy current file's filename only (without path)
" <space><f10>  copy current file's path+filename relative to current directory with the line number (in utl format)
" <space>!      Layout 1 (2 vertical panes)
" <space>@      Layout 2 (2 horizontal panes)
" <space>#      Layout 3 (3 panes: 2 vertical, 1 horizontal)
" <space>$      Layout 4 (4 panes)
" <space>^      Layout 6 (6 panes)
" <space>*      Layout 8 (8 panes)
" <space>)      Layout 10 (10 panes)
" <space>-      toggle show file owner
" <space>1      sort directory by name ascending
" <space>2      sort directory by name descending
" <space>3      sort directory by type ascending
" <space>4      sort directory by type descending
" <space>5      sort directory by size ascending
" <space>6      sort directory by size descending
" <space>7      sort directory by date ascending
" <space>8      sort directory by date descending
" <space>0      to change directory attributes
" <space>9      to change directory time display and sorting
" <space>.      reload directory (refresh)
" <space>a      write path to open (windows explorer address bar like) (append to current buffer)
" <space>A      write path to open (windows explorer address bar like) (open in new buffer)
" <space>b      list buffers to open in new tab (not related to directory browsing but useful. Requires utl.vim)
" <space>B      list buffers to delete (not related to directory browsing but useful. Requires utl.vim)
" <space>c      duplicate (clone) file
" <space>C      open current directory in command prompt
" <space>d      new directory
" <space>D      delete file or directory
" <space>e      open file in current buffer
" <space>f      Set filter to show only certain files example: *.txt or pic*.jpg
" <space>F      list directory of current file
" <space>g      grep current file (file is opened inside vim and vimgrep is used. No need for cygwin here.)
" <space>h      go up a directory
" <space>i      go to previous dir listing (if many listings were done in the same buffer it allows to go directly back to a previous listing)
" <space>I      open file in internet explorer
" <space>j      preview file (rapidly includes the file into the current buffer. Do <space>k to remove the file and go to next file in the dir listing. Doing successively <space>j and <space>k allows to preview quickly one file after another. If directory listings are saved to disk, they may be quickly opened using this mapping <space>j to list them and browse them.) 
" <space>k      used with preview file to remove the preview and go down one line to next file to preview
" <space>l      list directory (go inside a directory)
" <space>L      list directory recursively (go inside subdir)
" <space>m      go to next dir listing (if many listings were done in the same buffer it allows to go directly to the next listing)
" <space>M      open a "contextual menu" to run operations on files. This requires the utl plugin. The contextual menu is a text file containing utl links that are executed using the path in the clipboard register @*. For example here's the content of a contextual menu file, it contains some links to compile csharp code and to edit the menu itself, you may create a menu to your liking. To remove the contextual menu after <space>M is issued, press "u" (undo):
"               MENU
"               <url:vimscript:tabe! I:/data/Scripts/vim/menu.txt>
"               EDIT
"               <url:vimscript:echo     'editpad pro'             | call g:cPathF() | exe '!start Z:\\Apps\\JGSoft\\EditPadPro7\\EditPadPro7.exe ' . @*>
"               <url:vimscript:echo     'excel'                   | call g:cPathF() | exe '!start c:\\Program Files\\Microsoft Office\\Office12\\EXCEL.EXE ' . @*>
"               <url:vimscript:echo     'visual studio'           | call g:cPathF() | exe '!start devenv.exe /edit ' . @*>
"               <url:vimscript:echo     'word'                    | call g:cPathF() | exe '!start c:\\Program Files\\Microsoft Office\\Office12\\WINWORD.EXE ' . @*>
"               <url:vimscript:echo     'wordpad'                 | call g:cPathF() | exe '!start C:\\Program Files\\Windows NT\\Accessoires\\wordpad.exe ' . @*>
"               COMPILE/RUN
"               <url:vimscript:echo     'autohotkey'              | call g:cPathF() | exe '! z:/Apps/Portable/AutoHotkey/AutoHotkey.exe ' . @*>
"               <url:vimscript:echo     'bash script'             | call g:cPathF() | split | enew | exe \"r! c:/cygwin/bin/bash.exe \" . @*>
"               <url:vimscript:echo     'batch files'             | call g:cPathF() | split | enew | exe \"r! \" . @*>
"               <url:vimscript:echo     'cs ms (compile+run)'     | call g:cPathF() | split | enew | exe 'r! c:\\WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727\\csc.exe /out:c:\\t.exe ' . @v | r! c:/t.exe>
"               <url:vimscript:echo     'cs ms (compile)'         | call g:cPathF() | split | enew | exe 'r! c:\\WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727\\csc.exe /out:c:\\t.exe ' . @v >
"               <url:vimscript:echo     'cs ms (run)'             | split | enew | r! c:/t.exe>
"               <url:vimscript:echo     'cs mono (compile+run)'   | call g:cPathF() | split | enew | exe 'r! c:\\Progra~1\\Mono-2.10.8\\bin\\mcs /out:c:\\t.exe ' . @* | r! c:\\Progra~1\\Mono-2.10.8\\bin\\mono.exe c:/t.exe>
"               <url:vimscript:echo     'cs mono (compile)'       | call g:cPathF() | split | enew | exe 'r! c:\\Progra~1\\Mono-2.10.8\\bin\\mcs /out:c:\\t.exe ' . @* >
"               <url:vimscript:echo     'cs mono (run)'           | split | enew | r! c:\\Progra~1\\Mono-2.10.8\\bin\\mono.exe c:/t.exe>
"               <url:vimscript:echo     'hta'                     | call g:cPathF() | exe '! mshta.exe ' . @*>
"               <url:vimscript:echo     'html'                    | call g:cPathF() | exe '! ' . @*>
"               <url:vimscript:echo     'html to pdf (+open)'     | call g:cPathF() | exe '! Z:/Apps/Portable/CmdUtils/Prince/Engine/bin/prince.exe ' . @* . ' -o t.pdf & t.pdf'>
"               <url:vimscript:echo     'html to pdf'             | call g:cPathF() | exe '! Z:/Apps/Portable/CmdUtils/Prince/Engine/bin/prince.exe ' . @* . ' -o t.pdf'>
"               <url:vimscript:echo     'php'                     | call g:cPathF() | split | enew | exe \"r! Z:/Apps/Portable/php/php.exe \" . @*>
"               <url:vimscript:echo     'pl/sql'                  | call g:cPathF() | split | enew | exe \"r! sqlplus.exe -s hr/hr@xe @\" . @*>
"               <url:vimscript:echo     'vbscript'                | call g:cPathF() | split | enew | execute \"r! cscript.exe /nologo \" . @*>
"               Tip: You may copy paste the links from the menu at the top of a file you are editing or even a directory listing, and when you want to run or open the file, you do gg to go to the top of the file and <space>z to execute the link. After it is executed, do ctrl-o 2 times to return to the previous location. You may add "w" to write the file if you are editing a file to save it, and if you are in a directory listing, do <space>p to copy the path of a file and then gg to go to top of the file where the links would be, and do <space>z to open/run the copied file path.
" <space>n      new file in new tab
" <space>N      new file in current tab
" <space>o      open list dir pointed to by a windows .lnk file (dosen't work for all .lnk to directory files, to improve)
" <space>O      open file in notepad
" <space>p      copy file path and name. The path is copied in several formats to different registers. Registers where chosen instead of variables because the path can then be pasted. Often the paths needs to be pasted to files for linking or documentation etc.
"                  1- in @p (directory only) with \
"                  2- in @* (directory and filename) with \ 
"                  3- in @z (directory only) with /
"                  4- in @x (directory and filename) with /
"                  5- in @f (filename only)
" <space>P      show current path
" <space>q      show available volumes
" <space>Q      show available volumes with names, plus, details about shares and computers
" <space>r      run file
" <space>R      rename file or directory
" <space>s      open file in split
" <space>S      list current directory in a split window (no need to have already a directory browser opened)
" <space>t      open file in tab
" <space>T      list current directory in a tab (no need to have already a directory browser opened) 
" <space>u      open filename in clipboard current tab
" <space>U      open filename in clipboard in new tab
" <space>v      open file in vsplit
" <space>V      list current directory in a vsplit window (no need to have already a directory browser opened) 
" <space>w      write append directory listing to disk
" <space>W      write overwrite directory listing to disk
" <space>x      open current directory in windows explorer
" <space>X      Show tree of directory and subdirectories using the tree command
" <space>y      list the directory of the path in clipboard (with or without filename) in a new buffer
" <space>Y      list the directory of the path in clipboard (with or without filename) in the current buffer
" <space>z      open utl link under cursor in a split window (utl plugin required)
" <space>Z      open utl link under cursor in tab (utl plugin required)
" uu, uuu, UU, UUU, UUUU, uur abbreviations used with the utl plugin to insert links and references
"
" Bookmarks tip: To make quick bookmarks to files and directories, use vim usual marks with m and ' or ` (:help marks) to points to files and directories in a dir listing since these are buffers and files if written to disk. Use <space>w or <space>W to write a listing to disk. Since the dir listings are files, they can be edited and annoted like any files and one could edit his/her own directory listings to group together in a file related directories. For example I created a file c:\dirlist_doc which contains 2 directories with documentation in pdf etc. When I open this c:/dirlist_doc file, I find all my docs there and I could search files or add marks to the file using vim m and ' or ` (:help marks). Even if a <space>L would be done on these dir, all the subdirectories would be displayed and so the docs would be easily searched since all files in the subdirectories would be in this c:\dirlist_doc file. You may open a new tab with <space>n before to go to a mark and go to marks there. Also if you want to quickly access a previously made bookmarks on a saved directory listing using for example mA (mark with A), you could do <space>n to open a new tab, then to do the 'A or `A to access it. I added <space><tab> which opens the default browsing history file 'dirlist_' in the g:dirListPath. So it would be possible to use always this file to do browsing and to put file marks inside for quick bookmarking.
"
"
" Browsing history tip: You may also use <space>w and save to default file and use \A..\Z to always list directories to same file, and save to same default file, this way you may use also marks with lowercase letters inside this same file, as well as to use the / to find files. This default file could be some sort of browsing history. In this "browsing history file", you may put some links at the top of the file taken from your contextual menu to lauch files to external applications (do gg to go to top of the file where the links would be and ctrl-o 2 times to return to previous location). You may edit this "browsing history" file by selecting and deleting text in it like any text file. If your browsing history file becomes too much big, you may clone it using <space>c and then delete some of its content. 

" Project management tip: Using the same tips previously described, one could have projects directories files example dirlist_myproject and put directories related to a project. The files not needed in a directory could be deleted. If the content of the subdirectories are needed, do a <space>L on the root directory of the project, the dir command will list all the sub directories, then edit the files (lines) in the directories listed. Also as previously explained in the tips above, the links to run/open/edit files related to a project may be pasted at the top of the file from the your contextual menu.
"
" "Commands shortcuts" can be used to assosiate words to commands using the dictionary g:cmdDict like so for example:
" let g:cmdDict = {
"     \ 'backup' : '!start z:/vifm/runtime/commands/Backup.bat',
"     \ 'bin' : 'call g:dirTab("c:/cygwin/bin")',
"     \ 'test' : 'echo "allo"',
"     \ 'cmdutils' : 'call g:dirTab("z:/apps/portable/cmdutils")',
"     \ 'commands' : 'call g:dirTab("z:/vifm/runtime/commands")',
"     \ 'menu' : 'tabe i:/data/Scripts/vim/m',
"     \ 'notes' : 'call g:dirTab("i:/data/notes")',
" \}
" If example the user does <space>; and enters the word "backup" the backup is started. This may be
" not directly related to directory browsing but I find it useful if one has many directories, he may associate words
" to these directories for example to do <space>; and write the word "notes" will run the command g:dirTab("i:/data/notes") to list the directory i:/data/notes using this plugin. If commands were previously entered, you may use the up/down or ctrl+p/ctrl+n on the command line after doing <space>;
" If utl is used the command shortcut dictionnary may be set using a utl link like this for example and subsequent changes to the dictionnary could be reloaded by executing the link:
" <url:vimscript:let g:cmdDict = { 'backup' : '!start z:/vifm/runtime/commands/Backup.bat', 'bin' : 'call g:dirSplit(\"c:/cygwin/bin\")', 'cmdutils' : 'call g:dirSplit(\"z:/apps/portable/cmdutils\")', 'commands' : 'call g:dirSplit(\"z:/vifm/runtime/commands\")', 'menu' : 'tabe i:/data/Scripts/vim/m', 'notes' : 'call g:dirSplit(\"i:/data/notes\")', 'scripts' : 'call g:dirSplit(\"i:/data/scripts/vim\")', 'shortcuts' : 'call g:dirSplit(\"i:/data/shortcuts\")', 'travail' : 'call g:dirSplit(\"z:/data/travail\")', }>
"
" The functions in this plugin may be used in other scripts, plugins or vimrc, especially the g:dirTab, g:dirSplit and other variants, or the g:cPath function. The global variables g:dirSort, g:dirFilter, g:dirTime, g:dirAttributes or g:dirOwner may also be used in scripts. A example of the g:cPath function was given in the overview section above. Another example here is with the use of the utl.vim plugin which I use. The function g:dirSplit is used inside a url to open a directory by clicking the link or doing the command :Utl ol (or the corresponding mapping):
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
" Default sorting
" let g:dirSort = '/o:gn'

" Directory attributes
" let g:dirAttributes = '/a:-h'

" Directory time
" let g:dirTime = '/t:w'

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
" nmap -s :call g:dirSplit("c:/program files")
" Then press - and then s to execute the command.
"
" - Do \C to list the c:\ directory in a new buffer, or \D to list the d:\ etc. All alphabet letters are "pre-mapped" this way. You may change them to capital letters if they conflict with your current mappings.
"
" - Do \c to list the c:\ directory in the current buffer (appended), or \d to list the d:\ etc.
"
" - Do <space>a (or <space>A) write a path like c:/temp (or c:\temp). This mappings makes it possible to type in paths.
"
" - Do <space>f and write *.txt to see only the *.txt files and do again <space>f and write *.* to see all files.
"
" - Do <space>7 to sort by date
"
" - Do <space><esc> to issue a command (so vim maybe used instead of a dos command prompt window)
"
" - You may use the predifined layouts <space>!, <space>@, etc (see above) to view multiple directories in the same window. You may do your own layouts too using the same commands (10 windows is the maximum predefined, but you may add more if you have a large screen). I suggest that you map the :tabclose command to close the tab where there are layouts because the close buffer or close window command would then have to be repeated as many time as there are panes.
"
" Todo:
" - detect OS version (2000/xp/7) because in win2000 and 7 for example, the number of caracters before the filename in the dir listing is not the same, it is 39 in win2000 and 36 in windows 7, so add a condition there to select the number of caracters accordingly.
" - Maybe not have always paths copied to clipboard...use variables and copy to clipboard when needed only
" - Maybe to make is work with the ls command under linux.
" - peut-etre ajouter un hash table qui contiendrait des mots-cles/Paths et qui permettrait par exemple d'ecrire cmdutils et ca changerait vers le path z:\apps\portables\cmdutils
" - peut-etre permettre d'entrer une partie seulement des commands dans le dictionnaire et que ca va trouver la commande quand meme
" - In another version of the plugin, do <space>m to mark the current file with an * (in copyfile add also the copy of the line number in the register @n), and in the function that will mark a file, will with the line number add the * and all the commands line delete, clone etc will be inside new functions. And when a mark * is done on a file with <space>m the file path will be added to an list (array) and all these commands (delete, run, clone, etc) will be executed in a loop on all the files in the list (array)
" - ajouter copie d'un fichier: cPath et apres dans le rep dest mettre @f et @p dans variables temp f et p et faire un autre copy path et ensuite faire la commande de copie. Pour un move faire meme chose mais faire un delete des fichier source (variable p et f) apres.
" - conserver les repertoires recemment browser dans un tableau
" - put the encoding as a global variable
" - maybe have a layout function which takes the number of rows and columns in parameters and split accordingly and maybe this function global so it may be called from utl links to have predefined layouts. Also have a global array that would contain the default paths for each of the directory listed in these windows.
"
" ------------------------------------------------------------------------------

" Variables

" List directories recursively (used by <space>L) 
let g:dirRecursive = 0 

" Default filter (all files)
let g:dirFilter = '*.*'

" Default sorting
let g:dirSort = '/o:gn'

" Directory attributes
let g:dirAttributes = '/a:-h'

" Directory time
let g:dirTime = '/t:w'

" Show file owner (maybe slow for large directories and slow disk access so is not set by default)
let g:dirOwner = ''

" Path where to save dirlist files for browsing history etc (include the trailing /)
let g:dirListPath = 'c:/'

" Contextual menu path
let g:dirMenuPath = 'I:/data/Scripts/vim/menu.txt'

" Command shortcuts (Optional. This dictionnary g:cmdDict may be moved to your vimrc and may contain the commands you want. It is used with the g:cmdExe function and the mapping <space>; and it is not absolutly part of this plugin. I put it inside the plugin because it may be a fast way to open directories). If commands were previously entered, you may use the up/down or ctrl+p/ctrl+n on the command line after doing <space>;
" Uncomment and put this g:cmdDict variable and it's content to your vimrc or use it inside a utl link. Modify its content for your needs.
" let g:cmdDict = {
"     \ 'backup'      : '!start z:/vifm/runtime/commands/Backup.bat',
"     \ 'bin'         : 'call g:dirSplit("c:/cygwin/bin")',
"     \ 'cmdutils'    : 'call g:dirSplit("z:/apps/portable/cmdutils")',
"     \ 'commands'    : 'call g:dirSplit("z:/vifm/runtime/commands")',
"     \ 'menu'        : 'tabe i:/data/Scripts/vim/m',
"     \ 'notes'       : 'call g:dirSplit("i:/data/notes")',
"     \ 'scripts'     : 'call g:dirSplit("i:/data/scripts/vim")',
"     \ 'shortcuts'   : 'call g:dirSplit("i:/data/shortcuts")',
" \}

" Mappings

" change backslash to forwardslash on the current line
nnoremap <silent> f/ :s/\\/\//g<cr>

" change forwardslash to backslash on the current line
nnoremap <silent> f<Bslash> :let tmp=@/<CR>:s:/:\\:ge<CR>:let @/=tmp<CR>

" change backslash to double backslash on the current line
nnoremap <silent> ff<Bslash> :let tmp=@/<CR>:s:\\:\\\\:ge<CR>:let @/=tmp<CR>

" change forwardslash to double backslash on the current line
nnoremap <silent> fff<Bslash> :let tmp=@/<CR>:s:/:\\\\:ge<CR>:let @/=tmp<CR>

" change doublebackslash to backslash the current line
nnoremap <silent> ffff<Bslash> :let tmp=@/<CR>:s:\\\\:\\:ge<CR>:let @/=tmp<CR>

" command shortcuts
nmap <space>; :exe 'call g:cmdExe("' . input('command shortcut: ') . '")'<cr>

" show the command shorcuts
nmap <space>: :echo g:cmdDict<cr>

" execute command on the vim command line (fast if escape remapped to capslock)
nmap <space><esc> :exe 'normal G' \| :r! 

" open default 'browsing history' file, useful for fast browsing
nmap <space><tab> :call g:openDirList_()<cr>

" search files
nmap <space><f2> :call g:dirFind()<cr>

" search files
nmap <space><f3> :call g:dirFind()<cr>

" grep files
nmap <space><f4> :call g:dirGrep()<cr>

" copy current file's path+filename relative to current directory with backslash
nmap <space><f5> :let @*=expand("%:p:h") . '\' . expand("%:t")<CR>

" copy current file's path+filename relative to current directory with forward slash
nmap <space><f6> :let @*=substitute(expand("%:p:h") . '/' . expand("%:t"), '\', '/', 'g')<CR>

" copy current file's path only (with backslash)
nmap <space><f7> :let @*=expand("%:p:h")<CR>

" copy current file's path only (with forward slash)
nmap <space><f8> :let @*=substitute(expand("%:p:h"), '\', '/', 'g')<CR>

" copy current file's filename only (without path)
nmap <space><f9> :let @*=substitute(expand("%:t"), '\', '/', 'g')<CR>

" copy current file's path+filename relative to current directory with the line number (in utl format)
nmap <space><f10> :let @*=substitute('<url://' . expand("%:p:h") . '/' . expand("%:t") . '#line=' . line(".") . '>', '\', '/', 'g')<CR>

" reload directory (refresh)
nmap <space>. :call g:cPath() \| call g:dir(@p)<cr>

" Toggle show file owner
nmap <space>- :call g:cPath() \| let g:dirOwner = g:dirOwner == '' ? '/q' : '' \| call g:dir(@p)<cr>

" Mappings to change sorting
nmap <space>1 :call g:cPath() \| let g:dirSort = '/o:gn' \| call g:dir(@p) \| echo 'sorted by name ascending'<cr>
nmap <space>2 :call g:cPath() \| let g:dirSort = '/o:g-n' \| call g:dir(@p) \| echo 'sorted by name descending'<cr>
nmap <space>3 :call g:cPath() \| let g:dirSort = '/o:ge' \| call g:dir(@p) \| echo 'sorted by type ascending'<cr>
nmap <space>4 :call g:cPath() \| let g:dirSort = '/o:g-e' \| call g:dir(@p) \| echo 'sorted by type descending'<cr>
nmap <space>5 :call g:cPath() \| let g:dirSort = '/o:gs' \| call g:dir(@p) \| echo 'sorted by size ascending'<cr>
nmap <space>6 :call g:cPath() \| let g:dirSort = '/o:g-s' \| call g:dir(@p) \| echo 'sorted by size descending'<cr>
nmap <space>7 :call g:cPath() \| let g:dirSort = '/o:gd' \| call g:dir(@p) \| echo 'sorted by date ascending'<cr>
nmap <space>8 :call g:cPath() \| let g:dirSort = '/o:g-d' \| call g:dir(@p) \| echo 'sorted by date descending'<cr>

" Mapping to change directory time display and sorting
nmap <space>9 :call g:cPath() \| let g:dirTime = input("time (for display and sorting): [c]reation, [a]ccess, [w]rite: ", "w") \| let g:dirTime = '/t:' . g:dirTime \| call g:dir(@p)<cr>

" Mapping to change directory attributes
nmap <space>0 :call g:cPath() \| let g:dirAttributes = input("attributes (may be combined): (d)irectories, (h)idden, (s)ystem, (r)ead only, (a)rchive, (-)negation: ", "-h") \| let g:dirAttributes = '/a:' . g:dirAttributes \| call g:dir(@p)<cr>

" Layout 1 (2 vertical panes)
nmap <space>! :call g:dirTab('c:\') \| call g:dirVSplit('c:\')<cr> 
" Layout 2 (2 horizontal panes)
nmap <space>@ :call g:dirTab('c:\') \| call g:dirSplit('c:\')<cr> 
" Layout 3 (3 panes)
nmap <space># :call g:dirTab('c:\') \| call g:dirSplit('c:\') \| call g:dirVSplit('c:\')<cr> 
" Layout 4 (4 panes)
nmap <space>$ :call g:dirTab('c:\') \| call g:dirSplit('c:\') \| call g:dirVSplit('c:\') \| wincmd j \| call g:dirVSplit('c:\') \| wincmd k<cr> 
" Layout 6 (6 panes)
nmap <space>^ :call g:dirTab('c:\') \| call g:dirSplit('c:\') \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| wincmd j \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| wincmd k<cr> 
" Layout 8 (8 panes)
nmap <space>* :call g:dirTab('c:\') \| call g:dirSplit('c:\') \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| wincmd j \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| wincmd k<cr> 
" Layout 10 (10 panes)
nmap <space>) :call g:dirTab('c:\') \| call g:dirSplit('c:\') \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| wincmd j \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| call g:dirVSplit('c:\') \| wincmd k<cr> 

" write path to open (windows explorer address bar like) (append to current buffer)
nmap <space>a :unlet! p \| let p = input('path (append to current buffer): ', '') \| call g:dir(p)<cr>

" write path to open (windows explorer address bar like) (open in current buffer)
nmap <space>A :unlet! p \| let p = input('path (new split window): ', '') \| call g:dir(p)<cr>

 " list buffers to open in new tab (not related to directory browsing but useful. Requires utl.vim)
nmap <space>b :tabnew \| call g:listBuffers('tabnew\|b')<cr>

 " list buffers to delete (not related to directory browsing but useful. Requires utl.vim)
nmap <space>B :tabnew \| call g:listBuffers('bd!')<cr>

" duplicate (clone) file
nmap <space>c :call g:cPath() \| exe '!copy ' @p . @f . ' ' @p . @f . '_' . substitute(strftime('%x_%X'), ':', '-', 'g') \| call g:dir(@p)<cr>

" open directory in command prompt
nmap <space>C :call g:cPath() \| silent exe '!start cmd /k "dir /o:g ' . @p . '"'<cr>

" new directory
nmap <space>d :unlet! t \| let t = input('Directory name: ') \| :call g:cPath() \| call mkdir(t) \| call g:dir(@p)<cr>

" delete file or directory
nmap <space>D :call g:dirDelete()<cr>

" open file in buffer
nmap <space>e :call g:cPath() \| exe 'e! ' . @p . @f<cr>

" set filter to show only certain files
nmap <space>f :call g:cPath() \| let dirFilter = input('filter: ', '*.') \| call g:dir(@p)<cr>

" list directory of current file
nmap <space>F :exe "call g:dirSplit('" . expand('%:p:h') . "')"<cr>

" grep file
nmap <space>g :call g:cPath() \| exe 'tabe ' . @p . @f \| exe 'vimgrep ' . input('grep current file keywords: ') . ' %' \| exe 'copen'<cr>

" up directory
nmap <space>h :call g:cPath() \| call g:dir(@p . '..')<cr>

" go to previous dir listing 
nmap <space>i :call search(' .:\', 'b') \| exe 'normal zt0'<cr> 

" open file in internet explorer
nmap <space>I :call g:cPath() \| silent exe '!start "c:\program files\internet explorer\iexplore.exe" "' . @p . @f . '"'<cr>

" preview file (include the file and undo "u" (or <space>k to remove it) (useful also to view content of lnk files and copy their target)
nmap <space>j :call g:cPath() \| exe 'normal zt' \| exe 'r ' . @p . @f<cr>

" used with preview file to remove the preview and go down one line to next file to preview
nmap <space>k :exe 'normal uj'<cr>

" list directory (go inside subdir)
nmap <space>l :call g:cPath() \| call g:dir(@p . @f)<cr>

" list directory recursively (go inside subdir)
nmap <space>L :call g:cPath() \| let g:dirRecursive = 1 \| call g:dir(@p . @f) \| let g:dirRecursive = 0<cr>

" go to next dir listing 
nmap <space>m :call search(' .:\') \| exe 'normal zt2j0'<cr> 

" show contextual menu for actions on files
nmap <space>M :call g:cPath() \| exe 'r ' . g:dirMenuPath \| exe 'normal ztk0'<cr> 

" new file in new tab
nmap <space>n :tabe!<cr>

" new file current tab
nmap <space>N :enew!<cr>

" open list dir using a lnk file (dosen't work for all lnk to directory files, to improve)
nmap <space>o :call g:cPathLnk() \| call g:dir(@*)<cr>

" open file in notepad
nmap <space>O :call g:cPath() \| silent exe '!start notepad.exe "' . @p . @f . '"'<cr>

" copy file path
nmap <space>p :call g:cPath()<cr> 

" show path
nmap <space>P :pwd<cr> 

" show available volumes
nmap <space>q :call g:dirVolumes(0)<cr>

" show available volumes with names
nmap <space>Q :call g:dirVolumes(1)<cr>

" run file
nmap <space>r :call g:cPath() \| silent exe '!start cmd /c "' . @p . @f . '"'<cr>

" rename file or directory
nmap <space>R :call g:cPath() \| exe 'call rename("' . @f . '","' . input('rename to: ', @f) . '")' \| call g:dir(@p)<cr>

" open file in split
nmap <space>s :call g:cPath() \| exe 'split \| enew \| e ' . @p . @f<cr>

" list directory in a split window
nmap <space>S :call g:cPath() \| exe 'split \| enew' \| call g:dir(@p)<cr>

" open file in tab
nmap <space>t :call g:cPath() \| exe 'tabe ' . @p . @f<cr>

" list current directory in a tab (no need to have already a directory browser opened) 
nmap <space>T :call g:cPath() \| call g:dirTab(@p . @f)<cr>

" open filename in clipboard in current tab
nmap <space>u :exe 'e ' . getreg('*')<cr>

" open filename in clipboard in new tab
nmap <space>U :exe 'tabe ' . getreg('*')<cr>

" open file in vsplit
nmap <space>v :call g:cPath() \| exe 'vsplit \| enew \| e ' . @p . @f<cr>

" list current directory in a vsplit window
nmap <space>V :call g:cPath() \| exe 'vsplit \| enew' \| call g:dir(@p)<cr>

" write append directory listing to disk
nmap <space>w :exe 'silent! w! >> ' . input('save (append) directory listing to: ', g:dirListPath . 'dirlist_')<cr>

" write overwrite directory listing to disk
nmap <space>W :exe 'w! ' . input('save (overwrite) directory listing to: ', g:dirListPath . 'dirlist_')<cr>

" open current directory in windows explorer
nmap <space>x :call g:cPath() \| silent exe '!start explorer "' . @p . '"'<cr>

" Show tree of directory and subdirectories using the tree command
nmap <space>X :call g:cPath() \| call g:tree(@p . @f)<cr>

" list the directory of the path in clipboard (with or without filename) in a new split window
nmap <space>y :call g:dirSplit(fnamemodify(@*, ":p:h"))<cr>

" list the directory of the path in clipboard (with or without filename) in the current buffer
nmap <space>Y :call g:dir(fnamemodify(@*, ":p:h"))<cr>

" open utl link under cursor in split windows (utl plugin required)
nmap <space>z :Utl openLink underCursor split<cr>	

" open utl link under cursor in tab (utl plugin required)
nmap <space>Z :Utl openLink underCursor tabe<cr>	

" Check clues to know if the current file (buffer) is a dirlisting from this plugin
function! s:isDir()
    let i = 0
    " search for the .:\ string
    let match = ''
    let match = search(' .:\', 'n')    
    if match != ''
        let i = i + 1
    endif
    " search for a time string
    let match = ''
    let match = search('[0-9]\{2\}:[0-9]\{2\}', 'n')
    if match != ''
        let i = i + 1
    endif
    if i == 2
        return 1
    else 
        return 0
    endif
endfunction

" Diversify the path in other forms of path (4 paths format) 
" 1- in @p (directory only) with \
" 2- in @* (directory and filename) with \ 
" 3- in @z (directory only) with /
" 4- in @x (directory and filename) with /
" 5- in @f (filename only)
function! s:divPath()
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

" If current file is a directoryBrowser, copy the path and the filename from the directory listing
function! g:cPath()
    if s:isDir() == 1
        " On windows 2000 (39)
        "exe 'normal mf039l"fy$' 
        " On Windows 7 (36)
        if g:dirOwner == ''
            let l:nbChar = 36
        else
            let l:nbChar = 59
        endif
        exe 'normal mf0' . l:nbChar . 'l"fy$' 
        call search(' .:\', 'b') 
        exe 'normal l"py$`f' 
        call s:divPath()
    endif
endfunction

" If current file is not directoryBrowser but another file, get path and filename from its filename (%)
" Used to put inside utl links so that the same links for example may be executed inside a file as well as from the contextual menu of directoryBrowser
function! g:cPathF()
    if s:isDir() == 0
        let @p = expand('%:p:h')
        let @f = expand('%:t') 
        call s:divPath()
    endif
endfunction

" to copy the path from a lnk (shortcut) file to a directory (the lnk path is copied to the @* register)
function! g:cPathLnk()
    call g:cPath()
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
    let l:path = substitute(a:path, '/', '\\', 'g')
    " Add trailing backslash in case there is no
    let l:path = l:path . '\'
    " Remove extra trailing backslashes if any
    let l:path = substitute(l:path, '\\\\', '\\', 'g')
    " List subdirectories recursively
    if g:dirRecursive
       let l:recursive = '/S' 
    else
       let l:recursive = '' 
    endif
    normal G
    exe 'r! dir ' . g:dirSort . ' ' . g:dirAttributes . ' ' . g:dirTime . ' ' . l:recursive . ' ' . g:dirOwner . ' /4 "' . l:path . g:dirFilter . '"'
    call search(' .:\', 'b')
    normal zt2j0
    exe 'cd ' . l:path
endfunction

" Show directory tree recursively of the selected directory
function! g:tree(path)
    exe 'r! tree ' . '"' . a:path . '"'
    call search('^.:\', 'b')
endfunction

" Recursive files find 
function! g:dirFind()
    call g:cPath()
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
    call g:cPath()
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
        call g:cPath()
        silent exe '!del /S/Q "' . @p . @f . '"'
        silent exe '!rmdir /S/Q "' . @p . @f . '"'
        call g:dir(@p)
    endif
endfunction

" List the available volumes and some other details about shares and computers
function! g:dirVolumes(showDetails)
    call append(line('$'), 'Volumes') 
	for i in range(1, 26)
	  let l:vol = nr2char(i + 96)
      if isdirectory(l:vol . ':\')
         call append(line('$'), l:vol . ':') 
         " More slow when details are showned (names are showned using the vol command)
         if (a:showDetails)
             let l:volName = system('vol ' . l:vol . ':')
             call append(line('$'), l:volName)
         endif
      endif   
	endfor
    normal G
    " Add some information about shares and computers to the volume list
    if (a:showDetails)
        silent exe 'r! net share'
        silent exe 'r! net config workstation'
        silent exe 'r! net view'
    endif
    call search('Volumes', 'b') 
    normal zt0
endfunction

" Mappings to some root directories
nmap \. :call g:dir('.')<cr>
nmap \a :call g:dir('a:/')<cr>
nmap \b :call g:dir('b:/')<cr>
nmap \c :call g:dir('c:/')<cr>
nmap \d :call g:dir('d:/')<cr>
nmap \e :call g:dir('e:/')<cr>
nmap \f :call g:dir('f:/')<cr>
nmap \g :call g:dir('g:/')<cr> 
nmap \h :call g:dir('h:/')<cr>
nmap \i :call g:dir('i:/')<cr>
nmap \j :call g:dir('j:/')<cr>
nmap \k :call g:dir('k:/')<cr>
nmap \l :call g:dir('l:/')<cr>
nmap \m :call g:dir('m:/')<cr>
nmap \o :call g:dir('o:/')<cr>
nmap \p :call g:dir('p:/')<cr>
nmap \q :call g:dir('q:/')<cr>
nmap \r :call g:dir('r:/')<cr>
nmap \s :call g:dir('s:/')<cr>
nmap \t :call g:dir('t:/')<cr>
nmap \u :call g:dir('u:/')<cr>
nmap \v :call g:dir('v:/')<cr>
nmap \w :call g:dir('w:/')<cr>
nmap \x :call g:dir('x:/')<cr>
nmap \y :call g:dir('y:/')<cr>
nmap \z :call g:dir('z:/')<cr>
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
nmap -a :call g:dirSplit('a:/')<cr>
nmap -b :call g:dirSplit('b:/')<cr>
nmap -c :call g:dirSplit('c:/')<cr>
nmap -d :call g:dirSplit('d:/')<cr>
nmap -e :call g:dirSplit('e:/')<cr>
nmap -f :call g:dirSplit('f:/')<cr>
nmap -g :call g:dirSplit('g:/')<cr> 
nmap -h :call g:dirSplit('h:/')<cr>
nmap -i :call g:dirSplit('i:/')<cr>
nmap -j :call g:dirSplit('j:/')<cr>
nmap -k :call g:dirSplit('k:/')<cr>
nmap -l :call g:dirSplit('l:/')<cr>
nmap -m :call g:dirSplit('m:/')<cr>
nmap -o :call g:dirSplit('o:/')<cr>
nmap -p :call g:dirSplit('p:/')<cr>
nmap -q :call g:dirSplit('q:/')<cr>
nmap -r :call g:dirSplit('r:/')<cr>
nmap -s :call g:dirSplit('s:/')<cr>
nmap -t :call g:dirSplit('t:/')<cr>
nmap -u :call g:dirSplit('u:/')<cr>
nmap -v :call g:dirSplit('v:/')<cr>
nmap -w :call g:dirSplit('w:/')<cr>
nmap -x :call g:dirSplit('x:/')<cr>
nmap -y :call g:dirSplit('y:/')<cr>
nmap -z :call g:dirSplit('z:/')<cr>
nmap -A :call g:dirVSplit('a:/')<cr>
nmap -B :call g:dirVSplit('b:/')<cr>
nmap -C :call g:dirVSplit('c:/')<cr>
nmap -D :call g:dirVSplit('d:/')<cr>
nmap -E :call g:dirVSplit('e:/')<cr>
nmap -F :call g:dirVSplit('f:/')<cr>
nmap -G :call g:dirVSplit('g:/')<cr> 
nmap -H :call g:dirVSplit('h:/')<cr>
nmap -I :call g:dirVSplit('i:/')<cr>
nmap -J :call g:dirVSplit('j:/')<cr>
nmap -K :call g:dirVSplit('k:/')<cr>
nmap -L :call g:dirVSplit('l:/')<cr>
nmap -M :call g:dirVSplit('m:/')<cr>
nmap -O :call g:dirVSplit('o:/')<cr>
nmap -P :call g:dirVSplit('p:/')<cr>
nmap -Q :call g:dirVSplit('q:/')<cr>
nmap -R :call g:dirVSplit('r:/')<cr>
nmap -S :call g:dirVSplit('s:/')<cr>
nmap -T :call g:dirVSplit('t:/')<cr>
nmap -U :call g:dirVSplit('u:/')<cr>
nmap -V :call g:dirVSplit('v:/')<cr>
nmap -W :call g:dirVSplit('w:/')<cr>
nmap -X :call g:dirVSplit('x:/')<cr>
nmap -Y :call g:dirVSplit('y:/')<cr>
nmap -Z :call g:dirVSplit('z:/')<cr>
nmap =a :call g:dirTab('a:/')<cr>
nmap =b :call g:dirTab('b:/')<cr>
nmap =c :call g:dirTab('c:/')<cr>
nmap =d :call g:dirTab('d:/')<cr>
nmap =e :call g:dirTab('e:/')<cr>
nmap =f :call g:dirTab('f:/')<cr>
nmap =g :call g:dirTab('g:/')<cr> 
nmap =h :call g:dirTab('h:/')<cr>
nmap =i :call g:dirTab('i:/')<cr>
nmap =j :call g:dirTab('j:/')<cr>
nmap =k :call g:dirTab('k:/')<cr>
nmap =l :call g:dirTab('l:/')<cr>
nmap =m :call g:dirTab('m:/')<cr>
nmap =o :call g:dirTab('o:/')<cr>
nmap =p :call g:dirTab('p:/')<cr>
nmap =q :call g:dirTab('q:/')<cr>
nmap =r :call g:dirTab('r:/')<cr>
nmap =s :call g:dirTab('s:/')<cr>
nmap =t :call g:dirTab('t:/')<cr>
nmap =u :call g:dirTab('u:/')<cr>
nmap =v :call g:dirTab('v:/')<cr>
nmap =w :call g:dirTab('w:/')<cr>
nmap =x :call g:dirTab('x:/')<cr>
nmap =y :call g:dirTab('y:/')<cr>
nmap =z :call g:dirTab('z:/')<cr>

" Abbreviations used with the utl plugin to insert links and references (see utl documentation)
" This command pastes a path from clipboard for utl with and change slashes to forward
abb uu <url://>ha<esc>:let @*=substitute(@*, '\', '/', 'g')<cr>"+p
abb uuu <url:>ha<esc>:let @*=substitute(@*, '\', '/', 'g')<cr>"+p
abb uuuu <url:vimscript:split \| e! >ha<esc>:let @*=substitute(@*, '\', '/', 'g')<cr>"+p
abb uuuuu <url:vimscript:call g:dirSplit('')>3ha<esc>:let @*=substitute(@*, '\', '/', 'g')<cr>"+p
abb UU <url:#>h<esc>p
abb UUU <url:#tp=>h<esc>p
abb UUUU <url:#line=>h<esc>"+p
" Insert a reference number (date and time) in the file and copies the link to this reference in the clipboard
abb uur <esc>:let tmp=strftime("%y%m%d%H%M%S")<cr>:let @*="<url://" . substitute(expand("%:p:h") . '/' . expand("%:t"), '\', '/', 'g') . "#" . expand(tmp) . ">"<CR>:let @0=expand(tmp)<cr>"0p

" Commands shortcuts
" If commands were previously entered, you may use the up/down or ctrl+p/ctrl+n on the command line after doing <space>;
function! g:cmdExe(c)
    exe g:cmdDict[a:c]
endfunction

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

" open default 'browsing history' file, useful for fast browsing
function! g:openDirList_()
    split
    if filereadable(g:dirListPath . 'dirlist_')
        exe 'e ' . g:dirListPath . 'dirlist_'
    else
        enew
        call g:dir('c:/')
        exe 'w ' . g:dirListPath . 'dirlist_'
    endif    
endfunction
