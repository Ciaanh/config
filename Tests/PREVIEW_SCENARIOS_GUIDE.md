# Guide des Scenarios de Preview - Oh My Posh

Objectif : documenter le comportement reel du script [preview-omp.ps1](d:/_perso/config/Tests/preview-omp.ps1) et la couverture des scenarios actuellement implementes.

Derniere mise a jour : 2026-04-24
Version du script : 2.1

---

## Table des matieres

1. Vue d'ensemble
2. Flux d'execution
3. Couverture des segments et blocs
4. Description des 15 scenarios
5. Ajouter de nouveaux scenarios
6. Meilleures pratiques

---

## Vue d'ensemble

Le script [preview-omp.ps1](d:/_perso/config/Tests/preview-omp.ps1) affiche toujours la meme suite de 15 scenarios pour un theme donne :

- 12 scenarios standard
- 3 scenarios Claude

Il n'y a plus de branchement conditionnel du type "si le theme contient tel segment" ou "si le nom du theme contient claude".

Les scenarios Claude sont toujours executes eux aussi. Si le theme ne contient pas de segment `claude`, oh-my-posh les ignore silencieusement, ce qui est le comportement recherche.

Le script utilise maintenant `universal` comme shell de rendu par defaut. C'est important pour la preview : ce mode reflete correctement le theme selectionne, alors que `pwsh` peut produire un rendu trompeur lors d'une previsualisation hors integration shell reelle.

---

## Flux d'execution

Flux reel du script :

```text
Script lance
    ↓
Resolution du theme cible
    ↓
Resolution du chemin absolu du theme une seule fois
    ↓
Chargement de la liste fixe des 15 scenarios
    ↓
Pour chaque scenario :
    • creation d'un repertoire temporaire isole
    • Set-Location dans ce repertoire
    • execution du Setup si present
    • rendu du prompt via oh-my-posh
    • nettoyage du repertoire temporaire et des variables d'environnement
    ↓
Affichage de "Fin de la prevue"
```

Details utiles :

- Les scenarios standard passent le repertoire temporaire a `oh-my-posh print primary` via `--pwd`.
- Les scenarios Claude utilisent `oh-my-posh claude` et s'executent dans un sous-dossier `my-project` pour fournir un contexte plus realiste.
- Le chemin du theme est resolu avant les changements de repertoire, ce qui evite les problemes de config ignores ou resolus depuis le mauvais dossier.

---

## Couverture des segments et blocs

La couverture ci-dessous represente les contextes que le script essaie de provoquer. Un segment n'apparait visiblement que si le theme le contient.

| Categorie | Segment | Scenario(s) | Contexte |
|-----------|---------|-------------|----------|
| Systeme | `status` ou `exit` | 1, 2, 3 | Codes 0, 1, 127 |
| Systeme | `executiontime` | 4, 5, 6 | 120ms, 1.5s, 5.2s |
| Systeme | `path` | 1-15 | Repertoires temporaires isoles |
| Systeme | `session` | 12 | Variables SSH posees |
| SCM | `git` | 9, 10, 11 | Repo propre, dirty, branche feature |
| Langage | `python` | 7 | `VIRTUAL_ENV`, `PYTHONVERSION`, `requirements.txt` |
| Langage | `node`, `npm` | 8 | `package.json` |
| Projet | `project` | 7, 8 | Detection par fichiers de projet selon le theme |
| Special | `claude` | 13, 14, 15 | Context window, cout, modele, rate limits |

Segments explicitement non couverts dans le code actuel :

- `root`
- `kubectl`
- `aws`
- `az`
- `gcp`
- `docker`
- `golang`
- `rust`
- `terraform`
- `helm`
- `jobs`
- `sysinfo`
- `connection`

---

## Description des 15 scenarios

### 1. Exit succes (code 0)

- Type : standard
- Params : `Code = 0`, `ExecTime = 150`
- Setup : aucun
- But : montrer l'etat nominal apres commande reussie

### 2. Exit erreur (code 1)

- Type : standard
- Params : `Code = 1`, `ExecTime = 250`
- Setup : aucun
- But : montrer l'etat erreur classique

### 3. Exit non trouve (code 127)

- Type : standard
- Params : `Code = 127`, `ExecTime = 100`
- Setup : aucun
- But : montrer un code de sortie d'echec plus severe

### 4. Execution rapide (120ms)

- Type : standard
- Params : `Code = 0`, `ExecTime = 120`
- Setup : aucun
- But : tester les seuils bas du segment `executiontime`

### 5. Execution moderee (1.5s)

- Type : standard
- Params : `Code = 0`, `ExecTime = 1500`
- Setup : aucun
- But : tester un temps d'execution au-dessus du threshold courant de nombreux themes

### 6. Execution lente (5.2s)

- Type : standard
- Params : `Code = 0`, `ExecTime = 5200`
- Setup : aucun
- But : tester un rendu de tache longue

### 7. Python venv active

- Type : standard
- Params : `Code = 0`, `ExecTime = 180`
- Setup :

```powershell
$env:VIRTUAL_ENV = '.venv'
$env:PYTHONVERSION = '3.11.8'
'requests' | Out-File 'requirements.txt'
```

- But : declencher les segments Python et la detection de projet Python selon le theme

### 8. Projet Node.js

- Type : standard
- Params : `Code = 0`, `ExecTime = 220`
- Setup :

```powershell
@{ name = 'demo-app'; version = '1.0.0' } | ConvertTo-Json | Out-File 'package.json'
```

- But : declencher les segments Node, npm et eventuellement `project`

### 9. Git - repo propre (main)

