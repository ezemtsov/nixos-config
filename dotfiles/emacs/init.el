(setq comp-deferred-compilation nil)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize) ;; Initialize nix packages

;; Global configuration
(use-package emacs
  :init
  (setq custom-file "~/.emacs.d/custom.el")

  (recentf-mode t) ;; remember previous files
  (blink-cursor-mode 0) ;; stop blinking
  (windmove-default-keybindings) ;; move with arrows
  (delete-selection-mode t) ;; delete on paste
  (electric-pair-mode t) ;; smart parentesis wrapping

  (setq gc-cons-threshold (* 100 1000 1000))
  (setq gc-cons-percentage 0.6)

  ;; Trim heap fragmentation hourly, glibc is greedy
  (run-with-timer 0 3600 (lambda () (malloc-trim 0)))
  (midnight-mode t) ;; Offload buffers nightly

  (global-auto-revert-mode t)
  (setq global-auto-revert-non-file-buffers t)

  (winner-mode t) ;; be able to undo window change
  (auto-save-mode nil)

  ;; Just kill the vterm buffers, don't ask
  (setq kill-buffer-query-functions nil)

  ;; Copy on selection
  (setq mouse-drag-copy-region t)

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

  (which-key-mode t) ;; show options
  (setq-default indent-tabs-mode nil) ;; disable tabs
  (setq tab-width 4) ;; 4 spaces always
  (setq js-indent-level 2)

  (defun clean () (interactive) (mapc 'kill-buffer (buffer-list))) ;; kill all buffers
  (setq ring-bell-function 'ignore)
  (global-goto-address-mode) ;; enable URLs as hyperlinks. Navigate with C-c RET

  ;; avoid unnecessary window resizing
  (setq even-window-sizes nil)

  ;; Enable auto completion globally
  (global-completion-preview-mode t)

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
  (inhibit-startup-message t) ;; disable startup screen
  (initial-scratch-message nil) ;; remove startup message
  (dired-mouse-drag-files t) ;; drag'n'drop from emacs
  (dired-listing-switches "-alFh") ;; show human-readable dired
  (auto-save-file-name-transforms '((".*" "/tmp/" t))) ;; keep trash away from source
  (backup-directory-alist '((".*" . "/tmp/"))) ;; keep trash away from source
  (magit-display-buffer-function ;; show magit in the same buffer
   'magit-display-buffer-same-window-except-diff-v1)

  ;; (mouse-drag-copy-region t) ;; copy mouse selection by default
  ;; (setq mouse-autoselect-window t) ;; select buffer with mouse
  ;; (setq focus-follows-mouse t)

  ;; Disable creation of lock-files named .#<filename>.
  (setq-default create-lockfiles nil)

  :hook
  (prog-mode . hl-line-mode)
  (prog-mode . display-line-numbers-mode)
  (prog-mode . show-paren-mode)
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
  ("C-q" . kill-buffer-and-its-windows)
  ("M->" . flymake-goto-next-error)
  ("M-<" . flymake-goto-prev-error))

;; Automatically use tree-sitter modes when available
(use-package treesit
  :config
  (setq major-mode-remap-alist
        '((python-mode . python-ts-mode)
          (rust-mode . rust-ts-mode)
          (json-mode . json-ts-mode)
          (go-mode . go-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (javascript-mode . js-ts-mode)
          (js-mode . js-ts-mode)
          (css-mode . css-ts-mode)
          (html-mode . html-ts-mode)
          (yaml-mode . yaml-ts-mode)
          (sh-mode . bash-ts-mode)
          (c-mode . c-ts-mode)
          (c++-mode . c++-ts-mode)
          (cmake-mode . cmake-ts-mode)
          (dockerfile-mode . dockerfile-ts-mode)
          (toml-mode . toml-ts-mode))))

(use-package color-theme-sanityinc-tomorrow
  :ensure t
  :init
  (load-theme 'sanityinc-tomorrow-night t)
  :config
  ;; Better font rendering on Linux
  (setq x-use-underline-position-properties t)
  (setq underline-minimum-offset 1)

  ;; Pixel-precise font rendering
  (setq frame-resize-pixelwise t)
  (setq window-resize-pixelwise t)

  ;; Font settings
  (set-face-attribute 'default nil
                      :font "IBM Plex Mono Text"
                      :height 120
                      ;; :height 180
                      :weight 'regular)

  ;; Use different weights for emphasis
  (set-face-attribute 'bold nil :weight 'semibold)
  (set-face-attribute 'italic nil :slant 'italic)

  ;; Ensure proper emoji rendering with fallback
  (set-fontset-font t 'symbol "Noto Color Emoji" nil 'prepend)
  (set-fontset-font t 'unicode "Noto Color Emoji" nil 'append)

  ;; Make mode-line half height
  (set-face-attribute 'mode-line nil :height 80)
  (set-face-attribute 'mode-line-inactive nil :height 80)

  (menu-bar-mode 0)
  (scroll-bar-mode 0)
  (tool-bar-mode 0)
  (fringe-mode 0))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package savehist
  :init
  (defvar savehist-additional-variables)
  (savehist-mode 1))

(use-package project
  :init
  (add-hook 'savehist-mode-hook
            (lambda nil
              (add-to-list 'savehist-additional-variables 'project-compile)))
  :config
  (setq project-switch-commands #'project-find-file)
  (setq project-vc-extra-root-markers '(".gitignore")))

(use-package consult
  :ensure t
  :init
  ;; Appropriated from tazjin's little functions file
  ;; https://cs.tvl.fyi/depot/-/blob/users/tazjin/emacs/config/functions.el
  (defun executable-list ()
    "Creates a list of all external commands available on $PATH
     while filtering NixOS wrappers."
    (cl-loop
     for dir in (split-string (getenv "PATH") path-separator)
     when (and (file-exists-p dir) (file-accessible-directory-p dir))
     for lsdir = (cl-loop for i in (directory-files dir t)
                          for bn = (file-name-nondirectory i)
                          when (and (not (cl-search "-wrapped" i))
                                    (not (member bn completions))
                                    (not (file-directory-p i))
                                    (file-executable-p i))
                          collect bn)
     append lsdir into completions
     finally return (sort completions 'string-lessp)))

  (defvar consult-source-current-buffer
    (list :name "Current"
          :category 'buffer
          :action   #'consult--buffer-action
          :items    (list (buffer-name (current-buffer)))))

  (defvar consult-source-vterm
    (list :name "Vterm Sessions"
          :narrow ?v
          :category 'buffer
          :face 'consult-buffer
          :history 'buffer-name-history
          :state #'consult--buffer-state
          :action #'consult--buffer-action
          :items
          (lambda ()
            (mapcar #'buffer-name
                    (seq-filter
                     (lambda (buf)
                       (with-current-buffer buf
                         (eq major-mode 'vterm-mode)))
                     (buffer-list))))))

  (defun consult-vterm ()
    "List and switch to vterm sessions only."
    (interactive)
    (consult-buffer '(consult-source-vterm)))

  :custom
  (consult-buffer-sources
   '(consult-source-current-buffer
     consult-source-buffer
     consult-source-hidden-buffer
     consult-source-modified-buffer
     consult-source-recent-file
     (:name "Apps"
            :category app
            :items executable-list
            :action (lambda (cand) (start-process cand nil cand)))))
  :bind
  ("C-s" . consult-line)
  ("C-x b" . consult-buffer)
  ("C-x p s" . consult-ripgrep))

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
  :config
  (setq corfu-auto nil)
  (setq corfu-auto-delay 0.5)
  (setq corfu-echo-mode t)
  (setq corfu-popupinfo-mode t)
  :init
  (global-corfu-mode)
  :bind
  ("M-/" . completion-at-point))

;; File dabbrev & path extensions
(use-package cape
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-abbrev)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-dict)
  (add-to-list 'completion-at-point-functions #'cape-file)
  :bind
  ("M-d" . cape-file))

(use-package vundo
  :ensure t
  :init
  (setq vundo-compact-display t)
  (setq vundo-popup-timeout 0.7))

;; Use fish for vterm
(use-package vterm
  :defer t
  :custom
  (vterm-max-scrollback 5000)
  (vterm-timer-delay 0.01)
  (vterm-buffer-name-string "vterm %s")
  (vterm-shell "fish")
  :config
  ;; Allow custom commands from shell for dynamic buffer naming
  (add-to-list 'vterm-eval-cmds
               '("vterm-rename-buffer-with-command"
                 (lambda (cmd)
                   (let ((dir (file-name-nondirectory
                               (directory-file-name default-directory))))
                     (rename-buffer (format "vterm %s: %s" dir cmd) t)))))
  (add-to-list 'vterm-eval-cmds
               '("vterm-rename-buffer-by-directory"
                 (lambda ()
                   (let ((dir (file-name-nondirectory
                               (directory-file-name default-directory))))
                     (rename-buffer (format "vterm %s" dir) t))))))

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

(use-package buffer-move :ensure t)
(use-package rotate :ensure t)
(use-package rainbow-delimiters :ensure t)
(use-package markdown-mode :ensure t)
(use-package pdf-tools :ensure t)

(use-package tab-bar
  :config
  (setq tab-bar-tab-name-function 'tab-bar-tab-name-all)
  (setq tab-bar-separator "")
  (setq tab-bar-close-button-show nil) ;; Hide annoying close buttom
  (setq tab-bar-format '(tab-bar-format-tabs tab-bar-format-align-right tab-bar-format-global))
  (tab-bar-mode 1)
  (tab-bar-history-mode t)
  :custom
  (tab-bar-new-tab-choice
   (lambda () (get-buffer-create "*scratch*")))
  (tab-bar-tab-hints 1)
  (tab-bar-show nil)
  :bind
  ("C-s-<left>" . (lambda () (interactive) (tab-bar-move-tab -1)))
  ("C-s-<right>" . (lambda () (interactive) (tab-bar-move-tab 1))))

;;-----------------------------------------------------------
;; EWM Configuration (Wayland replacement for EXWM)
;;-----------------------------------------------------------

;; Module path is auto-detected from load-path. Override only if needed:
;; (setenv "EWM_MODULE_PATH" "~/git/ewm/compositor/target/debug/libewm_core.so")

(use-package ewm
  :commands (ewm-start-module ewm-transient)
  :init
  ;; Fullscreen toggle with window config restore
  (defvar fullscreen-buffer--state nil)
  (defun fullscreen-buffer--toggle ()
    "Maximize buffer, toggle back to previous layout."
    (interactive)
    (if fullscreen-buffer--state
        (let ((val (get-register (tab-bar--current-tab-index))))
          (register-val-jump-to val nil)
          (setq mode-line-format (default-value 'mode-line-format))
          (setq fullscreen-buffer--state nil))
      (progn
        (window-configuration-to-register (tab-bar--current-tab-index))
        (delete-other-windows)
        (setq mode-line-format nil)
        (setq fullscreen-buffer--state t))))


  :custom
  (ewm-output-config
   '(("DP-1" :width 2560 :height 1440)
     ("eDP-1" :scale 1.25)))
  (ewm-xkb-layouts '("us" "ru" "no" "se"))
  (ewm-xkb-options "grp:caps_toggle")
  (ewm-input-config '((touchpad :natural-scroll t)))

  :bind
  ;; Control panel - use s-c to start/stop/debug
  ("s-c" . ewm-transient)
  ;; Core actions - EWM auto-detects super-key bindings from keymap
  ("s-d" . consult-buffer)
  ("s-e" . rotate:even-horizontal)
  ("s-v" . rotate:even-vertical)
  ("s-f" . fullscreen-buffer--toggle)
  ("s-a" . consult-vterm)
  ("s-<return>" . (lambda () (interactive)
                    (vterm (concat "shell " default-directory))))
  ;; Buffer movement
  ("C-s-<left>" . buf-move-left)
  ("C-s-<right>" . buf-move-right)
  ("C-s-<up>" . buf-move-up)
  ("C-s-<down>" . buf-move-down)
  ;; Tab shortcuts
  ("S-s-<right>" . tab-bar-move-tab)
  ("S-s-<left>" . tab-bar-move-tab-backward)
  ("S-s-<down>" . tab-bar-history-back)
  ("S-s-<up>" . tab-bar-history-forward)
  ;; Input method switching (s-SPC prefix)
  ("s-SPC e" . (lambda () (interactive) (set-input-method nil)))
  ("s-SPC r" . (lambda () (interactive) (set-input-method 'russian-computer)))
  ("s-SPC n" . (lambda () (interactive) (set-input-method 'norwegian-keyboard)))
  ("s-SPC s" . (lambda () (interactive) (set-input-method 'swedish-keyboard))))

(use-package dumb-jump
  :ensure t
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package eglot
  :custom
  ;; shutdown eglot servers after buffer is closed
  (eglot-autoshutdown t))

(use-package eldoc-box
  :ensure t
  :bind
  :bind ("C-." . eldoc-box-help-at-point))

(use-package nix-ts-mode
  :ensure t
  :mode "\\.nix\\'"
  :custom
  (nix-nixfmt-bin "nixpkgs-fmt")
  :hook
  (nix-ts-mode . eglot-ensure))

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

(use-package tsx-ts-mode :mode "\\.tsx\\'")
(use-package tide
  :ensure t
  :hook ((typescript-ts-mode . tide-setup)
         (tsx-ts-mode . tide-setup)
         (typescript-ts-mode . tide-hl-identifier-mode)))

(use-package web-mode
  :ensure t
  :defer t
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode)))

(use-package highlight-indentation
  :ensure t
  :hook (fsharp-mode . highlight-indentation-mode))

(use-package eglot-fsharp
  :ensure t
  :custom
  ;; Use system-installed fsautocomplete from NixOS
  (eglot-fsharp-server-path "/run/current-system/sw/bin/")
  ;; Disable auto-installation since we're using the NixOS package
  (eglot-fsharp-server-install-dir nil))

(use-package fsharp-mode
  :ensure t
  :defer t
  :config
  (add-to-list 'auto-mode-alist '("\\.fsproj\\'" . nxml-mode))
  (add-to-list 'auto-mode-alist '("\\.csproj\\'" . nxml-mode))
  (setq fsharp-mode-project-root nil)
  :hook
  (fsharp-mode . eglot-ensure))

(use-package python-mode
  :ensure t
  :config
  (setenv "PYTHONENCODING" "utf-8")
  (setq python-indent-offset 4)
  :hook
  (python-mode . eglot-ensure))

(use-package typescript-mode
  :defer t
  :ensure t
  :custom
  (typescript-mode-indent-offset 4)
  :hook
  (typescript-mode . setup-tide-mode))

(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'"
  :hook
  (rust-mode . eglot-ensure))

(use-package json-mode
  :ensure t
  :mode "\\.json\\'"
  :hook
  (json-mode . eglot-ensure))

(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :config
  (setq-default tab-width 4)
  :hook
  (go-mode . eglot-ensure))

(use-package jupyter
  :ensure t
  :config
  (setq jupyter-repl-echo-eval-p t))

(use-package hcl-mode
  :ensure t
  :mode "\\.tf\\'")

(use-package telega
  :config
  (setq telega-emoji-use-images nil)
  (setq telega-use-images t)
  (setq telega-chat-show-avatars t)
  (setq telega-root-show-avatars t)
  (setq telega-user-show-avatars t)
  (setq telega-chat-history-limit 50)
  (telega-notifications-mode t))

(use-package eat
  :ensure t
  :config
  (eat-eshell-mode t))

(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind ("C-c C-'" . claude-code-ide-menu)
  :config
  (setq claude-code-ide-terminal-backend 'vterm)
  (setq claude-code-ide-use-ide-diff nil)
  (claude-code-ide-emacs-tools-setup))

(use-package envrc
  :ensure t
  :config
  (envrc-global-mode t))

(use-package yasnippet
  :ensure t
  :bind
  ("M-+" . yas-insert-snippet)
  :config
  (yas-global-mode t))

(use-package yasnippet-capf
  :ensure t
  :after cape
  :config
  (add-to-list 'completion-at-point-functions #'yasnippet-capf))

(use-package yasnippet-snippets
  :ensure t)

(use-package apheleia
  :ensure t
  :init
  (apheleia-global-mode t))

(use-package groovy-mode
  :ensure t)

(use-package kotlin-ts-mode
  :ensure t
  :mode "\\.kit\\'"
  :hook
  (kotlin-ts-mode . eglot-ensure))

(use-package go-mode
  :ensure t
  :custom
  (go-ts-mode-indent-offset 4))
