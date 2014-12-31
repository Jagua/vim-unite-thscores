" vim: set et fdm=marker ft=vim sts=2 sw=2 ts=2 :
" NEW BSD LICENSE {{{
" Copyright (c) 2014, Jagua.
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without modification,
" are permitted provided that the following conditions are met:
"
"     1. Redistributions of source code must retain the above copyright notice,
"        this list of conditions and the following disclaimer.
"     2. Redistributions in binary form must reproduce the above copyright notice,
"        this list of conditions and the following disclaimer in the documentation
"        and/or other materials provided with the distribution.
"     3. The names of the authors may not be used to endorse or promote products
"        derived from this software without specific prior written permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
" ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
" WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
" IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
" INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
" BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
" DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
" LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
" OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
" THE POSSIBILITY OF SUCH DAMAGE.
" }}}


scriptencoding utf-8


let s:save_cpo = &cpo
set cpo&vim


" This plugin requires ThScores pipe (by Jagua).
let s:rss_url = 'http://pipes.yahoo.com/pipes/pipe.run'
\             . '?_id=7b7c4ad5a9cfdc1005a68de6479d07bd&_render=rss'

let s:system = function(get(g:, 'thscores#system_function',
\                           unite#util#has_vimproc() ? 'vimproc#system' : 'system'))

let s:source = {
\ 'name' : 'thscores',
\ 'description' : 'Unite thscores',
\ 'default_action' : 'info',
\ 'parents': [],
\ 'action_table' : {
\   'echo' : {
\     'description' : 'echo this candidate.',
\     'is_quit' : 0,
\   },
\   'info' : {
\     'description' : 'show a comment.',
\     'is_quit' : 0,
\   },
\   'translate_info' : {
\     'description' : 'show a translated comment.',
\     'is_quit' : 0,
\   },
\   'replayDL' : {
\     'description' : 'download a replay file.',
\     'is_quit' : 0,
\   },
\ },
\}

let s:kind = deepcopy(s:source)

let s:V = vital#of('vital')

function! s:source.gather_candidates(args, context)
  let s:item = s:V.import('Web.XML').parseURL(s:rss_url).childNode('channel').childNodes('item')
  function! s:getval(node)
    return empty(a:node) ? '' : a:node.value()
  endfunction
  return map(copy(s:item), '{
  \ "word" : s:getval(v:val.childNode("title")),
  \ "action__path" : s:getval(v:val.childNode("title")),
  \ "kind" : "thscores",
  \ "thscore__replayUrl" : s:getval(v:val.childNode("link")),
  \ "thscore__comment" : s:getval(v:val.childNode("description")),
  \ }')
endfunction


function! unite#sources#thscores#define()
  return s:source
endfunction


function! s:kind.action_table.echo.func(candidate)
  echo a:candidate
endfunction


function! s:kind.action_table.info.func(candidate)
  echo a:candidate.thscore__comment
endfunction


function! s:kind.action_table.translate_info.func(candidate)
  echo mstrans#translate(a:candidate.thscore__comment,
  \                      '',
  \                      get(g:, 'mstrans_to', 'ja'))
endfunction


function! s:kind.action_table.replayDL.func(candidate)
  if executable('wget')
    call s:system('wget --content-disposition'
    \             .' --directory-prefix=' . expand('~/Downloads/')
    \             . ' ' . a:candidate.thscore__replayUrl)
  endif
endfunction


call unite#define_kind(s:kind)


function! s:unite_custom_settings()
  call unite#custom#profile('source/thscores', 'context', {
  \ 'profile_name' : 'source/thscores',
  \ })
  call unite#custom#alias('thscores', 'preview', 'info')
  call unite#custom#profile('source/thscores', 'substitute_patterns', {
  \ 'pattern' : '^\%(th06\|beni\)',
  \ 'subst' : '【紅】',
  \ 'priority' : 1,
  \ })
  call unite#custom#profile('source/thscores', 'substitute_patterns', {
  \ 'pattern' : '^\%(th07\|you\)',
  \ 'subst' : '【妖】',
  \ 'priority' : 1,
  \ })
  call unite#custom#profile('source/thscores', 'substitute_patterns', {
  \ 'pattern' : '^\%(th08\|ei\)',
  \ 'subst' : '【永】',
  \ 'priority' : 1,
  \ })
  call unite#custom#profile('source/thscores', 'substitute_patterns', {
  \ 'pattern' : '^\%(th10\|kaze\)',
  \ 'subst' : '【風】',
  \ 'priority' : 1,
  \ })
  call unite#custom#profile('source/thscores', 'substitute_patterns', {
  \ 'pattern' : '^\%(th11\|chi\|ti\)',
  \ 'subst' : '【地】',
  \ 'priority' : 1,
  \ })
  call unite#custom#profile('source/thscores', 'substitute_patterns', {
  \ 'pattern' : '^\%(th12\|hosh\=i\)',
  \ 'subst' : '【星】',
  \ 'priority' : 1,
  \ })
  call unite#custom#profile('source/thscores', 'substitute_patterns', {
  \ 'pattern' : '^\%(th128\|dai\)',
  \ 'subst' : '【大】',
  \ 'priority' : 2,
  \ })
  call unite#custom#profile('source/thscores', 'substitute_patterns', {
  \ 'pattern' : '^\%(th13\|kami\)',
  \ 'subst' : '【神】',
  \ 'priority' : 1,
  \ })
  call unite#custom#profile('source/thscores', 'substitute_patterns', {
  \ 'pattern' : '^\%(th14\|\%(kagaya\)\=ki\)',
  \ 'subst' : '【輝】',
  \ 'priority' : 1,
  \ })
endfunction


call s:unite_custom_settings()


let &cpo = s:save_cpo
unlet s:save_cpo

