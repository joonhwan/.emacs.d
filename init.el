;;; init.el --- skeleton config  -*- lexical-binding: t; coding:utf-8 -*-
;; let emacs begins...

;;; Bootstrap
;; Speed up startup
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)
(add-hook 'after-init-hook
          `(lambda ()
             (setq gc-cons-threshold 800000
                   gc-cons-percentage 0.1)
             (garbage-collect)) t)

;; ** which box i am using? mac? windows?
;; [TIP] http://dreamstorm.cafe24.com/cgi-bin/moin.cgi/dreamstorm/emacs
(defconst win32p
  (if (eq system-type 'windows-nt) t nil)
  "true if win32 nt-emacs")
(defconst unixp
  (if (memq system-type '(hpux dgux usg-unix-v irix linux gnu/linux)) t nil)
  "true if any unix emacs")
(defconst officep
  (if (string-match "DESKTOP" system-name) t nil)
  "true if office pc")
(defconst macp
  (if (eq system-type 'darwin) t nil))
(defconst homep
  (not officep)
  "true if office pc")

;;
;; Package 환경설정(`use-package'/ `package')
;; 
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(setq-default use-package-always-ensure t ; Auto-download package if not exists
              use-package-always-defer t ; Always defer load package to speed up startup
              use-package-verbose nil ; Don't report loading details
              use-package-expand-minimally t  ; make the expanded code as minimal as possible
              use-package-enable-imenu-support t) ; Let imenu finds use-package definitions
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package)
  )
