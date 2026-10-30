# ECG-IA : une application d'interprétation des ECG dans les régions éloignées de la RK

> Traduction française du document original en russe (`docs/spec/original/`). Contenu inchangé ; voir `docs/spec/TRANSLATION_NOTES.md`.

## Pertinence du problème

Les maladies cardiovasculaires (MCV) sont la première cause de décès au Kirghizistan : elles représentent de façon constante **50–52 % de tous les décès**, soit **17–20 mille personnes chaque année** (~50 décès par jour). Pour la mortalité due à la cardiopathie ischémique, la République kirghize (RK) se classe **3e chez les femmes** et **5e chez les hommes** sur les 51 pays de la Région européenne de l'OMS. Plus de **65 % de la population** vit en milieu rural, où le déficit de personnel et de technologie se fait le plus durement sentir.

### Données clés

| Indicateur | Valeur | Source |
|---|---|---|
| Part des MCV dans la structure de la mortalité | 50–52 % | MSS RK, 2022–2026 |
| Décès par MCV par an | ~19 000 | IJMEDRI, 2024 |
| Mortalité pour 100 000 habitants | 234,5 | European Heart Journal, 2024 |
| Part de la population atteinte d'hypertension artérielle | 34–37 % | CNCMI (Centre national de cardiologie et de médecine interne) |
| Part de la population rurale | 65,1 % | CNS (Comité national de statistique), 2023 |
| Adultes de 40–64 ans avec un risque de MCV >30 % à 10 ans | 1 sur 5 | World Bank PHC Report |

### Le problème : pénurie de personnel et absence d'expertise ECG au niveau des soins primaires

- **Pénurie de cardiologues.** Les feldshers et les médecins généralistes (MG) enregistrent des ECG, mais n'ont pas la formation suffisante pour reconnaître les arythmies potentiellement mortelles et les syndromes coronariens aigus (SCA). Les régions montagneuses (Naryn, Talas, Batken, Alaï) sont gravement sous-dotées en spécialistes.
- **Retard de diagnostic = décès.** Dans l'infarctus aigu du myocarde, chaque tranche de 30 minutes de retard augmente la létalité de 7–8 %. La transmission des ECG par télémédecine est pratiquement inaccessible dans la plupart des FAP (postes de feldsher-sage-femme).
- **L'équipement existe, l'interprétation non.** Dans le cadre des réformes des soins de santé primaires (SSP), des appareils ECG ont été achetés pour les établissements ruraux sans système d'aide à la décision.
- **La médecine numérique est sous-utilisée.** L'OMS et la Banque mondiale l'indiquent explicitement : la télémédecine reste un « levier inexploité » dans les communautés éloignées de la RK.

### L'opportunité technologique existe déjà

Les modèles d'apprentissage profond fondés sur la MIT-BIH Arrhythmia Database atteignent une **précision de 98–99,4 %** dans la classification des arythmies. Les algorithmes de numérisation des ECG papier à partir d'une photo de smartphone traitent une image en **moins de 7 secondes**, tout en étant robustes aux défauts d'image (plis, taches, distorsion de perspective). Cela rend la tâche techniquement réalisable dans le cadre d'un projet de recherche.

European Heart Journal, 2024 · IJMEDRI, 2024 · Nature — ECG digitization, 2025 · Nature — Deep learning ECG, 2024

## Concept du projet

**ECG-AI KG** est une application mobile dotée d'un backend d'IA pour l'interprétation automatique des tracés ECG papier à partir d'une photo prise avec un téléphone. Utilisateurs cibles : feldshers, infirmières et MG des FAP/CMF (centres de médecine familiale) des districts éloignés de la RK.

### Objectif du projet

Réduire le délai entre l'enregistrement de l'ECG et la décision clinique sur la prise en charge du patient **de plusieurs heures à 1–2 minutes** dans les établissements sans cardiologue, et ainsi améliorer la survie en cas de SCA, d'arythmies potentiellement mortelles et d'autres affections aiguës.

### Scénario utilisateur

1. Le feldsher enregistre l'ECG sur l'appareil et prend une photo du tracé avec un smartphone.
2. Il téléverse la photo dans l'application ECG-AI KG.
3. Le modèle d'IA numérise le signal et classifie la pathologie.
4. À l'écran : l'interprétation — normal / suspicion de pathologie + type + degré d'urgence.
5. L'application fournit un bref algorithme des actions à suivre (évacuation d'urgence / surveillance / consultation).

