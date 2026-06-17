scriptencoding utf-8

if !exists('*CopilotChat')
    finish
endif

" map Cmd+Enter to submit chat message
inoremap  <C-o>:SubmitChatMessage<CR>
