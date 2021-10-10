;; My custom emacs settings file

;; Common shortcuts:
;;    c-x c-f: find file
;;    m-x: run command
;;    c-x [->,<-]: switch buffers
;;    c-y: paste
;;    m-w: copy
;;    c-s: search
;;    m-.: declaration definition
;;    m-?: find use
;;    c-x c-s: save file
;;    c-x o: change cursor to other buffer
;;    c-x 3: split vertically
;;    c-x 2: split horizontally
;;    c-x 1: hide other windows
;;    c-/: undo
;; magit:
;;    c-x g: start magit
;;    h: help
;; Exwm:
;;    s-&: Launch application
;;    s-r: Switch to line-mode, exit fullscreen, refresh layout.
;;    s-[0-9]: Switch workspace
;; Helm-tramp:
;;    C-c s: start helm-tramp

(require 'package) ;; needed

;; package repositories
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-hook 'prog-mode-hook 'display-line-numbers-mode) ;; display line numbers on code
(add-hook 'prog-mode-hook 'show-paren-mode) ;; parenthesis highlighting on code
(display-time-mode 1) ;; Show clock

;;(setq inhibit-startup-message t) ;; disable startup screen
;;(desktop-save-mode 1) ;; save & restore last session (restores all buffers so not that useful)
(add-to-list 'default-frame-alist '(fullscreen . maximized)) ;; start maximized
;; (tool-bar-mode -1) ;; Remove gui toolbar
(add-to-list 'default-frame-alist '(font . "DejaVu Sans Mono-14")) ;; Font size to 14 (For high resolution screens, if text is too small)

