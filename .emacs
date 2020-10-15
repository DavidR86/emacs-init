;; My custom emacs settings file
;; Current language syntax & completion support: Rust, Rust-toml, ~lisp.

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
;; helm-tramp
;;    c-c s: start helm-tramp

(require 'package) ;; needed

;; package repositories
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
             ("melpa" . "https://melpa.org/packages/")))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-hook 'prog-mode-hook 'display-line-numbers-mode) ;; display line numbers on code
(add-hook 'prog-mode-hook 'show-paren-mode) ;; parenthesis highlighting on code
;;(setq inhibit-startup-message t) ;; disable startup screen
;;(desktop-save-mode 1) ;; save & restore last session (restores all buffers so not that useful)
(add-to-list 'default-frame-alist '(fullscreen . maximized)) ;; start maximized
(tool-bar-mode -1) ;; Remove gui toolbar

;; automatically install use-package. Check if installed to prevent slowdown on startup.
(unless (package-installed-p 'use-package)
(package-refresh-contents)
(package-install 'use-package))

;; update packages automatically (not necessary)
;;(use-package auto-package-update
;;  :ensure t
;;  :config
;;  (setq auto-package-update-delete-old-versions t)
;;  (setq auto-package-update-hide-results t)
;;  (auto-package-update-maybe))

;; GENERAL: UI ++++++++++++++++++++++++++++++++++++++++++++++++

;; auto get: Helm configuration: better menus and searches
(use-package helm
  :ensure t
  :config
  (require 'helm-config)
  (global-set-key (kbd "M-x") 'helm-M-x)
    (global-set-key (kbd "C-x r b") 'helm-filtered-bookmarks)
    (global-set-key (kbd "C-x C-f") 'helm-find-files)
    (global-set-key (kbd "C-x C-b") 'helm-buffers-list)
    (global-set-key (kbd "C-s") 'helm-occur)
(setq rtags-display-result-backend 'helm)
  )

;; auto get: a nice theme
(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn t) ;; set theme
  )

;; GENERAL +++++++++++++++++++++++++++++++++++++++++++++++++++
;; Requirements: Git
;; auto get: git client
(use-package magit
  :ensure t
  :config
  ;; Magit config
  (global-set-key (kbd "C-x g") 'magit-status)
  )
;; auto get: fix path issues on MacOS and Linux
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))
  )
;; auto get: Helm-tramp: helm integration with tramp-mode.
(use-package helm-tramp
  :ensure t
  :config
  (setq tramp-default-method "ssh")
  (define-key global-map (kbd "C-c s") 'helm-tramp)
  )

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
  (setq company-minimum-prefix-length 1)
  (setq company-idle-delay 0))

;; auto get: syntax error check
;;(use-package flycheck
;;  :ensure t
;;  :hook (prog-mode . flycheck-mode))

;; auto get: auto documentation in minibuffer (bottom of screen function definition)
(use-package eldoc
  :ensure t)

;; LANGUAGE: Rust ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; Requirements: Install Rust, cargo, rls?

;; auto get: rust syntax
(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'"
  :init
  (add-hook 'rust-mode-hook #'eglot-ensure)
  :config (setq rust-format-on-save t))

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
 '(package-selected-packages
   (quote
    (jsonrpc prettier-js zenburn-theme web-mode use-package toml-mode magit js2-mode helm flymake-jslint flymake-jshint flycheck exec-path-from-shell eglot company cargo auto-package-update))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )