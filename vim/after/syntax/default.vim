syn match Special "[(){}\[\]<>"'`,;]"  " darker parentheses
syn match Statement "->\|<=\|>="  " brighter logicals
syn match Statement "[-+=?!$%^&*|~:]"  " brighter operators
syn match Statement "\(/\)\@<!/\(/\)\@!" "birghter single forward-slashes
" TODO: fix Swift /* */ comments
