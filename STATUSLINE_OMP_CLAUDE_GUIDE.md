# Guide — Statusline Claude Code enrichie avec Oh My Posh

**Objectif** : reproduire (et dépasser) la richesse d'information de
[`statusline/statusline-command.sh`](statusline/statusline-command.sh) dans une
statusline **multi‑ligne dédiée à Claude Code**, construite avec le segment
`claude` d'Oh My Posh et basée sur l'esthétique de
[`Tests/hul10.omp.json`](Tests/hul10.omp.json).

Document compagnon de [OH_MY_POSH_SEGMENTS_REFERENCE.md](OH_MY_POSH_SEGMENTS_REFERENCE.md)
(segment *Claude Code* §10). **Tout a été vérifié sur Oh My Posh v29.10.**

---

## 1. Ce que fait déjà `statusline-command.sh`

Le script bash lit le JSON envoyé par Claude Code sur stdin et affiche, façon
Powerlevel10k :

| # | Information | Source JSON (bash) | Détail visuel |
|---|-------------|--------------------|---------------|
| 1 | Répertoire courant | `.workspace.current_dir` | `$HOME` → `~` |
| 2 | Branche Git + dirty | `git` CLI | icône branche + `*` si modifié |
| 3 | Modèle | `.model.display_name` | icône robot |
| 4 | **Contexte %** | `.context_window.used_percentage` | **jauge + couleur dynamique** (vert <50 %, jaune 50–79 %, rouge ≥80 %) |
| 5 | **Tokens cumulés** | `.context_window.total_input_tokens` / `total_output_tokens` | `12.3k↓ 4.5k↑`, format `k`/`M` |
| 6 | **Limites de débit** | `.rate_limits.five_hour` / `.seven_day` | `5h:42%` / `7d:18%`, **couleur dynamique** |

L'ancienne config Oh My Posh n'exposait que **2 sur 6** (modèle + jauge sans
couleur ni %). Ce guide documente la nouvelle config qui couvre #3→#6 **plus** le
coût, la durée et les lignes éditées.

---

## 2. Le segment `claude` expose bien plus que le JSON brut

Le binaire Oh My Posh parse lui‑même les données de session et expose des
propriétés *déjà calculées et formatées*. Pas besoin de `jq`/`awk`.

> ⚠️ **Vérifié sur Oh My Posh v29.10** (`oh-my-posh version`). La doc en ligne
> décrit une build plus récente : plusieurs propriétés qu'elle liste **n'existent
> pas encore** en v29.10 et font échouer le rendu (« unable to create text based
> on template »). Les tableaux ci‑dessous distinguent ce qui **fonctionne
> réellement** ici de ce qui est *online‑only*. Méthode de test : voir §8.

### 2.1 Options du segment

| Option | Type | Défaut | Rôle |
|--------|------|--------|------|
| `gauge_marked_char` | string | `▰` | cases pleines — **sans effet sur les méthodes `.X.GaugeUsed` en v29.10** |
| `gauge_unmarked_char` | string | `▱` | cases vides — idem (sans effet ici) |

> La jauge `█`/`░` 10 cases du bash n'est **pas** reproductible en v29.10 :
> `.TokenUsagePercent.GaugeUsed` rend toujours `▰▱` sur 5 cases. À accepter tel
> quel (ou attendre une build exposant `.TokenGauge` + options).

### 2.2 Propriétés utiles (mapping avec le bash) — **vérifiées v29.10**