- Type : standard
- Params : `Code = 0`, `ExecTime = 200`
- Setup : initialise un repo Git sur `main`, cree `README.md`, commit `Initial`
- But : montrer un repo propre

### 10. Git - working dir modifie

- Type : standard
- Params : `Code = 0`, `ExecTime = 280`
- Setup : initialise un repo puis cree un fichier stage, un fichier modifie et un fichier non suivi
- But : montrer les etats `staged`, `modified`, `untracked`

### 11. Git - feature branch (2 commits ahead)

- Type : standard
- Params : `Code = 0`, `ExecTime = 310`
- Setup : initialise un repo, cree `feature/new-api`, ajoute deux commits
- But : montrer une branche de feature avec divergence locale

### 12. Session SSH

- Type : standard
- Params : `Code = 0`, `ExecTime = 190`
- Setup :

```powershell
$env:SSH_CLIENT = '192.168.1.100 22 22'
$env:SSH_CONNECTION = '192.168.1.100 22 10.0.0.50 22'
```

- But : declencher le contexte de session distante

### 13. Claude - contexte faible (22%)

- Type : Claude
- Modele : Claude Sonnet 4.5
- Contexte : `UsedPercent = 22`
- But : debut de session, faible consommation du context window

### 14. Claude - contexte modere (45%)

- Type : Claude
- Modele : Claude Opus 4
- Contexte : `UsedPercent = 45`
- But : session active avec historique et cout intermediaire

### 15. Claude - contexte sature (87%)

- Type : Claude
- Modele : Claude Sonnet 4.5
- Contexte : `UsedPercent = 87`
- But : simuler une longue session proche de saturation

---

## Ajouter de nouveaux scenarios

### Structure attendue

Chaque scenario du tableau `$scenarios` suit l'une de ces deux formes.

Scenario standard :

```powershell
@{
    Name   = "X. Description"
    Desc   = "Contexte realistic"
    Setup  = { }
    Params = @{ Code = 0; ExecTime = 250 }
}
```

Scenario Claude :

```powershell
@{
    Name   = "X. Claude - description"
    Desc   = "Contexte realistic"
    Setup  = $null
    Claude = @{
        ModelDisplay = 'Claude Sonnet 4.5'
        ModelId      = 'claude-sonnet-4-5-20250929'
        UsedPercent  = 22
        InputTokens  = 18432
        OutputTokens = 4123
        CostUSD      = 0.0824
        DurationMs   = 125000
        ApiDurationMs = 45000
        LinesAdded   = 312
        LinesRemoved = 87
    }
}
```

### Procedure

1. Ouvrir [preview-omp.ps1](d:/_perso/config/Tests/preview-omp.ps1).
2. Localiser le tableau `$scenarios` dans `Render-Scenarios`.
3. Inserer le nouveau scenario directement dans ce tableau.
4. Garder une numerotation sequentielle.
5. Si vous ajoutez un scenario standard, decaler ensuite les numeros des scenarios Claude si necessaire.
6. Mettre a jour ce guide si la couverture change.

Il n'existe plus de bloc `if ($isClaudeTheme)` dans le script. Toute instruction qui y fait reference est obsolete.

### Exemples de tests

Depuis le dossier [Tests](d:/_perso/config/Tests) :

```powershell
# Theme du dossier Tests
.\preview-omp.ps1 -Path .\tokyo.omp.json

# Theme situe au niveau parent
.\preview-omp.ps1 -Path ..\_ciaanh.omp.json

# Watch mode
.\preview-omp.ps1 -Path ..\_ciaanh.claude.omp.json -Watch

# Tous les themes du dossier courant
.\preview-omp.ps1 -All
```

### Points d'attention

- `Setup` s'execute dans un repertoire temporaire isole, pas dans le dossier `Tests`.
- Les variables d'environnement temporaires sont nettoyees en fin de scenario pour `VIRTUAL_ENV`, `PYTHONVERSION`, `SSH_CLIENT` et `SSH_CONNECTION`.
- Le chemin affiche par le theme standard correspond au repertoire temporaire du scenario, pas au dossier de lancement du script.
- Les scenarios Claude utilisent le sous-dossier `my-project` sous un repertoire temporaire pour simuler un projet reel.

---

## Meilleures pratiques

### A faire

1. Garder les scenarios hermetiques et reproductibles.
2. Utiliser uniquement des artefacts crees dans le repertoire temporaire.
3. Choisir des temps d'execution et etats Git plausibles.
4. Preferer `universal` pour la preview visuelle.
5. Verifier qu'un theme sans segment cible ignore proprement le scenario.
6. Mettre a jour la table de couverture apres ajout ou suppression d'un scenario.

### A eviter

1. Ajouter une logique conditionnelle basee sur la detection de segments du theme.
2. Faire des `Setup` dependants de l'etat du poste ou du repo courant.
3. Ecrire dans le dossier `Tests` ou ailleurs hors repertoire temporaire.
4. Reintroduire un scenario `root` sans mecanisme realiste pour le simuler.
5. Documenter des chemins de test qui ne correspondent pas au dossier depuis lequel le script est execute.

---

## Ressources

- [preview-omp.ps1](d:/_perso/config/Tests/preview-omp.ps1)
- [OH_MY_POSH_SEGMENTS_REFERENCE.md](d:/_perso/config/OH_MY_POSH_SEGMENTS_REFERENCE.md)
- [OH_MY_POSH_SCENARIOS.md](d:/_perso/config/OH_MY_POSH_SCENARIOS.md)
- Documentation Oh My Posh : https://ohmyposh.dev
- Schema JSON : https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json