### Principes clés

- **Mode hors ligne** — fonctionne sans Internet (essentiel pour les FAP de montagne).
- **Soutien, pas remplacement** — le résultat est présenté comme une « aide à l'interprétation » et non comme un diagnostic ; la décision finale revient au médecin.
- **Interface simple** — conçue pour un utilisateur ayant un niveau moyen de littératie numérique.
- **Bilinguisme** — interface en kirghiz et en russe.
- **Journalisation** — tous les cas sont conservés pour un audit ultérieur et le réentraînement du modèle.

## CdC (cahier des charges) : description du système

Le système se compose de trois éléments : une application mobile (client), un serveur de traitement par IA et un panneau d'administration.

### Composants du système

| Composant | Description |
|---|---|
| Application mobile | Android/iOS, mode hors ligne (modèle allégé), téléversement de la photo de l'ECG, affichage du résultat |
| Backend d'IA (cloud) | Serveur de traitement d'images : numérisation → classification → rédaction du compte rendu |
| Panneau d'administration | Suivi des cas, gestion des utilisateurs, export des données pour le MS RK (ministère de la Santé de la RK) |

### Données d'entrée

- Photo d'un tracé ECG papier (12 dérivations ou format abrégé) prise avec l'appareil photo standard d'un smartphone.
- Métadonnées : âge et sexe du patient, établissement, date/heure.

### Données de sortie

- **Interprétation** : normal / suspicion de pathologie (avec indication du type).
- **Catégorie d'urgence** : 🔴 urgence / 🟡 surveillance / 🟢 consultation programmée.
- **Liste des patterns détectés** : par exemple « Tachycardie sinusale », « Signes de SCA avec sus-décalage du segment ST », « Fibrillation auriculaire ».
- **Bref algorithme d'action** : 3–5 étapes pour le personnel médical.
- **Visualisation** : mise en évidence des segments anormaux sur l'ECG numérisé.

### Pathologies ciblées (MVP)

Dans un premier temps, le système reconnaît les affections prioritaires potentiellement mortelles :

1. Syndrome coronarien aigu (sus-décalage ST / sous-décalage ST)
2. Fibrillation et flutter auriculaires
3. Tachycardies ventriculaires / fibrillation ventriculaire
4. Bloc auriculo-ventriculaire complet (3e degré)
5. Tachy- et bradyarythmies sinusales
6. Blocs de branche (BBG / BBD)

## CdC : architecture et pile technologique

### Pile technologique

| Couche | Technologie | Justification |
|---|---|---|
| Application mobile | Flutter (Android + iOS) | Base de code unique, prise en charge du mode hors ligne |
| Numérisation de l'image ECG | YOLOv11 (segmentation) + OpenCV | État de l'art (SOTA) pour la numérisation des ECG papier, open source |
| Classification des arythmies | CNN + BiLSTM (signal 1D) | Précision de 98–99,4 % sur MIT-BIH ; combine patterns spatiaux et temporels |
| Jeu de données d'entraînement | MIT-BIH Arrhythmia Database (PhysioNet) | Référence absolue, 48 enregistrements, annotés par deux cardiologues |
| Jeu de données complémentaire | PTB-XL (21 837 ECG) | Extension aux 12 dérivations et au SCA |
| API backend | Python (FastAPI) | Développement rapide, pile d'apprentissage profond native |
| Cloud | Google Cloud / serveur local du MS | Flexibilité ; option de déploiement sur site pour la souveraineté des données |
| Modèle allégé hors ligne | TensorFlow Lite | Classification de base sans Internet |
| Panneau d'administration | React + PostgreSQL | Pile web standard |

### Pipeline de traitement de l'image ECG

1. **Prétraitement de l'image** — correction de la perspective, suppression des ombres, alignement sur la grille du papier (OpenCV).
2. **Segmentation des courbes** — extraction du signal ECG de l'arrière-plan (segmentation d'instances YOLOv11).
3. **Numérisation** — conversion des pixels en série temporelle numérique, calibrée sur la grille standard (25 mm/s, 10 mm/mV).
4. **Classification** — CNN + BiLSTM sur le signal 1D, entraîné sur MIT-BIH + PTB-XL.
5. **Génération du compte rendu** — moteur de gabarits avec logique clinique + enrichissement du texte par LLM (facultatif).
6. **Journalisation** — enregistrement du cas dans une base de données sécurisée pour l'audit et le réentraînement.