| Besoin (cf. §1) | Propriété Oh My Posh | v29.10 | Note |
|-----------------|----------------------|--------|------|
| #3 Modèle | `.Model.DisplayName` | ✅ | + `.Model.ID` |
| #4 Jauge contexte | `.TokenUsagePercent.GaugeUsed` | ✅ | **méthode** (cases utilisées) |
| #4 Jauge restante | `.TokenUsagePercent.Gauge` | ✅ | méthode (capacité restante) |
| #4 % chiffré | `.TokenUsagePercent` | ✅ | s'imprime directement (`78`). ⚠️ **pas** `printf "%.0f"` |
| #4 Jauge racine | `.TokenGaugeUsed` / `.TokenGauge` | ❌ | *online‑only* — **échoue** |
| #5 Tokens entrée | `.ContextWindow.TotalInputTokens` | ✅ | brut |
| #5 Tokens sortie | `.ContextWindow.TotalOutputTokens` | ✅ | brut |
| #5 Taille fenêtre | `.ContextWindow.ContextWindowSize` | ✅ | ex. `200000` |
| #5 Tokens (formaté) | `.FormattedTokens` | ✅ | ex. `1.2K` (total prêt à l'emploi) |
| #6 Quota 5h | `.FiveHourUsage` | ✅ | s'imprime directement (`42`) |
| #6 Jauge 5h | `.FiveHourUsage.GaugeUsed` | ✅ | **méthode** |
| #6 Quota 7j | `.SevenDayUsage` / `.SevenDayUsage.GaugeUsed` | ✅ | idem |
| #6 Jauge racine | `.FiveHourGauge` / `.SevenDayGauge` | ❌ | *online‑only* — échoue |

### 2.3 Bonus absents du script bash

| Propriété | Type | v29.10 | Exemple / sens |
|-----------|------|--------|----------------|
| `.FormattedCost` | string | ✅ | `$0.42` — coût de la session |
| `.FormattedDuration` | string | ✅ | `2m 5s` — durée totale |
| `.FormattedAPIDuration` | string | ✅ | `0m 45s` — temps en appels API |
| `.Cost.TotalLinesAdded` / `.Cost.TotalLinesRemoved` | int | ✅ | lignes `+`/`−` |
| `.Cost.TotalCostUSD` | float64 | ✅ | coût brut (calculs/seuils) |
| `.FastMode` | bool | ❌ | *online‑only* — **échoue** |
| `.Effort.Level` | string | ❌ | *online‑only* — échoue |
| `.Thinking.Enabled` / `.OutputStyle.Name` | — | ❌ | *online‑only* |
| `.FiveHourResetsIn` / `.SevenDayResetsIn` | Duration | ❌ | *online‑only* — **échoue** |
| `.Version` / `.Agent.Name` / `.Worktree.*` | string | ❌ | *online‑only* |

> ❌ = listé dans la doc en ligne mais **absent ou cassé en v29.10**. Tester
> chaque propriété avant usage (§8). Liste complète : voir
> [OH_MY_POSH_SEGMENTS_REFERENCE.md](OH_MY_POSH_SEGMENTS_REFERENCE.md) §10 et
> <https://ohmyposh.dev/docs/segments/cli/claude>.

---

## 3. Les 3 techniques clés pour égaler le bash

### 3.1 Couleur dynamique selon un seuil (#4, #6)

> ⚠️ **Piège n°1 en v29.10** : `.TokenUsagePercent` / `.FiveHourUsage` sont du
> type `Percentage`. On **ne peut PAS** écrire `ge .TokenUsagePercent 80.0`
> (le rendu échoue), ni `printf "%.0f"` (rend `%!f(text.Percentage=78)`).
>
> ✅ La conversion qui marche : `(.TokenUsagePercent.String | float64)`.
> Le résultat est comparable avec `ge` / `lt`.

Deux approches, toutes deux utilisées dans la config :

**a) `foreground_templates`** — colore *tout* un segment (recommandé) :

```jsonc
"foreground": "p:green",
"foreground_templates": [
  "{{ if ge (.TokenUsagePercent.String | float64) 80.0 }}p:red{{ end }}",
  "{{ if ge (.TokenUsagePercent.String | float64) 50.0 }}p:yellow{{ end }}"
]
// foreground (vert) sert de défaut quand aucune règle ne s'applique
```

**b) balise couleur construite dans le `template`** — colore un *fragment* :

