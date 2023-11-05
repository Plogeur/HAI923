# Tutorat HAI923 - Machine Learning 2

Ce github contient les notebooks pour le tutorat de HAI923 Machine Learning 2, qui explore les techniques avancées de deep learning pour la classification d'images. Nous verrons : le preprocessing, les réseaux de neurones convolutionnels (CNN), les réseaux génératifs adverses (GAN) et les autoencodeurs (AE). Nous reverrons également des aspects essentielle du machine learning comme la visualisation des données/résultats et l'optimization des hyperparamètres.

## À propos du tutorat

Le tutorat de HAI923 Machine Learning 2 est conçu afin de réaliser au mieux votre projet final et permet aux étudiants d'approfondir leur compréhension du deep learning et à acquérir des compétences avancées dans ce domaine. Il sera décomposer en plusieurs session de 3h, chacune d'elles aura une partie de *cours magistral* (d'environ 15 à 20 min) pour exposée les points théorique/rappel du cours et d'une partie de *travaux pratique* (de 30 min à 3h).
Vous trouverez les slides du tutorat sur google slide à cette adresse : https://docs.google.com/presentation/d/11ySc3aOzT5im5neBQmwZJ2Pl5dDy48ivxX6NhOwBCaA/edit?usp=sharing et les notebooks qui couvrent les différents sujets que nous aborderont pendant celui-ci :

- [Notebook_Preprocessing 1](https://github.com/Plogeur/HAI923/blob/main/Notebook_preprocessing_1.ipynb) : Visualisation des données (Répartition des images par classes, caractéristiques des images et clustering)
- [Notebook_Preprocessing_2](https://github.com/Plogeur/HAI923/blob/main/Notebook_preprocessing_2.ipynb) : Prétraitement des données avant l'entraînement des modèles, kfold et data augmentation.
- [Notebook_CNN](https://github.com/Plogeur/HAI923/blob/main/Notebook_CNN.ipynb) : Explorez l'utilisation des CNN pour la vision par ordinateur, la reconnaissance d'images et d'autres tâches liées à la vision. Création du baseline, transfer learning et fine tuning.
- [Notebook_GAN&AE](https://github.com/Plogeur/HAI923/blob/main/Notebook_GAN&AE.ipynb) : Applications des Generative Adversarial Networks (GAN), des Autoencoders (AE) et des variant autoencoders (VAE) pour la génération d'images.
- [Notebook_Optimization](https://github.com/Plogeur/HAI923/blob/main/Notebook_Optimisation&tensorboard.ipynb) : Optimisation des hyperparamètres des modèles et visualisation avec tensorboard.
- [Notebook_Interpretation](https://github.com/Plogeur/HAI923/blob/main/Notebook_Interpretation.ipynb) : Interprétation des résultats des modèles (matrice de confusion, roc curve, methode d'interprétation : feature map, SHAP, LIME et GRAD-CAM).
- [Notebook_vit](https://github.com/Plogeur/HAI923/blob/main/Notebook_vit.ipynb) : Utilisation de l'architecture Vision Transformer (ViT) pour des tâches de vision par ordinateur.
- [pipeline](https://github.com/Plogeur/HAI923/blob/main/pipeline.bash) : Redimensionne par detection d'object (yolov8x) l'animal ayant la plus grande résolution dans une image et augmente la résolution de l'image par upscaling (CNN/GAN).

## Instructions d'utilisation

1. Clonez ce projet sur votre machine locale : ``git clone https://github.com/Plogeur/HAI923.git``
2. Ajoutez les différents notebooks à votre Google Drive.
3. Lancez les notebooks via `Google Colab` (n'oubliez pas de passer en mode GPU !!!).
4. Enjoy it !
