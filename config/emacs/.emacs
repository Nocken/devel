;; .emacs

(add-to-list 'load-path "~/.emacs.d/lisp")

;;; uncomment this line to disable loading of "default.el" at startup
;; (setq inhibit-default-init t)

;; turn on font-lock mode
(global-font-lock-mode 1)

;; Fix the DEL key behavior
;(normal-erase-is-backspace-mode 1)

;; enable visual feedback on selections
(transient-mark-mode t)

;; show paren mode
(show-paren-mode t)

;; mouse
(mouse-wheel-mode t)

;; set tool-bar
(tool-bar-mode nil)

;; forbidden startup picture
(setq inhibit-startup-message t) 

;; set chinese enviroment
;(set-language-environment 'Chinese-GB)
;(set-keyboard-coding-system 'euc-cn)
;(set-clipboard-coding-system 'euc-cn)
;(set-terminal-coding-system 'euc-cn)
;(set-buffer-file-coding-system 'euc-cn)
;(set-selection-coding-system 'euc-cn)
;(modify-coding-system-alist 'process "*" 'euc-cn)
;(setq default-process-coding-system '(euc-cn . euc-cn))
;(setq-default pathname-coding-system 'euc-cn)
   
;; set tab width
(setq default-tab-width 4)
(setq c-basic-offset 4)

;; Xrefactory configuration part ;;
;; some Xrefactory defaults can be set here
;(defvar xref-current-project nil) ;; can be also "my_project_name"
;(defvar xref-key-binding 'global) ;; can be also 'local or 'none
;(setq load-path (cons "/home/me/.emacs.d/xref/emacs" load-path))
;(setq exec-path (cons "/home/me/.emacs.d/xref" exec-path))
;(load "xrefactory")
;; end of Xrefactory configuration part ;;
;(message "xrefactory loaded")
;; call xref cracker
;(call-process "crackxref")

;; Load CEDET
;(load-file "~/.emacs.d/lisp/cedet/common/cedet.elc")
;(load-file "/usr/share/emacs/site-lisp/cedet-common/cedet.el")

;; Enabling various SEMANTIC minor modes.  See semantic/INSTALL for more ideas.
;; Select one of the following:

;; * This enables the database and idle reparse engines
;;(semantic-load-enable-minimum-features)

;; * This enables some tools useful for coding, such as summary mode
;;   imenu support, and the semantic navigator
;(semantic-load-enable-code-helpers)

;; * This enables even more coding tools such as the nascent intellisense mode
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;(semantic-load-enable-guady-code-helpers)

;; * This turns on which-func support (Plus all other code helpers)
;(semantic-load-enable-excessive-code-helpers)

;; This turns on modes that aid in grammar writing and semantic tool
;; development.  It does not enable any other features such as code
;; helpers above.
;; (semantic-load-enable-semantic-debugging-helpers)

;; Fold Tags
;(global-set-key [(control tab)] 'senator-fold-tag-toggle)

;; Load ECB
;(add-to-list 'load-path "~/.emacs.d/lisp/ecb")
;(load-file "~/.emacs.d/lisp/ecb/ecb.elc")
;(require 'ecb)
;(setq ecb-tip-of-the-day nil)

;; Some Setting
;(global-set-key [f12] 'compile)
;(global-set-key [(control tab)] 'semantic-complete-analyze-inline)
;(global-set-key [f7] 'eshell)
;(global-set-key [f6] 'gdb)
;; (global-set-key [f11] 'enlarge-window)
;; (global-set-key [f12] 'enlarge-window-horizontally)
;; (global-set-key [f4] 'shrink-window-horizontally)
;(global-set-key [f12] 'ecb-activate)
;(global-set-key [(control f12)] 'ecb-deactivate)
;(global-set-key [(meta f12)] 'compile)

;; enable hippie-expand 
;(autoload 'senator-try-expand-semantic "senator")
;(setq hippie-expand-try-functions-list '(
;senator-complete-symbol 
;senator-try-expand-semantic
;try-expand-dabbrev 
;try-expand-dabbrev-visible 
;try-expand-dabbrev-all-buffers 
;try-expand-dabbrev-from-kill 
;try-complete-file-name-partially 
;try-complete-file-name 
;try-expand-all-abbrevs 
;try-expand-list 
;try-expand-line 
;try-complete-lisp-symbol-partially 
;try-complete-lisp-symbol)) 
;(global-set-key [(meta ?/)] 'hippie-expand) 
;;(global-set-key "\M-/" 'hippie-expand)

;; cscope support
;(add-to-list 'load-path "~/.emacs.d/cscope/contrib/xcscope")
(require 'xcscope)
(setq cscope-do-not-update-database t)

;; Global support
;(setq load-path (cons "~/share/gtags" load-path))
;(autoload 'gtags-mode "gtags" "" t)
;(setq c-mode-hook  '(lambda ()(gtags-mode 1)))
;(require 'xgtags)
;(add-hook 'c-mode-common-hook (lambda ()(xgtags-mode 1)))

;; set color theme
(if (eq window-system 'x)
 (progn
  ;(custom-set-variables
  ; '(color-theme-selection "Gnome 2" nil (color-theme)))
  ;(require 'color-theme)
  ;(color-theme-initialize)
  ;(color-theme-gnome2))
 )
)

;;set c style
;(add-hook 'c-mode-hook '(lambda() (c-set-style "linux")))
;;set c__ style
;(add-hook 'c++-mode-hook '(lambda() (c-set-style "linux")))
;;set style for all language support by cc-mode
;(add-hook 'c-mode-common-hook '(lambda() (c-set-style "linux")))

;; Start My Functions


;; End My Functions

;; Enable server/client mode
;(server-start)

;; load session
;; (add-to-list 'load-path "~/.emacs.d/session/lisp")
;(require 'session)
;;(load-file "~/.emacs.d/session/lisp/session.elc")
;(add-hook 'after-init-hook 'session-initialize)
;; If you want to use both desktop and session, use:
;(setq desktop-globals-to-save '(desktop-missing-file-warning))


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(desktop-enable t nil (desktop))
 '(desktop-missing-file-warning t)
 '(desktop-save-mode t nil (desktop))
 '(ecb-options-version "2.40")
 '(ecb-tip-of-the-day nil)
 '(semantic-mode t)
 '(semanticdb-default-save-directory "~/.semantic_cache.d"))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