```go-template
<{{ if ge (.TokenUsagePercent.String | float64) 80.0 }}p:red{{ else if ge (.TokenUsagePercent.String | float64) 50.0 }}p:yellow{{ else }}p:green{{ end }}>{{ .TokenUsagePercent.GaugeUsed }} {{ .TokenUsagePercent }}%</>
```

- Seuils identiques au bash : `≥80` rouge, `≥50` jaune, sinon vert.
- `{{ .TokenUsagePercent }}` s'imprime directement (`78`) — pas de `printf`.
- `<p:red>` réfère la `palette` (ou `<#ff3030>`).

### 3.2 Formater les tokens en `k`/`M` (#5)

Le bash utilise `awk`. En template, on divise avec `divf` (Sprig, intégré) :

```go-template
{{ if ge .ContextWindow.TotalInputTokens 1000 }}{{ printf "%.1fk" (divf .ContextWindow.TotalInputTokens 1000.0) }}{{ else }}{{ .ContextWindow.TotalInputTokens }}{{ end }}↓
```

> Note : `ge`/`printf` fonctionnent ici car `TotalInputTokens` est un **int**
> classique (≠ type `Percentage`). Plus simple si le total suffit :
> `.FormattedTokens` donne déjà `1.2K`.

### 3.3 Style multi‑ligne (base hul10)

hul10 chaîne des blocs `prompt` avec `newline: true` et des connecteurs
`┌ ├ └` (segments `text`), en style `plain` sur fond transparent. On garde ce
squelette mais **chaque ligne devient une facette de la session Claude**.

---

## 4. La config finale — statusline multi‑ligne dédiée Claude Code

La nouvelle [`_ciaanh.claude.omp.json`](_ciaanh.claude.omp.json) :

```text
┌ 󰯉 Opus 4.8 · branche git ≡                    $0.42 · 2m 5s · +120 -8
├ ▰▰▰▱▱ 78% ctx · 12.3k↓ 4.5k↑ /200k
└ 5h ▰▰▱▱▱ 42% · 7d ▰▰▰▰▱ 88%
```

| Ligne | Contenu | Segments |
|-------|---------|----------|
| `┌` + bloc droit | modèle · branche git ⋯ coût · durée · lignes ± | `claude`, `git`, `claude` |
| `├` | jauge contexte + % (coloré par seuil) · tokens ↓/↑ / taille fenêtre | `claude` ×2 |
| `└` | quotas 5h & 7j (chacun coloré par seuil) | `claude` ×2 |

**Décisions de design imposées par la v29.10** (cf. §2, §3) :

- jauges via la **méthode** `.X.GaugeUsed` → rendu `▰▱` 5 cases, non configurable ;
- `%` via `{{ .TokenUsagePercent }}` directement (jamais `printf`) ;
- couleurs de seuil via `foreground_templates` + `(.X.String | float64)` ;
- propriétés `.FastMode`, `.Effort`, `.FiveHourResetsIn` **retirées** (cassées).

> 💡 **Icônes** : `󰯉` (robot), connecteurs `┌ ├ └`, et les glyphes Nerd Font de
> branche/crayon dans le segment `git`. Tout glyphe de
> [statusline-command.sh](statusline/statusline-command.sh) peut être collé tel
> quel dans un `template`. Pré‑requis : une **Nerd Font** dans le terminal.

---

## 5. Variante « tout sur une ligne » (rprompt compact)

Si 3 lignes est trop, condensez tout dans un seul bloc droit (couleurs de
fragment construites dans le template, cf. §3.1‑b) :

