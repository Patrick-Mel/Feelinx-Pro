# FEELINX — CHARTE GRAPHIQUE ET MANUEL DE MARQUE (2026)

> Document officiel d'identité visuelle de la marque **Feelinx** (« Des liens qui se ressentent »).
> Conçu pour garantir l'intégrité de la marque sur tous les points de contact : application mobile (iOS & Android), web, supports marketing et communication institutionnelle.

---

## 1. VISION & POSITIONNEMENT DE LA MARQUE

### 1.1 Le Nom : Feelinx
**Feelinx** (prononcé /fi-linksk/) est la fusion de deux concepts fondamentaux :
- **Feelings** (ressentis, émotions, authenticité des sentiments).
- **Links** (liens, connexions humaines, ponts sociaux).

Feelinx n'est pas simplement une application de rencontre : c'est la plateforme premium de mise en relation de la jeunesse urbaine et connectée d'Afrique et de sa diaspora (Douala, Yaoundé, Abidjan, Dakar, Lagos, Kinshasa, Paris, Bruxelles). Elle réinvente les codes du *social dating* en conciliant l'exigence d'un produit technologique mondial et la maîtrise des réalités socioculturelles africaines.

### 1.2 La Personnalité de Marque
1. **Chaleureuse & Électrisante** : Une marque axée sur l'énergie émotionnelle et le respect.
2. **Ultra-Moderne (2026)** : Un langage visuel contemporain, géométrique, vectoriel et lumineux avec glassmorphisme & micro-animations.
3. **Confiante & Sécurisante** : Une esthétique sobre et statutaire qui inspire une confiance absolue.
4. **Sensuelle avec Élégance** : La suggestion de l'attraction et du désir, avec un raffinement haut de gamme.
5. **Modernité Urbaine Africaine** : L'expression d'une jeunesse africaine créative, ambitieuse et connectée au monde.

---

## 2. EXPLORATION CRÉATIVE & SYMBOLE : « THE FEELINX INFINITY PULSE »

Le logo officiel de Feelinx est **« The Feelinx Infinity Pulse »** :
- **La boucle d'infini ($\infty$)** : Symbolise les possibilités infinies de connexions et la durabilité des liens.
- **Le cœur fusionné** : Formé au centre de la boucle, suggérant l'amour, l'attraction et le sentiment authentique.
- **L'onde cardiaque / signal (Pulse)** : Intégrée en négatif/positif dans l'axe médian, symbolisant le pouls accéléré lors d'un match ou d'un coup de foudre.
- **La perle dorée d'étincelle (Spark)** : Positionnée au centre géométrique, symbolisant la magie de la rencontre.

---

## 3. PALETTE DE COULEURS OFFICIELLE

| Nom de la Couleur | Rôle dans l'Identité | Code HEX | Code RGB | Code CMJN | Code HSL |
|---|---|---|---|---|---|
| **Coral Pink** | Couleur Primaire | `#FF3366` | `rgb(255, 51, 102)` | `C:0 M:80 J:60 K:0` | `345°, 100%, 60%` |
| **Amethyst Violet** | Couleur Secondaire | `#9D4EDD` | `rgb(157, 78, 221)` | `C:29 M:65 J:0 K:13` | `273°, 68%, 59%` |
| **Warm Gold Spark** | Couleur d'Accent & Premium | `#FFB703` | `rgb(255, 183, 3)` | `C:0 M:28 J:99 K:0` | `43°, 100%, 51%` |
| **Dark Obsidian Surface** | Fond Sombre App | `#0A0915` | `rgb(10, 9, 21)` | `C:52 M:57 J:0 K:92` | `245°, 40%, 6%` |
| **Pure White** | Réserve / Texte | `#FFFFFF` | `rgb(255, 255, 255)` | `C:0 M:0 J:0 K:0` | `0°, 0%, 100%` |

### Dégradé Signature Feelinx (Tri-Color Glow)
- **Composition** : `#FF3366` (Coral Pink) $\rightarrow$ `#9D4EDD` (Amethyst Violet) $\rightarrow$ `#FFB703` (Gold).
- **Orientation** : 135° (diagonale haut-gauche vers bas-droite).

---

## 4. LIVRABLES D'ACTIFS D'IDENTITÉ (ASSETS)

Tous les actifs vectoriels (SVG) et matriciels (PNG) sont générés et disponibles dans les répertoires :
- `docs/assets/branding/`
- `mobile/assets/branding/`

1. `logo-primary.svg` : Logo principal avec symbole "Infinity Pulse", typographie et dégradé complet sur fond sombre.
2. `logo-symbol.svg` : Symbole seul (icône d'application).
3. `logo-vertical.svg` : Standard vertical pour affichage mobile & splash screens.
4. `logo-wordmark.svg` : Typographie "Feelinx." isolée.
5. `logo-white.svg` : Monochrome blanc sur fond sombre.
6. `logo-black.svg` : Monochrome sombre sur fond clair.
7. `logo-premium.svg` : Symbole pour fonctionnalités VIP & Gold.
8. `app-icon.png` : Icône native HD pour Android et iOS (1024x1024).
9. `app-icon-adaptive-foreground.png` : Foreground vectoriel pour Android Adaptive Icons.

---

## 5. RECOMMANDATIONS RENDERER & LOGO DART (FLUTTER)

Dans l'application Flutter (`mobile/lib/core/theme/feelinx_logo.dart`), le composant `FeelinxLogo` s'appuie sur un `CustomPainter` natif vectoriel avec dégradé HSL dynamique (`#FF3366` vers `#9D4EDD` et `#FFB703`), garantissant un rendu à 60/120 images par seconde sans aucune déperdition de qualité ni dépendance SVG lourde lors des animations.
