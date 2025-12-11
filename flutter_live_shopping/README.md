# Flutter Live Shopping

Application de démonstration d'une expérience de live shopping construite avec Flutter.

## Comment lancer l'application

1.  **Prérequis :** Assurez-vous d'avoir le [SDK Flutter](https://flutter.dev/docs/get-started/install) installé sur votre machine.
2.  **Cloner le dépôt :**
    ```sh
    git clone https://github.com/FulbertoDev/test-flutter.git
    cd flutter_live_shopping
    ```
3.  **Installer les dépendances :**
    ```sh
    flutter pub get
    ```
4.  **Lancer l'application :**
    ```sh
    flutter run
    ```
    L'application peut être lancée sur un émulateur, un appareil physique ou sur le web.

## Structure du projet

Le projet suit une architecture organisée pour séparer les responsabilités :

-   `lib/`: Contient tout le code source Dart.
    -   `main.dart`: Point d'entrée de l'application.
    -   `app.dart`: Widget racine de l'application, configuration du thème et du routeur.
    -   `config/`: Fichiers de configuration, comme la configuration du routeur.
    -   `models/`: Modèles de données (ex: `Product`, `LiveStream`).
    -   `providers/`: Fournisseurs d'état avec le package `Provider`.
    -   `screens/`: Widgets représentant les différents écrans de l'application.
    -   `services/`: Services pour la communication réseau (API), le stockage local, etc.
    -   `utils/`: Fonctions et classes utilitaires.
    -   `widgets/`: Widgets réutilisables partagés à travers l'application.
-   `assets/`: Fichiers statiques, comme les images ou les fichiers JSON de mock.
-   `test/`: Tests unitaires et tests de widgets.
-   `pubspec.yaml`: Fichier de configuration du projet, incluant les dépendances.

## Choix techniques

-   **State Management :** `provider` a été choisi pour sa simplicité et sa légèreté. Il permet une gestion réactive de l'état en séparant la logique métier de l'interface utilisateur.
-   **Navigation :** `go_router` est utilisé pour gérer la navigation et les URLs de manière déclarative, ce qui est particulièrement utile pour une application web et mobile.
-   **Réseau :** `dio` est utilisé pour effectuer les requêtes HTTP. C'est un client puissant qui supporte les intercepteurs, la gestion des erreurs et la configuration globale.
-   **Sérialisation JSON :** `json_serializable` et `json_annotation` sont utilisés pour générer automatiquement le code de conversion entre les objets Dart et le JSON.
-   **Mise en page responsive :** `responsive_builder` aide à créer des interfaces qui s'adaptent aux différentes tailles d'écran.
-   **Mise en cache d'images :** `cached_network_image` pour afficher et mettre en cache les images provenant du réseau.
-   **Polices de caractères :** `google_fonts` pour intégrer facilement des polices depuis Google Fonts.
-   **Vidéo :** `video_player` pour l'intégration et le contrôle des flux vidéo.

## Difficultés rencontrées


## Améliorations possibles