(eval-when-compile
  (require 'use-package)
  )

;; 
;; 전역 설정 모음.
;;
(setq-default inhibit-startup-message t
              initial-scratch-message nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(toggle-scroll-bar -1)
(set-frame-font "D2Coding" nil t)

;; 언어관련
(set-language-environment "Korean")
(setq default-input-method "korean-hangul390")
(setq default-korean-keyboard "3") 	; 3벌식
(global-set-key (kbd "S-SPC") 'toggle-input-method)
(prefer-coding-system 'utf-8)
;; i use command key as meta 
(setq mac-command-modifier 'meta)
(size-indication-mode t)
;; enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)
;; more useful frame title, that show either a file or a
;; buffer name (if the buffer isn't visiting a file)
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "Emacs : %b"))))
(defun my:shell ()
  (interactive)
  (let ((coding-system-for-read 'euc-kr-dos)
	(coding-system-for-write 'euc-kr-dos)
	(coding-system-require-warning t))
    (call-interactively 'shell))
  )


;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)
(global-linum-mode t)
(setq visible-bell t)

;;
;; Package별 설정
;;
(use-package diminish)
(use-package delight)
;; Safe cross-platform default font settings
;; hint from : https://www.reddit.com/r/emacs/comments/871vmb/safe_crossplatform_default_font_settings/
(use-package faces
  :ensure nil
  :custom
  (face-font-family-alternatives '(("D2Coding" "Consolas" "DejaVu Sans Mono" "Monaco" "Monospace")))
  :custom-face
  (fixed-pitch ((t nil)))
  (fixed-pitch-serif ((t nil)))
  :init
  (set-face-attribute 'default nil :family (caar face-font-family-alternatives) :weight 'regular :width 'semi-condensed)
  )

(use-package which-key
  :diminish
  :init
  (which-key-mode))
;; (use-package ido
;;   :config
;;   (setq
;;    ido-enable-flex-matching t
;;    ido-everywhere t
;;    ido-virtual-buffers t
;;    )
;;   (use-package ido-vertical-mode
;;     :requires ido
;;     :config
;;     (ido-vertical-mode)
;;     )
;;   :init
;;   (ido-mode 1)
;;   :bind
;;   ("C-x C-b" . 'ibuffer)
;;   )

(use-package helm
  :diminish helm-mode
  :init
  (progn
    (require 'helm-config)
    (setq helm-candidate-number-limit 100)
    ;; From https://gist.github.com/antifuchs/9238468
    (setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
          helm-input-idle-delay 0.01  ; this actually updates things
                                        ; reeeelatively quickly.
          helm-yas-display-key-on-candidate t
          helm-quick-update t
          helm-M-x-requires-pattern nil
          helm-ff-skip-boring-files t)
    (helm-mode)
    )
  :bind
  (("C-c h" . helm-mini)
   ("C-h a" . helm-apropos)
   ("C-x C-b" . helm-buffers-list)
   ("C-x b" . helm-buffers-list)
   ("M-y" . helm-show-kill-ring)
   ("M-x" . helm-M-x)
   ("C-x c o" . helm-occur)
   ("C-x c s" . helm-swoop)
   ("C-x c y" . helm-yas-complete)
   ("C-x c Y" . helm-yas-create-snippet-on-region)
   ("C-x c b" . my/helm-do-grep-book-notes)
   ("C-x c SPC" . helm-all-mark-rings))
  )

;; (use-package helm-unicode
;;   )

(use-package outshine
  :diminish outshine-mode
  ;; Easier navigation for source files, especially this one.
  :bind (:map outshine-mode-map
              ("<S-iso-lefttab>" . outshine-cycle-buffer)
              )
  :hook
  (emacs-lisp-mode . outshine-mode)
  )

(use-package dired
  :ensure nil
  :config
  (progn
    ;; always delete and copy recursively
    (setq dired-recursive-deletes 'always)
    (setq dired-recursive-copies 'always)
    ;; if there is a dired buffer displayed in the next window, use its
    ;; current subdir, instead of the current subdir of this dired buffer
    (setq dired-dwim-target t)
    (setq dired-listing-switches "-alh --group-directories-first")
    (cond
     (win32p
      (progn
 	(require 'ls-lisp)
 	(setq dired-listing-switches "-alh"
	      ;; ls-lisp-use-insert-directory-program nil
	      ;; ls-lisp-verbosity '('links 'uid)
	      ls-lisp-ignore-case t
	      ls-lisp-use-localized-time-format t
	      ls-lisp-format-time-list '("%y/%m/%d %H:%M:%S" "%y/%m/%d %H:%M:%S")
	      ls-lisp-dirs-first t
	      )
 	(setq ls-lisp-emulation (quote MS-Windows))
 	(ls-lisp-set-options) ;; special functionupdating parameters for ls-lisp
 	))
     (macp
      (message "macp")
      (setq
       ls-lisp-use-insert-directory-program nil
       ls-lisp-emulation 'MacOS
       ls-lisp-use-localized-time-format t
       ls-lisp-format-time-list '("%y/%m/%d %H:%M" "%y/%m/%d %H:%M")
       ls-lisp-dirs-first t
       )
      ))
    ;; enable some really cool extensions like C-x C-j(dired-jump)
    (require 'dired-x)
    )
  )

(use-package magit
  :bind ("C-c m" . magit-status)
  )

(use-package markdown-mode
  :mode ("\\.md\\'". markdown-mode)
  )

(use-package dracula-theme
  :init (load-theme 'dracula t)
  )

(use-package undo-tree
  :diminish undo-tree-mode
  :init (global-undo-tree-mode 1)
  :bind
  (("C-/" . undo-tree-undo)
   ("C-S-/" . undo-tree-redo)
   ;;("C-c l" . undo-tree-switch-branch)
   ("C-x u" . undo-tree-visualize))
  :ensure t)

(use-package recentf
  :hook (after-init . recentf-mode)
  :config
  (setq
   ;; recentf-save-file (expand-file-name "recentf" bozhidar-savefile-dir)
   recentf-max-saved-items 500
   recentf-max-menu-items 15
   ;; disable recentf-cleanup on Emacs start, because it can cause
   ;; problems with remote files
   recentf-auto-cleanup 'never
   )
  :bind
  ("C-c . f" . 'recentf-open-files)
  :init
  (recentf-mode +1)
  )

(use-package shell
  :init
  )  

;; When config gets stable, using emacs server may be more convenient
(require 'server)
(unless (server-running-p)
  (when (and (>= emacs-major-version 23)
           (equal window-system 'w32))
  (defun server-ensure-safe-dir (dir) "Noop" t)) ; Suppress error "directory
                                                 ; ~/.emacs.d/server is unsafe"
                                                 ; on windows.
  (server-start))

(cd "~")
;; 
;;
;;
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)
(put 'narrow-to-region 'disabled nil)
