;;; package --- Summary
;;; Commentary:

;;; Paths
(defvar dotemacs-dir (file-name-directory load-file-name))

;; follow symlinks automagically
(setq vc-follow-symlinks t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
(eval-when-compile (require 'use-package))

;; automatically use anaconda mode for python
(add-hook 'python-mode-hook 'anaconda-mode)

;; Setup company mode for autocompletion
(require 'company)
(setq company-idle-delay 0.3
     company-tooltip-limit 10
     company-minimum-prefix-length 0)
(add-hook 'after-init-hook 'global-company-mode)

;; gitgutter
(global-git-gutter-mode t)

;; column-marker
(add-hook 'python-mode-hook
     (lambda ()
      (column-marker-1 80)
     )
)

;; projectile
(projectile-global-mode)
(setq projectile-completion-system 'grizzl)

;; delete trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; pyflakes
(add-hook 'after-init-hook #'global-flycheck-mode)

;; ido mode
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

;; smex
(use-package smex
  :ensure t
  :bind (("M-x" . smex)
       ("M-X" . smex-major-mode-commands)
       ("C-c M-x" . execute-extended-command))
  :init
  (setq smex-save-file (expand-file-name "smex.hist" dotemacs-dir)
       smex-history-length 250))

;; white spaces
(add-hook 'after-init-hook 'global-whitespace-mode)
(setq whitespace-display-mappings
  '(
    (space-mark 32 [183] [46]) ; 32 SPACE, 183 MIDDLE DOT 「·」, 46 FULL STOP 「.」
    (tab-mark 9 [9655 9] [92 9]) ; 9 TAB, 9655 WHITE RIGHT-POINTING TRIANGLE 「▷」
  ))