### Modèle de données (simplifié)

| Entité | Champs clés |
|---|---|
| Patient | ID, âge, sexe |
| Enregistrement ECG | ID, photo (hachage), établissement, date |
| Résultat | ID de l'enregistrement, patterns[], urgence, texte du compte rendu |
| Utilisateur | ID, rôle (feldsher/médecin/admin), établissement |

## CdC : exigences fonctionnelles

### FR-1 : téléversement et prétraitement de l'image

- L'utilisateur téléverse une photo du tracé ECG via l'appareil photo ou la galerie.
- L'application détecte automatiquement les bords du tracé et corrige la distorsion de perspective.
- En cas de mauvaise qualité d'image : notification avec instructions pour reprendre la photo.
- Formats pris en charge : JPG, PNG, HEIC.

### FR-2 : numérisation et analyse de l'ECG

- Extraction du signal des 12 dérivations (ou des dérivations disponibles si l'image est partielle).
- Détermination automatique de la fréquence cardiaque, des intervalles P-Q-R-S-T, de la durée du QRS, du QTc.
- Classification des patterns avec indication du niveau de confiance du modèle (confidence score).

### FR-3 : affichage des résultats

- Écran de résultat : catégorie d'urgence (code couleur), liste des patterns, compte rendu textuel.
- Visualisation : signal numérisé avec mise en évidence des segments anormaux.
- Algorithme d'action : 3–5 étapes concrètes (en kirghiz et en russe).
- Avertissement : « Le résultat est un outil d'aide. La décision finale revient au médecin. »

### FR-4 : historique et journalisation

- Stockage local des 50 derniers cas sur l'appareil.
- Synchronisation avec le serveur lorsqu'une connexion Internet est disponible.
- Export de l'enregistrement en PDF pour transmission en vue d'une consultation.

### FR-5 : gestion des utilisateurs

- Inscription de l'utilisateur rattachée à un établissement (FAP/CMF).
- Rôles : feldsher, MG, administrateur du MS.
- Authentification à deux facteurs pour les administrateurs.

### FR-6 : panneau d'administration (pour le MS RK)

- Tableau de bord : nombre de demandes par région, types de pathologies, évolution mensuelle.
- Gestion des établissements et des utilisateurs.
- Export de données anonymisées pour l'analyse épidémiologique.
- Signalements pour vérification manuelle par un cardiologue (réentraînement du modèle).

## CdC : exigences non fonctionnelles, sécurité et réglementation

### Performance

- Temps de traitement de l'image sur le serveur : **< 10 secondes** (avec une connexion Internet 3G standard).
- Temps d'exécution du modèle allégé hors ligne : **< 20 secondes** sur un appareil Android moyen.
- Disponibilité du serveur : **99,5 %** (uptime).

### Sécurité et confidentialité

- Toutes les données des patients sont transmises via **TLS 1.3**.
- Les données médicales sont stockées sous forme anonymisée (pseudonymisation conformément aux principes du RGPD et à la législation de la RK).
- Les photos d'ECG ne sont pas conservées sur le serveur plus de 30 jours sans le consentement explicite de l'établissement.
- Contrôle d'accès basé sur les rôles (RBAC).

### Exigences réglementaires pour le déploiement par l'intermédiaire du MS RK

| Exigence | Action |
|---|---|
| Logiciel médical | Enregistrement en tant que dispositif médical auprès du MS RK |
| Validation clinique | Pilote au CNCMI : comparaison des interprétations de l'IA avec celles des experts — ≥100 cas |
| Consentement éclairé | Protocole de consentement du patient lors de la conservation des données |
| Audit de l'algorithme | Rapport trimestriel sur la précision du modèle pour le MS |
| Langues de l'interface | Kirghiz + russe (obligatoire) |

### Limites du modèle (à indiquer obligatoirement dans l'interface)

- Le modèle est entraîné sur MIT-BIH + PTB-XL : des données issues principalement de populations occidentales. Un réentraînement sur des données kirghizes est nécessaire lors de la phase pilote.
- La qualité du résultat dépend de la qualité de la photo : éclairage, angle de prise de vue, résolution ≥ 5 Mpx.
- Le système ne remplace pas le médecin : c'est un outil d'**aide à la décision clinique (CDSS)**.

## Feuille de route de mise en œuvre

### Étape 1 — Recherche et prototype (mois 1–3)

- [ ] Étudier la MIT-BIH Arrhythmia Database (PhysioNet) : structure des données, annotations.
- [ ] Mettre en œuvre un pipeline de base : chargement de l'enregistrement → prétraitement → classification (CNN / BiLSTM).
- [ ] Mettre en œuvre un module de numérisation des ECG papier à partir d'une photo (sur la base de l'outil open source ECGtizer ou d'un équivalent).
- [ ] Atteindre une précision ≥ 95 % sur le jeu de test MIT-BIH pour les 5 classes principales.
- [ ] Documenter la méthodologie pour l'intégrer dans un research paper scolaire.

### Étape 2 — MVP de l'application (mois 4–6)

- [ ] Développer l'interface mobile (Flutter) : téléversement de photo, écran de résultat, historique.
- [ ] Déployer l'API backend (FastAPI) sur un serveur cloud.
- [ ] Intégrer TensorFlow Lite pour le mode hors ligne.
- [ ] Traduire l'interface en kirghiz et en russe.
- [ ] Effectuer des tests internes sur 20–30 tracés ECG (recueillis auprès de connaissances du milieu médical).

### Étape 3 — Pilote et validation (mois 7–9)

- [ ] Contacter le CNCMI ou l'AMEK (Académie médicale d'État kirghize) avec une proposition de collaboration.
- [ ] Mener des tests pilotes : 100+ cas, comparaison avec l'interprétation experte d'un cardiologue.
- [ ] Recueillir les retours des feldshers de 2–3 FAP (ergonomie).
- [ ] Publier les résultats de la recherche (conférence scolaire / revue).

