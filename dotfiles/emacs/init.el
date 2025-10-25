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

  (setq gc-cons-threshold (* 20 1000 1000))
  (setq gc-cons-percentage 0.6)

  (global-auto-revert-mode t)
  (setq global-auto-revert-non-file-buffers t)

  (winner-mode t) ;; be able to undo window change
  (auto-save-mode nil)

  ;; Just kill the vterm buffers, don't ask
  (setq kill-buffer-query-functions nil)

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
  (set-fontset-font t 'symbol "Noto Color Emoji" nil 'append)

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
  (mouse-autoselect-window t) ;; select buffer with mouse
  (focus-follows-mouse t)

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
  ("M-TAB" . completion-at-point)
  ("M-/" . completion-at-point)
  ("C-c a" . align-regexp)
  ("C-c w" . whitespace-cleanup)
  ("M-<backspace>" . backward-delete-word)
  ("C-x k" . kill-current-buffer)
  ("M-!" . async-shell-command)
  ("C-q" . kill-buffer-and-its-windows)
  ("M->" . flymake-goto-next-error)
  ("M-<" . flymake-goto-prev-error))

(use-package color-theme-sanityinc-tomorrow
  :ensure t
  :init
  (load-theme 'sanityinc-tomorrow-night t)
  :config
  (set-face-attribute 'default nil :font "JetBrains Mono-12")
  (set-face-attribute 'mode-line nil :height 0.8)
  (set-face-attribute 'tab-bar nil :height 0.8)
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

  (defvar consult--source-current-buffer
    (list :name "Current"
          :category 'buffer
          :action   #'consult--buffer-action
          :items    (list (buffer-name (current-buffer)))))

  :custom
  (consult-buffer-sources
   '(consult--source-current-buffer
     consult--source-buffer
     consult--source-hidden-buffer
     consult--source-modified-buffer
     consult--source-recent-file
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
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package undo-tree
  :ensure t
  :config
  (undo-tree-mode t))

;; Use fish for vterm
(use-package vterm
  :defer t
  :custom
  (vterm-max-scrollback 10000)
  (vterm-timer-delay 0.01)
  (vterm-buffer-name-string "vterm %s")
  (vterm-shell "fish")
  :bind
  ("C-<return>" . (lambda () (interactive) (vterm (concat "shell " default-directory)))))

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
  (tab-bar-show t)
  :bind
  ("C-s-<left>" . (lambda () (interactive) (tab-bar-move-tab -1)))
  ("C-s-<right>" . (lambda () (interactive) (tab-bar-move-tab 1))))

(use-package i3bar
  :ensure t
  :config
  (i3bar-mode t))

;;-----------------------------------------------------------
;; EXWM Configuration
;;-----------------------------------------------------------
(use-package exwm
  :config
  (require 'exwm)
  (require 'exwm-randr)
  (require 'exwm-systemtray)
  (require 'exwm-xim)
  (require 'exwm-layout)

  (defun screen-lock ()
    (interactive)
    (start-process "xsecurelock" nil "xsecurelock"))

  (defun volume-mute ()
    (interactive) (shell-command "pactl set-sink-mute \"alsa_output.pci-0000_00_1f.3.analog-stereo\" toggle")
    (message "Speakers mute toggled"))

  (defun volume-up ()
    (interactive) (shell-command "pactl set-sink-volume \"alsa_output.pci-0000_00_1f.3.analog-stereo\" +5%")
    (message "Speakers volume up"))

  (defun volume-down ()
    (interactive) (shell-command "pactl set-sink-volume \"alsa_output.pci-0000_00_1f.3.analog-stereo\" -5%")
    (message "Speakers volume down"))

  (defvar fullscreen-buffer--state nil)

  (defun fullscreen-buffer--toggle ()
    "Maximize buffer"
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

  (defun tab-bar-select-or-return ()
    "This function behaves like `tab-bar-select-tab', except it calls
`tab-recent' if asked to jump to the current tab. This simulates
the back&forth behaviour of i3."
    (interactive)
    (let* ((key (event-basic-type last-command-event))
           (tab (if (and (characterp key) (>= key ?1) (<= key ?9))
                    (- key ?0)
                  0))
           (current (1+ (tab-bar--current-tab-index))))
      (if (eq tab current)
          (tab-recent)
        (tab-bar-select-tab tab))))

  ;;-----------------------------------------------------------
  ;; Experimental stuff
  ;;-----------------------------------------------------------
  ;; Attempt to ensure correct external monitor handling

  (defun my/exwm-ensure-workspaces (num-workspaces)
    "Ensure there are NUM-WORKSPACES created in EXWM"
    (let ((current-num-workspaces (length exwm-workspace--list)))
      (when (< current-num-workspaces num-workspaces)
        (dotimes (_ (- num-workspaces current-num-workspaces))
          (exwm-workspace-add))
        (message "Created %d new workspaces" (- num-workspaces current-num-workspaces)))
      (when (> current-num-workspaces num-workspaces)
        (dotimes (i (- current-num-workspaces num-workspaces))
          (exwm-workspace-delete))
        (message "Deleted %d workspaces" (- current-num-workspaces num-workspaces)))))

  (defun my/xrandr-list ()
    "xrandr query to get a list of monitors"
    (split-string (shell-command-to-string "xrandr --listmonitors | awk '{print $4}'") "\n" t))

  (defun my/exwm-update-workspaces ()
    "Ensure every connected monitor has a dedicated EXWM workspace"
    (let* ((monitors (my/xrandr-list))
           (num-monitors (length monitors)))
      ;; Ensure enough workspaces exist
      (my/exwm-ensure-workspaces num-monitors)
      ;; Clear current RANDR configuration
      (setq exwm-randr-workspace-monitor-plist nil)
      (dotimes (i num-monitors)
        ;; Assign a workspace to each monitor
        (setq exwm-randr-workspace-monitor-plist
              (append exwm-randr-workspace-monitor-plist
                      (list i (nth i monitors)))))
      (my/exwm-ensure-workspaces num-monitors)
      (message "Updated workspaces for monitors: %s" monitors)))

  (add-hook 'exwm-randr-refresh-hook #'my/exwm-update-workspaces)

  ;; Expect for browser, it should be named over it's tab
  (setq exwm-update-title-hook nil)
  (add-hook 'exwm-update-title-hook
            (lambda ()
              (cond ((member exwm-class-name '("firefox"))
                     (exwm-workspace-rename-buffer (format " %s" exwm-title)))
                    ((member exwm-class-name '("Beeper"))
                     (exwm-workspace-rename-buffer (format " %s" exwm-title)))
                    ((member exwm-class-name '("Slack"))
                     (exwm-workspace-rename-buffer (format " %s" exwm-title))))))

  ;; This is a nice macro that allows remap global exwm keys without
  ;; emacs restart. Found here: https://oremacs.com/2015/01/17/setting-up-ediff
  (defmacro csetq (variable value)
    `(funcall (or (get ',variable 'custom-set)
                  'set-default)
              ',variable ,value))

  ;; Note that using global keys is important to be able to reach
  ;; shortcuts for some X-based apps that take over keyboard, for
  ;; example Telegram Desktop.
  (csetq exwm-input-global-keys
         `(
           ;; Core actions
           (, (kbd "s-d") . consult-buffer)
           (, (kbd "s-e") . rotate:even-horizontal)
           (, (kbd "s-v") . rotate:even-vertical)
           (, (kbd "s-f") . fullscreen-buffer--toggle)
           (, (kbd "s-F") . exwm-layout-toggle-fullscreen)
           (, (kbd "s-Q") . exwm-workspace-delete)

           (, (kbd "s-a") . claude-code-ide-toggle)

           ;; Start programs
           (, (kbd "s-L") . (lambda () (interactive) (start-process "xsecurelock" nil "xsecurelock")))
           (, (kbd "s-<return>") . (lambda () (interactive) (vterm (concat "shell " default-directory))))
           (, (kbd "s-<print>") . (lambda () (interactive) (shell-command "exec flameshot gui")))

           ;; System keys
           (, (kbd "<XF86AudioMute>") . (lambda () (interactive) (shell-command-to-string "amixer set Master toggle")))
           (, (kbd "<XF86AudioLowerVolume>") . (lambda () (interactive) (shell-command-to-string "amixer set Master 10%-")))
           (, (kbd "<XF86AudioRaiseVolume>") . (lambda () (interactive) (shell-command-to-string "amixer set Master 10%+")))
           (, (kbd "<XF86MonBrightnessUp>") . (lambda () (interactive) (shell-command "light -A 10")))
           (, (kbd "<XF86MonBrightnessDown>") . (lambda () (interactive) (shell-command "light -U 10")))

           ;; Move focus
           (, (kbd "s-<left>") . (lambda () (interactive) (condition-case nil (windmove-left) (error (tab-previous)))))
           (, (kbd "s-<right>") . (lambda () (interactive) (condition-case nil (windmove-right) (error (tab-next)))))
           (, (kbd "s-<down>") . windmove-down)
           (, (kbd "s-<up>") . windmove-up)

           ;; Move buffers
           (, (kbd "C-s-<left>") . buf-move-left)
           (, (kbd "C-s-<right>") . buf-move-right)
           (, (kbd "C-s-<up>") . buf-move-up)
           (, (kbd "C-s-<down>") . buf-move-down)

           ;; tab shortcuts
           (, (kbd "s-w") . tab-close)
           (, (kbd "s-t") . tab-new)
           (, (kbd "S-s-<right>") . tab-bar-move-tab)
           (, (kbd "S-s-<left>") . tab-bar-move-tab-backward)
           (, (kbd "S-s-<down>") . tab-bar-history-back)
           (, (kbd "S-s-<up>") . tab-bar-history-forward)

           ;; Input switcher
           ,@(mapcar
              (lambda (spec)
                (let ((key (car spec))
                      (lang (cadr spec))
                      (method (caddr spec)))
                  `(,(kbd (format "s-<SPC> %s" key))
                    . (,lang . (lambda () (interactive) (set-input-method ,method))))))
              '(("e" "english" nil)
                ("r" "russian" 'russian-computer)
                ("n" "norwegian" 'norwegian-keyboard)
                ("s" "swedish" 'swedish-keyboard)))

           ;; Switch to tab by s-N
           ,@(mapcar (lambda (i)
                       `(,(kbd (format "s-%d" i)) .
                         tab-bar-select-or-return))
                     (number-sequence 1 9))

           ;; Resize buffers
           (, (kbd "C-M-<left>") . shrink-window-horizontally)
           (, (kbd "C-M-<right>") . enlarge-window-horizontally)
           (, (kbd "C-M-<up>") . shrink-window)
           (, (kbd "C-M-<down>") . enlarge-window)

           (, (kbd "s-O") . exwm-workspace-move-window)
           (, (kbd "s-o") . exwm-workspace-switch)

           (, (kbd "C-\\") . toggle-input-method)))

         ;; Force Slack to behave
         ;; https://github.com/ch11ng/exwm/issues/574#issuecomment-490814569
         (add-to-list 'exwm-manage-configurations '((equal exwm-class-name "Slack") managed t))

         ;; Show system tray
         (exwm-systemtray-mode t)

         (setq exwm-floating-setup-hook nil)
         (add-hook 'exwm-floating-setup-hook #'exwm-layout-show-mode-line)

         ;; Set static name for most of the x classes
         (add-hook 'exwm-update-class-hook
                   (lambda () (exwm-workspace-rename-buffer exwm-class-name)))

         ;; Line-editing shortcuts
         (exwm-input-set-simulation-key (kbd "C-r") (kbd "C-r")) ;; refresh page
         (exwm-input-set-simulation-key (kbd "C-d") (kbd "C-d")) ;; cancel process

         (exwm-input-set-simulation-key (kbd "M-w") (kbd "C-c")) ;; copy text
         (exwm-input-set-simulation-key (kbd "C-y") (kbd "C-v")) ;; paste text

         ;; Workspace setup
         (setq exwm-workspace-show-all-buffers t)
         (setq exwm-layout-show-all-buffers t)

         (add-hook 'exwm-randr-screen-change-hook #'exwm-randr-refresh)

         ;; Enable XIM
         (exwm-xim-mode t)
         (setenv "XMODIFIERS" "@im=exwm-xim")

         ;; Enable EXWM
         (exwm-randr-mode t)
         (exwm-wm-mode t))

(use-package exwm-modeline
  :ensure t
  :config
  (exwm-modeline-mode))

(use-package exwm-mff
  :ensure t
  :config
  (exwm-mff-mode t))

(use-package dumb-jump
  :ensure t
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package eglot
  :custom
  ;; shutdown eglot servers after buffer is closed
  (eglot-autoshutdown t))

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

;; (use-package tide
;;   :ensure t
;;   :config
;;   (tide-setup)
;;   (flycheck-mode +1)
;;   (setq flycheck-check-syntax-automatically '(save mode-enabled))
;;   (eldoc-mode +1)
;;   (tide-hl-identifier-mode +1))

(use-package web-mode
  :ensure t
  :defer t
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode)))

(use-package highlight-indentation
  :ensure t
  :hook (fsharp-mode . highlight-indentation-mode))

(use-package eglot-fsharp
  :ensure t)

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
  :config
  (add-hook 'before-save-hook #'eglot-format-buffer)
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
  :ensure t
  :config
  (setq telega-use-images t)
  (setq telega-emoji-use-images t)
  (setq telega-emoji-font-family  "Noto Color Emoji")
  (telega-notifications-mode t))

(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind ("C-c C-'" . claude-code-ide-menu)
  :config
  (setq claude-code-ide-use-ide-diff nil)
  (claude-code-ide-emacs-tools-setup))

(use-package gptel
  :ensure t)

(use-package envrc
  :ensure t)

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
