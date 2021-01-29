syn match Special "[(){}\[\]<>,;]"  " darker parentheses
syn match Operator "[-+=?!$%^&*\\|~]"  " brighter operators
syn match Operator "[/*]\@<!/[/*]\@!"  " brighter '/' operator
syn match Operator "->\|<-\|<=\|>="  " brighter logicals
syn match Operator "\s\+[<>]\s\+"  " brighter logicals

" TODO:
" - haskell comments
