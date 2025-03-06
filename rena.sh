#!/bin/bash

# Fonction pour afficher le manuel d'aide
function afficher_aide {
  echo "Usage: $0 -e <extension> -p <préfixe> [-s <suffixe>] [-i]"
  exit 0
}

# Définition de la fonction
# verifier_nombre_dans_nom_fichier() {
#     # Utilise la commande "basename" pour extraire le nom de fichier sans extension
#     nom_fichier=$(basename "$1" | sed 's/\.[^.]*$//')
    
#     # Vérifie s'il y a un nombre dans le nom du fichier
#     if [[ $nom_fichier =~ [0-9]+ ]]; then
#         return 0  # Retourne 0 pour vrai (true)
#         # echo "yes"
#     else
#         return 1  # Retourne 1 pour faux (false)
#         # echo "no"
#     fi
# }

# Définition de la fonction
extraire_nombre() {
    # Vérifie s'il y a un nombre dans l'argument
    if [[ $1 =~ [0-9]+ ]]; then
        # Utilise une expression régulière pour extraire le nombre
        nombre="${BASH_REMATCH[0]}"
        echo "$nombre"
    fi
}

# Fonction pour extraire la première séquence continue de chiffres du nom de fichier
# function extraire_chiffres {
#   local file_name="$1"
#   local chiffres=$(echo "$file_name" | sed -n 's/.*\([0-9]\+\).*/\1/p')
#   echo "$chiffres"
# }

while getopts "e:p:s:ih" opt; do
  case $opt in
    e)
      extension="$OPTARG"
      ;;
    p)
      prefix="$OPTARG"
      ;;
    s)
      suffix="$OPTARG"
      ;;
    i)
      utiliser_premier_chiffre=true
      ;;
    h)
      afficher_aide
      ;;
    \?)
      echo "Usage: $0 -e <extension> -p <préfixe> [-s <suffixe>] [-i]"
      exit 1
      ;;
  esac
done

if [ -z "$extension" ] || [ -z "$prefix" ]; then
  echo "Usage: $0 -e <extension> -p <préfixe> [-s <suffixe>] [-i]"
  exit 1
fi

count=1

for file in *."$extension"; do
  if [ -f "$file" ]; then
    if [ "$utiliser_premier_chiffre" == true ]; then
      # Utilise la fonction pour extraire la première séquence continue de chiffres du nom de fichier
      chiffres=$(extraire_nombre "$file")
      
      if [ -n "$chiffres" ]; then
        new_count="$chiffres"
      else
        continue # Ignore les fichiers sans chiffre dans le nom
      fi
    else
      # Utilise printf pour formater le numéro avec des zéros de remplissage
      new_count=$(printf '%02d' $count)
    fi

    if [ -n "$suffix" ]; then
      new_name="$prefix $new_count $suffix.$extension"
    else
      new_name="$prefix $new_count.$extension"
    fi

    mv "$file" "$new_name"
    echo "Renommé $file en $new_name"
    ((count++))
  fi
done

echo "Renommage terminé."
