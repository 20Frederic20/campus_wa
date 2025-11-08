import random
import string


def generer_mot_de_passe(longueur=12):
    """
    Génère un mot de passe solide de la longueur spécifiée.

    Args:
        longueur (int): Longueur du mot de passe (défaut: 12).

    Returns:
        str: Le mot de passe généré.
    """
    # Ensembles de caractères
    minuscules = string.ascii_lowercase
    majuscules = string.ascii_uppercase
    chiffres = string.digits
    symboles = string.punctuation

    # Tous les caractères possibles
    caracteres = minuscules + majuscules + chiffres + symboles

    # Générer un mot de passe avec au moins un de chaque type
    mot_de_passe = [
        random.choice(minuscules),
        random.choice(majuscules),
        random.choice(chiffres),
        random.choice(symboles)
    ]

    # Compléter avec des caractères aléatoires
    mot_de_passe += [random.choice(caracteres) for _ in range(longueur - 4)]

    # Mélanger le tout
    random.shuffle(mot_de_passe)

    return ''.join(mot_de_passe)


# Exemple d'utilisation
if __name__ == "__main__":
    longueur = int(
        input("Entrez la longueur du mot de passe (défaut: 12) : ") or 12
    )
    password = generer_mot_de_passe(longueur)
    print(f"Votre mot de passe solide : {password}")
    print(
        "Conseil : Ne le partagez avec personne et changez-le régulièrement !"
    )
