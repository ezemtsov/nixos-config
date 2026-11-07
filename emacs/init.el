;; -*- lexical-binding: t; -*-
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize) ;; Initialize nix packages

;; Global configuration
(use-package emacs
  :init
  ;; Keep Customize output beside this file
  (load (setq custom-file (locate-user-emacs-file "custom.el")) t)

  (recentf-mode t) ;; remember previous files
  (savehist-mode 1)
  (windmove-default-keybindings) ;; move with arrows

  ;; Trim heap fragmentation hourly, glibc is greedy
  (run-with-timer 0 3600 #'malloc-trim 0)
  (midnight-mode t) ;; Offload buffers nightly

  (global-auto-revert-mode t)

  (winner-mode t) ;; be able to undo window change

  ;; New frames open on *scratch*, like new tabs
  (add-hook 'after-make-frame-functions (lambda (frame) (with-selected-frame frame (scratch-buffer))))

  ;; Kill buffers with a live process without asking
  (remove-hook 'kill-buffer-query-functions #'process-kill-buffer-query-function)

  (defun split-window-below-focus ()
    (interactive)
    (split-window-below)
    (redisplay) ; https://github.com/emacs-exwm/exwm/issues/22
    (windmove-down))

  (defun split-window-right-focus ()
    "Split the window horizontally and focus the new window."
    (interactive)
    (split-window-right)
    (redisplay) ; https://github.com/emacs-exwm/exwm/issues/22
    (windmove-right))

  (defun clean () (interactive) (kill-matching-buffers-no-ask "" t)) ;; kill all buffers

  ;; Setup emoji
  (setf use-default-font-for-symbols nil)

  (defun delete-word (arg)
    "Delete characters forward until encountering the end of a word.
With argument, do this that many times."
    (interactive "p")
    (delete-region (point) (progn (forward-word arg) (point))))

  (defun backward-delete-word (arg)
    "Delete characters backward until encountering the end of a word.
With argument, do this that many times."
    (interactive "p")
    (delete-word (- arg)))

  :custom
  (use-short-answers t)	;; y or n
  (initial-scratch-message nil) ;; remove startup message
  (dired-mouse-drag-files t) ;; drag'n'drop from emacs
  (dired-listing-switches "-alFh") ;; show human-readable dired
  (auto-save-file-name-transforms '((".*" "/tmp/" t))) ;; keep trash away from source
  (backup-directory-alist '((".*" . "/tmp/"))) ;; keep trash away from source
  (magit-display-buffer-function ;; show magit in the same buffer
   'magit-display-buffer-same-window-except-diff-v1)
  (create-lockfiles nil) ;; no .#<filename> lock files
  (blink-cursor-mode nil) ;; stop blinking
  (delete-selection-mode t) ;; delete on paste
  (electric-pair-mode t) ;; smart parentesis wrapping
  (which-key-mode t) ;; show options
  (global-goto-address-mode t) ;; enable URLs as hyperlinks. Navigate with C-c RET
  (minibuffer-follows-selected-frame nil) ;; Keep minibuffer local to the current frame
  (gc-cons-threshold (* 100 1000 1000))
  (gc-cons-percentage 0.6)
  (global-auto-revert-non-file-buffers t)
  (savehist-ignored-variables '(command-history))
  (mouse-drag-copy-region t "Copy on selection")
  (mouse-drag-and-drop-region t)
  (mouse-drag-and-drop-region-cross-program t)
  (indent-tabs-mode nil) ;; disable tabs
  (tab-width 4) ;; 4 spaces always
  (js-indent-level 2)
  (ring-bell-function 'ignore)
  (even-window-sizes nil) ;; avoid unnecessary window resizing
  (fringe-mode 0)
  (frame-resize-pixelwise t)
  (window-resize-pixelwise t)

  :hook
  (prog-mode . hl-line-mode)
  (prog-mode . display-line-numbers-mode)
  (before-save . whitespace-cleanup)

  :bind
  ("C-x 2" . split-window-below-focus)
  ("C-x 3" . split-window-right-focus)
  ("C-=" . text-scale-increase)
  ("C--" . text-scale-decrease)
  ("C-c a" . align-regexp)
  ("C-c w" . whitespace-cleanup)
  ("M-<backspace>" . backward-delete-word)
  ("C-x k" . kill-current-buffer)
  ("M-!" . async-shell-command)
  ("C-q" . kill-buffer-and-window))

;; Automatically prefer tree-sitter modes when grammars are available
(use-package treesit-auto
  :ensure t
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package doom-themes
  :ensure t
  :init
  (load-theme 'doom-molokai t)
  :config
  ;; Font settings
  (add-to-list 'default-frame-alist '(font . "IBM Plex Mono Text-12"))

  ;; Use different weights for emphasis
  (set-face-attribute 'bold nil :weight 'semibold)

  ;; Ensure proper emoji rendering with fallback
  (set-fontset-font t 'symbol "Noto Color Emoji" nil 'prepend)
  (set-fontset-font t 'unicode "Noto Color Emoji" nil 'append)

  (face-spec-set 'mode-line '((t :height 80 :box nil)))
  (face-spec-set 'mode-line-inactive '((t :height 80 :box nil)))

  (menu-bar-mode 0)
  (scroll-bar-mode 0)
  (tool-bar-mode 0)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :config
  ;; Keep the selected window on focus-out, otherwise ewm looks weird
  (advice-add 'doom-modeline-focus-change :override #'doom-modeline-set-selected-window))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package desktop
  :init (desktop-save-mode 1)
  :hook (magit-mode . desktop-save-buffer-as-bookmark)
  :config
  (defun desktop-save-bookmark (_)
    (bookmark-make-record))

  (defun desktop-restore-bookmark (_ _ record)
    (bookmark-handle-bookmark record)
    (current-buffer))

  (defun desktop-save-buffer-as-bookmark ()
    (when (assq major-mode desktop-buffer-mode-handlers)
      (setq-local desktop-save-buffer #'desktop-save-bookmark)))

  ;; Magit buffers are saved as their bookmark records.
  (dolist (mode
           '(magit-status-mode
             magit-log-mode
             magit-diff-mode
             magit-revision-mode
             magit-refs-mode))
    (add-to-list 'desktop-buffer-mode-handlers
                 (cons mode #'desktop-restore-bookmark))))

(use-package project
  :custom
  (project-switch-commands #'project-find-file)
  (project-vc-extra-root-markers '("go.mod" "Cargo.toml" ".gitignore")))

(use-package consult
  :ensure t
  :init
  (defvar consult-source-xdg-apps
    `(:name "Apps"
            :narrow ?a
            :category app
            :items ,(lambda ()
                      (mapcar #'car (ewm-list-xdg-apps)))
            :action ,#'ewm-launch-xdg-command))

  (defvar consult-source-current-buffer
    (list :name "Current"
          :category 'buffer
          :action   #'consult--buffer-action
          :items    (lambda () (list (buffer-name (window-buffer (minibuffer-selected-window)))))))

  :custom
  (consult-buffer-sources
   '(consult-source-current-buffer
     consult-source-buffer
     consult-source-hidden-buffer
     consult-source-modified-buffer
     consult-source-recent-file
     consult-source-xdg-apps))
  :bind
  ("C-s" . consult-line)
  ("C-x b" . consult-buffer)
  (:map project-prefix-map ("s" . consult-ripgrep)))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic)))

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :config
  (corfu-echo-mode 1)
  (corfu-popupinfo-mode 1)
  :bind
  ("M-/" . completion-at-point))

;; File dabbrev & path extensions
(use-package cape
  :ensure t
  :init
  (add-hook 'completion-at-point-functions #'cape-abbrev)
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-dict)
  (add-hook 'completion-at-point-functions #'cape-file)
  :bind
  ("M-C-d" . cape-file))

(use-package vundo
  :ensure t
  :custom
  (vundo-compact-display t))

(use-package rio
  :load-path "/home/ezemtsov/git/el-rio"
  :commands (rio rio-attach)
  :custom (rio-detach t) (rio-bell-functions '(ewm-workspace-mark-urgent ding)))

(use-package multiple-cursors
  :ensure t
  :bind
  ("C->" . 'mc/mark-next-like-this)
  ("C-<" . 'mc/mark-previous-like-this))

;; Spell checker
(use-package jinx
  :ensure t
  :hook (emacs-startup . global-jinx-mode)
  :bind
  ("M-$" . jinx-correct)
  ("C-M-$" . jinx-languages))

(use-package ultra-scroll
  :ensure t
  :config
  (ultra-scroll-mode t))

(use-package pdf-tools
  :ensure t
  :defer t
  :init (pdf-loader-install))

(use-package tab-bar
  :config
  (tab-bar-mode 1)
  (tab-bar-history-mode t)
  :custom
  (tab-bar-show nil)
  (tab-bar-new-tab-choice
   (lambda () (get-buffer-create "*scratch*"))))

;;-----------------------------------------------------------
;; EWM Configuration
;;-----------------------------------------------------------

(use-package ewm
  ;; Load at init so the compositor starts before the rest of the file.
  :demand t
  :load-path "/home/ezemtsov/git/ewm/lisp"
  :preface
  (defun ewm-firefox-keys ()
    (when (equal ewm-surface-app "firefox")
      (setq-local ewm-surface-emulate-keys '(("M-w" . "C-c") ("C-y" . "C-v")))))
  :init
  (add-to-list 'default-frame-alist '(alpha-background . 97))
  (add-to-list 'default-frame-alist '(blur-background . t))

  :bind (:map ewm-mode-map
              ("s-q" . kill-buffer-and-window)
              ("s-d" . consult-buffer)
              ("s-<return>" . (lambda () (interactive) (rio)))

              ("<print>" . (lambda () (interactive)
                             (start-process "screenshot" nil "dms" "screenshot")))

              ("s-C-<left>" . winner-undo)
              ("s-C-<right>" . winner-redo)

              ("s-<double-wheel-right>" . ewm-focus-right)
              ("s-<double-wheel-left>" . ewm-focus-left)
              ("s-<double-wheel-down>" . ewm-focus-down)
              ("s-<double-wheel-up>" . ewm-focus-up)

              ;; Input method switching (s-SPC prefix)
              ("s-SPC e" . (lambda () (interactive) (set-input-method nil)))
              ("s-SPC r" . (lambda () (interactive) (set-input-method 'russian-computer)))
              ("s-SPC n" . (lambda () (interactive) (set-input-method 'norwegian-keyboard)))
              ("s-SPC s" . (lambda () (interactive) (set-input-method 'swedish-keyboard))))

  :custom
  ;; Never prefer a stale .elc over a newer .el; this repo rebases often
  ;; and outdated byte-code surfaces as spurious void-variable errors.
  (load-prefer-newer t)
  (ewm-input-config '((touchpad :natural-scroll t :dwt nil)))
  (ewm-output-config
   '(
     ("eDP-1" :width 1920 :height 1200 :scale 1.0)
     ("DP-2" :width 3840 :height 1440 :scale 1.0 :refresh 100)
     ("DP-6" :width 3840 :height 2160 :scale 1.25 :refresh 120)
     ("Dell Inc. DELL P2725HE 87Z8C84" :width 1920 :height 1080 :scale 1.0 :transform 1)
     ("Dell Inc. DELL S2725QC JN0L464" :width 3840 :height 2160 :scale 1.5 :refresh 120)))
  (ewm-focus-follows-mouse t)
  (ewm-idle 300)
  (ewm-cursor-hide-when-typing nil)

  :config
  (add-hook 'ewm-update-app-hook #'ewm-firefox-keys)
  (ewm-start-module))

(use-package dumb-jump
  :ensure t
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package eglot
  :custom
  ;; shutdown eglot servers after buffer is closed
  (eglot-autoshutdown t)
  :hook
  ((python-ts-mode rust-ts-mode json-ts-mode go-ts-mode nix-ts-mode kotlin-ts-mode) . eglot-ensure))

(use-package flymake
  :bind (("M->" . flymake-goto-next-error) ("M-<" . flymake-goto-prev-error)))

(use-package eldoc-box
  :ensure t
  :bind ("C-." . eldoc-box-help-at-point))

(use-package nix-ts-mode
  :ensure t
  :mode "\\.nix\\'")

;; Add support for pushing to gerrit
(use-package magit
  :ensure t
  :config
  (defun magit-push-to-gerrit ()
    (interactive)
    (message (if (magit-commit-at-point) (magit-commit-at-point) "HEAD"))
    (let ((refspec (if (magit-commit-at-point) (magit-commit-at-point) "HEAD")))
      (message refspec)
      (magit-push-refspecs "origin" (format "%s:refs/for/master" refspec) nil)))

  (transient-append-suffix 'magit-push "p"
    '("R" "Push to gerrit" magit-push-to-gerrit)))

(use-package forge
  :ensure t
  :after magit
  :custom
  (forge-add-pullreq-refspec nil)
  (forge-owned-accounts '(("ezemtsov")))
  :init (setq forge-add-default-sections nil)
  :config
  (defun forge-insert-own-pullreqs ()
    "Insert authored and assigned pull requests as separate sections."
    (dolist (slot '(:author :assignee :reviewer))
      (forge-insert-pullreqs
       (forge--topics-spec :type 'pullreq :state 'open slot "ezemtsov" :limit 20 :order 'newest))))
  (add-hook 'magit-status-sections-hook #'forge-insert-own-pullreqs t))

(use-package tide
  :ensure t
  :hook (((typescript-ts-mode tsx-ts-mode) . tide-setup)
         (typescript-ts-mode . tide-hl-identifier-mode)))

(use-package go-ts-mode
  :defer t
  :custom
  (go-ts-mode-indent-offset 4))

(use-package jupyter
  :ensure t
  :custom (jupyter-repl-echo-eval-p t))

(use-package hcl-mode
  :ensure t
  :mode "\\.tf\\'")

(use-package telega
  :ensure t
  :config
  (setq telega-emoji-use-images nil
        telega-use-images t
        telega-chat-show-avatars t
        telega-root-show-avatars t
        telega-user-show-avatars t
        telega-chat-history-limit 50)
  (telega-notifications-mode t))

(use-package envrc
  :ensure t
  :config
  (envrc-global-mode t))

(use-package yasnippet
  :ensure t
  :bind
  ("M-+" . yas-insert-snippet)
  :init (yas-global-mode t))

(use-package yasnippet-capf
  :ensure t
  :defer t
  :init (add-hook 'completion-at-point-functions #'yasnippet-capf))

(use-package yasnippet-snippets
  :ensure t)

(use-package apheleia
  :ensure t
  :init
  (apheleia-global-mode t))

(use-package groovy-mode
  :ensure t)

(use-package kotlin-ts-mode :ensure t :defer t)
