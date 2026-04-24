<#
.SYNOPSIS
    Prévisualiseur de thèmes Oh My Posh utilisant le binaire officiel.
    Affiche le thème dans un ensemble complet de scénarios indépendamment de sa configuration.

.DESCRIPTION
    - Liste les thèmes (.omp.json/.yaml/.toml) du dossier
    - Affiche un aperçu complet avec ~12 scénarios couvrant les segments principaux :
      * Exit codes (succès/erreur)
      * Durées d'exécution (rapide/lente)
      * Environnements (venv Python, Node.js, Rust, etc.)
      * Contextes système (SSH, root, batterie)
      * Git states (détection repo automatique)
      * Infos système et cloud
    - Watch mode : redessine quand le fichier change
    - Tous les scénarios s'affichent TOUJOURS, quel que soit le thème

.PARAMETER Path
    Chemin du thème à prévisualiser (.omp.json, .yaml, .toml)

.PARAMETER All
    Prévisualiser tous les thèmes du dossier

.PARAMETER Filter
    Filtre glob pour -All (par défaut: *.omp.json)

.PARAMETER Watch
    Mode watch : redessine quand le fichier change

.PARAMETER Shell
    Shell de rendu pour la prévue (universal recommandé, sinon pwsh, bash, zsh, fish, cmd, nu, claude)

.EXAMPLE
    .\preview-omp.ps1
    .\preview-omp.ps1 -Path .\_ciaanh.omp.json
    .\preview-omp.ps1 -Path .\_ciaanh.claude.omp.json -Watch
    .\preview-omp.ps1 -All
    .\preview-omp.ps1 -All -Filter "*ciaanh*"
#>
[CmdletBinding(DefaultParameterSetName = 'Single')]
param(
    [Parameter(ParameterSetName = 'Single', Position = 0)]
    [string]$Path,

    [Parameter(ParameterSetName = 'All')]
    [switch]$All,

    [Parameter(ParameterSetName = 'All')]
    [string]$Filter = '*.omp.json',

    [Parameter(ParameterSetName = 'Single')]
    [switch]$Watch,

    [ValidateSet('universal', 'pwsh', 'bash', 'zsh', 'fish', 'cmd', 'nu', 'claude')]
    [string]$Shell = 'universal',

    [int]$ExitCode = 0,
    [int]$ExecutionTime = 0,
    [string]$Pwd = $PWD.Path,

    # Forcer le mode Claude Code (rend via `oh-my-posh claude` avec stdin JSON mocké)
    [switch]$Claude
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Error "oh-my-posh n'est pas installé. Installer via : winget install JanDeDobbeleer.OhMyPosh -s winget"
    exit 1
}

function Show-Banner {
    param([string]$Text, [ConsoleColor]$Color = 'Cyan')
    $line = '─' * ($Text.Length + 4)
    Write-Host ''
    Write-Host "┌$line┐" -ForegroundColor $Color
    Write-Host "│  $Text  │" -ForegroundColor $Color
    Write-Host "└$line┘" -ForegroundColor $Color
}

function Render-Theme {
    param([string]$ThemePath, [int]$Code = 0, [int]$ExecTime = 0, [string]$CurrentPath)
    & oh-my-posh print primary --config $ThemePath --shell $Shell --status $Code --execution-time $ExecTime --pwd "$CurrentPath"
    Write-Host ''
}

function Render-ClaudeTheme {
    param([string]$ThemePath, [string]$JsonData)
    $JsonData | & oh-my-posh claude --config $ThemePath
    Write-Host ''
}

