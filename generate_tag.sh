#!/bin/bash

# Script pour générer un tag avec le format LIV800V182X basé sur le projet et la version du fichier pom.xml

# Vérifier si le script est exécuté dans un dépôt Git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Erreur : Ce script doit être exécuté depuis un dépôt Git."
  exit 1
fi

# Définir le numéro de projet pour Cx_Customisation_Projects_custcare_cu
PROJECT_NUMBER="800"

# Chemin du fichier pom.xml
POM_FILE="TTCxNonKernel3Maven/pom.xml"

# Vérifier si le fichier pom.xml existe
if [[ ! -f $POM_FILE ]]; then
  echo "Erreur : Fichier pom.xml introuvable dans le répertoire actuel."
  exit 1
fi

# Lire la version depuis le fichier pom.xml
VERSION=$(grep -oPm1 "(?<=<version>)[^<]+" "$POM_FILE")
if [[ -z $VERSION ]]; then
  echo "Erreur : Impossible de lire la version depuis le fichier pom.xml."
  exit 1
fi

# Transformer la version pour le format attendu (ex: 18.2.1 -> 182)
VERSION_TAG=$(echo "$VERSION" | awk -F '.' '{printf "%s%s", $1, $2}')

# Récupérer les tags existants pour le projet actuel
EXISTING_TAGS=$(git tag | grep "LIV${PROJECT_NUMBER}V${VERSION_TAG}")

# Calculer le prochain numéro de séquence (X) pour le tag
if [[ -z $EXISTING_TAGS ]]; then
  NEXT_SEQUENCE=0
else
  LAST_TAG=$(echo "$EXISTING_TAGS" | sort | tail -n 1)
  LAST_SEQUENCE=$(echo "$LAST_TAG" | grep -oP "(?<=LIV${PROJECT_NUMBER}V${VERSION_TAG})\\d+")
  NEXT_SEQUENCE=$((LAST_SEQUENCE + 1))
fi

# Générer le nouveau tag
NEW_TAG="LIV${PROJECT_NUMBER}V${VERSION_TAG}${NEXT_SEQUENCE}"

# Créer le nouveau tag
echo "Création du tag : $NEW_TAG"
git tag "$NEW_TAG"

# Pousser le nouveau tag vers le dépôt distant
echo "Envoi du tag $NEW_TAG vers le dépôt distant..."
git push origin "$NEW_TAG"

echo "Tag $NEW_TAG créé et poussé avec succès."