### Étape 4 — Présentation au MS RK et passage à l'échelle (mois 10–12)

- [ ] Préparer un dossier pour le MS : CdC, résultats du pilote, plan de déploiement.
- [ ] Présenter le projet lors d'une réunion du groupe de travail sur la santé numérique du MS RK.
- [ ] Transmettre le code source et la documentation au partenaire gouvernemental.
- [ ] Déposer une demande de subvention (PNUD, OMS RK, AKF Health Program).

## Résultats attendus et KPI

### KPI techniques

| Métrique | Valeur cible |
|---|---|
| Précision de la classification (accuracy) | ≥ 97 % sur le jeu de test MIT-BIH |
| Sensibilité (recall) pour le SCA | ≥ 95 % (essentiel : les faux négatifs sont inacceptables) |
| Spécificité | ≥ 93 % |
| Temps de traitement de la photo (serveur) | < 10 s |
| Temps d'exécution du modèle hors ligne | < 20 s |

### KPI cliniques et sociaux (pilote)

| Métrique | Valeur cible |
|---|---|
| Concordance avec un cardiologue expert | ≥ 90 % pour la catégorie d'urgence |
| Satisfaction des feldshers (enquête) | ≥ 4/5 points |
| Nombre d'établissements dans le pilote | ≥ 3 FAP/CMF |
| Nombre d'ECG traités pendant le pilote | ≥ 100 cas |

### Résultats pour le portfolio (pour l'admission)

- Un prototype fonctionnel de l'application ECG-AI KG, au code source ouvert sur GitHub.
- Une publication scientifique ou une présentation lors d'une conférence (niveau scolaire / régional).
- Une lettre officielle / un protocole d'accord (MoU) du CNCMI ou du MS RK concernant la collaboration.
- Données du pilote : matrice de confusion, courbe ROC, retours du personnel médical.
- Une présentation du projet pour le MS RK (ce document en constitue la base).

### Valeur pour le MS RK

Le projet répond à un problème que le MS RK reconnaît officiellement comme prioritaire : améliorer la qualité du diagnostic des MCV au niveau des soins primaires dans les districts éloignés. Il ne nécessite pas l'achat de nouvel équipement : il utilise les appareils ECG et les smartphones du personnel médical déjà disponibles. Le coût de déploiement de la première étape est minime (serveur cloud + maintenance), tout en pouvant potentiellement couvrir l'ensemble des 980+ FAP du pays.