```jsonc
{
  "type": "claude",
  "style": "plain",
  "background": "transparent",
  "foreground": "p:mint",
  "template": " 󰯉 {{ .Model.DisplayName }} <p:white>·</> <{{ if ge (.TokenUsagePercent.String | float64) 80.0 }}p:red{{ else if ge (.TokenUsagePercent.String | float64) 50.0 }}p:yellow{{ else }}p:green{{ end }}>{{ .TokenUsagePercent.GaugeUsed }} {{ .TokenUsagePercent }}%</> <p:white>·</> <p:violet>{{ if ge .ContextWindow.TotalInputTokens 1000 }}{{ printf \"%.1fk\" (divf .ContextWindow.TotalInputTokens 1000.0) }}{{ else }}{{ .ContextWindow.TotalInputTokens }}{{ end }}↓ {{ if ge .ContextWindow.TotalOutputTokens 1000 }}{{ printf \"%.1fk\" (divf .ContextWindow.TotalOutputTokens 1000.0) }}{{ else }}{{ .ContextWindow.TotalOutputTokens }}{{ end }}↑</> <p:white>·</> <p:green>{{ .FormattedCost }}</> <p:white>·</> 5h:{{ .FiveHourUsage }}% 7d:{{ .SevenDayUsage }}% "
}
```

---

## 6. Options & extras

- **Lignes éditées dans la session** : `+{{ .Cost.TotalLinesAdded }} -{{ .Cost.TotalLinesRemoved }}`
- **Masquer un fragment quand vide/zéro** : entourer d'un `{{ if … }} … {{ end }}`
  (ex. coût seulement si `gt .Cost.TotalCostUSD 0.0`).
- **Performance** : le segment `claude` lit les données de session (pas d'appel
  réseau) → pas besoin de `cache`.

## 7. Pièges (tous vérifiés en v29.10)

1. **`Percentage` non comparable / non `printf`‑able** : toujours
   `(.X.String | float64)` pour comparer, et `{{ .X }}` pour afficher le nombre.
   `ge .TokenUsagePercent 80.0` et `printf "%.0f" .X` cassent le rendu.
2. **Jauges = méthodes** : `.TokenUsagePercent.GaugeUsed`, pas `.TokenGaugeUsed`
   (racine, *online‑only*). Les options `gauge_marked_char` n'ont **aucun effet**
   sur ces méthodes → jauge figée `▰▱` 5 cases.
3. **`used_percentage` entier obligatoire** : une valeur **fractionnaire**
   (`78.6`) fait **échouer tout le parsing** de la charge utile par
   `oh-my-posh claude` (rendu totalement vide). C'est Claude Code qui émet le
   JSON ; à connaître pour le diagnostic.
4. **Nerd Font obligatoire** pour tous les glyphes.
5. **`\"` à échapper** dans les `template` JSON (autour de `printf "%.1fk"`).
6. **Hors session Claude Code**, les propriétés `claude` sont vides → les lignes
   `├`/`└` apparaissent quasi vides (comportement normal).

---

## 8. Application & test

La statusline Claude Code utilise la sous‑commande **`oh-my-posh claude`** (lit le
JSON de session sur stdin), **pas** `print primary` :

```jsonc
// settings.json de Claude Code
"statusLine": {
  "type": "command",
  "command": "oh-my-posh claude --config D:/_perso/config/_ciaanh.claude.omp.json"
}
```

**Tester localement** (charge utile simulée) :

```powershell
$payload = @'
{
  "model": { "display_name": "Opus 4.8" },
  "cost": { "total_cost_usd": 0.42, "total_duration_ms": 125000, "total_lines_added": 120, "total_lines_removed": 8 },
  "context_window": { "used_percentage": 78, "total_input_tokens": 12300, "total_output_tokens": 4500, "context_window_size": 200000 },
  "rate_limits": { "five_hour": { "used_percentage": 42 }, "seven_day": { "used_percentage": 88 } }
}
'@
$payload | oh-my-posh claude --config _ciaanh.claude.omp.json          # rendu couleur
$payload | oh-my-posh claude --config _ciaanh.claude.omp.json --plain  # texte seul
```

> Faire varier `used_percentage` / `five_hour` / `seven_day` (`42`, `65`, `88`)
> pour observer les bascules vert → jaune → rouge. L'ancienne config est
> récupérable via git : `git checkout -- _ciaanh.claude.omp.json`.