# ─── Scénarios Claude Code ──────────────────────────────────
# Construit un JSON Claude Code conforme au schéma de `oh-my-posh claude`
# (voir oh-my-posh/src/segments/claude.go : ClaudeData)
function New-ClaudeData {
    param(
        [string]$ModelDisplay = 'Claude Sonnet 4.5',
        [string]$ModelId = 'claude-sonnet-4-5-20250929',
        [int]$UsedPercent = 22,
        [int]$ContextSize = 200000,
        [int]$InputTokens = 18432,
        [int]$OutputTokens = 4123,
        [double]$CostUSD = 0.0824,
        [int]$DurationMs = 125000,
        [int]$ApiDurationMs = 45000,
        [int]$LinesAdded = 312,
        [int]$LinesRemoved = 87,
        [Nullable[double]]$FiveHourPct = 38,
        [Nullable[double]]$SevenDayPct = 14,
        [string]$ProjectDir = $PWD.Path
    )
    $data = [ordered]@{
        session_id = [guid]::NewGuid().ToString()
        model      = [ordered]@{ id = $ModelId; display_name = $ModelDisplay }
        workspace  = [ordered]@{
            current_dir  = $PWD.Path
            project_dir  = $ProjectDir
            git_worktree = ''
        }
        context_window = [ordered]@{
            used_percentage     = $UsedPercent
            context_window_size = $ContextSize
            total_input_tokens  = $InputTokens
            total_output_tokens = $OutputTokens
            current_usage      = [ordered]@{
                input_tokens                  = $InputTokens
                output_tokens                 = $OutputTokens
                cache_creation_input_tokens   = 0
                cache_read_input_tokens       = 0
            }
        }
        cost = [ordered]@{
            total_cost_usd          = $CostUSD
            total_duration_ms       = $DurationMs
            total_api_duration_ms   = $ApiDurationMs
            total_lines_added       = $LinesAdded
            total_lines_removed     = $LinesRemoved
        }
        rate_limits = [ordered]@{
            five_hour = [ordered]@{ used_percentage = $FiveHourPct; resets_at = ([DateTimeOffset]::Now.AddHours(3)).ToUnixTimeSeconds() }
            seven_day = [ordered]@{ used_percentage = $SevenDayPct; resets_at = ([DateTimeOffset]::Now.AddDays(4)).ToUnixTimeSeconds() }
        }
    }
    return ($data | ConvertTo-Json -Depth 10 -Compress)
}



