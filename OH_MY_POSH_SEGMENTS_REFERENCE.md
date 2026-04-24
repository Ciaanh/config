# Oh My Posh - Référence Complète des Segments et Blocs

**Dernière mise à jour**: 2026-04-24  
**Version**: 4 (configuration actuelle)  
**Source de vérité**: `oh-my-posh/website/docs/` (documentation officielle)

> Cette référence couvre l'**intégralité** des blocs et segments présents dans la documentation officielle d'Oh My Posh : **13 pages de configuration** + **108 segments** répartis en 8 catégories (système, langages, SCM, cloud, CLI, web, santé, musique). Les identifiants (`type`) utilisés sont ceux exacts attendus par le moteur Oh My Posh.
>
> Répartition par catégorie (source : `oh-my-posh/website/docs/segments/`) :
> - **Système** : 16 segments
> - **Langages** : 26 segments
> - **SCM** : 7 segments
> - **Cloud** : 10 segments
> - **CLI** : 34 segments
> - **Web** : 8 segments
> - **Santé** : 4 segments
> - **Musique** : 3 segments

## Table des matières

1. [Structure Générale](#structure-générale)
2. [Blocs (Blocks)](#blocs-blocks)
3. [Segments Système](#segments-système)
4. [Segments Langages de Programmation](#segments-langages-de-programmation)
5. [Segments Gestion de Source (SCM)](#segments-gestion-de-source-scm)
6. [Segments Cloud](#segments-cloud)
7. [Segments Web & API](#segments-web--api)
8. [Segments Santé & Fitness](#segments-santé--fitness)
9. [Segments Musique](#segments-musique)
10. [Segments Outils CLI & Développement](#segments-outils-cli--développement)
11. [Propriétés Globales des Templates](#propriétés-globales-des-templates)

---

## Structure Générale

### Convention de rendu sommaire

Les rendus ci-dessous sont volontairement schématiques. Ils montrent l'ordre, le contenu et l'intention visuelle des segments, sans chercher à reproduire exactement les couleurs, espacements Unicode ou séparateurs Powerline de votre terminal.

```text
[PATH: ~/src/app] [GIT: main ~1 +2] [NODE: 22.14.0] [TIME: 14:37]
```

### Configuration JSON/YAML

Oh My Posh utilise une configuration structurée autour de trois concepts clés:

Formats observés dans le dépôt de thèmes:

- JSON: `.omp.json`
- YAML: `.omp.yaml`

```json
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 4,
  "final_space": false,
  "palette": {
    "color_name": "#HEXCODE"
  },
  "accent_color": "32",
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": []
    }
  ]
}
```

### Paramètres Globaux

| Paramètre | Type | Description | Exemple |
|-----------|------|-------------|---------|
| `version` | `int` | Version du schéma de configuration | `4` |
| `final_space` | `boolean` | Ajouter un espace à la fin du prompt | `false` |
| `terminal_background` | `color` | Couleur de fond du terminal | `"#000000"` |
| `accent_color` | `color` | Couleur par défaut pour l'accent | `"32"` ou `"p:red"` |
| `console_title_template` | `string` | Template du titre de la fenêtre terminal | `"{{ .Shell }} in {{ .Folder }}"` |
| `pwd` | `string` | Notifier le terminal du répertoire courant | `"osc99"`, `"osc7"`, `"osc51"` |
| `var` | `map` | Variables pour utilisation dans les templates | `{"my_var": "value"}` |
| `shell_integration` | `boolean` | Activer les séquences OSC FinalTerm | `true` |
| `enable_cursor_positioning` | `boolean` | Auto-masquer les nouvelles lignes (bash/zsh) | `true` |
| `patch_pwsh_bleed` | `boolean` | Corriger le saignement de fond PowerShell | `false` |
| `async` | `boolean` | Charger le prompt de manière asynchrone | `false` |
| `streaming` | `int` | Timeout du streaming en millisecondes | `0` |
| `extends` | `string` | Hériter d'une autre configuration | `"path/to/config.json"` |
| `transient_prompt` | `object` | Prompt simplifié affiché après exécution | Voir plus bas |
| `secondary_prompt` | `object` | Prompt secondaire pour saisie multi-ligne | Voir plus bas |

### Fonctionnalités relevées dans les thèmes existants

Le parcours de `oh-my-posh/themes` met en évidence plusieurs usages importants qui n'étaient pas explicitement couverts dans cette référence initiale.

#### 1. Prompts multi-lignes avec plusieurs blocs `prompt`

Beaucoup de thèmes utilisent plusieurs blocs `prompt` successifs avec `newline: true` pour construire une interface sur 2 à 4 lignes.

```json
{
  "type": "prompt",
  "alignment": "left",
  "newline": true,
  "segments": []
}
```

#### Rendu sommaire

```text
╭─ user on branch
├─ ~/workspace/project
╰─❯
```

#### 2. `console_title_template`

Très présent dans les thèmes. Il pilote le titre de la fenêtre/onglet terminal avec les mêmes capacités de template que le prompt.

```json
{
  "console_title_template": "{{ if .Root }}root @ {{ end }}{{ .Shell }} in {{ .Folder }}"
}
```

#### 3. `transient_prompt`

Utilisé notamment par `1_shell.omp.json` et `kushal.omp.json`. Il remplace le prompt complet après validation d'une commande.

```json
{
  "transient_prompt": {
    "background": "transparent",
    "foreground": "#FEF5ED",
    "template": "❯ "
  }
}
```

#### 4. `secondary_prompt`

Observé dans `kushal.omp.json`. Sert de prompt secondaire lors d'une commande shell multi-ligne.

```json
{
  "secondary_prompt": {
    "background": "transparent",
    "foreground": "#D6DEEB",
    "template": "╰─❯ "
  }
}
```

#### 5. Tags de style inline dans les chaînes

Plusieurs thèmes injectent des balises de style directement dans `template`, `leading_diamond` ou `trailing_diamond`.

```json
{
  "leading_diamond": "<#00c7fc>  </><#B6D6F2> in </>",
  "template": "{{ .CurrentDate | date \"Monday <#ffffff>at</> 3:04 PM\" }}"
}
```

#### 6. Couleurs dynamiques avec `foreground_templates` et `background_templates`

Très répandues dans les thèmes pour refléter un état Git, une erreur, une batterie faible ou un code retour non nul.

#### 7. `pwd` moderne et alias historique `osc99`

La documentation actuelle privilégie `pwd: "osc99"`, mais certains thèmes utilisent encore la forme historique:

```json
{
  "osc99": true
}
```

#### 8. Réutilisation d'autres segments dans les templates

Certains thèmes exploitent les propriétés inter-segments, par exemple:

```template
{{ if .Segments.Git.RepoName }}{{ .Segments.Git.RepoName }}{{ else }}{{ .Folder }}{{ end }}
```

ou

```template
{{ if .Segments.Session.SSHSession }}SSH{{ end }}
```

#### 9. Segments “toujours visibles”

Les thèmes s'appuient souvent sur `always_enabled: true` pour `status`, `executiontime` ou `project`.

#### 10. Présence de clés legacy dans quelques thèmes

Le balayage des thèmes montre aussi quelques clés historiques ou moins visibles dans la documentation courante, par exemple `osc99: true` ou `root_icon` dans certains thèmes. Pour une configuration neuve, il vaut mieux privilégier les clés documentées par le schéma courant et considérer ces usages comme des indices de compatibilité ascendante.

---

## Blocs (Blocks)

### Types de Blocs

Les blocs sont des conteneurs pour les segments, définissant leur position et leur style.

#### **Bloc Principal (Prompt)**

```json
{
  "type": "prompt",
  "alignment": "left",
  "segments": []
}
```

**Propriétés**:

| Propriété | Type | Défaut | Description |
|-----------|------|--------|-------------|
| `type` | `string` | - | `"prompt"` - bloc principal |
| `alignment` | `string` | `"left"` | `"left"` ou `"right"` |
| `newline` | `boolean` | `false` | Commencer sur une nouvelle ligne |
| `filler` | `string` | - | Caractère répété entre blocs gauche/droit |
| `overflow` | `string` | `"hide"` | `"hide"` ou `"break"` (comportement quand trop long) |
| `leading_diamond` | `string` | - | Caractère d'ouverture |
| `trailing_diamond` | `string` | - | Caractère de fermeture |
| `segments` | `array` | - | Tableau d'objets segments |
| `force` | `boolean` | `false` | Toujours afficher le bloc |
| `index` | `int` | - | Forcer la position du bloc |

#### **Bloc Droit (Right Prompt)**

```json
{
  "type": "rprompt",
  "alignment": "right",
  "segments": []
}
```

**Notes**:
- Seulement un bloc `rprompt` est autorisé
- Affiche les segments alignés à droite du terminal
- Requiert le support du shell (PowerShell, bash récent, zsh, etc.)

### Exemple de Configuration Complète

```json
{
  "version": 4,
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "path",
          "style": "powerline",
          "foreground": "#ffffff",
          "background": "#61AFEF"
        }
      ]
    },
    {
      "type": "rprompt",
      "alignment": "right",
      "segments": [
        {
          "type": "time",
          "style": "plain",
          "foreground": "#007ACC"
        }
      ]
    }
  ]
}
```

#### Rendu sommaire

```text
~/projet/src                             14:37
```

---

## Segments Système

Les segments système affichent des informations sur le système, l'environnement et l'état d'exécution.

### 1. **Battery** (Batterie)

**Source**: `battery.go`  
**Objectif**: Afficher l'état de la batterie du dispositif  
**Détection**: État de charge, pourcentage, état

#### Configuration

```json
{
  "type": "battery",
  "style": "powerline",
  "foreground": "#111111",
  "background": "#FFA500",
  "options": {
    "charged_icon": "\ue22f ",
    "charging_icon": "\ue234 ",
    "discharging_icon": "\ue231 "
  },
  "cache": {
    "duration": "10m",
    "strategy": "session"
  }
}
```

#### Rendu sommaire

```text
🔋 87%
🔌 100%
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `charged_icon` | `string` | `"\ue22f "` | Icône quand chargée |
| `charging_icon` | `string` | `"\ue234 "` | Icône pendant la charge |
| `discharging_icon` | `string` | `"\ue231 "` | Icône pendant la décharge |
| `display_error` | `boolean` | `false` | Afficher les erreurs |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Icon` | `string` | Icône d'état |
| `.Percentage` | `int` | Pourcentage (0-100) |
| `.State` | `State` | État (Full, Charged, Charging, Discharging) |
| `.Error` | `string` | Message d'erreur |
| `.EstimatedTimeLeft` | `time.Duration` | Temps estimé restant |

---

### 2. **Connection** (Connexion Réseau)

**Source**: `connection.go`  
**Objectif**: Afficher l'état de la connexion réseau/WiFi  
**Détection**: WiFi, Bluetooth, Mobile

#### Configuration

```json
{
  "type": "connection",
  "style": "plain",
  "foreground": "#00AA00",
  "options": {
    "type": "wifi"
  }
}
```

#### Rendu sommaire

```text
📶 WiFi
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `type` | `string` | `"wifi"` | `"wifi"`, `"bluetooth"`, ou `"mobile"` |

---

### 3. **Execution Time** (Durée d'Exécution)

**Source**: `executiontime.go`  
**Objectif**: Afficher la durée d'exécution de la dernière commande  
**Utile pour**: Identifier les commandes lentes

#### Configuration

```json
{
  "type": "executiontime",
  "style": "plain",
  "foreground": "#FF6B6B",
  "options": {
    "always_enabled": false,
    "threshold": 500,
    "style": "austin"
  }
}
```

#### Rendu sommaire

```text
⏱ 2.3s
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `always_enabled` | `boolean` | `false` | Toujours afficher la durée |
| `threshold` | `int` | `500` | Durée minimale pour afficher le segment (ms) |
| `style` | `string` | `austin` | Format de durée: `austin`, `roundrock`, `dallas`, `galveston`, etc. |

#### Styles fréquemment observés dans les thèmes

| Style | Exemple |
|-------|---------|
| `austin` | `2.1s` |
| `roundrock` | `2s 100ms` |
| `dallas` | `2.1` |
| `galveston` | `00:00:02` |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Ms` | `int` | Durée en millisecondes |
| `.FormattedMs` | `string` | Durée formatée (ex: `500ms`, `2.5s`) |

---

### 4. **OS** (Système d'Exploitation)

**Source**: `os.go`  
**Objectif**: Afficher le nom du système d'exploitation et architecture  
**Détection**: Linux, macOS, Windows, etc.

#### Configuration

```json
{
  "type": "os",
  "style": "plain",
  "foreground": "#FF00FF",
  "options": {
    "arch": false,
    "display_distro": true
  }
}
```

#### Rendu sommaire

```text
 Windows
🐧 Ubuntu x86_64
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `arch` | `boolean` | `false` | Afficher l'architecture (x86_64, arm64, etc.) |
| `display_distro` | `boolean` | `false` | Afficher la distribution Linux |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Icon` | `string` | Icône du système d'exploitation |
| `.String` | `string` | Nom du système d'exploitation |
| `.Distro` | `string` | Distribution Linux |
| `.Arch` | `string` | Architecture du système |

---

### 5. **Path** (Chemin d'Accès)

**Source**: `path.go`  
**Objectif**: Afficher le chemin du répertoire courant  
**Modes**: 10 styles différents (agnoster, full, folder, mixed, etc.)

#### Configuration

```json
{
  "type": "path",
  "style": "powerline",
  "powerline_symbol": "\ue0b0",
  "foreground": "#ffffff",
  "background": "#61AFEF",
  "options": {
    "style": "folder",
    "dir_length": 3,
    "folder_separator_icon": "\ue0bb",
    "home_icon": "~",
    "folder_icon": "..",
    "mapped_locations": {
      "C:\\temp": "\ue799",
      "~/Projects": "\uea83"
    }
  }
}
```

#### Rendu sommaire

```text
~/Projects/oh-my-posh
.. / src / segments
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `folder_separator_icon` | `string` | `/` | Séparateur entre dossiers |
| `home_icon` | `string` | `~` | Icône pour le home |
| `folder_icon` | `string` | `..` | Icône pour les dossiers |
| `windows_registry_icon` | `string` | `\uF013` | Icône pour Windows Registry |
| `style` | `enum` | `agnoster` | Mode d'affichage (voir styles) |
| `max_depth` | `number` | `1` | Profondeur maximale |
| `max_width` | `any` | `0` | Largeur maximale |
| `dir_length` | `number` | `1` | Longueur des segments (style fish) |
| `full_length_dirs` | `number` | `1` | Nombre de répertoires en pleine longueur |
| `mapped_locations` | `map` | - | Remplacements personnalisés de chemins |

#### Styles Path

- **agnoster**: Chaque dossier intermédiaire = `folder_icon`
- **agnoster_full**: Chaque dossier complet
- **agnoster_short**: Raccourci après `max_depth`
- **full**: Chemin complet
- **folder**: Seulement le dossier courant
- **mixed**: Mélange de symboles et de noms
- **letter**: Première lettre de chaque dossier
- **unique**: Première lettre unique de chaque dossier
- **powerlevel**: Style Powerlevel10k
- **fish**: Style fish shell

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Path` | `string` | Chemin complet |
| `.Location` | `string` | Chemin formaté |
| `.Folder` | `string` | Dossier courant |
| `.StackCount` | `int` | Nombre d'éléments dans la pile |

---

### 6. **Project** (Projet)

**Source**: `project.go`  
**Objectif**: Afficher le nom du projet (depuis pyproject.toml, package.json, etc.)  
**Détection**: Fichiers de config de projet

#### Configuration

```json
{
  "type": "project",
  "style": "plain",
  "foreground": "#00AA00",
  "options": {
    "always_enabled": false,
    "dotnet_files": ["*.sln", "*.csproj"]
  }
}
```

#### Rendu sommaire

```text
📁 my-awesome-app
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `always_enabled` | `boolean` | `false` | Toujours afficher le segment |
| `<type>_files` | `array` | `[]` | Surcharge des fichiers de détection par type de projet, ex. `dotnet_files` |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Type` | `string` | Type de projet détecté (`node`, `python`, `dotnet`, etc.) |
| `.Version` | `string` | Version du projet |
| `.Target` | `string` | Framework ou cible du projet |
| `.Name` | `string` | Nom du projet |
| `.Error` | `string` | Contexte d'erreur si la lecture échoue |

---

### 7. **Root** (Utilisateur Root/Admin)

**Source**: `root.go`  
**Objectif**: Afficher un indicateur quand utilisateur root ou admin  
**Utile pour**: Distinguer les sessions privilégiées

#### Configuration

```json
{
  "type": "root",
  "style": "plain",
  "foreground": "#FF0000",
  "options": {
    "symbol": "#"
  }
}
```

#### Rendu sommaire

```text
#
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `symbol` | `string` | `#` | Symbole à afficher si root |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Root` | `boolean` | True si utilisateur root/admin |

---

### 8. **Session** (Session - User@Host)

**Source**: `session.go`  
**Objectif**: Afficher l'utilisateur courant et le nom d'hôte  
**Utile pour**: SSH, sessions multiples

#### Configuration

```json
{
  "type": "session",
  "style": "powerline",
  "foreground": "#ffffff",
  "background": "#4B95E9",
  "options": {
    "user_info_separator": " @ ",
    "ssh_icon": "\uf817"
  }
}
```

#### Rendu sommaire

```text
nicolas @ workstation
🔐 nicolas @ srv-prod-01
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `user_info_separator` | `string` | ` @ ` | Séparateur entre user et host |
| `ssh_icon` | `string` | `\uf817` | Icône pour SSH |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.User` | `string` | Utilisateur courant |
| `.Host` | `string` | Nom d'hôte |
| `.SSH` | `boolean` | True si SSH |
| `.Icon` | `string` | Icône (SSH si applicable) |

---

### 9. **Shell** (Shell)

**Source**: `shell.go`  
**Objectif**: Afficher le shell courant (bash, zsh, PowerShell, fish, etc.)  
**Détection**: Variable d'environnement SHELL

#### Configuration

```json
{
  "type": "shell",
  "style": "plain",
  "foreground": "#00AA00",
  "options": {
    "mapped_shell_names": {
      "powershell": "pwsh"
    }
  }
}
```

#### Rendu sommaire

```text
pwsh
bash
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `mapped_shell_names` | `object` | - | Alias texte/glyphe pour les noms de shell |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Name` | `string` | Nom du shell |
| `.Version` | `string` | Version du shell |

---

### 10. **Status** (Code de Sortie)

**Source**: `status.go`  
**Objectif**: Afficher le code de sortie de la dernière commande  
**Utile pour**: Détecter les erreurs

#### Configuration

```json
{
  "type": "status",
  "style": "plain",
  "foreground": "#FF0000",
  "foreground_templates": [
    "{{ if eq .Code 0 }}#00AA00{{ end }}"
  ],
  "options": {
    "always_enabled": true,
    "status_template": "{{ if eq .Code 0 }}✓{{ else }}✗ {{ reason .Code }}{{ end }}"
  }
}
```

#### Rendu sommaire

```text
✓
✗ 1
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `always_enabled` | `boolean` | `false` | Toujours afficher le statut |
| `status_template` | `string` | `{{ .Code }}` | Template utilisé pour chaque code de retour |
| `status_separator` | `string` | `\|` | Séparateur quand plusieurs statuts sont disponibles |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Code` | `int` | Code de sortie (0 = succès) |
| `.String` | `string` | Texte formaté issu de `status_template` |
| `.Error` | `boolean` | Indique si au moins un code de retour est en erreur |

---

### 11. **Sysinfo** (Informations Système)

**Source**: `sysinfo.go`  
**Objectif**: Afficher les informations système (CPU, RAM, uptime)  
**Détection**: Charge système, mémoire

#### Configuration

```json
{
  "type": "sysinfo",
  "style": "plain",
  "foreground": "#007ACC",
  "options": {
    "all": false,
    "physical_only": true,
    "ramdrive_only": false
  }
}
```

#### Rendu sommaire

```text
💾 7420/16000MB (46%)
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `all` | `boolean` | `false` | Afficher toutes les infos |
| `physical_only` | `boolean` | `false` | Afficher seulement RAM physique |
| `ramdrive_only` | `boolean` | `false` | Afficher seulement RAM drive |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Total` | `int` | RAM totale (MB) |
| `.Available` | `int` | RAM disponible (MB) |
| `.Used` | `int` | RAM utilisée (MB) |
| `.Percent` | `float` | Pourcentage utilisé |
| `.Uptime` | `int` | Uptime en secondes |

---

### 12. **Text** (Texte Statique)

**Source**: `text.go`  
**Objectif**: Afficher du texte statique  
**Utile pour**: Espacements, séparateurs, labels

#### Configuration

```json
{
  "type": "text",
  "style": "plain",
  "foreground": "#FFFFFF",
  "options": {
    "text": "❯"
  }
}
```

#### Rendu sommaire

```text
❯
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `text` | `string` | - | Texte à afficher |

---

### 13. **Time** (Heure/Date)

**Source**: `time.go`  
**Objectif**: Afficher l'heure/date courant  
**Format**: Format golang personnalisable

#### Configuration

```json
{
  "type": "time",
  "style": "plain",
  "foreground": "#007ACC",
  "options": {
    "time_format": "15:04:05"
  }
}
```

#### Rendu sommaire

```text
14:37:52
2026-04-23
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `time_format` | `string` | `15:04:05` | Format de l'heure (golang) |

#### Formats Courants

| Format | Exemple |
|--------|---------|
| `15:04:05` | `14:30:45` |
| `15:04` | `14:30` |
| `2006-01-02` | `2026-04-23` |
| `01/02 15:04` | `04/23 14:30` |
| `Mon 15:04` | `Thu 14:30` |

---

### 14. **Upgrade** (Mises à Jour)

**Source**: `upgrade.go`  
**Objectif**: Afficher le nombre de paquets à mettre à jour  
**Détection**: Gestionnaires de paquets disponibles

#### Configuration

```json
{
  "type": "upgrade",
  "style": "plain",
  "foreground": "#FF6B6B",
  "cache": {
    "duration": "24h",
    "strategy": "session"
  }
}
```

#### Rendu sommaire

```text
⬆ 12
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Count` | `int` | Nombre de paquets à mettre à jour |

---

### 15. **Winget** (Windows Package Manager)

**Source**: `winget.go`  
**Objectif**: Afficher le nombre de paquets à mettre à jour (Windows)  
**Plateforme**: Windows uniquement

#### Configuration

```json
{
  "type": "winget",
  "style": "plain",
  "foreground": "#0078D4",
  "cache": {
    "duration": "24h",
    "strategy": "session"
  }
}
```

#### Rendu sommaire

```text
󰏖 5
```

---

### 16. **WinReg** (Windows Registry)

**Source**: `winreg.go`  
**Objectif**: Lire une valeur depuis le registre Windows  
**Utile pour**: Configuration système personnalisée

#### Configuration

```json
{
  "type": "winreg",
  "style": "plain",
  "foreground": "#FFFFFF",
  "options": {
    "path": "HKEY_CURRENT_USER\\Software\\...",
    "property": "PropertyName"
  }
}
```

#### Rendu sommaire

```text
DarkMode=1
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `path` | `string` | - | Chemin du registre |
| `property` | `string` | - | Propriété à lire |

---

## Segments Langages de Programmation

Les segments de langage affichent la version du langage/runtime quand détecté dans le répertoire courant.

### Configuration Standard pour Tous les Langages

```json
{
  "type": "LANGUAGE_NAME",
  "style": "plain",
  "foreground": "#FFFFFF",
  "background": "#LANGUAGE_COLOR",
  "options": {
    "home_enabled": false,
    "fetch_version": true,
    "cache_duration": "10m",
    "display_mode": "files",
    "extensions": ["FILE_EXTENSIONS"],
    "folders": ["FOLDER_NAMES"],
    "missing_command_text": "not installed"
  }
}
```

### Options Communes

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `home_enabled` | `boolean` | `false` | Afficher en home directory |
| `fetch_version` | `boolean` | `true` | Récupérer la version |
| `cache_duration` | `string` | `"10m"` | Durée du cache version |
| `display_mode` | `string` | `"files"` | `"always"`, `"files"`, ou `"context"` |
| `extensions` | `[]string` | - | Extensions de fichiers |
| `folders` | `[]string` | - | Noms de dossiers |
| `missing_command_text` | `string` | - | Texte si non installé |

### Propriétés Template Communes

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Full` | `string` | Version complète (ex: `3.11.8`) |
| `.Major` | `string` | Version majeure (ex: `3`) |
| `.Minor` | `string` | Version mineure (ex: `11`) |
| `.Patch` | `string` | Version patch (ex: `8`) |

### Langages Supportés

| Segment | Fichiers Détectés | Couleur Typique | Particularités |
|---------|-------------------|-----------------|----------------|
| **Clojure** (clj) | `project.clj`, `deps.edn` | `#63B132` | - |
| **Crystal** (cr) | `*.cr`, `shard.yml` | `#000000` | - |
| **Dart** (dart) | `pubspec.yaml`, `pubspec.lock` | `#00D4FF` | - |
| **.NET** (dotnet) | `*.csproj`, `*.sln`, `global.json` | `#512BD4` | Version du SDK |
| **Elixir** (ex) | `mix.exs`, `.formatter.exs` | `#4B275F` | - |
| **Fortran** (f) | `*.f90`, `*.f95`, `*.f03` | `#734F96` | - |
| **Golang** (go) | `go.mod`, `go.sum` | `#00ADD8` | Parse go.mod, go.work |
| **Haskell** (hs) | `*.hs`, `cabal.project` | `#5E5086` | - |
| **Java** (java) | `pom.xml`, `build.gradle` | `#007396` | - |
| **Julia** (jl) | `Project.toml`, `Manifest.toml` | `#9558B2` | - |
| **Kotlin** (kt) | `build.gradle.kts`, `*.kt` | `#7F52FF` | - |
| **Lua** (lua) | `*.lua` | `#2C3E50` | - |
| **Mojo** (mojo) | `*.mojo` | `#FF00FF` | - |
| **Nim** (nim) | `*.nim`, `*.nims` | `#FFE953` | - |
| **Node.js** (node) | `package.json`, `node_modules` | `#68A063` | Parse package.json |
| **OCaml** (ml) | `*.ml`, `*.mli`, `dune` | `#EC6813` | - |
| **Perl** (pl) | `*.pl`, `*.pm` | `#39457E` | - |
| **PHP** (php) | `composer.json`, `*.php` | `#777BB4` | - |
| **Python** (py) | `requirements.txt`, `pyproject.toml` | `#3776AB` | Virtual env detection |
| **R** (r) | `renv.lock`, `DESCRIPTION` | `#276DC3` | - |
| **Ruby** (rb) | `Gemfile`, `.ruby-version` | `#CC342D` | - |
| **Rust** (rs) | `Cargo.toml`, `Cargo.lock` | `#CE422B` | - |
| **Swift** (swift) | `Package.swift`, `*.swift` | `#FA7343` | - |
| **V** (v) | `v.mod`, `*.v` | `#5D87BF` | - |
| **Vala** (vala) | `*.vala`, `meson.build` | `#7239B3` | - |
| **Zig** (zig) | `build.zig`, `*.zig` | `#EC915C` | - |

---

## Segments Gestion de Source (SCM)

Les segments SCM affichent des informations sur le système de contrôle de version courant.

### 1. **Git**

**Source**: `git.go`, `git_unix.go`, `git_windows.go`  
**Objectif**: Afficher les informations du repo Git  
**Détection**: Dossier `.git`

#### Configuration

```json
{
  "type": "git",
  "style": "powerline",
  "powerline_symbol": "\ue0b0",
  "foreground": "#193549",
  "background": "#ffeb3b",
  "options": {
    "fetch_status": true,
    "fetch_push_status": false,
    "fetch_upstream_icon": true,
    "fetch_user": false,
    "source": "cli",
    "untracked_modes": {
      "*": "normal"
    }
  },
  "template": "{{ .UpstreamIcon }}{{ .HEAD }}{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}"
}
```

#### Rendu sommaire

```text
 main ⇡1 ⇣2 ✏ +2 ~1
 feat/login ✏ +1
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `fetch_status` | `boolean` | `false` | Récupérer les modifications locales |
| `fetch_push_status` | `boolean` | `false` | Récupérer les infos push |
| `fetch_upstream_icon` | `boolean` | `false` | Récupérer l'icône upstream |
| `fetch_user` | `boolean` | `false` | Récupérer l'utilisateur Git |
| `source` | `string` | `"cli"` | `"cli"` ou `"pwsh"` (posh-git) |
| `untracked_modes` | `map` | - | Modes pour les fichiers non tracés |
| `ignore_submodules` | `map` | - | Ignorer les sous-modules |
| `mapped_branches` | `map` | - | Alias personnalisés pour les branches |
| `branch_template` | `string` | - | Template personnalisé pour le nom |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.HEAD` | `string` | Branche/tag/détail courant |
| `.BranchStatus` | `string` | Statut ahead/behind |
| `.UpstreamIcon` | `string` | Icône du service (GitHub, GitLab, etc.) |
| `.Working.Changed` | `boolean` | Fichiers modifiés |
| `.Working.String` | `string` | Résumé des modifications |
| `.Staging.Changed` | `boolean` | Fichiers stagés |
| `.Staging.String` | `string` | Résumé staging |
| `.Ahead` | `int` | Commits ahead |
| `.Behind` | `int` | Commits behind |
| `.StashCount` | `int` | Nombre de stash |
| `.RepoName` | `string` | Nom du répo |
| `.Dir` | `string` | Répertoire racine |
| `.RelativeDir` | `string` | Chemin relatif du repo |

#### Icônes Git

| Icône | Type | Défaut |
|-------|------|--------|
| `branch_icon` | Branche | `\ue0a0` |
| `commit_icon` | Commit (détached HEAD) | `\uF417` |
| `tag_icon` | Tag | `\uF412` |
| `github_icon` | GitHub | `\uF408` |
| `gitlab_icon` | GitLab | `\uF296` |
| `bitbucket_icon` | Bitbucket | `\uF171` |
| `azure_devops_icon` | Azure DevOps | `\uEBE8` |

---

### 2. **Fossil**

**Source**: `fossil.go`  
**Objectif**: Afficher les infos Fossil VCS  
**Plateforme**: Unix/Linux

#### Configuration

```json
{
  "type": "fossil",
  "style": "plain",
  "foreground": "#FFFFFF",
  "options": {
    "display_mode": "files",
    "fetch_status": true
  }
}
```

---

### 3. **Jujutsu**

**Source**: `jujutsu.go`  
**Objectif**: Afficher les infos Jujutsu (Git-compatible)  

#### Configuration

```json
{
  "type": "jujutsu",
  "style": "plain",
  "foreground": "#FFFFFF",
  "options": {
    "display_mode": "files",
    "fetch_status": true
  }
}
```

---

### 4. **Mercurial**

**Source**: `mercurial.go`  
**Objectif**: Afficher les infos Mercurial (Hg)  

#### Configuration

```json
{
  "type": "mercurial",
  "style": "plain",
  "foreground": "#FFFFFF",
  "options": {
    "display_mode": "files",
    "fetch_status": true
  }
}
```

---

### 5. **Plastic SCM**

**Source**: `plastic.go`  
**Objectif**: Afficher les infos Plastic SCM  

#### Configuration

```json
{
  "type": "plastic",
  "style": "plain",
  "foreground": "#FFFFFF",
  "options": {
    "display_mode": "files",
    "fetch_status": true
  }
}
```

---

### 6. **Sapling**

**Source**: `sapling.go`  
**Objectif**: Afficher les infos Sapling VCS  

#### Configuration

```json
{
  "type": "sapling",
  "style": "plain",
  "foreground": "#FFFFFF",
  "options": {
    "display_mode": "files",
    "fetch_status": true
  }
}
```

---

### 7. **Subversion**

**Source**: `svn.go`  
**Objectif**: Afficher les infos Subversion (SVN)  

#### Configuration

```json
{
  "type": "svn",
  "style": "plain",
  "foreground": "#FFFFFF",
  "options": {
    "display_mode": "files",
    "fetch_status": true
  }
}
```

---

## Segments Cloud

Les segments cloud affichent les contextes des services cloud et plateformes déployées.

### 1. **AWS**

**Source**: `aws.go`  
**Objectif**: Afficher le profil AWS et région courant  
**Détection**: Variables `AWS_PROFILE`, `AWS_REGION`

#### Configuration

```json
{
  "type": "aws",
  "style": "powerline",
  "foreground": "#ffffff",
  "background": "#FF9900",
  "options": {
    "display_default": false
  }
}
```

#### Rendu sommaire

```text
🔶 prod-eu@eu-west-3
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Profile` | `string` | Profil AWS courant |
| `.Region` | `string` | Région AWS |
| `.RegionAlias` | `string` | Alias region court |

---

### 2. **Azure (az)**

**Source**: `az.go`  
**Objectif**: Afficher la souscription Azure courant  
**Détection**: CLI Azure, configuration locale

#### Configuration

```json
{
  "type": "az",
  "style": "powerline",
  "foreground": "#ffffff",
  "background": "#0078D4"
}
```

#### Rendu sommaire

```text
☁ Contoso-Production
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Subscription` | `string` | Souscription Azure courant |

---

### 3. **Azure Developer (azd)**

**Source**: `azd.go`  
**Objectif**: Afficher l'environnement Azure Developer CLI  
**Détection**: Fichier `.azure/config`

#### Configuration

```json
{
  "type": "azd",
  "style": "plain",
  "foreground": "#ffffff"
}
```

---

### 4. **Azure Functions**

**Source**: `az_functions.go`  
**Objectif**: Afficher le contexte Azure Functions  

#### Configuration

```json
{
  "type": "azfunc",
  "style": "plain",
  "foreground": "#ffffff"
}
```

---

### 5. **Cloud Foundry**

**Source**: `cf.go`  
**Objectif**: Afficher org et space Cloud Foundry  
**Détection**: `cf` CLI

#### Configuration

```json
{
  "type": "cf",
  "style": "plain",
  "foreground": "#ffffff"
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Organization` | `string` | Organization CF |
| `.Space` | `string` | Space CF |

---

### 6. **CF Target** (`cftarget`)

**Source**: `cf_target.go`  
**Objectif**: Afficher la cible Cloud Foundry active (organisation / espace)  
**Identifiant `type`**: `cftarget` (sans underscore)

#### Configuration

```json
{
  "type": "cftarget",
  "style": "plain",
  "foreground": "#ffffff",
  "background": "#0C9DD1",
  "template": " \uf0c2 {{ .Org }}/{{ .Space }} "
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Org` | `string` | Organisation Cloud Foundry courante |
| `.Space` | `string` | Espace Cloud Foundry courant |

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `display_mode` | `enum` | `always` | `always` ou `context` |

---

### 7. **GCP** (Google Cloud Platform)

**Source**: `gcp.go`  
**Objectif**: Afficher le projet GCP et région  
**Détection**: `gcloud` CLI

#### Configuration

```json
{
  "type": "gcp",
  "style": "powerline",
  "foreground": "#ffffff",
  "background": "#4285F4"
}
```

#### Rendu sommaire

```text
🔵 my-gcp-project/europe-west1
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Project` | `string` | Projet GCP courant |
| `.Region` | `string` | Région GCP |

---

### 8. **Pulumi**

**Source**: `pulumi.go`  
**Objectif**: Afficher le stack Pulumi courant  
**Détection**: `Pulumi.yaml`

#### Configuration

```json
{
  "type": "pulumi",
  "style": "plain",
  "foreground": "#ffffff"
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Stack` | `string` | Stack Pulumi courant |
| `.Organization` | `string` | Organisation Pulumi |

---

### 9. **Sitecore**

**Source**: `sitecore.go`  
**Objectif**: Afficher le contexte Sitecore CLI  

#### Configuration

```json
{
  "type": "sitecore",
  "style": "plain",
  "foreground": "#ffffff"
}
```

---

### 10. **CDS** (SAP CAP)

**Source**: `cds.go`  
**Objectif**: Afficher le contexte SAP CAP  

#### Configuration

```json
{
  "type": "cds",
  "style": "plain",
  "foreground": "#ffffff"
}
```

---

## Segments Web & API

Les segments web affichent les informations depuis des services web et APIs externes.

### 1. **HTTP** (API Générique)

**Source**: `http.go`  
**Objectif**: Interroger un endpoint HTTP générique  
**Utile pour**: Données personnalisées

#### Configuration

```json
{
  "type": "http",
  "style": "plain",
  "foreground": "#ffffff",
  "options": {
    "url": "https://api.example.com/status",
    "http_timeout": 500,
    "cache_duration": "10m"
  }
}
```

#### Rendu sommaire

```text
API OK
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `url` | `string` | - | URL de l'endpoint |
| `http_timeout` | `int` | `2000` | Timeout en ms |
| `cache_duration` | `string` | `"10m"` | Durée du cache |

---

### 2. **IPify** (Adresse IP Publique)

**Source**: `ipify.go`  
**Objectif**: Afficher l'adresse IP publique  
**Service**: ipify.org

#### Configuration

```json
{
  "type": "ipify",
  "style": "plain",
  "foreground": "#ffffff",
  "cache": {
    "duration": "60m",
    "strategy": "session"
  }
}
```

---

### 3. **OpenWeatherMap**

**Source**: `owm.go`  
**Objectif**: Afficher la météo  
**Clé**: Requiert clé API OpenWeatherMap

#### Configuration

```json
{
  "type": "owm",
  "style": "plain",
  "foreground": "#ffffff",
  "options": {
    "api_key": "YOUR_API_KEY",
    "http_timeout": 500,
    "units": "metric"
  }
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Temperature` | `float` | Température |
| `.Condition` | `string` | Condition météo |
| `.Icon` | `string` | Icône météo |

---

### 4. **Carbon Intensity** (`carbonintensity`)

**Source**: `carbon_intensity.go`  
**Objectif**: Afficher l'intensité carbone temps-réel du réseau électrique (UK)  
**Identifiant `type`**: `carbonintensity` (sans underscore)

#### Configuration

```json
{
  "type": "carbonintensity",
  "style": "plain",
  "foreground": "#ffffff",
  "background": "#4CAF50",
  "template": " \uf06c {{ .Actual.Index }} {{ .TrendIcon }} ",
  "options": {
    "url": "https://api.carbonintensity.org.uk/regional",
    "http_timeout": 20,
    "cache_timeout": 10
  }
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Actual.Index` | `string` | Note de l'intensité (`very low`, `low`, `moderate`, `high`, `very high`) |
| `.TrendIcon` | `string` | Icône représentant la tendance |

---

### 5. **Brewfather**

**Source**: `brewfather.go`  
**Objectif**: Afficher l'info de la brasserie Brewfather  

#### Configuration

```json
{
  "type": "brewfather",
  "style": "plain",
  "foreground": "#ffffff",
  "options": {
    "api_key": "YOUR_API_KEY"
  }
}
```

---

### 6. **Wakatime**

**Source**: `wakatime.go`  
**Objectif**: Afficher le temps tracé Wakatime  
**Clé**: Requiert clé API Wakatime

#### Configuration

```json
{
  "type": "wakatime",
  "style": "plain",
  "foreground": "#ffffff",
  "options": {
    "api_key": "YOUR_API_KEY",
    "http_timeout": 500
  }
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.CumulativeTotal` | `string` | Temps total formaté |
| `.Hours` | `int` | Heures |
| `.Minutes` | `int` | Minutes |
| `.Seconds` | `int` | Secondes |

---

### 7. **NBA** (`nba`)

**Source**: `nba.go`  
**Objectif**: Afficher le planning et le score de votre équipe NBA favorite  
**Détection**: configuration de l'équipe

#### Configuration

```json
{
  "type": "nba",
  "style": "diamond",
  "foreground": "#ffffff",
  "template": " \udb82\udc06 {{ .HomeTeam }}{{ if .HasStats }} ({{ .HomeTeamWins }}-{{ .HomeTeamLosses }}){{ end }}{{ if .Started }}:{{ .HomeScore }}{{ end }} vs {{ .AwayTeam }}",
  "options": {
    "team": "",
    "days_offset": 8,
    "http_timeout": 20
  }
}
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `team` | `string` | - | Code de l'équipe (ex: `LAL`, `BOS`) |
| `days_offset` | `int` | `8` | Fenêtre de jours pour les matchs |
| `http_timeout` | `int` | `20` | Timeout HTTP (ms) |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.HomeTeam` / `.AwayTeam` | `string` | Équipes |
| `.HomeScore` / `.AwayScore` | `int` | Scores en cours |
| `.HomeTeamWins` / `.HomeTeamLosses` | `int` | Bilan équipe domicile |
| `.AwayTeamWins` / `.AwayTeamLosses` | `int` | Bilan équipe visiteuse |
| `.Time` / `.GameDate` / `.StartTimeUTC` | `string` | Horaires |
| `.GameStatus` | `int` | Statut du match |
| `.Started` | `bool` | Match commencé |
| `.HasStats` | `bool` | Statistiques disponibles |

---

### 8. **Todoist**

**Source**: `todoist.go`  
**Objectif**: Afficher le nombre de tâches du jour depuis Todoist  
**Clé**: Requiert clé API Todoist (profil utilisateur)

#### Configuration

```json
{
  "type": "todoist",
  "style": "powerline",
  "foreground": "#ffffff",
  "template": "{{ .TaskCount }}",
  "options": {
    "api_key": "YOUR_API_KEY",
    "http_timeout": 20
  }
}
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `api_key` | `string` | - | Clé API Todoist |
| `http_timeout` | `int` | `20` | Timeout HTTP (ms) |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.TaskCount` | `int` | Nombre de tâches dues aujourd'hui |

---

## Segments Santé & Fitness

Les segments santé affichent les données de santé et fitness depuis des services externes.

### 1. **Nightscout** (Glucose Sanguin)

**Source**: `nightscout.go`  
**Objectif**: Afficher les lectures de glucose Nightscout  
**Utile pour**: Diabète type 1

#### Configuration

```json
{
  "type": "nightscout",
  "style": "plain",
  "foreground": "#ffffff",
  "options": {
    "url": "https://YOUR_NIGHTSCOUT_URL",
    "http_timeout": 500
  }
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.BG` | `int` | Glucose sanguin |
| `.Trend` | `string` | Tendance (↑ ↗ → ↘ ↓) |

---

### 2. **Strava** (Activités de Sport)

**Source**: `strava.go`  
**Objectif**: Afficher la dernière activité Strava  
**Clé**: Requiert token Strava

#### Configuration

```json
{
  "type": "strava",
  "style": "plain",
  "foreground": "#ffffff",
  "options": {
    "access_token": "YOUR_ACCESS_TOKEN"
  }
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Name` | `string` | Nom de l'activité |
| `.Ago` | `string` | Temps écoulé depuis l'activité |
| `.Hours` | `int` | Heures écoulées |

---

### 3. **Withings** (Métriques de Santé)

**Source**: `withings.go`  
**Objectif**: Afficher les métriques Withings  
**Clé**: Requiert token Withings

#### Configuration

```json
{
  "type": "withings",
  "style": "plain",
  "foreground": "#ffffff",
  "options": {
    "access_token": "YOUR_ACCESS_TOKEN"
  }
}
```

---

### 4. **Ramadan**

**Source**: `ramadan.go`  
**Objectif**: Afficher les heures de Sehar (Fajr) et Iftar (Maghrib) avec compte à rebours pendant le Ramadan  
**Détection**: automatiquement masqué hors période de Ramadan si `hide_outside_ramadan: true`

#### Configuration

```json
{
  "type": "ramadan",
  "style": "diamond",
  "foreground": "#ffffff",
  "template": "\ud83c\udf19 Roza {{ .RozaNumber }} \u00b7 {{ .NextEvent }} in {{ .TimeRemaining }}",
  "options": {
    "latitude": 0,
    "longitude": 0,
    "city": "",
    "country": "",
    "method": 3,
    "school": 0,
    "hide_outside_ramadan": true,
    "http_timeout": 20
  }
}
```

#### Options

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `latitude` / `longitude` | `float64` | `0` | Coordonnées GPS |
| `city` / `country` | `string` | - | Alternative géographique |
| `method` | `int` | `3` | Méthode de calcul (Aladhan API) |
| `school` | `int` | `0` | École de jurisprudence (Hanafi, Shafii) |
| `hide_outside_ramadan` | `bool` | `true` | Masquer hors Ramadan |
| `first_roza_date` | `string` | - | Date de début manuelle |
| `http_timeout` | `int` | `20` | Timeout HTTP (ms) |

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Fajr` | `string` | Heure de Fajr (Sehar) |
| `.Iftar` | `string` | Heure de Maghrib (Iftar) |
| `.Imsak` | `string` | Heure d'Imsak |
| `.RozaNumber` | `int` | Numéro du jour de jeûne |
| `.NextEvent` | `string` | Prochain événement (Sehar/Iftar) |
| `.TimeRemaining` | `string` | Temps restant avant le prochain événement |
| `.Fasting` | `bool` | Période de jeûne active |

---

## Segments Musique

Les segments musique affichent les informations de lecture musicale en cours.

### 1. **Spotify**

**Source**: `spotify.go`, `spotify_darwin.go`, `spotify_linux.go`, `spotify_windows.go`  
**Objectif**: Afficher la piste Spotify en lecture  
**Détection**: Application Spotify ou PWA

#### Configuration

```json
{
  "type": "spotify",
  "style": "plain",
  "foreground": "#1DB954",
  "options": {}
}
```

#### Rendu sommaire

```text
🎵 Daft Punk - Harder Better Faster Stronger
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Status` | `string` | `"playing"`, `"paused"`, `"stopped"` |
| `.Artist` | `string` | Artiste |
| `.Track` | `string` | Titre de la piste |
| `.Album` | `string` | Album |
| `.Icon` | `string` | Icône Spotify |

#### Notes Plateforme

- **macOS/Linux**: Support complet (playing, paused, stopped)
- **Windows/WSL**: État de lecture uniquement, supporte app native et Edge PWA

---

### 2. **Last.FM**

**Source**: `lastfm.go`  
**Objectif**: Afficher la piste scrobblée Last.FM  

#### Configuration

```json
{
  "type": "lastfm",
  "style": "plain",
  "foreground": "#ffffff",
  "options": {
    "api_key": "YOUR_API_KEY",
    "user": "YOUR_USERNAME"
  }
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Track` | `string` | Titre de la piste |
| `.Artist` | `string` | Artiste |
| `.Album` | `string` | Album |
| `.Playing` | `boolean` | Actuellement en écoute |

---

### 3. **YouTube Music**

**Source**: `ytm.go`  
**Objectif**: Afficher la piste YouTube Music en lecture  

#### Configuration

```json
{
  "type": "ytm",
  "style": "plain",
  "foreground": "#ffffff"
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Status` | `string` | État de lecture |
| `.Artist` | `string` | Artiste |
| `.Track` | `string` | Titre |
| `.Icon` | `string` | Icône YouTube |

---

## Segments Outils CLI & Développement

Les segments CLI affichent des informations sur les outils de développement et frameworks.

### 1. **Angular**

**Source**: `angular.go`  
**Détection**: `angular.json`  

```json
{
  "type": "angular",
  "style": "plain",
  "foreground": "#DD0031"
}
```

---

### 2. **Docker**

**Source**: `docker.go`  
**Objectif**: Afficher le contexte Docker courant  
**Détection**: `Dockerfile`, `docker-compose.yml`

#### Configuration

```json
{
  "type": "docker",
  "style": "plain",
  "foreground": "#2496ED",
  "options": {
    "display_mode": "files",
    "fetch_context": false
  }
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Context` | `string` | Contexte Docker |
| `.Version` | `string` | Version Docker |

---

### 3. **kubectl** (Kubernetes)

**Source**: `kubectl.go`  
**Objectif**: Afficher le contexte et namespace Kubernetes  
**Détection**: `kubectl` CLI

#### Configuration

```json
{
  "type": "kubectl",
  "style": "powerline",
  "foreground": "#ffffff",
  "background": "#326CE5",
  "options": {
    "display_mode": "files",
    "namespace": true,
    "context": true
  }
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Namespace` | `string` | Namespace Kubernetes courant |
| `.Context` | `string` | Contexte kubectl courant |
| `.Icon` | `string` | Icône Kubernetes |

---

### 5. **Maven**

**Source**: `mvn.go`  
**Détection**: `pom.xml`  

```json
{
  "type": "mvn",
  "style": "plain",
  "foreground": "#C60C30"
}
```

---

### 6. **npm / pnpm / yarn**

**Source**: `npm.go`, `pnpm.go`, `yarn.go`  
**Objectif**: Afficher la version du gestionnaire de paquets  
**Détection**: `package.json`

#### Configuration (npm)

```json
{
  "type": "npm",
  "style": "plain",
  "foreground": "#CB3837",
  "options": {
    "display_mode": "files",
    "cache_duration": "10m"
  }
}
```

#### Configuration (pnpm)

```json
{
  "type": "pnpm",
  "style": "plain",
  "foreground": "#F69220"
}
```

#### Configuration (yarn)

```json
{
  "type": "yarn",
  "style": "plain",
  "foreground": "#2C8EBB"
}
```

---

### 7. **Terraform**

**Source**: `terraform.go`  
**Détection**: `*.tf`, `terraform.tfstate`  

#### Configuration

```json
{
  "type": "terraform",
  "style": "plain",
  "foreground": "#844FFF",
  "options": {
    "display_mode": "files"
  }
}
```

#### Propriétés Template

| Propriété | Type | Description |
|-----------|------|-------------|
| `.WorkspaceName` | `string` | Nom du workspace Terraform courant |

---

### 8. **Helm**

**Source**: `helm.go`  
**Détection**: `Chart.yaml`  

```json
{
  "type": "helm",
  "style": "plain",
  "foreground": "#0F1689"
}
```

---

### 9. **ArgoCD**

**Source**: `argocd.go`  
**Objectif**: Afficher le contexte ArgoCD actif (nom, utilisateur, serveur)

```json
{
  "type": "argocd",
  "style": "powerline",
  "template": " \ue734 {{ .Name }}:{{ .User }}@{{ .Server }} "
}
```

**Propriétés**: `.Name`, `.Server`, `.User`

---

### 10. **Claude Code**

**Source**: `claude.go`  
**Objectif**: Afficher les informations de session Claude Code (modèle IA, usage de tokens, coûts, workspace)  
**Notes**: requiert une session Claude Code active

```json
{
  "type": "claude",
  "style": "diamond",
  "template": " \udb82\udfc9 {{ .Model.DisplayName }} \uf2d0 {{ .TokenUsagePercent.Gauge }} "
}
```

**Propriétés**: `.SessionID`, `.Model`, `.Workspace`, `.Cost`, `.ContextWindow`, `.TokenUsagePercent`, `.FormattedCost`, `.FormattedTokens`, `.FormattedDuration`, `.FormattedAPIDuration`, `.FiveHourUsage`, `.SevenDayUsage`

---

### 11. **GitHub Copilot**

**Source**: `copilot.go`  
**Objectif**: Afficher les statistiques d'utilisation et le quota GitHub Copilot  
**Notes**: requiert authentification OAuth via `oh-my-posh auth copilot`

```json
{
  "type": "copilot",
  "style": "diamond",
  "template": " \uec1e {{ .Premium.Percent.Gauge }} ",
  "options": { "http_timeout": 1000 }
}
```

**Options**: `http_timeout` (int, défaut `20`)  
**Propriétés**: `.Premium`, `.Inline`, `.Chat` (chacune `CopilotUsage`), `.BillingCycleEnd`

---

### 12. **Nix-Shell**

**Source**: `nix_shell.go`  
**Objectif**: Afficher l'état de la nix-shell si dans un environnement Nix

```json
{
  "type": "nix-shell",
  "style": "powerline",
  "template": "(\udb84\udd05-{{ .Type }})"
}
```

**Propriétés**: `.Type`

---

### 13. **Talosctl**

**Source**: `talosctl.go`  
**Objectif**: Afficher le contexte Talos Kubernetes actif

```json
{
  "type": "talosctl",
  "style": "powerline",
  "template": " \udb84\udcfe {{ .Context }}"
}
```

**Propriétés**: `.Context`

---

### 14. **Umbraco**

**Source**: `umbraco.go`  
**Objectif**: Afficher la version Umbraco détectée dans le répertoire courant

```json
{
  "type": "umbraco",
  "style": "diamond",
  "template": "\udb81\udd49 {{ .Version }}"
}
```

**Propriétés**: `.Version`, `.Modern` (bool)

---

### 15. **Unity**

**Source**: `unity.go`  
**Objectif**: Afficher la version Unity et la version C# utilisée  
**Notes**: effectue un appel réseau (timeout par défaut: 2000 ms)

```json
{
  "type": "unity",
  "style": "powerline",
  "template": "\ue721 {{ .UnityVersion }}{{ if .CSharpVersion }} {{ .CSharpVersion }}{{ end }}",
  "options": { "http_timeout": 2000 }
}
```

**Options**: `http_timeout` (int, défaut `2000`)  
**Propriétés**: `.UnityVersion`, `.CSharpVersion`

---

### 16. **Autres Outils CLI** (résumé exhaustif)

Les segments CLI restants suivent le schéma standard "version d'un outil" avec les **options standard des langages** (`home_enabled`, `fetch_version`, `cache_duration`, `display_mode`, `extensions`, `folders`, `tooling`, `missing_command_text`, `version_url_template`) et les **propriétés standard** (`.Full`, `.Major`, `.Minor`, `.Patch`, `.URL`, `.Error`).

| Segment (`type`) | Détection | Notes spécifiques |
|------------------|-----------|-------------------|
| **Aurelia** (`aurelia`) | `package.json` (aurelia) | Template: `α {{ .Full }}` |
| **Bazel** (`bazel`) | `BUILD`, `WORKSPACE` | Option `icon` (défaut `\ue63a`), propriété `.Icon` |
| **Buf** (`buf`) | `buf.yaml`, `buf.lock` | Protocol Buffers CLI |
| **Bun** (`bun`) | `bun.lock`, `bun.lockb` | JavaScript runtime |
| **CMake** (`cmake`) | `CMakeLists.txt` | Build system |
| **Deno** (`deno`) | `deno.json`, `deno.jsonc` | JavaScript runtime |
| **Firebase** (`firebase`) | `.firebaserc`, `firebase.json` | Propriété unique `.Project` (pas de version) |
| **Flutter** (`flutter`) | `pubspec.yaml` | Supporte fvm (`tooling: ["fvm","flutter"]`) |
| **GitVersion** (`gitversion`) | Répertoire Git | Cache 30 min recommandé ; toutes variables GitVersion exposées |
| **NBGV** (`nbgv`) | `version.json` | Propriétés `.Version`, `.AssemblyVersion`, `.NuGetPackageVersion`, etc. |
| **Nx** (`nx`) | `nx.json` | Monorepo tool |
| **Quasar** (`quasar`) | `quasar.config.js` | Option `fetch_dependencies` ; propriétés `.Vite`, `.AppVite`, `.HasVite` |
| **React** (`react`) | `package.json` (react) | - |
| **Svelte** (`svelte`) | `svelte.config.js` | `display_mode` défaut `files` |
| **Taskwarrior** (`taskwarrior`) | `.taskrc` | Options `command` (défaut `task`), `commands` (map) ; propriété `.Commands` |
| **Tauri** (`tauri`) | `src-tauri/tauri.conf.json` | `display_mode` défaut `files` |
| **UI5 Tooling** (`ui5tooling`) | `.ui5rc`, `ui5.yaml` | SAP UI5 |
| **XMake** (`xmake`) | `xmake.lua` | Propriétés standard **sans** `.URL` |

**Note importante** : les segments **Kotlin** et **Haskell** ne sont PAS des segments CLI mais des **segments langages** (voir la section précédente). Les segments **GitVersion**, **Terraform**, **Docker**, **Helm**, **kubectl** se trouvent dans la documentation officielle sous `segments/cli/` (et non sous `scm/` ou `cloud/`).

---

## Propriétés Globales des Templates

Toutes les propriétés disponibles dans les templates, accessibles pour tous les segments:

### Propriétés d'Environnement

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Root` | `boolean` | True si utilisateur root/admin |
| `.PWD` | `string` | Répertoire courant (~) |
| `.AbsolutePWD` | `string` | Chemin absolu |
| `.Folder` | `string` | Dossier courant |
| `.Shell` | `string` | Shell courant (bash, zsh, pwsh, fish) |
| `.ShellVersion` | `string` | Version du shell |
| `.UserName` | `string` | Utilisateur courant |
| `.HostName` | `string` | Nom d'hôte |
| `.Code` | `int` | Code de sortie (0 = succès) |
| `.Jobs` | `int` | Nombre de jobs en arrière-plan |
| `.OS` | `string` | Système d'exploitation |
| `.WSL` | `boolean` | True si dans WSL |
| `.PromptCount` | `int` | Compteur du prompt |
| `.Version` | `string` | Version d'Oh My Posh |

### Propriétés d'Environnement

```template
{{ .Env.VARIABLE_NAME }}
```

Accéder à n'importe quelle variable d'environnement (ex: `{{ .Env.GO_VERSION }}`)

### Propriétés de Segment

| Propriété | Type | Description |
|-----------|------|-------------|
| `.Segment.Index` | `int` | Index du segment dans le bloc |
| `.Segment.Text` | `string` | Texte du segment actuel |

### Fonctions Spéciales

**Styles de couleur dynamique**:

```template
<COLOR>{{ .Value }}</COLOR>
{{ if condition }}#FF0000{{ else }}#00FF00{{ end }}
```

**Formatage de chemin**:

```template
{{ path .Path .Location }}
```

**Formatage personnalisé**:

```template
{{ .Value | date "2006-01-02" }}
{{ .Value | upper }}
{{ .Value | lower }}
{{ .Value | title }}
```

---

## Conseils de Configuration

### 1. **Performance**

- Utiliser `cache_duration` pour les segments externes (APIs, Git status, etc.)
- Éviter `fetch_status: true` sur Git pour les gros repos
- Utiliser `async: true` pour chargement parallèle

### 2. **Personnalisation**

- Utiliser les templates pour filtrer les segments par condition
- `foreground_templates` et `background_templates` pour les couleurs dynamiques
- `exclude_folders` pour désactiver segments dans certains répertoires

### 3. **Styles**

- `powerline`: Séparation visuelle claire
- `diamond`: Aspect plus sophistiqué
- `plain`: Minimaliste
- `accordion`: Style en accordéon

### 4. **Palettes de Couleurs**

- Définir une palette pour cohérence
- Utiliser références de palette: `p:color_name`
- Combiner avec `accent_color` global

---

## Ressources

- **Documentation officielle**: https://ohmyposh.dev
- **Repository GitHub**: https://github.com/JanDeDobbeleer/oh-my-posh
- **Galerie de thèmes**: https://ohmyposh.dev/docs/themes
- **Schéma JSON**: https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json