;; automatically install use-package. Check if installed to prevent slowdown on startup.
(unless (package-installed-p 'use-package)
(package-refresh-contents)
(package-install 'use-package))

(use-package auto-package-update
  :ensure t
  :if (not (daemonp))
  :custom
  (auto-package-update-interval 7) ;; in days
  (auto-package-update-prompt-before-update t)
  (auto-package-update-delete-old-versions t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe))

;; GENERAL: Window Manager ++++++++++++++++++++++++++++++++++++
;; auto get: exwm: Makes Emacs the window manager using exwm. Leave disabled if using GNOME or other window manager.
(use-package exwm)
(use-package exwm-config
  :config
  (load-file "~/.emacs.d/exwm-config-custom.el")
)
 
(use-package exwm-systemtray
  :config
  (exwm-systemtray-enable))

;;(if (package-installed-p 'exwm) (
;;(require 'exwm)
;;(require 'exwm-config)
;;(exwm-config-default)
;;(require 'exwm-systemtray)
;;(exwm-systemtray-enable)
;;  ))


;; GENERAL: UI ++++++++++++++++++++++++++++++++++++++++++++++++

;; auto get: Helm configuration: better menus and searches
;;(use-package helm
;;  :ensure t
;;  :config
;;  (require 'helm-config)
;;  (global-set-key (kbd "M-x") 'helm-M-x)
;;    (global-set-key (kbd "C-x r b") 'helm-filtered-bookmarks)
;;    (global-set-key (kbd "C-x C-f") 'helm-find-files)
;;    (global-set-key (kbd "C-x C-b") 'helm-buffers-list)
;;    (global-set-key (kbd "C-s") 'helm-occur)
;;(setq rtags-display-result-backend 'helm)
;;  )

;; Autocomplete code snippets
(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :init
  (use-package yasnippet-snippets :ensure t :after yasnippet)
  :hook ((prog-mode LaTeX-mode org-mode) . yas-minor-mode)
  :bind
  (:map yas-minor-mode-map ("C-c C-n" . yas-expand-from-trigger-key))
  (:map yas-keymap
        (("TAB" . smarter-yas-expand-next-field)
         ([(tab)] . smarter-yas-expand-next-field)))
  :config
  (yas-reload-all)
  (defun smarter-yas-expand-next-field ()
    "Try to `yas-expand' then `yas-next-field' at current cursor position."
    (interactive)
    (let ((old-point (point))
          (old-tick (buffer-chars-modified-tick)))
      (yas-expand)
      (when (and (eq old-point (point))
                 (eq old-tick (buffer-chars-modified-tick)))
        (ignore-errors (yas-next-field))))))

;; Ivy: searches
(use-package ivy
  :ensure t
  :diminish
  :init
  (use-package amx :ensure t :defer t)
  (use-package counsel :ensure t :diminish :config (counsel-mode 1))
  (use-package swiper :ensure t :defer t)
  (ivy-mode 1)
  :bind
  (("C-s" . swiper-isearch)
   (:map ivy-minibuffer-map
         ("C-r" . ivy-previous-line-or-history)
         ("M-RET" . ivy-immediate-done))
   (:map counsel-find-file-map
         ("C-~" . counsel-goto-local-home)))
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-height 10)
  (ivy-on-del-error-function nil)
  (ivy-magic-slash-non-match-action 'ivy-magic-slash-non-match-create)
  (ivy-count-format "【%d/%d】")
  (ivy-wrap t)
  :config
  (defun counsel-goto-local-home ()
      "Go to the $HOME of the local machine."
      (interactive)
    (ivy--cd "~/")))

;; auto get: a nice theme
;;(use-package zenburn-theme
;;  :ensure t
;;  :config
;;  (load-theme 'zenburn t) ;; set theme
;;  )

;; Diminish, a feature that removes certain minor modes from mode-line.
(use-package diminish
  :ensure t)

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;; Load the theme (doom-one, doom-molokai, etc); keep in mind that each
  ;; theme may have their own settings.
  (load-theme 'doom-vibrant t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme
  (doom-themes-neotree-config)  ; all-the-icons fonts must be installed!
  )

;;for this to work run "M-x all-the-icons-install-fonts"
(use-package all-the-icons
  :ensure t)

(use-package neotree
  :ensure t
  :config
  (global-set-key [f8] 'neotree-toggle)
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  )
;;tab bar manager
(use-package centaur-tabs
  :ensure t
  :demand
  :config
  (centaur-tabs-mode t)
  (centaur-tabs-headline-match)
  (setq centaur-tabs-style "chamfer") 
  (setq centaur-tabs-height 32)
  (setq centaur-tabs-set-icons t)
  (setq centaur-tabs-plain-icons t)
  (setq centaur-tabs-set-bar 'top)
  :bind
  ("C-<left>" . centaur-tabs-backward)
  ("C-<right>" . centaur-tabs-forward)
  )

;; Doom Modeline, a modeline from DOOM Emacs, but more powerful and faster.
(use-package doom-modeline
  :ensure t
  :custom
  ;; Don't compact font caches during GC. Windows Laggy Issue
  (inhibit-compacting-font-caches t)
  (doom-modeline-minor-modes t)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-height 15)
  :config
  (doom-modeline-mode))

;; An extensible emacs startup screen showing you what’s most important.
(use-package dashboard
  :ensure t
  :config
  (setq dashboard-projects-backend 'projectile)
  (setq dashboard-startup-banner "~/.emacs.d/logo.png")
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        ))
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (dashboard-setup-startup-hook))

;; GENERAL +++++++++++++++++++++++++++++++++++++++++++++++++++
;; Requirements: Git
;; auto get: git client
(use-package magit
  :ensure t
  :config
  ;; Magit config
  (global-set-key (kbd "C-x g") 'magit-status)
  )
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  )

(use-package treemacs-projectile
  :ensure t
  :defer t
  :after (treemacs projectile))


;; auto get: fix path issues on MacOS and Linux
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))
  )

;; auto get: Helm-tramp helm integration with tramp-mode.
;; Config: Make sure to have a ~/.ssh/config file with your ssh connections.
(use-package helm-tramp
  :ensure t
  :config
  (setq tramp-default-method "ssh")
  (define-key global-map (kbd "C-c s") 'helm-tramp)
  )

;; auto get: sudo-edit, open files as sudo
(use-package sudo-edit
  :ensure t
  :commands (sudo-edit))

;; GENERAL: Autocomplete ++++++++++++++++++++++++++++++++++++

;; auto get eglot: autocomplete backend. Needs a language server like rls.
(use-package eglot
  :init
  :ensure t
  :demand)

;; auto get: autocomplete frontent. (Autocomplete square with suggestions, uses Eglot and other things as backend)
(use-package company
  :ensure t
  :hook (prog-mode . company-mode)
  :config (setq company-tooltip-align-annotations t)
  (setq company-minimum-prefix-length 1))

;; LANGUAGE: Java +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; USAGE: Quickly build project with F5? F8?

;; auto get: syntax error check
 (use-package flycheck
   :ensure t
   :config
   (global-flycheck-mode)
  ;;:hook (java-mode . flycheck-mode)
  )

(use-package lsp-mode
  :ensure t
  :hook ((lsp-mode . lsp-enable-which-key-integration))
  :config
  (setq lsp-completion-enable-additional-text-edit nil)
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  )
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil))
(use-package helm-lsp
  :ensure t)
(use-package lsp-java
  :ensure t
  :config
  (add-hook 'java-mode-hook 'lsp))

(use-package dap-mode
:ensure t
:after lsp-mode
:config
(dap-mode 1)

;; The modes below are optional

(dap-ui-mode 1)
;; enables mouse hover support
(dap-tooltip-mode 1)
;; use tooltips for mouse hover
;; if it is not enabled `dap-mode' will use the minibuffer.
(tooltip-mode 1)
;; displays floating panel with debug buttons
;; requies emacs 26+
(dap-ui-controls-mode 1))

(use-package dap-java
:ensure nil)

(use-package which-key
  :ensure t
  :config (which-key-mode))

(use-package lsp-treemacs
  :ensure t)

(use-package quickrun
  :ensure t
)

;; auto get: auto documentation in minibuffer (bottom of screen function definition)
(use-package eldoc
  :ensure t)

;; LANGUAGE: Rust ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; Requirements: Install Rust, cargo, rls?

;; rustic = basic rust-mode + additions
(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status)
              ("C-c C-c e" . lsp-rust-analyzer-expand-macro)
              ("C-c C-c d" . dap-hydra)
              ("C-c C-c h" . lsp-ui-doc-glance))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

(defun rk/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm, but don't try to
  ;; save rust buffers that are not file visiting. Once
  ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
  ;; no longer be necessary.
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; for rust-analyzer integration

(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil))

;; auto get: rust cargo
(use-package cargo
  :ensure t
  :init
  (add-hook 'rust-mode-hook 'cargo-minor-mode)
  (add-hook 'toml-mode-hook 'cargo-minor-mode))

;; auto get: rust toml syntax
(use-package toml-mode
  :mode "\\.toml\\'"
  :ensure t)

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; setting up debugging support with dap-mode

(use-package exec-path-from-shell
  :ensure
  :init (exec-path-from-shell-initialize))

(when (executable-find "lldb-mi")
  (use-package dap-mode
    :ensure
    :config
    (dap-ui-mode)
    (dap-ui-controls-mode 1)

    (require 'dap-lldb)
    (require 'dap-gdb-lldb)
    ;; installs .extension/vscode
    (dap-gdb-lldb-setup)
    (dap-register-debug-template
     "Rust::LLDB Run Configuration"
     (list :type "lldb"
           :request "launch"
           :name "LLDB::Run"
	   :gdbpath "rust-lldb"
           ;; uncomment if lldb-mi is not in PATH
           ;; :lldbmipath "path/to/lldb-mi"
           ))))

;; +++++++++++++++++++
;; java

;; (use-package jdee
;;   :ensure t)

;; +++++++++++++++++++

;; LANGUAGE: Go ++++++++++++++++++++++++++++++++++++++++++++++++++
;; Requirements: go, gocode (go get -u github.com/nsf/gocode), gopls

(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :init
  (add-hook 'go-mode-hook 'eglot-ensure))

(use-package go-eldoc
  :ensure t
  :init
  (add-hook 'go-mode-hook 'go-eldoc-setup))

;; LANGUAGE: Javascript +++++++++++++++++++++++++++++++++++++++++++ [NOT GREAT]
;; Requirements:
;;    Npm
;;    javascript-typescript-langserver: npm install -g javascript-typescript-langserver

;;(use-package js2-mode
;;  :ensure t
;;  :mode "\\.js\\'"
;;  :init
;;  (add-hook 'js2-mode-hook #'js2-imenu-extras-mode)
;;  (add-hook 'js2-mode-hook #'eglot-ensure)
;;  )

;;(use-package prettier-js
;;  :ensure t
;;  :hook (web-mode . prettier-js-mode)
;;)

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx?$" . web-mode)) ;; auto-enable for .js/.jsx files
  (setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'")))
  :init
;;  (defun web-mode-init-hook ()
;;  "Hooks for Web mode.  Adjust indent."
;;  (setq web-mode-markup-indent-offset 4))
;;  (add-hook 'web-mode-hook  'web-mode-init-hook)
  )

(use-package graphql-mode
  :ensure t
  )

;; LANGUAGE: x86 assembly +++++++++++++++++++++++++++++++++++

(define-minor-mode my-mode "#Comm"
  "Comments start with `#'."
  (set (make-local-variable 'comment-start) "#"))

(add-to-list 'auto-mode-alist '("\\.s\\'" . my-mode))
(add-hook 'my-mode-hook #'asm-mode)

;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(asm-comment-char 35)
 '(jdee-jdk-registry (quote (("10.0" . "/usr/lib/jvm/java-11-openjdk-amd64"))))
 '(jdee-server-dir "~/emacs/jree-server")
 '(package-selected-packages
   (quote
    (quickrun treemacs-projectile sublimity-attractive sublimity-map sublimity-scroll sublimity counsel amx ivy dashboard doom-modeline sudo-edit which-key helm-lsp lsp-ui lsp-java eclim meghanada htmlize tabbar-ruler helm-tramp exwm jsonrpc prettier-js zenburn-theme web-mode use-package toml-mode magit js2-mode helm flymake-jslint flymake-jshint flycheck exec-path-from-shell eglot company cargo auto-package-update)))
 '(tooltip-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