function Invoke-Scenario {
    param([hashtable]$Scenario, [string]$ThemePath)

    Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host $Scenario.Name -ForegroundColor Cyan
    Write-Host "   $($Scenario.Desc)" -ForegroundColor DarkGray

    # ThemePath est déjà un chemin absolu résolu par Render-Scenarios avant tout appel
    $oldPwd = Get-Location
    $tmpBase = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "omp-demo-$(Get-Random)")
    $null = New-Item -ItemType Directory -Path $tmpBase -Force -ErrorAction SilentlyContinue

    if ($Scenario.Claude) {
        $tmpPath = Join-Path $tmpBase 'my-project'
        $null = New-Item -ItemType Directory -Path $tmpPath -Force -ErrorAction SilentlyContinue
    } else {
        $tmpPath = $tmpBase
    }

    try {
        Set-Location $tmpPath
        if ($Scenario.Setup) { & $Scenario.Setup }
        $scenarioPwd = (Get-Location).Path

        if ($Scenario.Claude) {
            $claudeParams = $Scenario.Claude.Clone()
            Render-ClaudeTheme -ThemePath $ThemePath -JsonData (New-ClaudeData @claudeParams)
        } else {
            Render-Theme -ThemePath $ThemePath -Code $Scenario.Params.Code -ExecTime $Scenario.Params.ExecTime -CurrentPath $scenarioPwd
        }
    } finally {
        Remove-Item Env:\VIRTUAL_ENV     -ErrorAction SilentlyContinue
        Remove-Item Env:\PYTHONVERSION   -ErrorAction SilentlyContinue
        Remove-Item Env:\SSH_CLIENT      -ErrorAction SilentlyContinue
        Remove-Item Env:\SSH_CONNECTION  -ErrorAction SilentlyContinue
        Set-Location $oldPwd
        Remove-Item $tmpBase -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Render-Scenarios {
    param([string]$ThemePath)
    Show-Banner -Text "Thème : $(Split-Path $ThemePath -Leaf)" -Color Yellow
    # Résoudre le chemin absolu UNE SEULE FOIS ici, avant tout changement de répertoire
    $absoluteThemePath = (Resolve-Path $ThemePath -ErrorAction Stop).Path

    # ═══════════════════════════════════════════════════════════════════════
    # LISTE FIXE DES SCÉNARIOS — identique pour TOUS les thèmes.
    #
    # Chaque scénario a la structure :
    #   Name   : string        — libellé affiché (numéro + titre)
    #   Desc   : string        — description courte affichée en gris
    #   Setup  : scriptblock   — contexte à créer dans un tmpdir (ou $null)
    #   Params : hashtable     — { Code: int; ExecTime: int }  (rendu standard)
    #   Claude : hashtable     — présent à la place de Params pour les scénarios
    #                            qui exercent le segment "claude" via stdin JSON.
    #                            Le thème l'ignore silencieusement s'il n'a pas
    #                            ce segment — c'est l'effet recherché.
    #
    # Pour AJOUTER un scénario : insérer une entrée dans ce tableau.
    # Voir le bloc "GUIDE D'EXTENSION" plus bas pour les exemples.
    # ═══════════════════════════════════════════════════════════════════════
    $scenarios = @(

        # ── Codes de sortie ────────────────────────────────────────────────
        # Valide : status (✓/✗), foreground_templates sur erreur
        @{
            Name  = "1. Exit succès (code 0)"
            Desc  = "Commande réussie — status affiche ✓, couleurs normales"
            Setup = $null
            Params = @{ Code = 0; ExecTime = 150 }
        },
        @{
            Name  = "2. Exit erreur (code 1)"
            Desc  = "Commande échouée — status affiche ✗ 1, couleur d'erreur"
            Setup = $null
            Params = @{ Code = 1; ExecTime = 250 }
        },
        @{
            Name  = "3. Exit non trouvé (code 127)"
            Desc  = "Commande introuvable — status affiche ✗ 127"
            Setup = $null
            Params = @{ Code = 127; ExecTime = 100 }
        },

        # ── Temps d'exécution ──────────────────────────────────────────────
        # Valide : executiontime (threshold, format, style)
        @{
            Name  = "4. Exécution rapide (120ms)"
            Desc  = "En dessous du threshold par défaut (500ms) — segment caché ou non"
            Setup = $null
            Params = @{ Code = 0; ExecTime = 120 }
        },
        @{
            Name  = "5. Exécution modérée (1.5s)"
            Desc  = "Au-dessus du threshold — executiontime s'affiche"
            Setup = $null
            Params = @{ Code = 0; ExecTime = 1500 }
        },
        @{
            Name  = "6. Exécution lente (5.2s)"
            Desc  = "Tâche longue — executiontime potentiellement coloré différemment"
            Setup = $null
            Params = @{ Code = 0; ExecTime = 5200 }
        },

        # ── Environnements de développement ───────────────────────────────
        # Valide : python (venv + version), node, npm, project
        @{
            Name  = "7. Python venv activé"
            Desc  = "Détection de .venv + version 3.11.8 — segments python, project"
            Setup = {
                $env:VIRTUAL_ENV = '.venv'
                $env:PYTHONVERSION = '3.11.8'
                'requests' | Out-File 'requirements.txt'
            }
            Params = @{ Code = 0; ExecTime = 180 }
        },
        @{
            Name  = "8. Projet Node.js"
            Desc  = "package.json présent — segments node, npm, project"
            Setup = {
                @{ name = 'demo-app'; version = '1.0.0' } | ConvertTo-Json | Out-File 'package.json'
            }
            Params = @{ Code = 0; ExecTime = 220 }
        },

        # ── Git ────────────────────────────────────────────────────────────
        # Valide : git (branch, clean/dirty, ahead/behind, staged, untracked)
        @{
            Name  = "9. Git — repo propre (main)"
            Desc  = "Branche main à jour, aucune modification — git affiche ✓"
            Setup = {
                git init --initial-branch=main 2>$null
                git config user.email "dev@example.com" 2>$null
                git config user.name "Demo User" 2>$null
                'init' | Out-File 'README.md'
                git add . 2>$null
                git commit -m 'Initial' 2>$null
            }
            Params = @{ Code = 0; ExecTime = 200 }
        },
        @{
            Name  = "10. Git — working dir modifié"
            Desc  = "Fichier modifié + staged + untracked — git affiche ✏ +1 ?1"
            Setup = {
                git init --initial-branch=main 2>$null
                git config user.email "dev@example.com" 2>$null
                git config user.name "Demo User" 2>$null
                'init' | Out-File 'README.md'
                git add . 2>$null
                git commit -m 'Initial' 2>$null
                'staged' | Out-File 'staged.txt'; git add staged.txt 2>$null
                'modified' | Out-File 'README.md'
                'untracked' | Out-File 'new.txt'
            }
            Params = @{ Code = 0; ExecTime = 280 }
        },
        @{
            Name  = "11. Git — feature branch (2 commits ahead)"
            Desc  = "Branche feature/new-api, ⇡2 — git affiche la divergence"
            Setup = {
                git init --initial-branch=main 2>$null
                git config user.email "dev@example.com" 2>$null
                git config user.name "Demo User" 2>$null
                'init' | Out-File 'README.md'
                git add . 2>$null
                git commit -m 'Initial' 2>$null
                git checkout -b feature/new-api 2>$null
                'change1' | Out-File 'api.go'; git add .; git commit -m 'feat: endpoint' 2>$null
                'change2' | Out-File 'api.go'; git add .; git commit -m 'feat: validation' 2>$null
            }
            Params = @{ Code = 0; ExecTime = 310 }
        },

        # ── Session / Système ──────────────────────────────────────────────
        # Valide : session (SSH indicator), shell, os, root
        @{
            Name  = "12. Session SSH"
            Desc  = "Variables SSH_CLIENT/SSH_CONNECTION posées — session affiche 🔐"
            Setup = {
                $env:SSH_CLIENT = '192.168.1.100 22 22'
                $env:SSH_CONNECTION = '192.168.1.100 22 10.0.0.50 22'
            }
            Params = @{ Code = 0; ExecTime = 190 }
        },

        # ── Segment Claude ─────────────────────────────────────────────────
        # Valide : claude (context window, coût, modèle, rate limits)
        # Les thèmes sans segment "claude" ignorent ces scénarios silencieusement.
        @{
            Name  = "13. Claude — contexte faible (22%)"
            Desc  = "Début de session — context window peu utilisé"
            Setup = $null
            Claude = @{
                ModelDisplay = 'Claude Sonnet 4.5'; ModelId = 'claude-sonnet-4-5-20250929'
                UsedPercent = 22; InputTokens = 18432; OutputTokens = 4123
                CostUSD = 0.0824; DurationMs = 125000; ApiDurationMs = 45000
                LinesAdded = 312; LinesRemoved = 87
            }
        },
        @{
            Name  = "14. Claude — contexte modéré (45%)"
            Desc  = "Session active avec historique — Opus 4"
            Setup = $null
            Claude = @{
                ModelDisplay = 'Claude Opus 4'; ModelId = 'claude-opus-4-20250514'
                UsedPercent = 45; InputTokens = 95000; OutputTokens = 18000
                CostUSD = 0.4251; DurationMs = 450000; ApiDurationMs = 280000
                LinesAdded = 1247; LinesRemoved = 342
            }
        },
        @{
            Name  = "15. Claude — contexte saturé (87%)"
            Desc  = "Session longue — alerte de saturation attendue"
            Setup = $null
            Claude = @{
                ModelDisplay = 'Claude Sonnet 4.5'; ModelId = 'claude-sonnet-4-5-20250929'
                UsedPercent = 87; InputTokens = 168000; OutputTokens = 25000
                CostUSD = 1.2310; DurationMs = 1850000; ApiDurationMs = 720000
                LinesAdded = 5812; LinesRemoved = 1203
            }
        }
    )

    Write-Host "$($scenarios.Count) scénarios (identiques pour tous les thèmes)" -ForegroundColor DarkGray
    Write-Host ''

    foreach ($scenario in $scenarios) {
        Invoke-Scenario -Scenario $scenario -ThemePath $absoluteThemePath
    }

    Show-Banner -Text "Fin de la prévue" -Color Green
}

<#
╔════════════════════════════════════════════════════════════════════════════╗
║              📖 GUIDE D'EXTENSION - AJOUTER DE NOUVEAUX SCÉNARIOS          ║
╚════════════════════════════════════════════════════════════════════════════╝

STRUCTURE D'UN SCÉNARIO
═══════════════════════

Chaque scénario est un hashtable PowerShell avec la structure :

    @{
        Name   = "Numéro. Description courte"          # Affiché en cyan
        Desc   = "Description longue du scénario"       # Affiché en gris
        Setup  = { scriptblock PowerShell }|$null       # Préparation du contexte
        Params = @{ Code = 0; ExecTime = 150 }         # Paramètres de rendu
    }

PARAMÈTRES DE Params
════════════════════

Scénarios standard (tous les thèmes) :
  - Code : int         Exit code (0=succès, 1=erreur, 127=non trouvé, etc.)
  - ExecTime : int     Durée exécution en ms (affichée par segment executiontime)

Scénarios Claude (thèmes '*claude*' uniquement) :
  - ModelDisplay : string          Nom du modèle ("Claude Sonnet 4.5", etc.)
  - ModelId : string               ID complet du modèle (optionnel)
  - UsedPercent : int              Pourcentage contexte utilisé (0-100)
  - InputTokens : int              Tokens d'entrée utilisés
  - OutputTokens : int             Tokens de sortie générés
  - CostUSD : double               Coût total en USD
  - DurationMs : int               Durée totale en ms
  - ApiDurationMs : int            Durée API en ms
  - LinesAdded : int               Lignes de code ajoutées
  - LinesRemoved : int             Lignes de code supprimées
  - ContextSize : int              Taille totale contexte (optionnel, défaut 200000)
  - FiveHourPct : double|null      % limite 5h (optionnel)
  - SevenDayPct : double|null      % limite 7j (optionnel)
  - ProjectDir : string            Répertoire projet (optionnel)

FONCTION Setup
═══════════════

Le Setup est un scriptblock exécuté dans un répertoire temporaire. Il peut :

Exemples :

# Créer un environnement Python venv
Setup = { 
    $env:VIRTUAL_ENV = '.venv'
    $env:PYTHONVERSION = '3.11.8'
}

# Créer un fichier
Setup = {
    @{ name = 'app'; version = '1.0.0' } | ConvertTo-Json | Out-File 'package.json'
}

# Initialiser un repo Git
Setup = {
    git init --initial-branch=main 2>$null
    git config user.email "test@example.com" 2>$null
    echo "content" > file.txt
    git add file.txt
    git commit -m "Initial" 2>$null
}

# Laisser $null pour pas de setup (contexte par défaut)
Setup = $null

EXEMPLES DE SCÉNARIOS À AJOUTER
═════════════════════════════════

1. SEGMENTS LANGAGE - Rust + Cargo
   ─────────────────────────────────
   @{
       Name  = "X. Projet Rust avec Cargo"
       Desc  = "Détection du toolchain Rust et cargo.toml"
       Setup = {
           @{ package = @{ name = 'my-app'; version = '0.1.0' } } | 
               ConvertTo-Json | Out-File 'Cargo.toml'
       }
       Params = @{ Code = 0; ExecTime = 350 }
   }

2. SEGMENTS LANGAGE - Go/golang
   ──────────────────────────────
   @{
       Name  = "X. Projet Go avec go.mod"
       Desc  = "Module Go avec dépendances détectées"
       Setup = {
           "module github.com/example/app`ngo 1.24" | 
               Out-File 'go.mod'
       }
       Params = @{ Code = 0; ExecTime = 220 }
   }

3. SEGMENTS SYSTÈME - Utilisateur root
   ────────────────────────────────────
   @{
       Name  = "X. Contexte admin/root"
       Desc  = "Indicateur de privil. élevés"
       Setup = $null
       Params = @{ Code = 0; ExecTime = 140; AsRoot = $true }
   }

4. SEGMENTS CLOUD - Kubernetes context
   ────────────────────────────────────
   @{
       Name  = "X. Kubernetes context (prod cluster)"
       Desc  = "Namespace et cluster k8s actif"
       Setup = {
           "apiVersion: v1`nkind: Config`nclusters:`n- name: prod-cluster" |
               Out-File '.kube/config'
           $env:KUBECONFIG = "$PWD/.kube/config"
       }
       Params = @{ Code = 0; ExecTime = 200 }
   }

5. SEGMENTS CLOUD - AWS/Azure/GCP profile
   ────────────────────────────────────────
   @{
       Name  = "X. AWS profile actif"
       Desc  = "Profil AWS détecté (prod/staging)"
       Setup = {
           $env:AWS_PROFILE = "production"
           $env:AWS_REGION = "eu-west-1"
       }
       Params = @{ Code = 0; ExecTime = 180 }
   }

6. SEGMENTS SYSTÈME - Batterie faible
   ──────────────────────────────────
   @{
       Name  = "X. Batterie faible (15%)"
       Desc  = "Alerte batterie sur laptop"
       Setup = {
           # Note: Oh-my-posh détecte la batterie système
           # Ce scénario affiche surtout quand le segment battery est actif
       }
       Params = @{ Code = 0; ExecTime = 120 }
   }

7. SEGMENTS GIT - Feature branch avec commits ahead
   ────────────────────────────────────────────────
   @{
       Name  = "X. Git feature branch (⇡2 commits)"
       Desc  = "Branche de feature avec commits ahead de main"
       Setup = {
           git init --initial-branch=main 2>$null
           git config user.email "dev@test.com" 2>$null
           git config user.name "Developer" 2>$null
           "init" | Out-File 'file.txt'
           git add . 2>$null
           git commit -m "Initial" 2>$null
           git checkout -b feature/new-api 2>$null
           "change1" | Out-File 'file.txt'
           git commit -am "Feature 1" 2>$null
           "change2" | Out-File 'file.txt'
           git commit -am "Feature 2" 2>$null
       }
       Params = @{ Code = 0; ExecTime = 310 }
   }

8. SEGMENTS GIT - Rebase/Merge en cours
   ─────────────────────────────────────
   @{
       Name  = "X. Git rebase en cours"
       Desc  = "Rebasing... | État de merge/rebase"
       Setup = {
           git init --initial-branch=main 2>$null
           git config user.email "dev@test.com" 2>$null
           git config user.name "Developer" 2>$null
           "init" | Out-File 'file.txt'
           git add . 2>$null
           git commit -m "Initial" 2>$null
           # Créer l'état REBASE-MERGE manuellement
           $rebaseDir = ".git/rebase-merge"
           [void](New-Item -ItemType Directory -Path $rebaseDir -Force)
           "1" | Out-File "$rebaseDir/msgnum"
           "3" | Out-File "$rebaseDir/end"
       }
       Params = @{ Code = 0; ExecTime = 200 }
   }

AJOUTER UN SCÉNARIO
═══════════════════

1. Localisez le tableau $scenarios dans Render-Scenarios
2. Ajoutez votre scénario AVANT la ligne "if ($isClaudeTheme) {"
3. Numérotez correctement (séquentiel)
4. Testez : .\preview-omp.ps1 -Path mon-theme.omp.json
5. Vérifiez que votre scénario s'affiche pour TOUS les thèmes

EXEMPLE COMPLET
════════════════

    @{
        Name  = "X. Titre du scénario"
        Desc  = "Description du contexte illustré"
        Setup = {
            # Préparation contextuelle si besoin
            # Sinon : Setup = $null
        }
        Params = @{
            Code     = 0              # Exit code
            ExecTime = 500            # Durée en ms
            # Optionnel pour Claude : ModelDisplay, UsedPercent, etc.
        }
    }

CONVENTIONS
═════════════

- Les numéros vont de 1-12 (scénarios standard) + 13+ (Claude-only si applicable)
- Les descriptions commencent par un emoji si pertinent
- Setup doit être hermétique (dans tmpdir, nettoyé après)
- Exit codes : 0=succès, 1=erreur, 127=cmd not found, >128=signal
- ExecTime : 100-200ms = rapide, 500-1000ms = modéré, 2000+ = lent
- Les segments non détectés s'ignorent silencieusement (oh-my-posh les cache)

TESTER VOS AJOUTS
════════════════════

Après modification :

    .\preview-omp.ps1 -Path ./_ciaanh.omp.json          # Test simple
    .\preview-omp.ps1 -Path ./_ciaanh.claude.omp.json   # Test Claude
    .\preview-omp.ps1 -All                               # Test tous thèmes
    .\preview-omp.ps1 -Path ./mon-theme.omp.json -Watch # Watch mode

╚════════════════════════════════════════════════════════════════════════════╝
#>

# ─── Mode All ──────────────────────────────────────────────
if ($All) {
    $themes = Get-ChildItem -Path . -Filter $Filter -File
    if (-not $themes) {
        Write-Warning "Aucun thème trouvé matchant '$Filter'"
        return
    }
    Show-Banner -Text "$($themes.Count) thèmes trouvés" -Color Green
    foreach ($t in $themes) { Render-Scenarios -ThemePath $t.FullName }
    return
}

# ─── Mode Single ──────────────────────────────────────────
if (-not $Path) {
    # Auto-détection
    $candidates = Get-ChildItem -Path . -Filter '*.omp.json' -File
    if (-not $candidates) {
        Write-Error "Aucun thème .omp.json trouvé. Spécifiez -Path <fichier>."
        exit 1
    }
    if ($candidates.Count -eq 1) {
        $Path = $candidates[0].FullName
    } else {
        Write-Host 'Thèmes disponibles :' -ForegroundColor Cyan
        for ($i = 0; $i -lt $candidates.Count; $i++) {
            Write-Host "  [$i] $($candidates[$i].Name)"
        }
        $idx = Read-Host 'Numéro'
        $Path = $candidates[[int]$idx].FullName
    }
}

if (-not (Test-Path $Path)) {
    Write-Error "Fichier introuvable : $Path"
    exit 1
}

if ($Watch) {
    Show-Banner -Text "Watch : $Path" -Color Magenta
    Write-Host 'Ctrl+C pour quitter.' -ForegroundColor DarkGray
    $lastWrite = (Get-Item $Path).LastWriteTime
    Render-Scenarios -ThemePath $Path
    while ($true) {
        Start-Sleep -Milliseconds 500
        $current = (Get-Item $Path).LastWriteTime
        if ($current -ne $lastWrite) {
            Clear-Host
            $lastWrite = $current
            Show-Banner -Text "Mis à jour : $(Get-Date -Format 'HH:mm:ss')" -Color Magenta
            Render-Scenarios -ThemePath $Path
        }
    }
} else {
    Render-Scenarios -ThemePath $Path
}
