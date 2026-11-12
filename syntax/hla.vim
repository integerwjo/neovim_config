" Vim syntax file for HLA (High Level Assembly), x86 HLA 2.x.
" Language:    HLA
" Maintainer:  local configuration
" Last Change: 2026-11-12

if exists("b:current_syntax")
  finish
endif

syn case match
syn sync minlines=50

" Comments ------------------------------------------------------------------
syn keyword hlaTodo TODO FIXME XXX HACK NOTE contained
syn region hlaComment start="//" end="$" contains=hlaTodo,@Spell
syn region hlaComment start="/\*" end="\*/" contains=hlaTodo,@Spell

" Preprocessor --------------------------------------------------------------
syn match hlaPreProc /^\s*#\s*\w\+/
syn region hlaInclude start=/#\s*include\s*(\?/ end=/)/ keepend contains=hlaString,hlaPreProc

" Strings and characters ----------------------------------------------------
syn region hlaString start=/"/ skip=/\\"/ end=/"/ contains=@Spell
syn region hlaCharacter start=/'/ skip=/\\'/ end=/'/

" Numbers -------------------------------------------------------------------
syn match hlaNumber /\<\d[0-9_]*\%(\.\d[0-9_]*\)\?\%([eE][+-]\?\d\+\)\?\>/
syn match hlaNumber /\<0[xX][0-9a-fA-F_]\+\>/
syn match hlaNumber /\$[0-9a-fA-F][0-9a-fA-F_]*\>/
syn match hlaNumber /%[01][01_]*\>/

" Declarations, control flow, operators, pseudo-ops -------------------------
syn keyword hlaKeyword program procedure method iterator macro class namespace
syn keyword hlaKeyword begin end endp endproc endmethod enditerator endmacro
syn keyword hlaKeyword endclass endnamespace endtype endvar endstatic endreadonly
syn keyword hlaKeyword endstorage endenum endunion endrecord endfor endwhile
syn keyword hlaKeyword static readonly storage var type const val enum union record
syn keyword hlaKeyword if then elseif else endif
syn keyword hlaKeyword while do for repeat until forever break continue
syn keyword hlaKeyword try exception endtry finally raise anyexception
syn keyword hlaKeyword protected unprotected
syn keyword hlaKeyword return exit exitif jmp call halt terminate
syn keyword hlaKeyword import includelib
syn keyword hlaKeyword and or xor not shl shr mod div in
syn keyword hlaKeyword align equ textequ proc segment ends assume public external
syn keyword hlaKeyword extrn register stdcall cdecl pascal
syn keyword hlaKeyword byte word dword qword tbyte

" Data types ----------------------------------------------------------------
syn keyword hlaType boolean
syn keyword hlaType int8 int16 int32 int64 int128
syn keyword hlaType uns8 uns16 uns32 uns64 uns128
syn keyword hlaType real32 real64 real80
syn keyword hlaType char string cstring hstring pointer
syn keyword hlaType val_t var_t

" Registers -----------------------------------------------------------------
syn match hlaRegister /\<\%(r[0-9]\+[dwb]\?\|[re]\%(ax\|bx\|cx\|dx\|si\|di\|bp\|sp\)\|[abcd][lhx]\|[sd]i\|[sb]p\|[cdefgs]s\|[er]ip\|xmm[0-9]\+\|ymm[0-9]\+\|zmm[0-9]\+\|mm[0-7]\|st[0-7]\|cr[0-4]\|dr[0-7]\)\>/

" x86 instructions ----------------------------------------------------------
syn keyword hlaInstruction mov movsx movzx movsd movss movdqa movdqu movaps movups movq
syn keyword hlaInstruction lea push pop pusha popa pushad popad pushf popfd pushfq
syn keyword hlaInstruction popf popfd popfq xchg add adc sub sbb mul imul div idiv
syn keyword hlaInstruction inc dec neg not and or xor test cmp shl sal shr sar
syn keyword hlaInstruction rol ror rcl rcr bt bts btr btc bsf bsr
syn keyword hlaInstruction jmp je jz jne jnz jg jge jl jle ja jae jb jbe jc jnc
syn keyword hlaInstruction jo jno js jns jp jnp loop loope loopne loopz loopnz
syn keyword hlaInstruction call ret retn iret iretd int into nop hlt cli sti
syn keyword hlaInstruction cld std cmc clc stc lahf sahf
syn keyword hlaInstruction lods lodsb lodsw lodsd stos stosb stosw stosd
syn keyword hlaInstruction movs movsb movsw movsd cmps cmpsb cmpsw cmpsd
syn keyword hlaInstruction scas scasb scasw scasd in out ins outs
syn keyword hlaInstruction rep repe repne repz repnz enter leave bound
syn keyword hlaInstruction cwd cdq cbw cwde cdqe cqo xlat xlatb
syn keyword hlaInstruction seta setae setb setbe sete setg setge setl setle
syn keyword hlaInstruction setne setz setnz seto setno sets setns
syn keyword hlaInstruction cpuid rdtsc rdtscp rdmsr wrmsr syscall sysret
syn keyword hlaInstruction sysenter sysexit lgdt sgdt lidt sidt lldt sldt ltr str
syn keyword hlaInstruction lmsw smsw clts invd wbinvd
syn keyword hlaInstruction fld fst fstp fadd fsub fmul fdiv fcom fcomp fild
syn keyword hlaInstruction fist fistp fxch fabs fchs fsqrt fsin fcos fptan
syn keyword hlaInstruction fpatan f2xm1 fyl2x fyl2xp1 fninit finit fldz fld1
syn keyword hlaInstruction fldpi fldl2e fldl2t fldlg2 fldln2 fprem fprem1
syn keyword hlaInstruction frndint fscale fxtract

" HLA standard library namespaces ------------------------------------------
syn match hlaBuiltin /\<\%(stdout\|stdin\|stderr\|argv\|env\|fileio\|memory\|math\|rand\|datetime\|os\|win32\|console\|conv\|strings\|tables\|lists\|arrays\|cset\|patterns\|sockets\|threads\|filesys\|RADbg\)\>/

" Compile-time functions and parameters -------------------------------------
syn match hlaSpecial /@[A-Za-z_][A-Za-z0-9_]*/

" Labels and field declarations ---------------------------------------------
syn match hlaLabel /^\s*[A-Za-z_][A-Za-z0-9_]*\s*:/

" Operators -----------------------------------------------------------------
syn match hlaOperator /[-+*<>=!&|~^]\+/

" Highlight links -----------------------------------------------------------
hi def link hlaTodo        Todo
hi def link hlaComment     Comment
hi def link hlaPreProc     PreProc
hi def link hlaInclude     Include
hi def link hlaString      String
hi def link hlaCharacter   Character
hi def link hlaNumber      Number
hi def link hlaKeyword     Keyword
hi def link hlaType        Type
hi def link hlaRegister    Identifier
hi def link hlaInstruction Statement
hi def link hlaBuiltin     Function
hi def link hlaSpecial     Special
hi def link hlaLabel       Label
hi def link hlaOperator    Operator

let b:current_syntax = "hla"
