;;;; Robert Weglarek's emacs configuration

;;; Paths

(defconst dotemacs-dir (file-name-directory load-file-name))
(defconst elisp-dir (expand-file-name "elisp" dotemacs-dir))
(add-to-list 'load-path elisp-dir)

;;; Packaging

(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))
(package-initialize)

(setq url-http-attempt-keepalives nil)

(defconst my-packages
  '(use-package
     diminish
     column-marker
     helm
     helm-projectile
     helm-descbinds
     git-gutter
     jinja2-mode)
  "A list of packages that must be installed.")

(defun install-my-packages ()
  "Install each package in ``my-packages`` if it isn't installed."
  (let ((package-contents-refreshed nil))
    (dolist (my-package my-packages)
      (unless (package-installed-p my-package)
        (unless package-contents-refreshed
          (package-refresh-contents)
          (setq package-contents-refreshed t))
        (package-install my-package)))))

(install-my-packages)

;;; Initialization

;; Base packages

(eval-when-compile
  (require 'use-package))
(require 'diminish)
(require 'bind-key)


;; Backups
(defconst my-backup-directory (expand-file-name "backups/" dotemacs-dir))
(make-directory my-backup-directory t)
(setq make-backup-files t
      vc-make-backup-files t
      backup-by-copying t
      backup-directory-alist `((".*" . ,my-backup-directory))
      delete-old-versions t
      kept-new-versions 10
      kept-old-versions 8
      version-control t)

;; Autosaves
(defconst my-autosave-directory (expand-file-name "autosave/" dotemacs-dir))
(make-directory my-autosave-directory t)
(setq auto-save-file-name-transforms
      `((".*" ,my-autosave-directory t)))

;; uniquify
(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward
        uniquify-separator "/"
        uniquify-after-kill-buffer-p t
                uniquify-ignore-buffers-re "^\\*"))

;; dired
(use-package dired
  :init
  (setq dired-omit-files (rx (seq ".pyc" eol))
        dired-omit-files-p t
        dired-recursive-deletes 'always
        dired-recursive-copies 'always)
  (use-package dired-x))

;; Buffer auto refresh
(global-auto-revert-mode t)

;; Use Google Chrome to open links
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "google-chrome")

(global-auto-revert-mode t)

(setq tab-always-indent 'complete
      tab-stop-list (number-sequence 4 200 4)
      require-final-newline t
      text-mode-hook '(turn-on-auto-fill
                       text-mode-hook-identify
                       abbrev-mode))
(setq-default indent-tabs-mode nil
              tab-width 4)

;; get rid of trailing whitespace
(defvar do-delete-trailing-whitespace t)
(add-hook 'before-save-hook
          (lambda()
            (unless (or (eq major-mode 'org-mode) (not do-delete-trailing-whitespace))
              (delete-trailing-whitespace))))


;; projectile
(use-package projectile
  :ensure t
  :diminish projectile-mode
  :config
  (projectile-global-mode t))

;; company
(use-package company
  :ensure t
  :diminish company-mode
  :init
  (setq company-idle-delay 0.3
        company-tooltip-limit 10
        company-minimum-prefix-length 0)
  (add-hook 'after-init-hook 'global-company-mode))


;; git gutter
(require 'git-gutter)
(global-git-gutter-mode t)


;; Python
(defun my-python-debug-insert-ipdb-set-trace ()
  "Insert ipdb trace call into buffer."
  (interactive)
  (insert "import ipdb; ipdb.set_trace()"))

(use-package python-environment
  :ensure t
  :init
  (setq venv-location "~/.virtualenvs"
        python-environment-directory venv-location
        python-environment-default-root-name "local"))

(use-package python
  :init
  (setq my-default-virtualenv-path (python-environment-root-path)
        python-shell-virtualenv-path my-default-virtualenv-path
        flycheck-python-flake8-executable (python-environment-bin "flake8" my-default-virtualenv-path))
  (put 'project-venv-name 'safe-local-variable #'stringp)
  (add-hook 'python-mode-hook
            (lambda ()
              (column-marker-1 80)
              (column-marker-2 100)))
  :config
  (bind-key "C-c /" 'my-python-debug-insert-ipdb-set-trace python-mode-map))

(defun my-python-mode-set-company-backends ()
  (set (make-local-variable 'company-backends)
       '((company-dabbrev-code
          company-jedi))))

(use-package company-jedi
  :ensure t
  :init
  (add-hook 'python-mode-hook
            (lambda ()
              (jedi:setup)
              (my-python-mode-set-company-backends)))
  :config
  (defun company-jedi-annotation (candidate)
    "Override annotating function"
    nil))


;; ido
(use-package ido
  :init
  (setq ido-enable-flex-matching t
        ido-create-new-buffer 'always
        ido-default-file-method 'selected-window
        ido-auto-merge-work-directories-length -1
        ido-use-virtual-buffers t
        ido-handle-duplicate-virtual-buffers 2
        ido-max-work-file-list 250
        ido-max-dir-file-cache 250
        ido-ignore-extensions t
        ido-save-directory-list-file (expand-file-name "ido.hist" dotemacs-dir))
  :config
  (ido-mode t))

(use-package ido-ubiquitous
  :ensure t
  :config
  (ido-ubiquitous-mode t))

(use-package ido-vertical-mode
  :ensure t
  :config
  (ido-vertical-mode 1)
  (setq ido-vertical-define-keys 'C-n-and-C-p-only))

(use-package smex
  :ensure t
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands)
         ("C-c M-x" . execute-extended-command))
  :init
  (setq smex-save-file (expand-file-name "smex.hist" dotemacs-dir)
        smex-history-length 250))


;; ui
(menu-bar-mode -1)

(when (display-graphic-p)
  (add-to-list 'default-frame-alist (cons 'width 120))
  (add-to-list 'default-frame-alist (cons 'height (/ (- (x-display-pixel-height) 100)
                                                     (frame-char-height))))
  (tool-bar-mode -1)
  (scroll-bar-mode -1)

  (use-package nlinum
    :ensure t
    :config
    (global-nlinum-mode 1)))

;; mode line settings
(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

(fset 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-message t
      use-dialog-box nil
      initial-scratch-message nil
      show-paren-mode t)

(use-package column-marker
  :ensure t
  :defer t)

(defun my-solarized-theme-swap ()
  "If solarized-dark is the current theme, switch to the light version, and vice versa."
  (interactive)
  (if (eql (position 'solarized-dark custom-enabled-themes) 0)
    (load-theme 'solarized-light t)
  (load-theme 'solarized-dark t)))

(use-package solarized-theme
  :ensure t
  :bind ("C-c w" . my-solarized-theme-swap)
  :init
  (setq solarized-use-variable-pitch nil)
  (load-theme 'solarized-dark t))

(use-package css
  :defer t
  :init
  (setq css-indent-offset 2))

(use-package js-mode
  :mode ("\\.js\\'"
         "\\.json\\'")
  :init
  (setq js-indent-level 2))

(use-package lua-mode
  :ensure t
  :defer t)

(use-package scss-mode
  :ensure t
  :defer t
  :init
  (setq scss-compile-at-save nil))

(use-package sh-mode
  :mode "\\.zsh\\'"
  :init
  (setq sh-basic-offset 2
        sh-indentation 2))

;;; Formats

(use-package yaml-mode
  :ensure t
  :defer t)

;;; Writing

(use-package markdown-mode
  :ensure t
  :defer t)

(use-package rst-mode
  :defer t
  :init
  (add-hook 'rst-mode-hook (lambda () (set-fill-column 80))))

;; helm
(require 'helm-config)
(require 'helm-projectile)

(setq helm-split-window-in-side-p t
      helm-buffers-fuzzy-matching t
      helm-move-to-line-cycle-in-source t
      helm-ff-search-library-in-sexp t
      helm-ff-file-name-history-use-recentf t)

(setq projectile-completion-system 'helm)
(helm-descbinds-mode)
(helm-mode 1)

(helm-projectile-on)
