#!/bin/bash

# Script pour g�n�rer un tag avec le format LIV800V182X bas� sur le projet et la version du fichier pom.xml

# V�rifier si le script est ex�cut� dans un d�p�t Git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Erreur : Ce script doit �tre ex�cut� depuis un d�p�t Git."
  exit 1
fi

# D�finir le num�ro de projet pour Cx_Customisation_Projects_custcare_cu
PROJECT_NUMBER="800"

# Chemin du fichier pom.xml
POM_FILE="TTCxNonKernel3Maven/pom.xml"

# V�rifier si le fichier pom.xml existe
if [[ ! -f $POM_FILE ]]; then
  echo "Erreur : Fichier pom.xml introuvable dans le r�pertoire actuel."
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

# R�cup�rer les tags existants pour le projet actuel
EXISTING_TAGS=$(git tag | grep "LIV${PROJECT_NUMBER}V${VERSION_TAG}")

# Calculer le prochain num�ro de s�quence (X) pour le tag
if [[ -z $EXISTING_TAGS ]]; then
  NEXT_SEQUENCE=0
else
  LAST_TAG=$(echo "$EXISTING_TAGS" | sort | tail -n 1)
  LAST_SEQUENCE=$(echo "$LAST_TAG" | grep -oP "(?<=LIV${PROJECT_NUMBER}V${VERSION_TAG})\\d+")
  NEXT_SEQUENCE=$((LAST_SEQUENCE + 1))
fi

# G�n�rer le nouveau tag
NEW_TAG="LIV${PROJECT_NUMBER}V${VERSION_TAG}${NEXT_SEQUENCE}"

# Cr�er le nouveau tag
echo "Cr�ation du tag : $NEW_TAG"
git tag "$NEW_TAG"

# Pousser le nouveau tag vers le d�p�t distant
echo "Envoi du tag $NEW_TAG vers le d�p�t distant..."
git push origin "$NEW_TAG"

echo "Tag $NEW_TAG cr�� et pouss� avec succ�s."
